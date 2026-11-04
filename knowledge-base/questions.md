# Conflicts, coverage gaps, and next questions

No resume copy was changed during this research. Preserve conflicting records rather than silently choosing the most impressive version.

## Highest-priority factual confirmations

| Question | Why it matters / evidence |
| --- | --- |
| **What exactly were Skylight's engagement start, MVP date, and public launch date?** | LinkedIn says Jan 2025 and 30-day launch; TechCrunch reports Apr 1 public launch after 10 weeks. Could describe different phases, but not yet reconciled. [LINKEDIN, SKYLIGHT_PRESS] |
| **What supports Skylight's 55,000 users / first 24 hours and chart ranks?** | First-party LinkedIn only. Need date, source, whether signups/onboarding/active users, and which store/region/chart. |
| **What is the basis of vTestify's 10× revenue growth?** | Already in baseline; need comparison period, revenue type, team versus personal contribution, and disclosure permission. [BASELINE] |
| **What exactly did Esquire acquire in late 2024, and is there a public/disclosable source?** | LinkedIn says eLitigate product. The independently found 2021 partnership does not establish or disprove a later acquisition. Never infer whole-company acquisition. |
| **Did ECU attendance/graduation end in 2009 or 2010?** | Baseline 2006–2009; LinkedIn 2006–2010. [BASELINE, LINKEDIN] |
| **How should the 2019 and 2024 role overlaps be described?** | Freelance/vTestify and vTestify/This Dot overlap. Could be legitimate transitions/concurrent work; not an error to erase. |
| **How did Savings Seeker Rx (2021–2022) fit into the consulting timeline?** | Project dates lie outside baseline freelance dates. Similar employer attribution questions apply to BWEL and WeaveUp. |
| **What are the accurate founding, organizing, and active dates for each community?** | Triangle Ruby has 2010/2012/2013 starts and 2019 vs present ends; RailsBridge 2018 vs present. Membership start ≠ organizer start. |
| **What did “30+ engineers” mean organizationally?** | Smashing Boxes organizational scope is in baseline, but direct-report count is unspecified. |
| **What are the current active meetup names and your exact role in each?** | Triangle Developers and Triangle.rb have public organizer evidence; Triangle JavaScript and RailsBridge current status not independently verified. |

## Highest-value evidence to add for future resumes

1. **Current AI/SDLC consulting case studies:** client or anonymized context, problem, team size, workflow/tools introduced, direct contribution, before/after cycle time/quality/cost, permission to disclose.
2. **This Dot client specifics:** concrete work for OpenAI, Wikimedia, Primerica, HUDL; distinguish leadership, implementation, review, migration, and enablement.
3. **Skylight ownership:** which native/editor/release/UI components were yours; technical challenge; collaborators; measurable outcome.
4. **Whisper implementation:** when shipped, audio/streaming architecture, speaker channels, quality/latency/cost metrics.
5. **DevOps scope:** actual hosting architecture, observability, incidents, on-call responsibilities, deployment frequency, recovery time; any Kubernetes/Terraform work not found publicly.
6. **Original harness contributions:** which my-pi extensions were original, adapted, or AI-generated; adoption and usability results; any upstream PRs under alternate accounts.
7. **Open-source highlights:** other usernames, direct commits, maintainer roles, high-impact PRs not found by authored-merged search. The two Swift PRs found are setup/docs, not compiler changes.
8. **Public speaking inventory:** event/date/title, recording/slides, whether delivered, audience size, keynote/panel/workshop distinction; older Triangle JavaScript/Ruby/ATO sessions.
9. **Community outcomes:** dated membership counts by platform, events personally organized, workshop attendance/completions, volunteer numbers, sponsorships.
10. **Consulting projects with only logos:** Duke, Adwerx, MAC, Vaco, Castra, BioConnect, Moogfest. Provide specific product, role, stack, dates, outcome.
11. **Forecast:** first release date, current maintenance status, provider migrations, dated workspace/adoption figures.
12. **Skills not yet supported:** React Query, browser extensions, cloud architecture specifics, formal AI evaluation pipelines, vector retrieval, model training. Do not add just because a job ad asks.

## Access and coverage log

- **Personal website:** fetched; mostly positioning and client logos, not detailed case studies.
- **LinkedIn profile and projects:** accessible partial public extraction. Projects and volunteering visible; employment titles/dates largely omitted, recommendations/skills/publications not recovered. The projects URL returned essentially the same profile content.
- **GitHub profile HTML:** extraction yielded boilerplate, replaced with public REST API evidence.
- **GitHub repositories:** two pages; 112 matches profile count. Metadata for all, selected README/code deep dives. No full clone or build of every repository.
- **GitHub merged PRs:** two pages; 141 matches search count, `incomplete_results: false`. Query scoped to authored public merged PRs only.
- **Gists:** one 100-item page returns 78, matching profile count. Metadata only except Watson bot.
- **Medium profile:** HTTP 403. **Public RSS succeeded** and supplied ten full article bodies; this is a feed window, not proof no older articles exist.
- **This Dot author-filter page:** ignored requested author filter in extraction and returned unrelated content; **not used as evidence of Brandon's authorship**. Two direct article pages were used instead.
- **my-pi and claude-agents root READMEs:** returned 404. Repository trees and selected files were retrieved successfully; not treated as missing projects.
- **Triangle Developers website:** partial JS-rendered extraction; community links visible. Public Meetup content also fetched.
- **allthingsopen.ai speaker URL:** HTTP 526. Alternate official 2025 allthingsai.org page succeeded.
- **NC State Applied AI Club page:** HTTP 403; search lead retained, not confirmed appearance.
- **Bandwidth event LinkedIn post:** useful title but body only contains navigation; marked title-only.
- **Videos/podcasts:** saved public post transcripts and ATO written summaries; recordings not watched in this pass.
- **Older references:** frozen resume.tex, original PDFs, and prior Phantom recommendations were not reinterpreted as independent new evidence. Phantom notes were used only as discovery leads; newly retained claims point to actual sources.
- **No private systems accessed:** no private GitHub repositories, email, authenticated LinkedIn export, employer systems, or unrelated local personal files.

## Rejected or narrowed claims

- Same-name results for `imathis`, a dance academic, sales executives, nonprofit leaders, and athletes were not attributed.
- Swift “core” clarified to main-repository **setup/documentation merges**, not compiler internals.
- Oracle's “MCP” comment contradicted by HTTP-fetch implementation; claim narrowed to document-context injection.
- Future “State of AI” appearance on Nov 5, 2026 not counted as delivered as of Nov 4.
- Meme-library talk draft and “enhancements to explore” are not delivered talks or implemented integrations.
- Third-party app growth is not automatically Brandon's personal impact.
- Generic site/publisher search summaries sometimes contradicted available primary evidence; archived for discovery only, never used to settle a fact.
