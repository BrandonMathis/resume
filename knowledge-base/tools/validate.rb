#!/usr/bin/env ruby
# Offline integrity checks. No downloaded code is executed and no network is used.
require 'json'
require 'yaml'
require 'digest'
require 'pathname'

root = File.expand_path('..', __dir__)
errors = []
check = ->(condition, message) { errors << message unless condition }
json = ->(relative) { JSON.parse(File.read(File.join(root, relative))) }
yaml = ->(relative) { YAML.safe_load(File.read(File.join(root, relative))) }
inside = ->(path) { path.start_with?(root + File::SEPARATOR) }

begin
  source_map = yaml.call('source-map.yaml')
  sources = source_map.fetch('sources')
  claims_document = yaml.call('claims.yaml')
  claims = claims_document.fetch('claims')
  manifest = json.call('sources/manifest.json')
  check.call(source_map['researched_on'] == claims_document['researched_on'], 'Research dates differ')
  check.call(manifest['researched_on'] == claims_document['researched_on'], 'Manifest research date differs')
  check.call(sources.is_a?(Hash) && !sources.empty?, 'Missing source map')
  check.call(claims.is_a?(Array) && !claims.empty?, 'Missing claims')
  ids = claims.map { |c| c.fetch('id') }
  check.call(ids.uniq.length == ids.length, 'Duplicate claim IDs')
  allowed = %w[artifact_backed first_party corroborated_context conflicted scheduled draft]

  sources.each do |id, source|
    path = File.expand_path(source.fetch('path'), root)
    check.call(inside.call(path), "Source path escapes knowledge base: #{id}")
    check.call(File.file?(path) && File.size?(path), "Missing/empty source: #{id} -> #{source['path']}")
    check.call(source['kind'].is_a?(String) && !source['kind'].empty?, "Missing source kind: #{id}")
  end
  claims.each do |claim|
    id = claim.fetch('id')
    %w[statement caveat].each { |key| check.call(claim[key].is_a?(String) && !claim[key].strip.empty?, "#{id}: missing #{key}") }
    check.call(allowed.include?(claim['evidence']), "#{id}: unknown evidence status")
    check.call([true, false].include?(claim['needs_confirmation']), "#{id}: confirmation must be boolean")
    check.call(claim['tags'].is_a?(Array) && !claim['tags'].empty?, "#{id}: missing tags")
    refs = claim.fetch('sources')
    check.call(refs.is_a?(Array) && !refs.empty?, "#{id}: missing sources")
    refs.each { |ref| check.call(sources.key?(ref), "#{id}: unknown source #{ref}") }
    if %w[conflicted scheduled draft].include?(claim['evidence'])
      check.call(claim['needs_confirmation'], "#{id}: nonfinal claim must need confirmation")
    end
  end

  # Curated documents only: third-party archived Markdown may legitimately contain dead links.
  Dir[File.join(root, '*.md')].each do |path|
    content = File.read(path)
    check.call(!content.include?("\0"), "NUL byte in #{path}")
    content.scan(/\[([A-Z][A-Z0-9_]*(?:, [A-Z][A-Z0-9_]*)*)\]/).flatten.each do |group|
      group.split(', ').each { |ref| check.call(sources.key?(ref), "#{File.basename(path)}: unknown evidence ID #{ref}") }
    end
    content.scan(/\]\(([^)]+)\)/).flatten.each do |target|
      next if target.match?(/\A(?:https?:|mailto:|#)/)
      local = target.split('#').first
      check.call(File.exist?(File.expand_path(local, File.dirname(path))), "#{File.basename(path)}: broken local link #{target}")
    end
  end

  entries = manifest.fetch('sources')
  manifest_paths = entries.map { |e| e.fetch('path') }
  check.call(manifest_paths.uniq.length == manifest_paths.length, 'Duplicate manifest paths')
  entries.each do |entry|
    path = File.expand_path(entry.fetch('path'), root)
    check.call(inside.call(path), "Manifest path escapes knowledge base: #{entry['path']}")
    if File.file?(path)
      check.call(Digest::SHA256.file(path).hexdigest == entry.fetch('sha256'), "Hash mismatch: #{entry['path']}; rebuild indexes after intentional updates")
      check.call(File.size?(path), "Empty artifact: #{entry['path']}")
    else
      errors << "Missing manifest artifact: #{entry['path']}"
    end
    check.call(entry['method'].is_a?(String), "Missing provenance method: #{entry['path']}")
  end
  actual = Dir.glob(File.join(root, 'sources/**/*'), File::FNM_DOTMATCH).select { |p| File.file?(p) }.map { |p| p.delete_prefix(root + '/') }.reject { |p| p == 'sources/manifest.json' }
  check.call(actual.sort == manifest_paths.sort, 'Source manifest coverage mismatch (including hidden directories)')

  profile = json.call('sources/github/profile.json')
  repos = Dir[File.join(root, 'sources/github/repos-page-*.json')].flat_map { |p| JSON.parse(File.read(p)) }
  pages = Dir[File.join(root, 'sources/github/merged-prs-page-*.json')].map { |p| JSON.parse(File.read(p)) }
  prs = pages.flat_map { |p| p.fetch('items') }
  check.call(repos.length == profile.fetch('public_repos'), 'Incomplete repository inventory')
  check.call(repos.map { |r| r['id'] }.uniq.length == repos.length, 'Duplicate repository IDs')
  check.call(prs.length == pages.first.fetch('total_count'), 'Incomplete merged PR inventory')
  check.call(prs.map { |p| p['id'] }.uniq.length == prs.length, 'Duplicate PR IDs')
  check.call(pages.none? { |p| p.fetch('incomplete_results') }, 'GitHub search marked incomplete')
  prs.each do |pr|
    check.call(pr.dig('user', 'login') == 'BrandonMathis', "Unexpected PR author: #{pr['html_url']}")
    check.call(pr.dig('pull_request', 'merged_at'), "Unmerged PR in merged inventory: #{pr['html_url']}")
  end
  check.call(json.call('sources/github/gists.json').length == profile.fetch('public_gists'), 'Incomplete gist inventory')
  %w[swift-31 swift-51 circleci-40 api-docs-388 api-docs-400].each do |name|
    pr = json.call("sources/github/#{name}.json")
    check.call(pr['merged'] == true && pr.dig('user', 'login') == 'BrandonMathis', "Invalid inspected PR attribution: #{name}")
  end
  code = json.call('sources/code/index.json')
  code.each do |entry|
    path = entry.fetch('snapshot').delete_prefix('knowledge-base/')
    check.call(File.file?(File.join(root, path)), "Missing pinned source: #{path}")
    check.call(entry['status'] == 'retrieved', "Failed pinned source: #{path}")
    check.call(entry['commit'].match?(/\A[0-9a-f]{40}\z/) && entry['url'].include?("/#{entry['commit']}/"), "Unpinned source: #{path}")
    check.call(path.end_with?('.txt'), "Code snapshot should be inert text: #{path}")
    commit = json.call("sources/github/#{entry.fetch('repo')}-commit.json")
    check.call(commit['sha'] == entry['commit'] && commit['commit'].is_a?(Hash), "Unverified commit ID: #{path}")
    tree = json.call("sources/github/#{entry.fetch('repo')}-tree.json")
    check.call(tree['truncated'] == false, "Truncated code tree: #{path}")
    blob = tree.fetch('tree').find { |item| item['path'] == entry['path'] }
    bytes = File.binread(File.join(root, path))
    git_sha = Digest::SHA1.hexdigest("blob #{bytes.bytesize}\0" + bytes)
    check.call(blob && blob['sha'] == git_sha, "Source differs from GitHub blob: #{path}")
  end
  # Parse every JSON artifact, including nested source snapshots.
  Dir.glob(File.join(root, '**/*.json'), File::FNM_DOTMATCH).each { |path| JSON.parse(File.read(path)) }
rescue KeyError, TypeError, ArgumentError, Psych::Exception, JSON::ParserError, Errno::ENOENT => e
  errors << "Validation blocked: #{e.class}: #{e.message}"
end

if errors.empty?
  puts "PASS: #{claims.length} claims, #{sources.length} source IDs, #{entries.length} hashed source artifacts, #{code.length} pinned files."
  puts 'Public inventory coverage and local references validated. No external project tests or resume/PDF changes performed.'
else
  warn errors.map { |error| "FAIL: #{error}" }.join("\n")
  exit 1
end
