#!/usr/bin/env ruby
# Builds a fresh diagnostic PDF without changing the source or published PDFs.
require 'json'
require 'open3'
require 'optparse'
require 'tmpdir'
require 'fileutils'
require 'yaml'
begin
  require 'rexml/document'
  require 'rexml/xpath'
rescue LoadError
  warn 'BLOCKED: Install REXML for this Ruby installation (gem install rexml).'
  exit 2
end

module ResumeLayout
  ROOT = File.expand_path('../../../..', __dir__)
  POLICY_PATH = File.expand_path('../policy.json', __dir__)

  def self.normalize(text)
    text.unicode_normalize(:nfkc).downcase.gsub(/[^\p{Alnum}]/, '')
  end

  def self.kind(heading)
    return :summary if /\A(summary|professional summary|profile)\z/i.match?(heading)
    return :experience if /experience|employment/i.match?(heading)

    :supporting
  end

  class Audit
    def initialize(policy)
      @policy = policy
    end

    def analyze(xml:, headings:, metrics:, explicit_break:, headline: nil)
      issues = []
      add = lambda do |code, message, details = {}|
        issues << { code: code, message: message }.merge(details)
      end
      document = REXML::Document.new(xml)
      pages = REXML::XPath.match(document, '/pdf2xml/page')
      raise 'PDF extraction produced no pages' if pages.empty?
      raise 'Source has no section headings to audit' if headings.empty?

      fonts = {}
      REXML::XPath.each(document, '//fontspec') do |font|
        fonts[font.attributes['id']] = Float(font.attributes['size'])
      end
      families = REXML::XPath.match(document, '//fontspec').map { |font| font.attributes['family'].to_s.split('+').last }
      unexpected = families.uniq.reject { |family| family == @policy.fetch('font_family') }
      unless unexpected.empty?
        add.call('font_family', "Expected #{@policy.fetch('font_family')}; found #{unexpected.join(', ')}. Install the required font; do not accept silent fallback.")
      end
      add.call('page_count', "Expected #{@policy.fetch('pages')} pages; got #{pages.length}.") unless pages.length == @policy.fetch('pages')
      [:summary, :experience].each do |kind|
        count = headings.count { |heading| ResumeLayout.kind(heading) == kind }
        add.call("#{kind}_required", "Expected exactly one #{kind} section; found #{count}.") unless count == 1
      end
      add.call('supporting_required', 'No supporting section was found.') unless headings.any? { |heading| ResumeLayout.kind(heading) == :supporting }
      add.call('explicit_break', 'Put an explicit page break immediately before the first supporting section.') unless explicit_break
      kinds = headings.map { |heading| ResumeLayout.kind(heading) }
      unless kinds.first(2) == [:summary, :experience] && kinds.drop(2).all? { |kind| kind == :supporting }
        add.call('section_order', 'Required order: summary, experience, then supporting sections.')
      end

      expected_metrics = { 'font' => 'body_pt', 'baseline' => 'baseline_pt' }
      expected_metrics.each do |metric, key|
        value = metrics.fetch(metric)
        expected = @policy.fetch(key)
        if (value - expected).abs > 0.05
          add.call('readability', "Normal #{metric} is #{value} pt; preserve #{expected} pt.")
        end
      end
      %w[left right top bottom].each do |side|
        inches = metrics.fetch(side) / 72.0
        if inches < @policy.fetch('minimum_margin_inches') - 0.001
          add.call('margin', "#{side.capitalize} margin is #{inches.round(3)} in; minimum is #{@policy.fetch('minimum_margin_inches')} in.")
        end
      end

      section = 'Header'
      spans = Hash.new { |hash, key| hash[key] = [] }
      observed_headings = []
      name_pages = []
      headline_pages = []
      misplaced = {}
      bad_fonts = {}
      bounds = []
      body_line_positions = Hash.new { |hash, key| hash[key] = [] }
      pages.each_with_index do |page, index|
        number = index + 1
        width = Float(page.attributes['width'])
        height = Float(page.attributes['height'])
        if (width - @policy.fetch('page_width_pdf_pt')).abs > 1 || (height - @policy.fetch('page_height_pdf_pt')).abs > 1
          add.call('paper_size', "Page #{number} is not US Letter.", page: number)
        end
        texts = REXML::XPath.match(page, 'text')
        texts = texts.map do |node|
          text = REXML::XPath.match(node, './/text()').map(&:value).join.strip
          [node, text]
        end.reject { |_, text| text.empty? }
        add.call('blank_page', "Page #{number} is empty or has no extractable text.", page: number) if texts.empty?
        texts.each do |node, text|
          normalized = ResumeLayout.normalize(text)
          heading = headings.find { |candidate| ResumeLayout.normalize(candidate) == normalized }
          if heading
            section = heading
            observed_headings << heading
          end
          spans[section] |= [number]
          expected_page = section == 'Header' || ResumeLayout.kind(section) != :supporting ? 1 : 2
          if number != expected_page
            misplaced[[section, number]] ||= text[0, 180]
          end
          name = normalized == ResumeLayout.normalize(@policy.fetch('name'))
          name_pages << number if name
          # An optional single-line headline under the name uses the section-title size.
          headline_line = section == 'Header' && headline && normalized == ResumeLayout.normalize(headline)
          headline_pages << number if headline_line
          font_key = if heading
                       'section_pt'
                     elsif section == 'Header'
                       if name then 'name_pt'
                       elsif headline_line then 'headline_pt'
                       else 'contact_pt'
                       end
                     else
                       'body_pt'
                     end
          # Allow for Poppler's rounding of extracted font sizes.
          actual = fonts.fetch(node.attributes['font'])
          expected = @policy.fetch(font_key)
          if (actual - expected).abs > 0.55
            bad_fonts[[section, actual, font_key]] ||= text[0, 120]
          end
          x = Float(node.attributes['left'])
          y = Float(node.attributes['top'])
          body_line_positions[number] << y if font_key == 'body_pt'
          right = x + Float(node.attributes['width'])
          bottom = y + Float(node.attributes['height'])
          margin = @policy.fetch('minimum_margin_inches') * 72
          # Integer-rounded extraction boxes can extend slightly past glyph edges.
          bounds << number if x < margin - 2 || y < margin - 2 || right > width - margin + 2 || bottom > height - margin + 2
        end
      end
      # Poppler caps zoom at 3x; normalize to 1/3pt precision.
      # Adjacent body rows may have extra list/entry spacing, never less than 12pt.
      gaps = body_line_positions.values.flat_map do |positions|
        positions.uniq.sort.each_cons(2).map { |first, last| last - first }
      end
      baseline = @policy.fetch('baseline_pt')
      if gaps.any? { |gap| gap < baseline - 0.35 }
        add.call('rendered_baseline', "Body rows are closer than the locked #{baseline} pt baseline.")
      end
      unless gaps.any? { |gap| (gap - baseline).abs <= 0.35 }
        add.call('rendered_baseline', 'Could not verify the configured baseline in the rendered PDF.')
      end
      headings.each do |heading|
        add.call('unmatched_heading', "Could not locate rendered heading: #{heading.inspect}. Manual validation/checker support is required.") unless observed_headings.include?(heading)
      end
      add.call('rendered_order', 'Rendered headings are duplicated or out of source order.') unless observed_headings == headings
      add.call('name_placement', 'The name must appear exactly once, on page 1.') unless name_pages == [1]
      if headline && headline_pages != [1]
        add.call('headline_placement', 'The headline must render exactly once, as one line in the page 1 header.')
      end
      misplaced.each do |(label, page), excerpt|
        code = ResumeLayout.kind(label) == :experience ? 'experience_overflow' : 'section_placement'
        add.call(code, "#{label} has content on page #{page}, not its assigned page.", page: page, excerpt: excerpt)
      end
      bad_fonts.each do |(label, actual, key), excerpt|
        add.call('rendered_font', "#{label}: rendered size #{actual} PDF pt does not match locked #{@policy.fetch(key)} pt.", excerpt: excerpt)
      end
      bounds.uniq.each do |page|
        add.call('text_bounds', "Text on page #{page} intrudes into the minimum margin or is clipped.", page: page)
      end
      {
        status: issues.empty? ? 'PASS_AUTOMATED' : 'FAIL',
        page_count: pages.length,
        sections: spans,
        normal_font_pt: metrics.fetch('font'),
        normal_baseline_pt: metrics.fetch('baseline'),
        point_unit: 'Typst/PDF pt (1/72 inch)',
        issues: issues,
        visual_review: 'Required; not performed by this script.'
      }
    end
  end

  def self.run_command(*command, chdir:)
    stdout, stderr, status = Open3.capture3(*command, chdir: chdir)
    raise "Command failed: #{command.first}\n#{stdout}\n#{stderr}" unless status.success?

    stdout + stderr
  end

  def self.available?(command)
    ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? { |dir| File.executable?(File.join(dir, command)) }
  end

  # Parse resolved values from generated Typst, not unvalidated YAML defaults.
  def self.typst_points(value)
    match = /\A(-?[\d.]+)(pt|in|cm|mm)\z/.match(value.strip)
    raise "Unsupported Typst dimension: #{value.inspect}" unless match

    Float(match[1]) * { 'pt' => 1, 'in' => 72, 'cm' => 72 / 2.54, 'mm' => 72 / 25.4 }.fetch(match[2])
  end

  def self.rendercv_metrics(typst)
    value = lambda do |key|
      typst[/^  #{Regexp.escape(key)}: ([^,]+),$/, 1] || raise("Missing generated Typst setting: #{key}")
    end
    font = typst_points(value.call('typography-font-size-body'))
    edges = typst.scan(/set text\(top-edge: (-?[\d.]+)em, bottom-edge: (-?[\d.]+)em\)/)
    raise 'Expected exactly one fixed text-frame rule in the RenderCV template.' unless edges.length == 1

    top, bottom = edges.first.map { |edge| Float(edge) }
    metrics = {
      'font' => font,
      'baseline' => (top - bottom) * font + typst_points(value.call('typography-line-spacing'))
    }
    %w[left right top bottom].each do |side|
      metrics[side] = typst_points(value.call("page-#{side}-margin"))
    end
    metrics
  end

  def self.precise_xml(pdf, chdir:)
    xml = run_command('pdftohtml', '-xml', '-i', '-stdout', '-zoom', '3', pdf, chdir: chdir)
    normalize_zoomed_xml(xml)
  end

  def self.normalize_zoomed_xml(xml)
    document = REXML::Document.new(xml)
    REXML::XPath.each(document, '//page | //text | //fontspec') do |node|
      %w[top left width height size].each do |key|
        node.attributes[key] = (Float(node.attributes[key]) / 3).to_s if node.attributes[key]
      end
    end
    document.to_s
  end

  def self.run_rendercv(source)
    artifact_dir = File.join(ROOT, 'build', 'layout-audit', File.basename(source, '.*'))
    FileUtils.mkdir_p(artifact_dir)
    %w[resume.pdf resume.typ compile.log report.json].each { |file| FileUtils.rm_f(File.join(artifact_dir, file)) }
    raise 'Install uv (brew install uv) to run the pinned RenderCV version.' unless available?('uv')

    data = YAML.safe_load(File.read(source))
    headings = data.fetch('cv').fetch('sections').keys
    headline = data.fetch('cv')['headline']
    policy = JSON.parse(File.read(POLICY_PATH))
    Dir.mktmpdir('resume-rendercv-') do |temp|
      pdf_path = File.join(temp, 'resume.pdf')
      typst_path = File.join(temp, 'resume.typ')
      command = ['uv', 'tool', 'run', '--python', '3.13', '--from', 'rendercv[full]==2.8',
                 'rendercv', 'render', source, '--output-folder', temp,
                 '--pdf-path', pdf_path, '--typst-path', typst_path,
                 '--dont-generate-markdown', '--dont-generate-html', '--dont-generate-png']
      log = run_command(*command, chdir: File.dirname(source))
      File.write(File.join(artifact_dir, 'compile.log'), log)
      raise 'RenderCV did not produce a fresh PDF and Typst source.' unless File.file?(pdf_path) && File.file?(typst_path)

      typst = File.read(typst_path)
      metrics = rendercv_metrics(typst)
      # The explicit break must split at the FIRST supporting section, exactly once.
      supporting = headings.find { |heading| kind(heading) == :supporting }
      split_heading = typst[/element\.body == \[([^\]]+)\]/, 1]
      explicit_break = supporting == split_heading && typst.scan(/^  pagebreak\(\)$/).length == 1 &&
                       typst.include?("resume-style(front.join())\n  pagebreak()\n  resume-style(back.join())")
      pdf = File.join(artifact_dir, 'resume.pdf')
      FileUtils.cp(pdf_path, pdf)
      FileUtils.cp(typst_path, File.join(artifact_dir, 'resume.typ'))
      xml = precise_xml(pdf, chdir: temp)
      report = Audit.new(policy).analyze(xml: xml, headings: headings, metrics: metrics,
                                        explicit_break: explicit_break, headline: headline)
      report[:source] = source
      report[:pdf] = pdf
      report_path = File.join(artifact_dir, 'report.json')
      File.write(report_path, JSON.pretty_generate(report) + "\n")
      puts "#{report[:status]}: #{report[:page_count]} pages; body #{metrics['font']} pt / #{metrics['baseline']} pt baseline"
      report[:sections].each { |label, pages| puts "  #{label}: page(s) #{pages.join(', ')}" }
      report[:issues].each do |issue|
        puts "  FAIL [#{issue[:code]}] #{issue[:message]}"
        puts "    #{issue[:excerpt]}" if issue[:excerpt]
      end
      puts "PDF: #{pdf}\nReport: #{report_path}\nVisual inspection is still required."
      report[:issues].empty? ? 0 : 1
    end
  rescue StandardError => error
    if artifact_dir && File.directory?(artifact_dir)
      File.write(File.join(artifact_dir, 'report.json'), JSON.pretty_generate({ status: 'BLOCKED', error: error.message }) + "\n")
      File.write(File.join(artifact_dir, 'compile.log'), error.message + "\n") unless File.file?(File.join(artifact_dir, 'compile.log'))
    end
    warn "BLOCKED: #{error.message}"
    2
  end

  def self.run(arguments)
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = 'Usage: check_layout.rb [--source path/to/resolved.yaml] (default: composed default variant)'
      opts.on('--source PATH', 'Source to compile and audit') { |path| options[:source] = path }
    end
    parser.parse!(arguments)
    raise "Unexpected arguments: #{arguments.join(' ')}" unless arguments.empty?
    unless options[:source]
      require_relative '../../../../scripts/resume_variant'
      options[:source] = ResumeVariant.compose('default')
    end
    source = File.expand_path(options.fetch(:source))
    raise "Source does not exist: #{source}" unless File.file?(source)
    raise 'Expected a RenderCV .yaml or .yml source.' unless %w[.yaml .yml].include?(File.extname(source))
    raise 'Install Poppler (brew install poppler) for pdftohtml.' unless available?('pdftohtml')

    run_rendercv(source)
  rescue StandardError, LoadError => error
    warn "BLOCKED: #{error.message}"
    2
  end
end

exit ResumeLayout.run(ARGV) if $PROGRAM_NAME == __FILE__
