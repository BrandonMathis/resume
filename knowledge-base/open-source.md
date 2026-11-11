# Open-source contribution evidence

## Snapshot and attribution

GitHub query `author:BrandonMathis is:pr is:merged`, retrieved Nov 4, 2026:
- **141** authored public merged PRs, all two pages retained.
- **76** outside the personal namespace, across **28 repositories**.
- Includes employer/community projects, forks, prototypes, and a revert. This is not “76 major upstream features.”
- Repository inventory: **112**, of which **44 are forks**. Forks are not contribution proof.
- Direct commits, coauthored work, unmerged submissions, deleted/private repositories, and non-GitHub work are not covered comprehensively.

Full searchable list: [catalogs/merged-pull-requests.md](catalogs/merged-pull-requests.md). Original API responses: `sources/github/merged-prs-page-{1,2}.json`.

## Main Swift repository — two verified merges

| PR | Scope | Merge date (UTC) | Detail |
| --- | --- | --- | --- |
| [swiftlang/swift #31](https://github.com/swiftlang/swift/pull/31) | Simplify obtaining Swift sources | Dec 11, 2015 | Source-checkout/bootstrap helper and README updates; 2 changed files, +46/−25 in API metadata. [SWIFT_31] |
| [swiftlang/swift #51](https://github.com/swiftlang/swift/pull/51) | README structure/styles | Mar 9, 2016 | Descriptive headers and Swift logo; 1 changed file, +16/−6. [SWIFT_51] |

Both full PR records explicitly identify `BrandonMathis` and `merged: true`; diffs are archived alongside them.

**Precise claim:** contributed merged source-setup tooling and documentation improvements to the main Swift language repository.

**Do not claim:** Swift compiler implementation, language/runtime feature development, Swift core-team membership, or significant compiler architecture work. “Merged into Swift core” is understandable as a repository-level statement but too ambiguous for a resume without this scope.

Brandon's own Nov 2026 description—“a PR to Swift programming language build tooling”—matches this scope, and he named no other missing maintainer roles or developer tools. [QUESTIONNAIRE]

## Sustained DevOps work — Smashing Boxes Taperole

**28 merged PRs** in the retrieved public search. The toolkit handles Rails infrastructure provisioning/deployment through Ruby and Ansible. [TAPEROLE, MERGED_PRS]

Selected attributable changes:
- [#95 — Postgres backups](https://github.com/smashingboxes/taperole/pull/95), May 25, 2016.
- [#100 — Rails 5](https://github.com/smashingboxes/taperole/pull/100), Mar 14, 2017.
- [#104 — Ubuntu 16](https://github.com/smashingboxes/taperole/pull/104), Sep 28, 2016.
- [#122 — Redis performance enhancements](https://github.com/smashingboxes/taperole/pull/122), Mar 8, 2017.
- [#126 — deployment/Puma repair](https://github.com/smashingboxes/taperole/pull/126), Mar 21, 2017.
- [#131](https://github.com/smashingboxes/taperole/pull/131) and [#133](https://github.com/smashingboxes/taperole/pull/133) — Nginx/certbot renewal behavior, Apr/Jul 2017.
- [#87 — deployer authorized_keys assignment](https://github.com/smashingboxes/taperole/pull/87), Mar 3, 2016.
- [#90 — Travis testing](https://github.com/smashingboxes/taperole/pull/90), Mar 30, 2016.

PR titles and merged status support these contribution topics; not all patches were individually audited. For a detailed interview story, read the exact PR diff first. “Redis performance enhancements” is a title, not a measured throughput claim.

## Other independently merged contributions

| Project | Concrete contribution | Evidence |
| --- | --- | --- |
| CircleCI public Ruby orb | IPv4 keyserver change fixing GPG import/RVM setup issue; merged Jul 8, 2020 | [#40](https://github.com/CircleCI-Public/ruby-orb/pull/40), full PR inspected [CIRCLECI] |
| RSpec API Documentation | API Blueprint handling of optional parameters; merged Aug 14, 2018 | [#388](https://github.com/zipmark/rspec_api_documentation/pull/388), full PR inspected [API_DOCS_388] |
| RSpec API Documentation | API Blueprint route grouping fix; merged Sep 17, 2018 | [#400](https://github.com/zipmark/rspec_api_documentation/pull/400), full PR inspected [API_DOCS_400] |
| Better Errors | binding_of_caller warning | [#59](https://github.com/BetterErrors/better_errors/pull/59), Dec 15, 2012 |
| Oracle enhanced ActiveRecord adapter | README fixes | [#303](https://github.com/rsim/oracle-enhanced/pull/303), Apr 11, 2013 |
| IMDb Ruby library | Encoding conversion change | [#53](https://github.com/ariejan/imdb/pull/53), Jan 31, 2014 |
| RedditKit.rb | Middleware warning fix | [#18](https://github.com/samsymons/RedditKit.rb/pull/18), Jan 29, 2014 |
| Orientation | Emoji support; dotenv configuration | [#135](https://github.com/orientation/orientation/pull/135), [#134](https://github.com/orientation/orientation/pull/134), 2015 |
| Dracula theme | Ruby instance-variable highlighting | [#105](https://github.com/dracula/dracula-theme/pull/105), Oct 29, 2015 |
| Vim CoffeeScript | Haml `:coffee` syntax highlighting | [#81](https://github.com/kchmck/vim-coffee-script/pull/81), Feb 24, 2012 |
| vim-rspec | rbenv guidance | [#20](https://github.com/skwp/vim-rspec/pull/20), Aug 15, 2012 |
| vim-flavored-markdown | Named Markdown code-delimiter syntax | [#20](https://github.com/jtratner/vim-flavored-markdown/pull/20), Aug 19, 2016 |
| Globalize | Code Climate badge/configuration-related README contribution | [#293](https://github.com/globalize/globalize/pull/293), Nov 1, 2013 |

Except where “full PR inspected” is stated, this table is based on public PR search metadata/title and merge timestamp. See [MERGED_PRS]. Avoid inflating documentation/theme fixes into core-library feature development.

## Employer, creative, and community contributions

- **Fraqture:** 3 merged animation/glitch-art PRs, Dec 2015–Jan 2016. [FRAQTURE, MERGED_PRS]
- **Smashing Boxes boxcar generator:** 6 merged PRs including RuboCop/Rails cops, Ruby target version, coverage default, and ignore rules. [MERGED_PRS]
- **TeamAttain EPA prototype:** 9 backend and 2 frontend merged PRs; air-quality APIs, serialization, location handling, and UI. Production/client context unknown. [MERGED_PRS]
- **Triangle Developers policies:** 3 merged PRs involving announcements, administrators, and DevOps attribution; Triangle.rb policy and site updates also present. These are concrete governance/maintenance evidence. [MERGED_PRS]
- **This Dot tech-community-slacks:** corrected Triangle Developers Slack link, merged May 26, 2023. [MERGED_PRS]

## Personal public tooling

See [projects.md](projects.md) and [ai-engineering.md](ai-engineering.md) for my-pi, agent-loop, pi-working-phrase, visual-regression-toolkit, meme-library, Oracle, and websynth.

Their existence is directly inspectable; widespread adoption, major-star popularity, sole authorship, and commercial impact are not established. Do not treat a personal repository merge as an independent maintainer accepting an upstream contribution.
