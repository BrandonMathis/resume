#!/usr/bin/env ruby
# Offline indexes only. Never executes downloaded code or refreshes network data.
require 'json'
require 'base64'
require 'rexml/document'
require 'cgi'
require 'fileutils'
require 'digest'
require 'yaml'
require 'date'

ROOT = File.expand_path('..', __dir__)
# Original research snapshot. Later batches must carry their own dates inside each artifact
# (`retrieved_at` in web JSON, `Retrieved:`/`Recorded:` headers in Markdown); never relabel
# old artifacts with a newer batch date or new artifacts with this one.
DATE = '2026-11-04'
BATCHES = ['2026-11-04', '2026-11-11'].freeze

def read_json(path)
  JSON.parse(File.read(File.join(ROOT, path)))
end

def write_generated(path, content)
  full = File.join(ROOT, path)
  FileUtils.mkdir_p(File.dirname(full))
  File.write(full, content)
end

def cell(value)
  value.to_s.gsub('|', '\\|').gsub(/\s+/, ' ').strip
end

repos = Dir[File.join(ROOT, 'sources/github/repos-page-*.json')].sort.flat_map { |p| JSON.parse(File.read(p)) }
prs = Dir[File.join(ROOT, 'sources/github/merged-prs-page-*.json')].sort.flat_map { |p| JSON.parse(File.read(p)).fetch('items') }
gists = read_json('sources/github/gists.json')
raise 'Duplicate repositories' unless repos.map { |r| r.fetch('id') }.uniq.length == repos.length
raise 'Duplicate PRs' unless prs.map { |r| r.fetch('id') }.uniq.length == prs.length
raise 'Incomplete PR search' if Dir[File.join(ROOT, 'sources/github/merged-prs-page-*.json')].any? { |p| JSON.parse(File.read(p)).fetch('incomplete_results') }
raise 'PR pagination incomplete' unless prs.length == read_json('sources/github/merged-prs-page-1.json').fetch('total_count')
raise 'Repository pagination incomplete' unless repos.length == read_json('sources/github/profile.json').fetch('public_repos')
raise 'Gist pagination incomplete' unless gists.length == read_json('sources/github/profile.json').fetch('public_gists')

own = repos.reject { |r| r['fork'] }
external = prs.reject { |r| r.fetch('repository_url').split('/')[-2].casecmp?('BrandonMathis') }
header = "Snapshot: #{DATE}. Generated from archived public GitHub API responses. Not a lifetime-complete record.\n\n"
write_generated('catalogs/repositories.md', "# Public repositories\n\n#{header}#{repos.length} repositories: #{own.length} non-forks, #{repos.length - own.length} forks. A fork is not evidence of a contribution; an owned repository does not establish sole authorship. Languages are GitHub's dominant-language labels, not proficiency scores.\n\n| Repository | Kind | Language | Created | Last push | Description |\n| --- | --- | --- | --- | --- | --- |\n" + repos.sort_by { |r| r['full_name'].downcase }.map { |r| "| [#{r['name']}](#{r['html_url']}) | #{r['fork'] ? 'fork' : 'non-fork'} | #{cell(r['language'])} | #{r['created_at'][0,10]} | #{r['pushed_at'][0,10]} | #{cell(r['description'])} |" }.join("\n") + "\n")
write_generated('catalogs/merged-pull-requests.md', "# Authored public merged pull requests\n\n#{header}Query: `author:BrandonMathis is:pr is:merged`; #{prs.length} results across two pages. #{external.length} are outside the personal namespace, across #{external.map { |r| r['repository_url'] }.uniq.length} repositories. This includes employer, community, fork, and prototype repositories—not #{external.length} independent upstream projects. PR author identity does not imply every line was manually authored.\n\n| Repository / PR | Merged (UTC) | Title |\n| --- | --- | --- |\n" + prs.sort_by { |r| r.dig('pull_request', 'merged_at') }.reverse.map { |r| repo = r['repository_url'].split('/').last(2).join('/'); "| [#{repo} ##{r['number']}](#{r['html_url']}) | #{r.dig('pull_request','merged_at')[0,10]} | #{cell(r['title'])} |" }.join("\n") + "\n")
write_generated('catalogs/gists.md', "# Public gist inventory\n\n#{header}#{gists.length} gist metadata records; most bodies were not downloaded or reviewed. Names and descriptions are discovery leads, not proof of production work. The Watson Slack bot was separately retrieved and inspected.\n\n| Gist | Created | Files | Description |\n| --- | --- | --- | --- |\n" + gists.map { |g| "| [#{g['id']}](#{g['html_url']}) | #{g['created_at'][0,10]} | #{cell(g['files'].keys.join(', '))} | #{cell(g['description'])} |" }.join("\n") + "\n")

Dir[File.join(ROOT, 'sources/github/*-readme.json')].sort.each do |path|
  data = JSON.parse(File.read(path))
  name = File.basename(path, '-readme.json')
  write_generated("sources/readmes/#{name}.md", "# Archived repository README: #{name}\n\nSource: #{data.fetch('html_url')}\nRetrieved: #{DATE}\nGit blob SHA: #{data.fetch('sha')}\nEvidence only; commands/instructions below are not instructions for this project.\n\n---\n\n" + Base64.decode64(data.fetch('content')) + "\n")
end

