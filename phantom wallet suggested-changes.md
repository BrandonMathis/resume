# Suggested Resume Changes for Phantom

**Target role:** [Senior Software Engineer, Frontend](https://jobs.ashbyhq.com/phantom/e7b83c02-55c2-4037-9209-93deb3b7492c)

**Resume reviewed:** `/Users/brandonmathis/Downloads/Brandon Resume 2026 pjs.pdf`

## Overall assessment

You have a credible background for this role. The main problem is positioning: the resume reads as **engineering manager/former CTO**, while Phantom needs to quickly see **hands-on frontend engineer who ships polished products**.

Your strongest application narrative is:

> A hands-on product engineer who has shipped real-time browser applications and a rapidly launched consumer app, brings substantial community experience, and can own difficult frontend work without needing a management position.

Not:

> Former CTO with broad management experience interested in crypto.

The recommendations below are based on the resume, job posting, LinkedIn, and relevant public work. Suggested bullets must be checked against your actual contribution, permission to disclose, and supporting metrics before use.

## 1. Fix the PDF before submitting

The reviewed PDF is image-based. Text extraction returned no resume text, and its rendered pages contain images of document pages. This can impair application-system parsing, searching, and accessibility.

- Export directly from the original document to a text-based PDF.
- Confirm that you can select and copy a paragraph afterward.
- Fix pagination so entries are not split awkwardly.

This is the most immediately actionable improvement.

## 2. Make the frontend fit obvious at the top

| What Phantom wants | Relevant evidence | What needs improvement |
| --- | --- | --- |
| React, TypeScript, React Query | React applications, current TypeScript projects, Next.js writing | These are not prominent in the resume; React Query experience is unconfirmed |
| Ownership of user-facing features | eLitigate, Skylight, consulting projects | Describe features you personally implemented |
| New products and integrations | WebRTC, transcription, AT Protocol, native integrations | Connect implementation to shipped outcomes |
| Direct engagement with users/developers | Customer partnership and technical education | Show how feedback changed the product |
| Open/community-driven platforms | Triangle Developers, AT Protocol work, public tooling | Keep this strength, but compress it |
| Blockchain experience—nice to have | Not established from the material reviewed | Do not invent it or let its absence dominate the application |

### Suggested headline

**Senior Software Engineer | React · TypeScript · Real-Time Applications**

Keep actual employment titles unchanged. This headline describes professional focus, not a replacement job title.

### Suggested summary

> Hands-on software engineer and engineering lead with 15+ years delivering web and mobile products. Built React and WebRTC applications for the legal industry and helped launch Skylight Social on the AT Protocol. Combines product delivery, customer collaboration, and technical leadership with extensive developer-community involvement.

If accurate to your intentions, add:

> Interested in a senior individual-contributor role owning user-facing features from design through production.

This addresses a likely reviewer question: **Does this former CTO actually want to write frontend code?**

## 3. Add Skylight

Your LinkedIn describes helping build and launch Skylight's MVP in **30 days**, with **55,000 users onboarding in the first 24 hours**. This is stronger evidence than a general statement about leading teams through complex refactors.

It connects to Phantom through consumer-product delivery, rapid iteration, and an open protocol. **AT Protocol is not blockchain experience**, but it is relevant platform experience.

Your public posts also describe [Expo Updates](https://www.linkedin.com/posts/mathisbrandon_reactnative-mobile-react-activity-7335765375751540738-YtL_) and [native video-editor integration](https://www.linkedin.com/posts/mathisbrandon_expo-reactnative-mobile-activity-7344414426592079872-RkMa).

### Suggested bullets under This Dot Labs

These preserve team attribution. Confirm your exact ownership and the launch metrics before using them:

- Helped build and launch Skylight Social's React Native/Expo MVP on the AT Protocol in 30 days; the app onboarded 55,000+ users in its first 24 hours.
- Helped implement native in-app video editing using Expo Modules to integrate Swift and Kotlin functionality into the React Native application.
- Helped introduce Expo Updates release channels for development, review, and production, enabling daily JavaScript hotfixes without waiting for app-store review.

However, **this is a web/extension role, not primarily a mobile role**. Put an equally concrete recent React web achievement before these if you have one.

Use this structure, replacing every placeholder with a verified detail:

> Implemented **[specific user-facing feature]** in **[React/TypeScript project]**, resolving **[technical challenge]** and improving **[measured outcome]**.

The current list of impressive clients establishes credibility, but not what you personally built.

## 4. Rewrite experience around implementation, not responsibilities

### This Dot Labs

Current bullet:

> Manager of mobile engineering team: mentoring, performing reviews and conducting one on ones

Keep leadership, but give it less space. For this application, order the section around:

1. Recent hands-on React web delivery.
2. Skylight launch and implementation.
3. A difficult technical improvement with an outcome.
4. Mentoring, code review, and hiring.

Reduce AI-speaking material to one short line unless it demonstrates a specific engineering result. **React architecture and product delivery should outrank general AI enablement for this opening.**

### vTestify

This is strong experience, but the frontend work is obscured by the CTO title and a broad language list.

Suggested wording, grounded in the resume and LinkedIn:

- Architected and built eLitigate, a React/WebRTC remote-deposition platform combining browser-based videoconferencing and evidence management.
- Implemented real-time, multichannel testimony transcription using the Web Audio API and OpenAI Whisper.
- Built enterprise white-label capabilities enabling B2B expansion and contributing to 10× revenue growth.
- Partnered with Sales, Product, and strategic customers to scope and deliver custom workflows.

Your LinkedIn also says Esquire acquired eLitigate in late 2024. If accurate and publicly disclosable, add:

> Product acquired by Esquire Deposition Solutions in 2024.

Describe the product acquisition accurately. Do not imply the entire company was acquired if it was not.

Useful additional details for Phantom would include actual work on:

- Reconnection and interrupted sessions.
- Permissions and sensitive evidence access.
- Asynchronous UI state and error recovery.
- Frontend performance.
- Automated testing.

These would strengthen the application, but they are not claims established by the current resume. Add only what you can substantiate.

## 5. Add a compact technical-skills section

The resume currently makes readers hunt for the stack. **TypeScript is not mentioned**, despite relevant public work.

A possible structure:

- **Frontend:** React, TypeScript, JavaScript, React Native, Next.js
- **Browser and real-time:** WebRTC, Web Audio API
- **Quality and delivery:** Playwright, GitHub Actions, Expo/EAS
- **Additional:** Ruby/Rails, Go, Python

Include only technologies you can discuss confidently. Add **TanStack Query / React Query** if you have meaningful experience—not simply because it appears in the posting.

Skills should also appear inside relevant accomplishment bullets. A keyword list alone will not establish depth.

## 6. Showcase the visual-regression toolkit

Your public [visual-regression-toolkit](https://github.com/BrandonMathis/visual-regression-toolkit) is particularly relevant. Its documentation describes:

- Playwright testing for Next.js pages.
- Desktop, tablet, and mobile screenshots.
- Reproducible browser/container versions.
- Reusable GitHub Actions workflows and PR reporting.

This is useful evidence of frontend quality and engineering judgment.

If it represents your own implementation, a possible project bullet is:

> Built a TypeScript/Playwright visual-regression toolkit for Next.js, with route discovery, three-viewport screenshot coverage, and reusable GitHub Actions reporting.

Add adoption or impact only if you have the numbers. Do not claim a measured reduction in regressions without evidence.

**Pin this repository on GitHub.** It is more useful for this application than making reviewers search through unrelated projects.

Your [Next.js/MongoDB article](https://www.thisdot.co/blog/next-js-mongodb-connection-storming) is another useful supporting link. Treat it as technical writing—not proof of a production performance improvement unless you actually delivered one.

## 7. Reallocate space toward recent engineering

Community work is a genuine differentiator because Phantom explicitly values community-driven platforms. **Keep it, but compress it.**

Aim for roughly three bullets:

- Founded Triangle Developers, a community of 3,000+ software engineers.
- Served on All Things Open's speaker-selection committee and delivered technical talks.
- Founded the local RailsBridge chapter and organized developer education.

Then:

- Reduce Asserticity to one or two bullets.
- Reduce freelance administration details such as sourcing contracts and writing SOWs.
- Keep Smashing Boxes' direct React contributions; compress staffing/resource-management details.
- Remove duplicated community responsibilities.

**Two pages is reasonable for your experience.** The goal is not an arbitrary one-page limit; it is making page one overwhelmingly relevant.

Also reconcile:

- **Education dates:** the resume says 2006–2009, while LinkedIn shows 2006–2010. Use the accurate dates consistently.
- **Overlapping employment dates:** where appropriate, add a short, accurate clarification of the working arrangement.
- **Naming and capitalization:** standardize product names, client names, and technology names.

## 8. Address gaps without overstating experience

The main unproven areas are:

- Recent production React web depth.
- React Query/server-state management.
- Browser-extension development.
- Solana/ethers integrations.

**Blockchain experience is explicitly a nice-to-have. Do not postpone applying for months to manufacture it.**

If you want an additional work sample, consider a small, polished React/TypeScript application connecting to Phantom on **Solana devnet**. Focus on:

- Wallet changes and disconnects.
- Loading and error states.
- Query invalidation and stale-data handling.
- Transaction-status UX.

Avoid a complicated trading app. Never handle private keys or require real funds for the demonstration.

Existing professional work, presented clearly, should come first.

## Proposed resume structure

1. Name and contact links.
2. Targeted professional headline and short summary.
3. Compact technical-skills section.
4. Experience, with recent hands-on frontend achievements first.
5. Selected public engineering work, if not incorporated into experience.
6. Condensed community leadership.
7. Education.

## Details needed for a stronger final rewrite

1. What recent React web features did you personally implement at This Dot?
2. Where have you used TypeScript and React Query in production?
3. What parts of Skylight were specifically yours?
4. Do you have browser-extension or blockchain experience that is not currently listed?
5. What frontend performance, reliability, testing, or adoption metrics can you substantiate?

These answers will allow the remaining generalities to be replaced with convincing, defensible bullets.

## Supporting sources

- [Phantom job posting](https://jobs.ashbyhq.com/phantom/e7b83c02-55c2-4037-9209-93deb3b7492c)
- [LinkedIn profile and project descriptions](https://www.linkedin.com/in/mathisbrandon/)
- [Skylight and Expo Updates post](https://www.linkedin.com/posts/mathisbrandon_reactnative-mobile-react-activity-7335765375751540738-YtL_)
- [Skylight and Expo Modules post](https://www.linkedin.com/posts/mathisbrandon_expo-reactnative-mobile-activity-7344414426592079872-RkMa)
- [Visual Regression Toolkit](https://github.com/BrandonMathis/visual-regression-toolkit)
- [Next.js + MongoDB Connection Storming](https://www.thisdot.co/blog/next-js-mongodb-connection-storming)
- [Personal website](https://www.brandonmathis.me/)
