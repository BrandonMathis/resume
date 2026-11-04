#!/usr/bin/env ruby
# End-to-end fresh-render regression tests. Requires the documented build dependencies.
require 'minitest/autorun'
require 'digest'
require_relative 'check_layout'

class RenderCVIntegrationTest < Minitest::Test
  def with_source
    Dir.mktmpdir('rendercv-test-') do |temp|
      stem = "layout-test-#{File.basename(temp)}"
      source = File.join(temp, "#{stem}.yaml")
      artifact = File.join(ResumeLayout::ROOT, 'build', 'layout-audit', stem)
      data = YAML.safe_load(File.read(File.join(ResumeLayout::ROOT, 'resume.yaml')))
      FileUtils.cp_r(File.join(ResumeLayout::ROOT, 'classic'), temp)
      File.write(source, YAML.dump(data))
      begin
        yield source, artifact, data
      ensure
        FileUtils.rm_rf(artifact)
      end
    end
  end

  def render(source, artifact)
    result = nil
    capture_io { result = ResumeLayout.run(['--source', source]) }
    [result, JSON.parse(File.read(File.join(artifact, 'report.json')))]
  end

  def test_fresh_render_passes_without_overwriting_the_published_pdf
    with_source do |source, artifact, _|
      published = File.join(ResumeLayout::ROOT, 'build', 'resume.pdf')
      before = File.file?(published) ? Digest::SHA256.file(published).hexdigest : nil
      result, report = render(source, artifact)
      assert_equal 0, result, report.inspect
      assert_equal 'PASS_AUTOMATED', report['status']
      assert_equal 2, report['page_count']
      assert_equal [1], report['sections']['Recent Work Experience']
      assert_equal [2], report['sections']['Education']
      assert_equal 12, report['normal_baseline_pt']
      assert File.file?(File.join(artifact, 'resume.typ'))
      after = File.file?(published) ? Digest::SHA256.file(published).hexdigest : nil
      assert_equal before, after
    end
  end

  def test_invalid_yaml_removes_stale_success_artifacts
    with_source do |source, artifact, _|
      FileUtils.mkdir_p(artifact)
      File.write(File.join(artifact, 'resume.pdf'), 'stale PDF')
      File.write(File.join(artifact, 'report.json'), '{"status":"PASS_AUTOMATED"}')
      File.write(source, "cv: [invalid YAML\n")
      result, report = render(source, artifact)
      assert_equal 2, result
      assert_equal 'BLOCKED', report['status']
      refute File.exist?(File.join(artifact, 'resume.pdf'))
      assert File.file?(File.join(artifact, 'compile.log'))
    end
  end

  def test_missing_summary_cannot_pass
    with_source do |source, artifact, data|
      data['cv']['sections'].delete('Summary')
      File.write(source, YAML.dump(data))
      result, report = render(source, artifact)
      assert_equal 1, result
      assert_includes report['issues'].map { |issue| issue['code'] }, 'summary_required'
    end
  end

  def test_experience_overflow_cannot_hide_behind_explicit_page_break
    with_source do |source, artifact, data|
      highlights = data['cv']['sections']['Recent Work Experience'].last['highlights']
      35.times { highlights << 'Synthetic overflow regression test bullet; never part of the real resume.' }
      File.write(source, YAML.dump(data))
      result, report = render(source, artifact)
      assert_equal 1, result
      assert_includes report['issues'].map { |issue| issue['code'] }, 'experience_overflow'
      assert_operator report['page_count'], :>, 2
    end
  end

  def test_missing_template_break_cannot_pass
    with_source do |source, artifact, _|
      preamble = File.join(File.dirname(source), 'classic', 'Preamble.j2.typ')
      File.write(preamble, File.read(preamble).sub('  pagebreak()', '  v(0pt)'))
      result, report = render(source, artifact)
      assert_equal 1, result
      assert_includes report['issues'].map { |issue| issue['code'] }, 'explicit_break'
    end
  end
end