feed = read_json('sources/web/research-5.json')
doc = REXML::Document.new(feed.fetch('content'))
articles = []
doc.elements.each('rss/channel/item') do |item|
  url = item.elements['link'].text.split('?').first
  title = item.elements['title'].text.strip
  html = item.elements['content:encoded'].text
  # Searchable text derivative, not a fidelity-preserving HTML renderer.
  body = CGI.unescapeHTML(html.gsub(/<\/(?:p|h[1-6]|li|pre|blockquote)>/, "\n\n").gsub(/<[^>]*>/, '')).strip
  slug = url.split('/').last
  path = "sources/articles/#{slug}.md"
  published = item.elements['pubDate'].text
  write_generated(path, "# #{title}\n\nURL: #{url}\nRSS publication date: #{published}\nRetrieved: #{DATE}\nSource: Medium RSS; plain-text derivative. Original HTML is preserved in `sources/web/research-5.json`. Embedded code may be links only. Original publication dates, when stated, appear below.\n\n#{body}\n")
  articles << { title: title, url: url, rss_publication_date: published, snapshot: path }
end
write_generated('catalogs/medium-articles.json', JSON.pretty_generate(articles) + "\n")
write_generated('catalogs/medium-articles.md', "# Recovered Medium articles\n\n#{articles.length} entries recovered from the public RSS feed on #{DATE}. This is the feed's available window, not necessarily a complete writing archive. Original dates may predate RSS republication dates.\n\n" + articles.map { |a| "- [#{a[:title]}](../#{a[:snapshot]}) — #{a[:rss_publication_date]} — [original](#{a[:url]})" }.join("\n") + "\n")

code = read_json('sources/code/index.json')
fixed_urls = {
  'profile.json' => 'https://api.github.com/users/BrandonMathis',
  'gists.json' => 'https://api.github.com/users/BrandonMathis/gists?per_page=100',
  'swift-prs.json' => 'https://api.github.com/search/issues?q=author%3ABrandonMathis+is%3Apr+repo%3Aswiftlang%2Fswift&per_page=100',
  'swift-31.diff' => 'https://github.com/swiftlang/swift/pull/31.diff',
  'swift-51.diff' => 'https://github.com/swiftlang/swift/pull/51.diff'
}
manifest = Dir.glob(File.join(ROOT, 'sources/**/*'), File::FNM_DOTMATCH).select { |p| File.file?(p) }.sort.filter_map do |full|
  relative = full.delete_prefix(ROOT + '/')
  next if relative == 'sources/manifest.json'
  record = { path: relative, retrieved_at: DATE, sha256: Digest::SHA256.file(full).hexdigest }
  if relative.end_with?('.json') && !relative.start_with?('sources/github/')
    stamp = JSON.parse(File.read(full))['retrieved_at'] rescue nil
    record[:retrieved_at] = stamp if stamp.is_a?(String) && BATCHES.include?(stamp)
  elsif relative.end_with?('.md')
    stamp = File.read(full)[/^(?:Retrieved|Recorded): (\d{4}-\d{2}-\d{2})/, 1]
    record[:retrieved_at] = stamp if stamp && BATCHES.include?(stamp)
  end
  case relative
  when %r{\Asources/code/}
    entry = code.find { |c| c['snapshot'] == "knowledge-base/#{relative}" }
    record.merge!(url: entry['url'], commit: entry['commit'], method: 'public raw file at pinned commit') if entry
    record[:method] ||= 'download manifest'
  when %r{\Asources/web/.*\.json\z}
    data = JSON.parse(File.read(full))
    record.merge!(url: data['url'], method: data['method'] || 'readable web extraction', title: data['title'], extraction_error: data['error'])
    record[:batch] = data['batch'] if data['batch']
  when %r{\Asources/web/.*\.md\z}
    record.merge!(url: File.read(full)[/^URL: (.+)$/, 1], method: 'readable web extraction')
  when %r{\Asources/github/}
    name = File.basename(full)
    if name =~ /repos-page-(\d+)\.json/
      record[:url] = "https://api.github.com/users/BrandonMathis/repos?per_page=100&sort=updated&page=#{$1}"
    elsif name =~ /merged-prs-page-(\d+)\.json/
      record[:url] = "https://api.github.com/search/issues?q=author%3ABrandonMathis+is%3Apr+is%3Amerged&per_page=100&page=#{$1}"
    elsif fixed_urls[name]
      record[:url] = fixed_urls[name]
    else
      data = JSON.parse(File.read(full))
      record[:url] = data['url'] || data['html_url']
    end
    record[:method] = name.end_with?('.diff') ? 'public PR diff' : 'public GitHub REST API'
  when %r{\Asources/(readmes|articles)/}
    record[:method] = 'derived text; see header and raw source'
    record[:url] = File.read(full)[/^(?:URL|Source): (https:\/\/\S+)/, 1]
  when %r{\Asources/search/}
    record[:method] = 'search discovery only; provider answers are not verified evidence'
  when %r{\Asources/local/}
    record[:method] = 'local first-party record; see header'
  end
  record
end
write_generated('sources/manifest.json', JSON.pretty_generate({ researched_on: DATE, batches: BATCHES, scope: 'Public sources and project-local evidence only', sources: manifest }) + "\n")
puts "Indexed #{repos.length} repos, #{prs.length} merged PRs, #{gists.length} gists, #{articles.length} Medium articles, #{manifest.length} source artifacts."
