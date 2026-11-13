# Project and impact dossier

Source IDs resolve in [source-map.yaml](source-map.yaml). This is research, not approved resume copy. “First-party” means Brandon's own resume/profile/post; public visibility alone is not independent verification.

## P01 — eLitigate / vTestify remote depositions

- **Relationship / dates:** Principal Engineer & CTO at vTestify, Aug 2019–Dec 2024. [BASELINE, LINKEDIN]
- **Problem:** remote depositions require testimony, video, exhibits/evidence, and attorney/court-reporter workflows in one platform rather than disconnected generic conferencing tools.
- **Personal/team contribution:** architected and built React/WebRTC deposition software; built real-time multichannel testimony transcription with Web Audio API and OpenAI Whisper; led architecture, development, review, hiring, and team processes. [BASELINE]
- **Business-facing contribution:** partnered with Sales/Product and strategic customers on custom solutions; built enterprise white-label capabilities enabling B2B sales. [BASELINE]
- **Claimed impact:** **10× revenue growth** associated with white-label capabilities. This is an existing resume claim, not an independently audited figure; baseline/period and personal causality need confirmation.
- **Corroborated product context:** Esquire's May 25, 2021 announcement names the vTestify partnership and integrated conferencing, exhibits, sidebar rooms, testimony review, and speech-to-text. It describes a pilot and planned August 2021 commercial release. It does not name Brandon or identify Whisper. [ESQUIRE]
- **Acquisition claim:** LinkedIn says Esquire acquired **eLitigate** in late 2024. No independent acquisition announcement was located. The 2021 partnership announcement neither proves nor disproves a later acquisition. Do not substitute “vTestify acquired.” [LINKEDIN]
- **Partner integrations (independent press, Nov 2026 follow-up):** Stenograph announced an integration of its CaseViewNet real-time transcript viewer directly into vTestify's deposition room on **Oct 26, 2021**, available to “white-labeled or branded” versions of the platform—independent confirmation that a white-label offering existed by then. On **Sep 14, 2022**, Stenograph and vTestify announced an **exclusive technology licensing and go-to-market agreement**; Stenograph's blog later described the licensed platform as **CaseTestify**. Neither release names Brandon. [STENO_2021, STENO_2022, CASETESTIFY, VT_PRESS]
- **Product timeline context:** vTestify's own 2021 recap lists a redesigned video room, noise suppression, video pinning/pop-out, the **vTestify Connect** native iOS app, “Continue as Guest,” the CaseViewNet integration, and enterprise analytics. Team-level product evidence; it does not attribute features to Brandon. [VT_PROGRESS_2021]
- **CTO scope (questionnaire, first-party):** oversaw integration of the product into partner systems at **US Legal, Esquire, and Stenograph**, working directly with those companies' development teams on stack, security capabilities, and integration; attended company leadership meetings and set technical direction; built the hiring process credited with hiring **a team of 15+ people** “before the company was acquired.” Stenograph (2022) and Esquire (2021) partnerships are independently documented; a **US Legal Support** relationship was not found publicly. [QUESTIONNAIRE, STENO_2022, ESQUIRE]
- **Engineering challenges (questionnaire, first-party):** (1) the pandemic-era shift to remote required a very simple onboarding/UX path for non-technical participants; (2) early adoption of **OpenAI SDKs for evidence/information processing plus a vector database for RAG-style search**; (3) demanding performance expectations met with **per-customer isolated environments** (separate database and application runtime per customer) with **autoscaling** configured day by day. These are self-reports; no architecture document, metrics, or dates were retrieved. [QUESTIONNAIRE]
- **People management and Kubernetes (confirmed Nov 13, 2026):** Brandon **managed the engineering staff** and built the full hiring process (15+ hires). He **worked hands-on with Kubernetes when vTestify deployed its software platform into Stenograph's infrastructure**. Whether the per-customer isolated environments above also ran on Kubernetes was not stated. [QUESTIONNAIRE_2026_11_13, QUESTIONNAIRE_2026_11_13_B]
- **Best uses:** full-stack product delivery; real-time/browser media; applied AI; CTO/leadership; customer-facing engineering; partner/enterprise integrations; Kubernetes/platform work.
- **Missing detail:** exact white-label features, revenue period, customers served, transcription latency/accuracy, user/session scale, security/compliance responsibility, acquisition disclosure permission, vector-store/LLM implementation details and dates, hosting platform for the isolated environments, and what “the company was acquired” refers to (see the `elitigate-acquisition` caveat in claims.yaml).

