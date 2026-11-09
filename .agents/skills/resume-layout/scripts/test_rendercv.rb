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
      data = YAML.safe_load(File.read(File.join(ResumeLayout::ROOT, 'variants/default.yml')))
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
      published = File.join(ResumeLayout::ROOT, 'build', 'variants', 'default', 'default.pdf')
      before = File.file?(published) ? Digest::SHA256.file(published).hexdigest : nil
      result, report = render(source, artifact)
      assert_equal 0, result, report.inspect
      assert_equal 'PASS_AUTOMATED', report['status']
      assert_equal 2, report['page_count']
      assert_equal [1], report['sections']['Recent Work Experience']
      assert_equal [2], report['sections']['Education']
      assert_equal 12, report['normal_baseline_pt']
      assert File.file?(File.join(artifact, 'resume.typ'))
      if before
        assert_equal before, Digest::SHA256.file(published).hexdigest
      else
        refute File.exist?(published), 'An audit must not create the build-path PDF'
      end
    end
  end

  def pdf_xml(artifact)
    xml, error, status = Open3.capture3('pdftohtml', '-xml', '-hidden', '-stdout', File.join(artifact, 'resume.pdf'))
    assert status.success?, error
    REXML::Document.new(xml)
  end

  def test_header_link_policy_preserves_escaping_icons_and_body_link_styles
    [false, true].each do |show_icons|
      with_source do |source, artifact, data|
        data['cv']['email'] = ['header_test+resume@example.com', 'second@example.com']
        data['design']['colors']['links'] = '#123456'
        data['design']['header']['connections']['hyperlink'] = true
        data['design']['header']['connections']['show_icons'] = show_icons
        data['cv']['sections']['Summary'][0] += ' [Body link](https://example.com/body).'
        File.write(source, YAML.dump(data))
        result, report = render(source, artifact)
        if show_icons
          # Font Awesome is intentionally outside this project's Helvetica-only
          # layout policy. This fixture tests rendering, not publishable layout.
          assert_equal 1, result, report.inspect
          assert_equal %w[font_family rendered_font], report['issues'].map { |issue| issue['code'] }.uniq.sort
        else
          assert_equal 0, result, report.inspect
        end
        document = pdf_xml(artifact)
        links = REXML::XPath.match(document, '//a')
        refute links.any? { |link| link.attributes['href'].start_with?('mailto:') }
        text = REXML::XPath.match(document, '//text//text()').map(&:value).join(' ')
        data['cv']['email'].each { |email| assert_includes text, email }
        data['cv']['social_networks'].each do |social|
          host = social['network'] == 'GitHub' ? 'github.com' : 'linkedin.com/in'
          matching_links = links.select { |node| node.attributes['href'] == "https://#{host}/#{social['username']}" }
          refute_empty matching_links
          # With icons, Poppler can split one link into separate icon/text nodes.
          link = matching_links.find { |node| node.elements['b'] }
          refute_nil link, 'Header link text must be bold'
          font = REXML::XPath.first(document, "//fontspec[@id='#{link.parent.attributes['font']}']")
          assert_equal '#123456', font.attributes['color']
        end
        body_link = links.find { |node| node.attributes['href'] == 'https://example.com/body' }
        refute_nil body_link
        assert_nil body_link.elements['b'], 'Header override must not make body links bold'
        typst = File.read(File.join(artifact, 'resume.typ'))
        assert_includes typst, '#connection-with-icon(' if show_icons
      end
    end
  end

  def test_disabled_header_hyperlinks_are_not_reintroduced
    with_source do |source, artifact, data|
      data['design']['header']['connections']['hyperlink'] = false
      File.write(source, YAML.dump(data))
      result, report = render(source, artifact)
      assert_equal 0, result, report.inspect
      assert_empty REXML::XPath.match(pdf_xml(artifact), '//a')
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
