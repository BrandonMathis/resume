#!/usr/bin/env ruby
# Compose content-only overlays; never maintain a second layout source.
require 'yaml'
require 'fileutils'

module ResumeVariant
  ROOT = File.expand_path('..', __dir__)
  RENDER = ['uv', 'tool', 'run', '--python', '3.13', '--from', 'rendercv[full]==2.8', 'rendercv'].freeze
  AUDITOR = File.join(ROOT, '.agents/skills/resume-layout/scripts/check_layout.rb')

  def self.names(root = ROOT)
    Dir.glob(File.join(root, 'variants', '*.yaml')).map { |path| File.basename(path, '.yaml') }.sort
  end

  def self.validate_name(name, root: ROOT)
    unless name.is_a?(String) && /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/.match?(name) && names(root).include?(name)
      raise ArgumentError, "Unknown variant #{name.inspect}; choose: #{names(root).join(', ')}"
    end
  end

  def self.compose(name, root: ROOT)
    validate_name(name, root: root)
    data = YAML.safe_load_file(File.join(root, 'resume.yaml'))
    overlay = YAML.safe_load_file(File.join(root, 'variants', "#{name}.yaml"))
    unless overlay.is_a?(Hash) && overlay.keys == ['sections'] && overlay['sections'].is_a?(Hash)
      raise ArgumentError, 'A variant must contain only a sections mapping; design, identity, locale, and settings are shared.'
    end

    sections = data.fetch('cv').fetch('sections')
    overlay.fetch('sections').each do |heading, entries|
      raise ArgumentError, "Unknown section #{heading.inspect}; define shared headings in resume.yaml." unless sections.key?(heading)
      unless entries.is_a?(Array) && !entries.empty?
        raise ArgumentError, "Section #{heading.inspect} must be a nonempty list of RenderCV entries."
      end

      # Replace the whole section, never concatenate bullets or merge array indices.
      # Assignment to an existing key preserves the baseline section order.
      sections[heading] = entries
    end

    directory = File.join(root, 'build', 'variants', name)
    FileUtils.mkdir_p(directory)
    # RenderCV resolves local templates beside its input. Refresh this generated
    # copy on every compose so it cannot become an independently maintained theme.
    template = File.join(directory, 'classic')
    FileUtils.rm_rf(template)
    FileUtils.cp_r(File.join(root, 'classic'), template)
    outputs = data.fetch('settings').fetch('render_command')
    { 'pdf' => 'pdf', 'typst' => 'typ', 'markdown' => 'md', 'html' => 'html' }.each do |kind, extension|
      outputs["#{kind}_path"] = "#{name}.#{extension}"
    end
    source = File.join(directory, "#{name}.yaml")
    File.write(source, "# GENERATED from resume.yaml + variants/#{name}.yaml; do not edit.\n" + YAML.dump(data))
    source
  end

  def self.pdf_path(name, audited: false)
    if audited
      File.join(ROOT, 'build', 'layout-audit', name, 'resume.pdf')
    else
      File.join(ROOT, 'build', 'variants', name, "#{name}.pdf")
    end
  end

  def self.open_pdf(name, audited: false)
    validate_name(name)
    path = pdf_path(name, audited: audited)
    unless File.file?(path)
      raise ArgumentError, "PDF not found: #{path}. Run `make preview #{name}` to build and audit it."
    end

    launch_preview(path)
  end

  def self.launch_preview(path, background: false)
    arguments = ['open']
    arguments << '-g' if background
    system(*arguments, '-a', 'Preview', path, chdir: ROOT)
  end

  def self.publish_watch_pdf(name)
    # The auditor writes diagnostic PDFs even on failure. Keep a separate stable
    # viewer file and replace it atomically only after an audit passes.
    path = File.join(File.dirname(pdf_path(name)), 'watch.pdf')
    temporary = "#{path}.#{Process.pid}.tmp"
    begin
      FileUtils.cp(pdf_path(name, audited: true), temporary)
      File.rename(temporary, path)
    ensure
      FileUtils.rm_f(temporary)
    end
    path
  end

  def self.execute(command, name)
    # Opening existing output must not compose, render, or alter any source.
    return open_pdf(name) if command == 'open'
    if command == 'preview'
      return false unless execute('pdf', name) && execute('check-layout', name)

      # Open the exact fresh audit artifact, never stale build output.
      return open_pdf(name, audited: true)
    end

    source = compose(name)
    case command
    when 'compose'
      puts source
      true
    when 'pdf'
      system(*RENDER, 'render', source, chdir: ROOT)
    when 'check-layout'
      system('ruby', AUDITOR, '--source', source, chdir: ROOT)
    else
      raise ArgumentError, "Unknown command: #{command}"
    end
  end

  def self.fingerprint(name)
    paths = [File.join(ROOT, 'resume.yaml'), File.join(ROOT, 'variants', "#{name}.yaml"), __FILE__]
    paths += Dir.glob(File.join(ROOT, 'classic', '**', '*')).select { |path| File.file?(path) }
    paths.sort.map { |path| [path, File.read(path)] }
  end

  def self.watch(name)
    validate_name(name)
    warn "Watching #{name}; building and auditing before each Preview refresh. Ctrl-C to stop."
    # Watch actual sources, not generated output. Capture before rendering so
    # edits made during a build are picked up on the next pass.
    previous = nil
    opened = false
    loop do
      begin
        current = fingerprint(name)
        if current != previous
          previous = current
          if execute('pdf', name) && execute('check-layout', name)
            path = publish_watch_pdf(name)
            if launch_preview(path, background: opened)
              opened = true
              warn "Preview updated: #{path} (visual review still required)."
            else
              warn 'Preview launch failed; still watching for edits.'
            end
          else
            warn 'Build/audit failed; keeping the last successful watch PDF. Still watching for edits.'
          end
        end
      rescue ArgumentError, KeyError, Psych::Exception, SystemCallError => error
        warn "Watch update failed: #{error.message}; still watching for edits."
      end
      sleep 1
    end
  rescue Interrupt
    true
  end

  def self.run(arguments)
    command, name, *extra = arguments
    if command == 'list' && name.nil?
      puts names
      return true
    end
    unless name && extra.empty? && %w[compose pdf check-layout watch preview open].include?(command)
      raise ArgumentError, 'Usage: resume_variant.rb list | {compose|pdf|check-layout|watch|preview|open} VARIANT'
    end
    command == 'watch' ? watch(name) : execute(command, name)
  rescue ArgumentError, KeyError, Psych::Exception, SystemCallError => error
    warn "ERROR: #{error.message}"
    false
  end
end

exit(ResumeVariant.run(ARGV) ? 0 : 1) if $PROGRAM_NAME == __FILE__
