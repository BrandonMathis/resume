#!/usr/bin/env ruby
require 'minitest/autorun'
require 'tmpdir'
require 'digest'
require_relative 'resume_variant'

class ResumeVariantTest < Minitest::Test
  def with_project
    Dir.mktmpdir('resume-variants-') do |root|
      FileUtils.cp(File.join(ResumeVariant::ROOT, 'resume.yaml'), root)
      %w[classic variants].each { |directory| FileUtils.cp_r(File.join(ResumeVariant::ROOT, directory), root) }
      yield root
    end
  end

  def load_yaml(path)
    YAML.safe_load_file(path)
  end

  def write_overlay(root, data)
    File.write(File.join(root, 'variants/full-stack.yaml'), YAML.dump(data))
  end

  def test_both_initial_variants_preserve_all_copy_and_shared_configuration
    with_project do |root|
      base_path = File.join(root, 'resume.yaml')
      before = Digest::SHA256.file(base_path).hexdigest
      base = load_yaml(base_path)
      assert_equal %w[full-stack react-native], ResumeVariant.names(root)
      ResumeVariant.names(root).each do |name|
        source = ResumeVariant.compose(name, root: root)
        result = load_yaml(source)
        assert_equal base['cv'], result['cv']
        assert_equal base['design'], result['design']
        assert_equal base['locale'], result['locale']
        expected = Marshal.load(Marshal.dump(base))
        { 'pdf' => 'pdf', 'typst' => 'typ', 'markdown' => 'md', 'html' => 'html' }.each do |kind, extension|
          expected['settings']['render_command']["#{kind}_path"] = "#{name}.#{extension}"
        end
        assert_equal expected, result
        assert_equal File.join(root, 'build', 'variants', name, "#{name}.yaml"), source
        Dir.glob(File.join(root, 'classic', '*')).each do |template|
          assert_equal File.read(template), File.read(File.join(File.dirname(source), 'classic', File.basename(template)))
        end
      end
      assert_equal before, Digest::SHA256.file(base_path).hexdigest
    end
  end

  def test_section_replacement_preserves_order_and_inherits_other_sections
    with_project do |root|
      base = load_yaml(File.join(root, 'resume.yaml'))
      # This text is confined to temporary test fixtures, never real resume copy.
      write_overlay(root, { 'sections' => { 'Summary' => ['Synthetic test summary'] } })
      result = load_yaml(ResumeVariant.compose('full-stack', root: root))
      expected = Marshal.load(Marshal.dump(base['cv']))
      expected['sections']['Summary'] = ['Synthetic test summary']
      assert_equal expected, result['cv']
      assert_equal base['cv']['sections'].keys, result['cv']['sections'].keys
      other = load_yaml(ResumeVariant.compose('react-native', root: root))
      assert_equal base['cv'], other['cv']
    end
  end

  def test_shared_changes_and_template_updates_propagate_on_recompose
    with_project do |root|
      source = ResumeVariant.compose('full-stack', root: root)
      base_path = File.join(root, 'resume.yaml')
      base = load_yaml(base_path)
      base['cv']['sections']['Summary'] = ['Synthetic shared update']
      File.write(base_path, YAML.dump(base))
      template = File.join(root, 'classic/Header.j2.typ')
      File.write(template, File.read(template) + "\n// Synthetic template update\n")
      File.write(File.join(File.dirname(source), 'classic/stale.typ'), 'stale')
      ResumeVariant.compose('full-stack', root: root)
      assert_equal base['cv'], load_yaml(source)['cv']
      assert_equal File.read(template), File.read(File.join(File.dirname(source), 'classic/Header.j2.typ'))
      refute File.exist?(File.join(File.dirname(source), 'classic/stale.typ'))
    end
  end

  def test_rejects_configuration_overrides_unknown_sections_and_invalid_lists
    with_project do |root|
      invalid = [nil, [], {}, { 'cv' => {} }, { 'sections' => nil },
                 { 'sections' => {}, 'design' => {} }, { 'sections' => {}, 'settings' => {} },
                 { 'sections' => { 'Renamed Education' => ['Test'] } },
                 { 'sections' => { 'Summary' => [] } }, { 'sections' => { 'Summary' => 'Test' } }]
      invalid.each do |overlay|
        write_overlay(root, overlay)
        assert_raises(ArgumentError) { ResumeVariant.compose('full-stack', root: root) }
      end
    end
  end

  def test_rejects_missing_variants_and_path_traversal
    with_project do |root|
      ['missing', '../resume', '../../resume', '/tmp/resume', ''].each do |name|
        assert_raises(ArgumentError) { ResumeVariant.compose(name, root: root) }
      end
    end
  end
end