## P02 — HUDL / FastModel Sports

- **Relationship / dates:** embedded Engineering Lead / React subject-matter expert through This Dot Labs; **Oct 2025–Mar 2026** in LinkedIn. [LINKEDIN]
- **Products:** FastDraw, FastScout, FastRecruit; play diagramming, scouting, and recruiting for NCAA/NBA/WNBA users.
- **Contribution:** led web and iOS-to-React Native migration work, shaped architecture, implemented changes, and mentored HUDL engineers on development practices as agentic coding gained traction.
- **Claimed impact:** helped deliver **all three projects on time** during a six-month engagement. First-party account; no independently verified schedule or scope.
- **Independent context:** Hudl completed its acquisition of FastModel Sports on **Mar 11, 2025**, roughly seven months before this engagement; FastModel's suite (FastDraw, FastScout, FastRecruit) serves NBA/WNBA/NCAA programs. This explains the HUDL/FastModel naming but says nothing about This Dot or Brandon. [HUDL_ACQ]
- **Questionnaire detail (first-party):**
  - Acted as **technical project manager** for the legacy-app → React Native migration, verifying one-to-one feature parity against the legacy application.
  - **FastDraw drawing system:** ported a legacy C library (recalled as “Armadillo”) that handled Cartesian-coordinate math and best-fit algorithms (fitting arrays of drawn points to Bézier curves) into **JavaScript**; built a finger-drawing system on iPad that vectorizes strokes into SVG shapes and Bézier lines, infers play semantics (passes, screens, dribbles), and animates plays forward and backward on native and web, using **react-native-svg** and **react-native-reanimated**.
  - Worked directly with a Hudl principal engineer, contributing 2-D math/graphics expertise, to hit a deadline for NCAA/NBA/WNBA coaching staff.
  - Refactored for extensibility so the core Hudl team could add shapes/lines/arrows for other sports (hockey, soccer/European football); reports that this goal was achieved.
  - The library name “Armadillo” is uncertain (the widely known Armadillo is a C++ linear-algebra library); confirm before naming it in copy. [QUESTIONNAIRE]
- **Best uses:** technical lead who still builds; cross-platform modernization; computational geometry/graphics in product UI; client enablement; business-aligned execution.
- **Missing detail:** team size, components personally owned per product, performance/test metrics, actual agent tools/process changes introduced at Hudl, whether the ported library is public.

## P03 — Skylight Social

- **Relationship:** This Dot Labs team working with Skylight founders, not sole founder/CTO or sole developer. [LINKEDIN, EXPO_NATIVE, EXPO_UPDATES]
- **Product:** short-form video social app on **AT Protocol**, with React Native/Expo and a native in-app editor. AT Protocol experience is **not blockchain experience**.
- **Implementation evidence:** Brandon's video transcript describes team use of **Expo Modules SDK** for native Swift/Kotlin integration. A second transcript describes **Expo Updates**, development/review/production channels, and shipping daily changes over the air. [EXPO_NATIVE, EXPO_UPDATES]
- **First-party launch claims:** LinkedIn lists Jan 2025, an MVP launched in **30 days**, **55,000+ users in the first 24 hours**, top-ten free-app and number-one Entertainment placement within 48 hours, and investment from Mark Cuban. [LINKEDIN]
- **Independent context:** TechCrunch's April 1, 2025 article reports public launch after **10 weeks of active development**, founders Tori White and Reed Harmeyer, AT Protocol, in-app editing, and Mark Cuban backing. It does not credit Brandon/This Dot or verify his 30-day/55,000-user claims. [SKYLIGHT_PRESS]
- **Important conflict:** January may indicate engagement start or an earlier MVP rather than public launch; 30 days may refer to the team's engagement rather than total development. This is a hypothesis, not a reconciliation. Confirm before using a dated launch bullet.
- **Origin of the 55,000 figure:** Brandon's public post (“topping the charts on the App Store now”) carries a reshare from Skylight co-founder Victoria (Tori) White stating “Skylight has over 55,000 users in its first 24hrs of launch.” The number therefore originates with the founder, not Brandon, and remains a company claim rather than audited analytics. LinkedIn shows only a relative “1y” timestamp. [SKYLIGHT_POST]
- **Questionnaire:** no additional Skylight detail was provided in the November 2026 answers.
- **Best uses:** mobile delivery, consumer products, native interoperability, release automation, teamwork under time pressure.
- **Missing detail:** exact dates, definition/source of launch metrics, owned features, delivery team size, and which launch milestones belong to which phase.

