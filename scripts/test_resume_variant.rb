#!/usr/bin/env ruby
require 'minitest/autorun'
require 'tmpdir'
require 'digest'
require 'open3'
require_relative 'resume_variant'

class ResumeVariantTest < Minitest::Test
  def with_project
    Dir.mktmpdir('resume-variants-') do |root|
      FileUtils.cp(File.join(ResumeVariant::ROOT, 'resume.yaml'), root)
      %w[classic variants].each { |directory| FileUtils.cp_r(File.join(ResumeVariant::ROOT, directory), root) }
      # Test composition mechanics against empty overlays, independent of live tailored copy.
      Dir.glob(File.join(root, 'variants', '*.yaml')).each { |path| File.write(path, "sections: {}\n") }
      yield root
    end
  end

  def load_yaml(path)
    YAML.safe_load_file(path)
  end

  def write_overlay(root, data)
    File.write(File.join(root, 'variants/full-stack.yaml'), YAML.dump(data))
  end

  def test_empty_overlays_preserve_all_copy_and_shared_configuration
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
        { 'pdf' => 'pdf', 'typst' => 'typ' }.each do |kind, extension|
          expected['settings']['render_command']["#{kind}_path"] = "#{name}.#{extension}"
        end
        %w[markdown html png].each do |kind|
          refute result['settings']['render_command'].key?("#{kind}_path")
          assert_equal true, result['settings']['render_command']["dont_generate_#{kind}"]
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

  def test_optional_headline_is_variant_specific
    with_project do |root|
      base = load_yaml(File.join(root, 'resume.yaml'))
      write_overlay(root, { 'headline' => 'Synthetic Headline', 'sections' => {} })
      result = load_yaml(ResumeVariant.compose('full-stack', root: root))
      expected = Marshal.load(Marshal.dump(base['cv']))
      expected['headline'] = 'Synthetic Headline'
      assert_equal expected, result['cv']
      assert_equal base['design'], result['design']
      refute load_yaml(ResumeVariant.compose('react-native', root: root))['cv'].key?('headline')
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
                 { 'sections' => { 'Summary' => [] } }, { 'sections' => { 'Summary' => 'Test' } },
                 { 'headline' => 'Test' }, { 'sections' => {}, 'headline' => '' },
                 { 'sections' => {}, 'headline' => ['Test'] }, { 'sections' => {}, 'headline' => "Two\nlines" },
                 { 'sections' => {}, 'name' => 'Test' }]
      invalid.each do |overlay|
        write_overlay(root, overlay)
        assert_raises(ArgumentError) { ResumeVariant.compose('full-stack', root: root) }
      end
    end
  end

  # Minitest 6 no longer bundles mocks; keep these tests dependency-free.
  def stub_variant(method, replacement)
    original = ResumeVariant.method(method)
    ResumeVariant.define_singleton_method(method) do |*arguments, **options|
      replacement.respond_to?(:call) ? replacement.call(*arguments, **options) : replacement
    end
    yield
  ensure
    ResumeVariant.define_singleton_method(method, original)
  end

  def test_preview_builds_then_audits_then_opens_the_audited_pdf
    Dir.mktmpdir('resume-preview-') do |directory|
      pdf = File.join(directory, 'reviewed.pdf')
      File.write(pdf, 'Synthetic PDF fixture; not rendered')
      calls = []
      paths = []
      path_lookup = lambda do |name, audited: false|
        paths << [name, audited]
        pdf
      end
      runner = ->(*arguments, **options) { calls << arguments; true }
      stub_variant(:compose, '/tmp/synthetic-full-stack.yaml') do
        stub_variant(:pdf_path, path_lookup) do
          stub_variant(:system, runner) do
            assert ResumeVariant.execute('preview', 'full-stack')
          end
        end
      end
      assert_equal [*ResumeVariant::RENDER, 'render', '/tmp/synthetic-full-stack.yaml'], calls[0]
      assert_equal ['ruby', ResumeVariant::AUDITOR, '--source', '/tmp/synthetic-full-stack.yaml'], calls[1]
      assert_equal ['open', '-a', 'Preview', pdf], calls[2]
      assert_equal [['full-stack', true]], paths
    end
  end

  def test_preview_never_opens_after_build_or_audit_failure
    [0, 1].each do |failure_index|
      calls = []
      runner = lambda do |*arguments, **options|
        calls << arguments
        calls.length - 1 != failure_index
      end
      stub_variant(:compose, '/tmp/synthetic-full-stack.yaml') do
        stub_variant(:system, runner) do
          refute ResumeVariant.execute('preview', 'full-stack')
        end
      end
      assert_equal failure_index + 1, calls.length
      refute calls.any? { |arguments| arguments.first == 'open' }
    end
  end

  def test_open_uses_existing_build_without_composing_or_rendering
    Dir.mktmpdir('resume-open-') do |directory|
      pdf = File.join(directory, 'existing.pdf')
      File.write(pdf, 'Synthetic PDF fixture; not rendered')
      calls = []
      lookup = lambda do |name, audited: false|
        assert_equal 'full-stack', name
        refute audited
        pdf
      end
      runner = ->(*arguments, **options) { calls << arguments; false }
      stub_variant(:compose, ->(*) { flunk 'open must not compose' }) do
        stub_variant(:pdf_path, lookup) do
          stub_variant(:system, runner) do
            refute ResumeVariant.execute('open', 'full-stack'), 'Propagate Preview launch failures'
          end
        end
      end
      assert_equal [['open', '-a', 'Preview', pdf]], calls
    end
  end

  def test_open_rejects_missing_pdf_and_invalid_variant_without_launching
    stub_variant(:pdf_path, '/nonexistent-resume-test/output.pdf') do
      stub_variant(:system, ->(*) { flunk 'must not launch Preview' }) do
        error = assert_raises(ArgumentError) { ResumeVariant.execute('open', 'full-stack') }
        assert_includes error.message, 'make preview full-stack'
        assert_raises(ArgumentError) { ResumeVariant.execute('open', '../resume') }
      end
    end
  end

  def with_watch_snapshots(snapshots)
    index = 0
    fingerprint = lambda do |_name|
      snapshot = snapshots.fetch(index)
      raise snapshot if snapshot.is_a?(Exception)

      snapshot
    end
    sleeper = lambda do |_seconds|
      index += 1
      raise Interrupt if index >= snapshots.length
    end
    stub_variant(:fingerprint, fingerprint) do
      stub_variant(:sleep, sleeper) { yield }
    end
  end

  def test_watch_rebuilds_directly_on_edits_and_opens_preview_only_once
    commands = []
    launches = []
    runner = ->(command, name, watch: false) { commands << [command, name, watch]; true }
    launcher = ->(path) { launches << path; true }
    _output, errors = capture_io do
      stub_variant(:execute, runner) do
        stub_variant(:launch_preview, launcher) do
          with_watch_snapshots([:initial, :initial, :edited]) do
            assert ResumeVariant.watch('full-stack')
          end
        end
      end
    end
    assert_equal [['pdf', 'full-stack', true]] * 2, commands
    assert_equal [ResumeVariant.watch_pdf_path('full-stack')], launches
    assert_includes errors, 'Ctrl-C to stop'
    assert_includes errors, 'unaudited draft'
  end

  def test_watch_recovers_from_a_failed_build_without_reopening_preview
    attempts = 0
    launches = 0
    runner = ->(_command, _name, watch: false) { attempts += 1; attempts != 2 }
    _output, errors = capture_io do
      stub_variant(:execute, runner) do
        stub_variant(:launch_preview, ->(_path) { launches += 1; true }) do
          with_watch_snapshots([:initial, :broken, :fixed]) do
            assert ResumeVariant.watch('full-stack')
          end
        end
      end
    end
    assert_equal 3, attempts
    assert_equal 1, launches
    assert_includes errors, 'Build failed; still watching'
  end

  def test_watch_recovers_from_transient_file_and_yaml_errors
    attempts = 0
    runner = lambda do |_command, _name, watch: false|
      attempts += 1
      raise Psych::Exception, 'Synthetic invalid YAML' if attempts == 1

      true
    end
    launches = 0
    _output, errors = capture_io do
      stub_variant(:execute, runner) do
        stub_variant(:launch_preview, ->(_path) { launches += 1; true }) do
          with_watch_snapshots([Errno::ENOENT.new('Synthetic file save'), :broken, :fixed]) do
            assert ResumeVariant.watch('full-stack')
          end
        end
      end
    end
    assert_equal 1, launches
    assert_includes errors, 'Synthetic file save'
    assert_includes errors, 'Synthetic invalid YAML'
  end

  def test_watch_retries_failed_initial_launch_but_stops_launching_after_success
    launches = 0
    launcher = ->(_path) { launches += 1; launches > 1 }
    _output, errors = capture_io do
      stub_variant(:execute, true) do
        stub_variant(:launch_preview, launcher) do
          with_watch_snapshots([:initial, :edited, :another_edit]) do
            assert ResumeVariant.watch('full-stack')
          end
        end
      end
    end
    assert_equal 2, launches
    assert_includes errors, 'Preview launch failed'
  end

  def test_watch_composition_changes_only_the_pdf_output_path
    with_project do |root|
      regular = load_yaml(ResumeVariant.compose('full-stack', root: root))
      watched = load_yaml(ResumeVariant.compose('full-stack', root: root, watch: true))
      regular['settings']['render_command']['pdf_path'] = 'watch.pdf'
      assert_equal regular, watched
      assert_equal 'watch.pdf', watched['settings']['render_command']['pdf_path']
    end
  end

  def test_watch_renderer_writes_the_displayed_file_without_copying_or_auditing
    with_project do |root|
      composer = ResumeVariant.method(:compose)
      compose_fixture = ->(name, watch: false) { composer.call(name, root: root, watch: watch) }
      builds = []
      runner = lambda do |*arguments, **options|
        assert_equal ResumeVariant::RENDER, arguments[0...-2]
        assert_equal 'render', arguments[-2]
        source = arguments.last
        settings = load_yaml(source)['settings']['render_command']
        path = File.join(File.dirname(source), settings['pdf_path'])
        File.write(path, 'Synthetic renderer output')
        builds << path
        true
      end
      stub_variant(:compose, compose_fixture) do
        stub_variant(:system, runner) do
          assert ResumeVariant.execute('pdf', 'full-stack', watch: true)
        end
      end
      expected = File.join(root, 'build/variants/full-stack/watch.pdf')
      assert_equal [expected], builds
      assert_equal 'Synthetic renderer output', File.read(expected)
      refute File.exist?(File.join(root, 'build/variants/full-stack/full-stack.pdf'))
    end
  end

  def test_watch_detects_baseline_overlay_and_template_edits_but_ignores_generated_output
    with_project do |root|
      previous = ResumeVariant.fingerprint('full-stack', root: root)
      ['resume.yaml', 'variants/full-stack.yaml', 'classic/Header.j2.typ'].each do |relative|
        File.open(File.join(root, relative), 'a') { |file| file.puts "\n# Synthetic fixture edit" }
        current = ResumeVariant.fingerprint('full-stack', root: root)
        refute_equal previous, current, "Must notice edits to #{relative}"
        previous = current
      end
      FileUtils.mkdir_p(File.join(root, 'build/variants/full-stack'))
      File.write(File.join(root, 'build/variants/full-stack/watch.pdf'), 'Synthetic generated PDF')
      assert_equal previous, ResumeVariant.fingerprint('full-stack', root: root)
    end
  end

  def make_dry_run(*arguments)
    Open3.capture3('make', '--no-print-directory', '-n', *arguments, chdir: ResumeVariant::ROOT)
  end

  def test_make_accepts_positional_and_explicit_variants
    %w[compose pdf check-layout watch preview open].each do |command|
      positional, error, status = make_dry_run(command, 'full-stack')
      assert status.success?, error
      explicit, error, status = make_dry_run(command, 'VARIANT=full-stack')
      assert status.success?, error
      assert_includes positional, "ruby scripts/resume_variant.rb #{command} \"full-stack\""
      assert_includes explicit, "ruby scripts/resume_variant.rb #{command} \"full-stack\""
    end
    output, error, status = make_dry_run('pdf', 'check-layout', 'VARIANT=full-stack')
    assert status.success?, error
    assert_includes output, 'resume_variant.rb pdf'
    assert_includes output, 'resume_variant.rb check-layout'
  end

  def test_make_rejects_ambiguous_or_invalid_shortcuts_before_running
    [
      ['preview', 'missing'],
      ['preview', 'full-stack', 'react-native'],
      ['preview', 'full-stack', 'VARIANT=react-native'],
      ['preview', 'full-stack', 'SOURCE=tailored.yaml']
    ].each do |arguments|
      output, error, status = make_dry_run(*arguments)
      refute status.success?, arguments.inspect
      assert_empty output
      refute_empty error
    end
  end

  def test_make_default_stays_baseline_pdf
    output, error, status = make_dry_run
    assert status.success?, error
    assert_includes output, 'render "resume.yaml"'
  end

  def test_rejects_missing_variants_and_path_traversal
    with_project do |root|
      ['missing', '../resume', '../../resume', '/tmp/resume', ''].each do |name|
        assert_raises(ArgumentError) { ResumeVariant.compose(name, root: root) }
      end
    end
  end
end
