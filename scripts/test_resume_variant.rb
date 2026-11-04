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

  def test_watch_builds_initially_and_on_edits_but_not_unchanged_polls
    commands = []
    launches = []
    publisher = ->(name) { assert_equal 'full-stack', name; '/tmp/watch.pdf' }
    runner = ->(command, name) { commands << [command, name]; true }
    launcher = ->(path, background: false) { launches << [path, background]; true }
    _output, errors = capture_io do
      stub_variant(:execute, runner) do
        stub_variant(:publish_watch_pdf, publisher) do
          stub_variant(:launch_preview, launcher) do
            with_watch_snapshots([:initial, :initial, :edited]) do
              assert ResumeVariant.watch('full-stack')
            end
          end
        end
      end
    end
    assert_equal [%w[pdf full-stack], %w[check-layout full-stack]] * 2, commands
    assert_equal [['/tmp/watch.pdf', false], ['/tmp/watch.pdf', true]], launches
    assert_includes errors, 'Ctrl-C to stop'
  end

  def test_watch_keeps_last_good_pdf_on_build_and_audit_failure_and_recovers
    %w[pdf check-layout].each do |failed_command|
      attempts = 0
      publications = 0
      launches = []
      runner = lambda do |command, _name|
        attempts += 1 if command == 'pdf'
        !(attempts == 2 && command == failed_command)
      end
      publisher = ->(_name) { publications += 1; '/tmp/watch.pdf' }
      launcher = ->(_path, background: false) { launches << background; true }
      _output, errors = capture_io do
        stub_variant(:execute, runner) do
          stub_variant(:publish_watch_pdf, publisher) do
            stub_variant(:launch_preview, launcher) do
              with_watch_snapshots([:initial, :broken, :fixed]) do
                assert ResumeVariant.watch('full-stack')
              end
            end
          end
        end
      end
      assert_equal 3, attempts
      assert_equal 2, publications
      assert_equal [false, true], launches
      assert_includes errors, 'keeping the last successful watch PDF'
    end
  end

  def test_watch_recovers_from_transient_file_and_yaml_errors
    attempts = 0
    runner = lambda do |_command, _name|
      attempts += 1
      raise Psych::Exception, 'Synthetic invalid YAML' if attempts == 1

      true
    end
    launches = 0
    _output, errors = capture_io do
      stub_variant(:execute, runner) do
        stub_variant(:publish_watch_pdf, '/tmp/watch.pdf') do
          stub_variant(:launch_preview, ->(*) { launches += 1; true }) do
            with_watch_snapshots([Errno::ENOENT.new('Synthetic file save'), :broken, :fixed]) do
              assert ResumeVariant.watch('full-stack')
            end
          end
        end
      end
    end
    assert_equal 1, launches
    assert_includes errors, 'Synthetic file save'
    assert_includes errors, 'Synthetic invalid YAML'
  end

  def test_watch_retries_foreground_launch_if_first_launch_fails
    launches = []
    launcher = lambda do |_path, background: false|
      launches << background
      launches.length > 1
    end
    _output, errors = capture_io do
      stub_variant(:execute, true) do
        stub_variant(:publish_watch_pdf, '/tmp/watch.pdf') do
          stub_variant(:launch_preview, launcher) do
            with_watch_snapshots([:initial, :edited]) { assert ResumeVariant.watch('full-stack') }
          end
        end
      end
    end
    assert_equal [false, false], launches
    assert_includes errors, 'Preview launch failed'
  end

  def test_publish_watch_pdf_atomically_copies_audit_output_and_preserves_last_good_on_error
    Dir.mktmpdir('resume-watch-') do |directory|
      audit = File.join(directory, 'audit.pdf')
      built = File.join(directory, 'full-stack.pdf')
      path = File.join(directory, 'watch.pdf')
      File.write(audit, 'Synthetic successful audit')
      File.write(path, 'Previous successful audit')
      lookup = ->(_name, audited: false) { audited ? audit : built }
      stub_variant(:pdf_path, lookup) do
        assert_equal path, ResumeVariant.publish_watch_pdf('full-stack')
        assert_equal File.read(audit), File.read(path)
        File.unlink(audit)
        assert_raises(Errno::ENOENT) { ResumeVariant.publish_watch_pdf('full-stack') }
        assert_equal 'Synthetic successful audit', File.read(path)
        assert_empty Dir.glob("#{path}.*.tmp")
      end
    end
  end

  def test_background_preview_refresh_does_not_request_focus
    calls = []
    runner = ->(*arguments, **options) { calls << arguments; true }
    stub_variant(:system, runner) do
      assert ResumeVariant.launch_preview('/tmp/watch.pdf', background: true)
    end
    assert_equal [['open', '-g', '-a', 'Preview', '/tmp/watch.pdf']], calls
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