## P04 — Saving Seeker RX (Savings Seeker Rx) / McKesson / CoverMyMeds

- **Relationship:** McKesson client engagement through **Mathis LLC**, explicitly confirmed by Brandon. Keep both McKesson and this project under Mathis LLC, not vTestify. Brandon calls it **Saving Seeker RX**; LinkedIn uses **Savings Seeker Rx**. [MCKESSON_2026_11_13, LINKEDIN]
- **Dates / overlap:** LinkedIn lists Jan 2021–Dec 2022; the baseline lists Mathis LLC as 2017–2019. Brandon confirms freelance work can overlap vTestify and that this is valid. His clarification settles attribution, not exact dates: retain the historical LinkedIn interval without inventing revised project dates or an overall consulting end date. [LINKEDIN, MCKESSON_2026_11_13]
- **Contribution:** led the project and performed full-stack development; built frontend UI, backend API, and custom integrations cross-referencing medication and pharmacy databases for discount-medication search. [LINKEDIN, MCKESSON_2026_11_13]
- **Cross-functional leadership:** coordinated across departments and verified functionality directly with VP-level stakeholders. [MCKESSON_2026_11_13]
- **Kubernetes / deployment:** worked directly with McKesson's DevOps team to configure and deploy this app in a **secure, HIPAA-compliant healthcare Kubernetes environment**. This is collaborative application deployment, not a claim of cluster ownership. [QUESTIONNAIRE_2026_11_13, QUESTIONNAIRE_2026_11_13_B, MCKESSON_2026_11_13]
- **HIPAA:** handled sensitive patient medical data and pharmaceutical databases. Compliance and deployment are Brandon's first-party account, not an independent compliance audit or personal certification. His Fortune 5 description of McKesson varies by year; date-stamp or omit the rank. [QUESTIONNAIRE_2026_11_13_B, MCKESSON_2026_11_13]
- **Missing detail:** exact engagement dates, implementation stack beyond Kubernetes, adoption/search volume, pricing-data freshness, impact on patient savings.
- **Project URL:** https://www.savingsseekerrx.com/ (listed on LinkedIn; product content not separately inspected).

## P05 — Forecast Slack bot

- **Dates:** LinkedIn lists Dec 2013–Oct 2021; product site and marketplace remained accessible at research time. These dates may describe a work interval rather than product lifetime. [LINKEDIN, FORECAST_SITE]
- **Product:** weather retrieval inside Slack; product site shows Fahrenheit/Celsius support.
- **Attribution:** Slack Marketplace explicitly names **Brandon Mathis** as developer and lists **Google Maps and Apple WeatherKit** as third-party services. [FORECAST_SLACK]
- **Claimed adoption:** installed and used daily by **2,000+ companies worldwide**, according to LinkedIn. No dated analytics snapshot was found.
- **Questionnaire (first-party):** describes long-term maintenance of what he calls “the number 1 installed weather bot for Slack,” a provider migration from **Dark Sky to Apple Weather**, long-running security updates, and daily use by notable workspaces including **Slack, Garmin, and “Rocket Propulsion labs”** (ambiguous—possibly Jet Propulsion Laboratory or Rocket Lab; confirm). Ranking and customer names are unverified and may need permission to cite. [QUESTIONNAIRE]
- **Migration context:** the Dark Sky API shut down on **Mar 31, 2023** and was replaced by Apple WeatherKit, which explains the provider change and brackets its timing; an older third-party listing still describes the bot as Dark Sky-powered. The 2013–Oct 2021 LinkedIn interval therefore cannot be the full maintenance window if the migration happened in 2022–2023. [DARKSKY_SUNSET, FORECAST_SLACK]
- **Best uses:** independently built integration product, external APIs, distribution and maintenance, user-facing utility, provider-migration and long-lived-product stewardship.
- **Guardrails:** don't claim current active usage, paid customers, HIPAA compliance, or 2013 WeatherKit usage. Current provider metadata must not be projected back across the whole listed date range. “#1 weather bot” needs a dated marketplace/category source before it appears in copy.

