#!/usr/bin/env ruby
require 'minitest/autorun'
require_relative 'check_layout'

class ResumeLayoutTest < Minitest::Test
  HEADINGS = ['Summary', 'Recent Work Experience', 'Education', 'Leadership & Community Activities'].freeze

  def setup
    @policy = JSON.parse(File.read(ResumeLayout::POLICY_PATH))
    @metrics = { 'font' => 10, 'baseline' => 12, 'left' => 36.135, 'right' => 36.135, 'top' => 36.135, 'bottom' => 36.135 }
    @front = [
      ['Brandon Mathis', 17], ['Contact details', 9], ['Summary', 12],
      ['Engineering leader.', 10], ['Recent Work Experience', 12],
      ['Example employer', 10], ['Built useful software.', 10]
    ]
    @back = [
      ['Education', 12], ['University and degree', 10],
      ['Leadership & Community Activities', 12], ['Community contributions', 10]
    ]
  end

  def xml(pages, spacing: 15)
    document = REXML::Document.new
    root = document.add_element('pdf2xml')
    [9, 10, 12, 17].each { |size| root.add_element('fontspec', { 'id' => size.to_s, 'size' => size.to_s, 'family' => 'ABCDEF+Helvetica' }) }
    pages.each_with_index do |lines, index|
      page = root.add_element('page', { 'number' => (index + 1).to_s, 'width' => '612', 'height' => '792' })
      lines.each_with_index do |(text, font), line|
        node = page.add_element('text', {
          'top' => (36 + line * spacing).to_s, 'left' => '36', 'width' => '400',
          'height' => '12', 'font' => font.to_s
        })
        node.add_text(text)
      end
    end
    document.to_s
  end

  def audit(pages = [@front, @back], **overrides)
    ResumeLayout::Audit.new(@policy).analyze(**{
      xml: xml(pages), headings: HEADINGS, metrics: @metrics, log: '', explicit_break: true
    }.merge(overrides))
  end

  def codes(report)
    report[:issues].map { |issue| issue[:code] }
  end

  def test_valid_two_page_resume
    report = audit
    assert_equal 'PASS_AUTOMATED', report[:status]
    assert_equal [1], report[:sections]['Recent Work Experience']
    assert_equal [2], report[:sections]['Education']
  end

  def test_experience_continuation_on_page_two_even_with_two_pages
    @back.unshift(['Continuation of the final experience bullet.', 10])
    report = audit
    assert_equal 2, report[:page_count]
    assert_includes codes(report), 'experience_overflow'
    issue = report[:issues].find { |item| item[:code] == 'experience_overflow' }
    assert_match(/Continuation/, issue[:excerpt])
  end

  def test_supporting_material_on_page_one
    @front.concat(@back.shift(2))
    assert_includes codes(audit), 'section_placement'
  end

  def test_three_page_resume_and_supporting_continuation
    report = audit([@front, @back, [['More community contributions', 10]]])
    assert_includes codes(report), 'page_count'
    assert_includes codes(report), 'section_placement'
  end

  def test_one_page_resume
    assert_includes codes(audit([@front + @back])), 'page_count'
  end

  def test_blank_second_page
    assert_includes codes(audit([@front, []])), 'blank_page'
  end

  def test_missing_summary
    @front.reject! { |text, _| ['Summary', 'Engineering leader.'].include?(text) }
    report = audit(headings: HEADINGS.drop(1))
    assert_includes codes(report), 'summary_required'
  end

  def test_reduced_normal_font_and_baseline
    @metrics.merge!('font' => 9, 'baseline' => 10)
    assert_equal 2, codes(audit).count('readability')
  end

  def test_increased_normal_baseline_also_requires_deliberate_policy_change
    @metrics['baseline'] = 13
    assert_includes codes(audit), 'readability'
  end

  def test_locally_shrunk_bullet
    @front[-1][1] = 9
    assert_includes codes(audit), 'rendered_font'
  end

  def test_margins_below_floor
    @metrics['left'] = 30
    assert_includes codes(audit), 'margin'
  end

  def test_clipped_or_margin_intruding_text
    extracted = xml([@front, @back]).sub('left=\'36\'', 'left=\'5\'')
    assert_includes codes(audit(xml: extracted)), 'text_bounds'
  end

  def test_missing_explicit_break
    assert_includes codes(audit(explicit_break: false)), 'explicit_break'
  end

  def test_overfull_box
    assert_includes codes(audit(log: 'Overfull \\hbox (12.0pt too wide)')), 'overfull_box'
  end

  def test_unmatched_heading_fails_closed
    assert_includes codes(audit(headings: HEADINGS + ['Certifications'])), 'unmatched_heading'
  end

  def test_name_missing
    @front.shift
    assert_includes codes(audit), 'name_placement'
  end

  def rendercv_typst(font: '10pt', leading: '2pt')
    <<~TYPST
      #let resume-style = rendercv.with(
        typography-font-size-body: #{font},
        typography-line-spacing: #{leading},
        page-left-margin: 0.5in,
        page-right-margin: 0.5in,
        page-top-margin: 0.5in,
        page-bottom-margin: 0.5in,
      )
      #show: doc => {
        set text(top-edge: 0.8em, bottom-edge: -0.2em)
      }
    TYPST
  end

  def test_rendercv_dimensions_and_baseline_are_not_confused_with_leading
    metrics = ResumeLayout.rendercv_metrics(rendercv_typst)
    assert_equal 10, metrics['font']
    assert_equal 12, metrics['baseline']
    assert_equal 36, metrics['left']
    assert_equal 1, metrics['point_scale']
    assert_in_delta 72, ResumeLayout.typst_points('2.54cm'), 0.001
  end

  def test_rendercv_reduced_leading_is_a_readability_failure
    metrics = ResumeLayout.rendercv_metrics(rendercv_typst(leading: '1pt'))
    assert_includes codes(audit(metrics: metrics)), 'readability'
  end

  def test_rendercv_missing_or_unmeasurable_frame_fails_closed
    assert_raises(RuntimeError) { ResumeLayout.rendercv_metrics(rendercv_typst.sub('top-edge: 0.8em', 'top-edge: auto')) }
    assert_raises(RuntimeError) { ResumeLayout.typst_points('1em') }
  end

  def test_rendercv_rendered_baseline_and_font_family
    metrics = ResumeLayout.rendercv_metrics(rendercv_typst)
    report = audit(xml: xml([@front, @back], spacing: 12), metrics: metrics)
    assert_equal 'PASS_AUTOMATED', report[:status]
    assert_equal 'Typst/PDF pt (1/72 inch)', report[:point_unit]
  end

  def test_rendercv_locally_reduced_row_spacing
    metrics = ResumeLayout.rendercv_metrics(rendercv_typst)
    report = audit(xml: xml([@front, @back], spacing: 10), metrics: metrics)
    assert_includes codes(report), 'rendered_baseline'
  end

  def test_rendercv_silent_font_fallback
    metrics = ResumeLayout.rendercv_metrics(rendercv_typst)
    extracted = xml([@front, @back], spacing: 12).gsub('ABCDEF+Helvetica', 'ABCDEF+Times')
    assert_includes codes(audit(xml: extracted, metrics: metrics)), 'font_family'
  end

  def test_rendercv_precise_extraction_uses_poppler_maximum_zoom
    zoomed = "<pdf2xml><page width='1836' height='2376'><fontspec id='0' size='30' family='Helvetica'/><text top='108' left='108' width='300' height='28' font='0'>Body</text></page></pdf2xml>"
    extracted = REXML::Document.new(ResumeLayout.normalize_zoomed_xml(zoomed))
    assert_equal '612.0', extracted.root.elements['page'].attributes['width']
    assert_equal '10.0', REXML::XPath.first(extracted, '//fontspec').attributes['size']
    assert_equal '36.0', REXML::XPath.first(extracted, '//text').attributes['top']
  end

  def test_unknown_heading_is_supporting_material
    assert_equal :supporting, ResumeLayout.kind('Certifications')
    assert_equal :experience, ResumeLayout.kind('Professional Experience')
    assert_equal :summary, ResumeLayout.kind('Professional Summary')
  end
end
