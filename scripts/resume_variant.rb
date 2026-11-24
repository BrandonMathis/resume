#!/usr/bin/env ruby
# Compose content-only overlays; never maintain a second layout source.
require 'yaml'
require 'fileutils'
require 'tmpdir'

module ResumeVariant
  ROOT = File.expand_path('..', __dir__)
  RENDER = ['uv', 'tool', 'run', '--python', '3.13', '--from', 'rendercv[full]==2.8', 'rendercv'].freeze
  AUDITOR = File.join(ROOT, '.agents/skills/resume-layout/scripts/check_layout.rb')
  SAFE_NAME = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  def self.names(root = ROOT)
    names = Dir.glob(File.join(root, 'variants', '*.{yml,yaml}')).map { |path| File.basename(path, '.*') }
    duplicates = names.group_by(&:itself).select { |_, paths| paths.length > 1 }.keys
    raise ArgumentError, "Duplicate variant names (.yml and .yaml): #{duplicates.join(', ')}" unless duplicates.empty?

    names.sort
  end

  def self.validate_name(name, root: ROOT)
    unless name.is_a?(String) && SAFE_NAME.match?(name) && names(root).include?(name)
      raise ArgumentError, "Unknown variant #{name.inspect}; choose: #{names(root).join(', ')}"
    end
  end

  def self.variant_path(name, root)
    Dir.glob(File.join(root, 'variants', "#{name}.{yml,yaml}")).fetch(0)
  end

  def self.slug(name, data)
    return name unless data.is_a?(Hash) && data.key?('slug')

    value = data['slug']
    unless value.is_a?(String) && SAFE_NAME.match?(value)
      raise ArgumentError, "Invalid slug for #{name}: use lowercase letters, digits, and single hyphens between words."
    end
    value
  end

  # Return the complete inheritance chain in parent-first order. Parent names
  # are variant names, not file paths; every chain must end at default.
  def self.sources(name, root: ROOT, ancestors: [])
    validate_name(name, root: root)
    if ancestors.include?(name)
      raise ArgumentError, "Circular variant inheritance: #{(ancestors + [name]).join(' -> ')}"
    end

    path = variant_path(name, root)
    data = YAML.safe_load_file(path)
    slug(name, data)
    if name == 'default'
      unless data.is_a?(Hash) && !data.key?('inherits') &&
             %w[cv design locale settings].all? { |key| data[key].is_a?(Hash) } && data['cv']['sections'].is_a?(Hash)
        raise ArgumentError, 'variants/default.yml must contain the full RenderCV configuration, without inherits.'
      end
      return [[path, data]]
    end

    unless data.is_a?(Hash) && data.key?('inherits') && data['sections'].is_a?(Hash) &&
           (data.keys - %w[inherits sections headline slug]).empty?
      raise ArgumentError, 'A variant must contain inherits and a sections mapping, with an optional headline and slug; design, identity, locale, and settings are shared.'
    end

    sources(data['inherits'], root: root, ancestors: ancestors + [name]) + [[path, data]]
  end

  def self.apply_overlay(data, overlay)
    if overlay.key?('headline')
      headline = overlay['headline']
      unless headline.is_a?(String) && !headline.strip.empty? && !headline.include?("\n")
        raise ArgumentError, 'A variant headline must be a nonempty single-line string.'
      end

      # The headline is audience-specific copy shown under the name; contact details stay shared.
      data.fetch('cv')['headline'] = headline.strip
    end

    sections = data.fetch('cv').fetch('sections')
    overlay.fetch('sections').each do |heading, entries|
      raise ArgumentError, "Unknown section #{heading.inspect}; define shared headings in variants/default.yml." unless sections.key?(heading)
      unless entries.is_a?(Array) && !entries.empty?
        raise ArgumentError, "Section #{heading.inspect} must be a nonempty list of RenderCV entries."
      end

      # Replace the whole section, never concatenate bullets or merge array indices.
      # Assignment to an existing key preserves the baseline section order.
      sections[heading] = entries
    end
  end

  def self.compose(name, root: ROOT, directory: File.join(root, 'build', 'variants', name))
    chain = sources(name, root: root)
    data = chain.first.last
    data.delete('slug') # Build metadata, not part of RenderCV's configuration.
    chain.drop(1).each { |_, overlay| apply_overlay(data, overlay) }

    FileUtils.mkdir_p(directory)
    # RenderCV resolves local templates beside its input. Refresh this generated
    # copy on every compose so it cannot become an independently maintained theme.
    template = File.join(directory, 'classic')
    FileUtils.rm_rf(template)
    FileUtils.cp_r(File.join(root, 'classic'), template)
    outputs = data.fetch('settings').fetch('render_command')
    # PDF only (Typst is its required intermediate); never emit Markdown/HTML/PNG.
    outputs['pdf_path'] = 'resume.pdf'
    outputs['typst_path'] = "#{name}.typ"
    %w[markdown html png].each do |kind|
      outputs.delete("#{kind}_path")
      outputs["dont_generate_#{kind}"] = true
    end
    source = File.join(directory, "#{name}.yaml")
    inputs = chain.map { |path, _| path.delete_prefix("#{root}/") }.join(' + ')
    File.write(source, "# GENERATED from #{inputs}; do not edit.\n" + YAML.dump(data))
    source
  end

  def self.pdf_path(name, audited: false)
    return File.join(ROOT, 'build', 'layout-audit', name, 'resume.pdf') if audited

    validate_name(name)
    slugs = names.to_h { |variant| [variant, slug(variant, YAML.safe_load_file(variant_path(variant, ROOT)))] }
    value = slugs.fetch(name)
    owners = slugs.select { |_, other_slug| other_slug == value }.keys
    raise ArgumentError, "Duplicate output slug #{value.inspect}: #{owners.join(', ')}" if owners.size > 1

    File.join(ROOT, 'build', "brandonmathis-#{value}.pdf")
  end

  def self.build_pdf(name)
    path = pdf_path(name)
    build_dir = File.dirname(path)
    FileUtils.mkdir_p(build_dir)
    Dir.mktmpdir('.resume-build-', build_dir) do |directory|
      source = compose(name, directory: directory)
      return false unless system(*RENDER, 'render', source, chdir: ROOT)

      # Publish only a successful render. Staging on the same filesystem allows atomic replacement.
      File.rename(File.join(directory, 'resume.pdf'), path)
    end
    puts "PDF: #{path}"
    path
  end

  def self.render_standalone(source, watch: false)
    Dir.mktmpdir('resume-source-') do |directory|
      args = ['render', source, '--pdf-path', 'build/resume.pdf',
              '--typst-path', File.join(directory, 'resume.typ')]
      args << '--watch' if watch
      system(*RENDER, *args, chdir: ROOT)
    end
  end

  def self.open_pdf(name, audited: false)
    validate_name(name)
    path = pdf_path(name, audited: audited)
    unless File.file?(path)
      command = audited ? "make check-layout #{name}" : "make pdf #{name}"
      raise ArgumentError, "PDF not found: #{path}. Run `#{command}` to generate it."
    end

    launch_preview(path)
  end

  def self.launch_preview(path)
    system('open', '-a', 'Preview', path, chdir: ROOT)
  end

  def self.execute(command, name)
    # Opening existing output must not compose, render, or alter any source.
    return open_pdf(name) if command == 'open'
    if command == 'preview'
      # The audit renders its own fresh PDF; a separate draft render is unnecessary.
      return false unless execute('check-layout', name)

      return open_pdf(name, audited: true)
    end

    case command
    when 'compose'
      puts compose(name)
      true
    when 'pdf'
      build_pdf(name)
    when 'check-layout'
      system('ruby', AUDITOR, '--source', compose(name), chdir: ROOT)
    else
      raise ArgumentError, "Unknown command: #{command}"
    end
  end

  def self.fingerprint(name, root: ROOT)
    paths = sources(name, root: root).map(&:first)
    paths += Dir.glob(File.join(root, 'classic', '**', '*')).select { |path| File.file?(path) }
    paths.sort.map { |path| [path, File.read(path)] }
  end

  def self.watch(name)
    validate_name(name)
    warn "Watching #{name}; rebuilding its draft PDF on edits. Ctrl-C to stop."
    warn "Live output is an unaudited draft; run `make check-layout #{name}` before publishing."
    # Watch actual sources, not generated output. Capture before rendering so
    # edits made during a build are picked up on the next pass.
    previous = nil
    opened_path = nil
    loop do
      begin
        current = fingerprint(name)
        if current != previous
          previous = current
          if (path = execute('pdf', name))
            if path != opened_path
              if launch_preview(path)
                opened_path = path
              else
                warn 'Preview launch failed; still watching for edits.'
              end
            end
            warn "Rebuilt: #{path} (unaudited draft)."
          else
            warn 'Build failed; still watching for corrected edits.'
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
    if %w[pdf-source watch-source].include?(command)
      raise ArgumentError, 'Set SOURCE to a standalone RenderCV YAML file.' if name.to_s.empty? || !extra.empty?

      return render_standalone(name, watch: command == 'watch-source')
    end
    if command == 'list' && name.nil?
      puts names
      return true
    end
    unless name && extra.empty? && %w[compose pdf check-layout watch preview open].include?(command)
      raise ArgumentError, 'Usage: resume_variant.rb list | {compose|pdf|check-layout|watch|preview|open} VARIANT | {pdf-source|watch-source} SOURCE'
    end
    command == 'watch' ? watch(name) : execute(command, name)
  rescue ArgumentError, KeyError, Psych::Exception, SystemCallError => error
    warn "ERROR: #{error.message}"
    false
  end
end

exit(ResumeVariant.run(ARGV) ? 0 : 1) if $PROGRAM_NAME == __FILE__