## P06 — BWEL / Dana-Farber breast-cancer research (Smashing Boxes)

- **Relationship:** Brandon worked with Dana-Farber both as a **Smashing Boxes** employee and later as a **Mathis LLC** consultant (confirmed Nov 13, 2026). Either role can carry the project; it need not appear under both. [QUESTIONNAIRE_2026_11_13, QUESTIONNAIRE_2026_11_13_B, BASELINE]
- **Dates:** Aug 2016–Dec 2017, from LinkedIn; the Dec 2017 end, a month after Smashing Boxes, fits the continued consulting relationship.
- **Product:** web app for communication between research staff/coaches and study participants.
- **Contribution account:** Fitbit integration for participant activity tracking; Twilio browser calling for coaches. [LINKEDIN]
- **HIPAA (confirmed):** the project handled **protected health information under HIPAA**. Brandon was **responsible for standards adherence and protecting patient data**; the team handled and **securely stored patient medical and pharmaceutical data** on **AWS HIPAA infrastructure** and on Dana-Farber's and Duke's **in-house infrastructure**; he received **expert training from Duke and Dana-Farber HIPAA specialists**. [QUESTIONNAIRE_2026_11_13, QUESTIONNAIRE_2026_11_13_B]
- **Best uses:** healthcare/research workflow integration, HIPAA-regulated PHI work, third-party APIs, real-time communication.
- **Scope notes:** team project (“we”); no study results or patient-health outcomes were reported.

## P07 — WeaveUp

- **Dates:** Apr 2015–Apr 2017, from LinkedIn.
- **Product/stack:** Rails, iOS, Angular platform for uploading vector/raster artwork, in-app pattern customization, and ordering printed/woven cloth as described by Brandon. [LINKEDIN]
- **Best uses:** cross-platform commerce and creative tooling, backend/mobile/frontend breadth.
- **Missing detail:** personal role, image-processing responsibilities, order integrations, scale, and measurable delivery impact.

## P08 — Fraqture

- **Dates:** LinkedIn lists Jan 2016–Nov 2017; merged PRs establish contributions as early as **Dec 2015**. Preserve both rather than forcing an artificial single start date.
- **Product:** interactive glitch-art installation associated in the first-party description with the Durham Storefront Project / The Carrack.
- **Artifact evidence:** upstream README describes **Clojure/Quil**, a 50-inch display, **540 DotStar LEDs**, and a Teensy 3.2 controller. It lists a 21C Durham storefront and New Orleans Entrepreneurs Week exhibitions without a clear year. [FRAQTURE]
- **Personally attributable merged changes:** image rotation/randomization (#1), spirograph animation (#2), and Quil blend glitch effect (#19). [MERGED_PRS]
- **Related writing:** “Clojure, A Reflection On My Latest Obsession,” originally Jan 27, 2016, explains image-block swapping and functional/graphics exploration. [MEDIUM]
- **Best uses:** creative technical problem solving, functional programming, interactive systems, cross-disciplinary collaboration.
- **Guardrails:** hardware/platform architecture is project context; personal hardware fabrication or exhibition management is not established.

## P09 — Boomerang

- **Dates:** Feb–Apr 2015.
- **Product:** native iOS/Android group photo sharing, with viewing unlocked after contributing a photo. [LINKEDIN]
- **Status:** first-party project description only; specific implementation responsibilities and outcomes are not available.

## P10 — Packpurchase

- **Dates:** Oct–Dec 2014.
- **Product:** community-focused discounted home-services application using Rails/iOS/Android. [LINKEDIN]
- **Status:** first-party project description only; clarify contribution and impact before drafting accomplishment claims.

## P11 — Assetricity industrial maintenance and P&ID tools

- **Dates:** role spans Jul 2009–Aug 2014.
- **Contribution:** Rails condition-based-maintenance software deployed through JRuby into IBM WebSphere; Ember.js refinery-layout P&ID viewer; XML schemas reflecting ISO standards; participation in standards meetings. [BASELINE]
- **Related narrative:** “Grit” describes an early MIMOSA contract to convert CRIS/CCOM XML, working remotely as the only coder, and delivering against a two-month deadline. This is first-party history; the exact contractual link between MIMOSA and Assetricity is not established. [MEDIUM]
- **Public breadcrumb:** IOM-OG Register prototype repository and XML/JRuby gist metadata. They are historical artifacts, not evidence of production quality. [REPOS, GISTS]

## P12 — Taperole deployment automation

- **Context:** Smashing Boxes public Rails provisioning/deployment toolkit; Ruby gem wrapping Ansible workflows with Ubuntu, Nginx, Puma, PostgreSQL, Redis, TLS, and deployment notifications. [TAPEROLE]
- **Attribution:** **28 merged PRs** by Brandon in the retrieved search. Examples: Postgres backups, Rails 5 support, Ubuntu 16 transition, Redis configuration/performance, Puma deploy repair, certificate-renewal hooks, install/update reliability. [MERGED_PRS]
- **Best uses:** practical DevOps, internal-platform work, repeatable delivery, developer experience. See [open-source.md](open-source.md).
- **Guardrails:** contribution count does not mean sole authorship, maintainer status, or a quantified uptime improvement.

## P13 — Visual Regression Toolkit

- **Artifact:** TypeScript CLI/configuration, Playwright route discovery and screenshot tests, reusable GitHub Actions workflows. README plus selected implementation inspected. [VISUAL_TOOLKIT]
- **Capabilities:** discover supported Next.js routes; desktop/tablet/mobile screenshots; normalize image/font/video readiness; reduce motion; control external requests; pinned Playwright/container versions; baseline artifacts and sticky PR reports.
- **Engineering nuance:** current docs describe screenshot differences/new pages as advisory, while build/server/image and other non-screenshot failures remain errors. It is not accurate to call every visual difference a blocking release gate.
- **Limitations:** unresolved parameterized SSR routes are not automatically covered; README says package is distributed from GitHub, not npm.
- **Best uses:** frontend quality, reusable delivery tooling, CI reproducibility.
- **Missing detail:** adoption across client sites, personal authorship boundaries, measured time/regression reductions.

## P14 — Meme Library / mobile AI-assisted workflow

- **Artifact:** Expo/React Native project; SQLite/native file storage; web-specific storage files in tree; tests; GitHub Actions; EAS updates; PR preview QR/deep links. [MEME_CI, REPOS]
- **Reviewed source:** `sources/code/meme-library/lib/meme-storage.ts.txt` and the commit-pinned CI snapshot; full source URLs are in `sources/code/index.json`.
- **Workflow:** lint, format, type checks, test job, security-audit job, automatic main-branch updates, and PR previews. Deployment dependencies in the inspected workflow are lint/test; security audit is a separate job, and Expo Doctor is commented out. Do not claim every check gates deployment.
- **AI evidence:** public talk draft describes phone-driven Claude Code workflows; numerous PRs reference Claude branches. The inspected CI file handles validation/publication and does not itself prove every code-generation step in the draft. [MEME_TALK, MERGED_PRS]
- **Best uses:** agent-assisted SDLC, mobile CI/CD, device review loops, implementation samples.
- **Guardrails:** side project/talk material, not verified enterprise transformation or confirmed delivered talk.

## P15 — Applied AI and coding-harness projects

See [ai-engineering.md](ai-engineering.md) for the evidence-backed technical breakdown:

- **Watson image-recognition Slack bot (2017):** third-party AI classification API + Slack responses. [WATSON]
- **D&D Oracle:** Anthropic streaming responses, Next.js route, public Google Doc context. [ORACLE, ORACLE_FETCH]
- **my-pi:** planning/execution workflows, fresh-session scheduling, handoffs, todo queues, worktree integration. [MY_PI, PI_LOOP]
- **agent-loop:** shell-driven Pi task iteration; distinct from the my-pi recurring scheduler. [AGENT_LOOP]
- **pi-working-phrase:** small TypeScript TUI extension. [PI_PHRASES]
- **claude-agents / Roo custom modes:** structured review, documentation, pairing, task decomposition, and MCP-assisted configuration. [CLAUDE_AGENTS, ROO]
- **AI Evolution or Revolution:** AI-directed Next.js conference presentation tool. [AI_SLIDES]

## P16 — Primerica (This Dot Labs)

- **Relationship:** This Dot Labs client; Brandon reports operating as **engineering lead** on a Vue front-end team. [BASELINE, QUESTIONNAIRE]
- **Questionnaire (first-party):** built features, kept work items current, handled deployments; collaborated across teams and departments; drove process changes and SDLC improvements; consulted on adherence to Primerica's core front-end (Vue) development guidelines. Led a **large Vue 2 → Vue 3 migration** completed by the requested deadline. Built **customer-facing statement-viewing features** under a tight, event-driven deadline tied to Primerica's **50th-anniversary** event at Mercedes-Benz Stadium.
- **Conflict to resolve:** Primerica's public convention page advertises the 50th-anniversary **2027 International Convention (July 7–10, 2027, Georgia World Congress Center and Mercedes-Benz Stadium)**, which is in the future at the Nov 11, 2026 retrieval date, whereas the answer describes the event in the past tense. The deadline may have been a pre-event release, or a different 2024–2026 Primerica event may be meant. Do not date-stamp this bullet until confirmed. [PRIMERICA_ATL27, QUESTIONNAIRE]
- **Missing detail:** engagement dates, team size, what “statement viewing” covers, migration scope (number of apps/components), disclosure permission.

## P17 — Wikimedia iOS testing (This Dot Labs)

- **Questionnaire (first-party):** worked with the Wikimedia team to **improve their iOS testing suite**, helped **source a contractor** for the project, and supported that contractor directly. [QUESTIONNAIRE]
- **Context, not corroboration:** This Dot's public Wikimedia case study describes a **2022 Vue/VueX/WebdriverIO Wikifunctions** engagement—before Brandon joined—so it is evidence of the employer relationship, not of his iOS work. Wikimedia's iOS test suite is public (`wikimedia/wikipedia-ios`), but no merged PR by Brandon to it appears in the retrieved search; his Wikipedia-iOS fork remains fork-only evidence. [THISDOT_WIKIMEDIA, REPOS, MERGED_PRS]
- **Missing detail:** dates, which test layers (unit/UI), measurable results, contractor's public contributions, disclosure permission.

## P18 — OpenAI (This Dot Labs)

- Brandon states the OpenAI work is **confidential**; no description is available and none should be invented. Keep the client name only as the baseline already uses it. Separately, he hosted an OpenAI technical lead on The Context Window podcast (GPT Sites episode), which is public content, not client work. [QUESTIONNAIRE, BASELINE, CONTEXT_WINDOW]

## P19 — Duke medication-tracking app (Smashing Boxes)

- **Questionnaire (first-party):** built a **mobile application for a Duke pharmaceutical research team to help patients track their medication**. [QUESTIONNAIRE, WEBSITE]
- **Relationship and compliance (confirmed Nov 13, 2026):** Brandon worked with Duke both as a **Smashing Boxes** employee and later as a **Mathis LLC** consultant; the baseline's freelance listing of Duke Health is accurate. The app handled **protected health information under HIPAA**; his HIPAA responsibilities are described under P06. [QUESTIONNAIRE_2026_11_13, QUESTIONNAIRE_2026_11_13_B, BASELINE]
- **Missing detail:** app dates, platform, study name, and outcomes.

## P20 — BioConnect / Bank of Montreal integration

- **Questionnaire (first-party):** traveled to Toronto as a **subject-matter expert** to help BioConnect connect its **Ruby on Rails** application to an **IBM-run Oracle database** for a biometric-authentication integration into the Bank of Montreal mobile app, delivered in partnership with IBM; also **mentored BioConnect team members** on full-stack development practices. [QUESTIONNAIRE]
- **Independent context:** BMO, BioConnect, and IBM Canada announced the biometric authentication platform for BMO Online Banking for Business and the BMO Banking for Business Mobile App on **Oct 22, 2018**, inside Brandon's freelance interval. The release does not name Brandon or any contractor. [BMO_BIOCONNECT]
- **Guardrails:** describe as consulting on a Rails/Oracle integration within a larger BMO/IBM program; do not claim ownership of BMO's biometric platform.

## Other associations needing project details

The baseline or website also names **Adwerx, MAC Cosmetics, Vaco, Castra, and Moogfest**. Brandon named Moogfest as worth expanding but supplied no description; a public search found Moogfest apps credited to other vendors, so keep it as a logo-level association. Keep these as relationship evidence, not fabricated case studies. [BASELINE, WEBSITE, QUESTIONNAIRE]

Public TeamAttain EPA prototype PRs show backend air-quality endpoints, serialization, Nginx roles, and frontend location/air-quality UI. They are attributable contributions, but contract/customer context and production deployment are unknown. [MERGED_PRS]
