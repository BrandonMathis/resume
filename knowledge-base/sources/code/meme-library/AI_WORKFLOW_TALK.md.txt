# Talk: "Ship From Your Couch: AI-Powered Mobile Dev From Your Phone"

## Abstract

What if you could build, review, and ship a React Native app without ever
opening your laptop? In this talk, I'll walk through the AI-powered developer
workflow I've built around Claude Code, GitHub Actions, Expo EAS, and my iPhone.
I'll show how a prompt typed on my phone triggers a GitHub workflow that writes
code, opens a pull request, publishes an Expo Go preview with a scannable QR
code, and lets me review the result on the same device I used to start it — all
before my coffee gets cold. Along the way, I'll share the memes I've been
collecting in the very app I'm building (because what's a side project without
memes?), dig into the surprisingly tricky URL plumbing that makes Expo Go deep
links actually work, and explore what this kind of workflow means for the future
of mobile development. Expect live demos, QR codes, a few bad jokes, and at
least one "it works on my phone" moment.

---

## Talk Details

- **Format:** 30–40 minute talk with live demo
- **Audience:** Mobile developers, React Native/Expo users, anyone curious about AI-assisted dev workflows
- **Tone:** Technical but approachable, meme-friendly, demo-heavy

---

## Narrative Arc

### The Hook

> "I built this app from my couch. On my phone. While watching TV. And I have
> the pull requests to prove it."

Open with a screenshot of a Claude Code prompt sent from your iPhone, the
resulting PR on GitHub, and the Expo Go preview running on the same phone. The
punchline: the app is a meme library — because of course it is.

### The Journey

1. **The Problem** — Laptops are great, but sometimes you just want to ship a
   quick fix from wherever you are.
2. **The Stack** — Claude Code + GitHub Actions + Expo EAS + your phone.
3. **The Workflow** — Walk through the full loop, prompt to production preview.
4. **The Details** — Deep dive into the gnarly URL construction and QR code
   mechanics.
5. **The Future** — Where AI-assisted mobile dev is heading next.

### The Landing

> "We're not replacing developers. We're giving them superpowers — and a reason
> to never put their phone down."

End with a live demo: prompt a change from your phone on stage, watch the PR
open, scan the QR code, and show the update in Expo Go. Drop a meme.

---

## Slide Outline

### Act 1: "The Couch Developer" (5 min)

**Slide 1 — Title Slide**

> "Ship From Your Couch: AI-Powered Mobile Dev From Your Phone"
>
> [Your name, event, date]
>
> _Meme suggestion: "Senior Developer" Drake meme — "Opening my laptop" (nah) /
> "Prompting from my phone" (yeah)_

**Slide 2 — The App**

- Show MemeLibrary — a React Native app built with Expo SDK 54, React 19,
  NativeWind, and react-native-reusables
- 2-column meme grid, tag-based filtering, favorites
- _"Every good side project needs a completely unnecessary amount of
  engineering."_

**Slide 3 — The Claim**

- "I can go from idea to reviewable, previewable code — from my phone."
- Show the full cycle: phone prompt → GitHub PR → Expo Go preview → phone
  review

---

### Act 2: "The Workflow" (10 min)

**Slide 4 — Architecture Overview**

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────┐
│  iPhone /    │────▶│  GitHub Actions   │────▶│  Expo EAS    │
│  Claude App  │     │  (CI + Preview)   │     │  (Update)    │
└─────────────┘     └──────────────────┘     └──────────────┘
       │                     │                       │
       │              ┌──────┴───────┐               │
       │              │ PR Comment   │               │
       │              │ + QR Code    │◀──────────────┘
       │              └──────────────┘
       │                     │
       ▼                     ▼
  ┌──────────────────────────────┐
  │  Scan QR → Expo Go Preview  │
  └──────────────────────────────┘
```

**Slide 5 — Claude Code on Mobile**

- Claude Code is available in the Claude iOS (and now Android) app
- Remote Control feature: continue a local dev session from your phone
- For this workflow: GitHub Actions runs Claude Code in CI, triggered by a
  prompt dispatched from the mobile app
- On desktop, there's a button that automates the PR creation; on mobile, the
  GitHub workflow handles it

**Slide 6 — The GitHub Workflow**

Walk through `.github/workflows/ci-and-update.yml`:

- **Job 1: Lint & Format** — ESLint + Prettier gate on every push/PR
- **Job 2: EAS Update (main)** — Auto-publish OTA updates on merge
- **Job 3: PR Preview** — The star of the show

**Slide 7 — PR Preview: The Magic**

Step-by-step walkthrough of the `pr-preview` job:

1. Lint passes → EAS CLI publishes update to branch `pr-<number>`
2. Extract `GROUP_ID` from EAS JSON output
3. Construct three URLs (next slide)
4. Post sticky comment to PR with QR code via
   `marocchino/sticky-pull-request-comment@v2`
5. Comment updates on every new commit — always shows the latest preview

**Slide 8 — The URL Plumbing (The Fun Part)**

_"This is where I lost two hours of my life so you don't have to."_

Three URLs, three different purposes:

```
# 1. Direct update URL (for programmatic access)
https://u.expo.dev/{PROJECT_ID}?channel-name=pr-{PR_NUMBER}

# 2. QR code image (rendered by Expo's QR service)
https://qr.expo.dev/eas-update?projectId={PROJECT_ID}&groupId={GROUP_ID}

# 3. Preview page URL (the key to the whole experience)
https://expo.dev/preview/update?message=PR%20Preview
  &updateRuntimeVersion=1.0.0
  &createdAt={ISO_TIMESTAMP}
  &slug=exp
  &projectId={PROJECT_ID}
  &group={GROUP_ID}
```

- **URL #2** (QR code image) is wrapped in an `<a>` tag linking to **URL #3**
  (preview page)
- When you **scan the QR code from desktop** on your phone → phone opens
  **URL #3** in Safari → Safari shows an "Open in Expo Go" interstitial →
  tapping it deep-links into Expo Go with the correct update
- When you **click the QR code in the GitHub PR on mobile** → same flow, but
  Safari opens directly since you're already on the phone
- The `expo.dev/preview/update` page is the bridge between "web URL" and
  "native app deep link" — it handles the `exp://` scheme redirect that makes
  Expo Go actually open

_Meme suggestion: "It's not much, but it's honest work" farmer meme over a
screenshot of the URL construction bash script_

**Slide 9 — The PR Comment**

Show a real screenshot of the sticky PR comment:

> 📱 **Expo Go Preview**
>
> Scan this QR code to open the latest version on your device:
>
> [QR Code Image → links to preview page]
>
> **Or open directly:** Open in Expo Go
>
> Update branch: `pr-42` | Updated on: `abc1234`

Emphasize: this comment is **sticky** — it updates in place on every push, so
there's always exactly one preview comment per PR, always showing the latest.

---

### Act 3: "The EAS Setup" (5 min)

**Slide 10 — EAS Configuration**

- `eas.json`: Three channels — `development`, `preview`, `production`
- `app.json` runtime version policy: `sdkVersion` — ensures Expo Go
  compatibility
- The `expo-updates` package handles OTA delivery
- Project ID `0384d7bc-...` ties everything together

**Slide 11 — Why EAS Update (Not EAS Build)**

- EAS Update = OTA JavaScript bundle push (seconds)
- EAS Build = full native binary compilation (minutes)
- For PR previews, we only need Update — the reviewer already has Expo Go
  installed
- This is what makes the workflow fast enough to be useful from a phone

---

### Act 4: "The Tech Stack" (5 min)

**Slide 12 — Stack Overview**

| Layer     | Tech                                      |
| --------- | ----------------------------------------- |
| Framework | Expo SDK 54, React Native 0.81, React 19  |
| Routing   | Expo Router v6 (file-based)               |
| Styling   | NativeWind (Tailwind CSS for RN)          |
| UI        | react-native-reusables (shadcn/ui for RN) |
| State     | React Context (MemeLibrary provider)      |
| CI        | GitHub Actions (lint, format, EAS update) |
| Preview   | EAS Update + sticky PR comments           |
| AI        | Claude Code (mobile + desktop)            |

**Slide 13 — The App Architecture**

```
app/
├── _layout.tsx          # Root layout with providers
├── index.tsx            # Redirect
├── AddMemeModal.tsx     # Modal for adding memes
└── (tabs)/
    ├── _layout.tsx      # Tab navigation
    ├── index.tsx        # Library (2-col grid)
    ├── add.tsx          # Photo picker
    └── settings.tsx     # Settings
```

- File-based routing with Expo Router
- Tab navigation with library, add, and settings screens
- Modal presentation for meme details and adding

---

### Act 5: "Live Demo" (5–8 min)

**Slide 14 — Let's Do It Live**

_Meme suggestion: Bill O'Reilly "We'll do it live!" screenshot_

Live demo flow:

1. Open Claude app on phone (or show on screen via AirPlay)
2. Type a prompt: _"Add a 'Random Meme' button to the library screen that
   selects and displays a random meme from the collection"_
3. Show the GitHub Action kicking off
4. Show the PR being created with the QR code comment
5. Scan the QR code on your phone
6. Expo Go opens with the updated app
7. Tap the new button, see a random meme

_Have a backup recording in case of live demo gremlins._

---

### Act 6: "What's Next" (5 min)

**Slide 15 — The AI-Assisted Dev Loop Is Getting Tighter**

- 2024: AI writes code suggestions in your IDE
- 2025: AI agents open PRs and run in CI
- 2026: AI agents fix their own CI failures, review each other's code, and
  deploy from your pocket

**Slide 16 — Tools to Watch**

Brief mention of emerging tools (detailed in the notes section below):

- Nx Self-Healing CI
- Expo MCP Server
- Claude Code Remote Control
- CodeRabbit / Greptile for AI code review
- Gitar for autonomous CI fix generation

**Slide 17 — Closing**

> "The best developer tool is the one you have with you. And you always have
> your phone."

_Final meme suggestion: Distracted boyfriend meme — boyfriend (you), girlfriend
(your laptop), other woman (your phone running Claude Code)_

---

## Speaker Notes & Talking Points

### On the "Why"

- This isn't about replacing the laptop. It's about extending your reach.
- Quick fixes, review approvals, feature prototyping — these are perfect
  phone-sized tasks.
- The meme library app is deliberately simple to keep the focus on the workflow,
  not the app complexity.

### On the URL Deep-Link Dance

- The `expo.dev/preview/update` URL is the unsung hero. Without it, you'd need
  a custom URL scheme or universal link setup.
- Expo provides this page as part of EAS — it detects the platform, shows the
  "Open in Expo Go" button, and handles the `exp://` deep link.
- The QR code from `qr.expo.dev` encodes the preview URL, not the direct update
  URL. This is critical — scanning a direct `u.expo.dev` URL would just show
  JSON in Safari.

### On the Sticky Comment

- `marocchino/sticky-pull-request-comment@v2` is the GitHub Action that makes
  the comment update in place.
- The `header: expo-preview` parameter is what makes it "sticky" — it finds and
  updates the existing comment instead of posting a new one.
- This prevents PR comment spam when you push multiple commits.

### On Claude Code Mobile

- The Claude iOS app with Claude Code support is the entry point.
- For more advanced workflows, Claude Code's Remote Control feature
  (`/remote-control`) lets you continue a local session from your phone.
- The GitHub Actions integration means you don't need a persistent local session
  — the CI runner is the execution environment.

---

## Additional Notes: AI Workflow Enhancements to Explore

These are recent tools and features (2025–2026) worth investigating to further
enhance the React Native development workflow described in this talk.

### 1. Nx Self-Healing CI

**What:** Nx Cloud's Self-Healing CI uses AI agents to automatically detect,
analyze, and fix CI failures — posting fix suggestions directly in PRs and, in
many cases, auto-committing the fix without developer intervention.

**Why it matters:** About 60% of generated fixes are accepted in large-scale
monorepos. Developers report saving more time from self-healing than from
caching and distributed task execution combined. The 2026 roadmap includes
autonomous AI agents that understand your entire codebase and make architectural
decisions.

**Try it:** Even without a monorepo, Nx Cloud's self-healing could wrap your
existing GitHub Actions pipeline and auto-fix lint/format/type errors that
Claude Code might introduce.

**Link:** https://nx.dev/docs/features/ci-features/self-healing-ci

### 2. Expo MCP Server

**What:** With Expo SDK 54+, the MCP (Model Context Protocol) server lets AI
assistants take screenshots of your running app, automate UI interactions, open
DevTools, and analyze app structure — all programmatically.

**Why it matters:** This closes the loop between "AI writes code" and "AI
verifies the result." An AI agent could generate a component, take a screenshot
of it running, and verify it looks correct — all without human intervention.

**Try it:** Enable the MCP server when starting your Expo dev server, then
connect Claude Code to it for visual verification of changes.

**Link:** https://expo.dev/blog/become-an-ai-native-developer-with-the-expo-mcp-server

### 3. Claude Code Remote Control

**What:** Anthropic's Remote Control feature lets you continue a local Claude
Code session from your phone, tablet, or browser. Your local environment stays
active — file system, MCP servers, tools, and project config all remain
available. Conversations sync across devices.

**Why it matters:** This is the "other path" to mobile development — instead of
running Claude Code in CI, you keep a persistent local session and remote into
it. Good for longer, more interactive development sessions.

**Try it:** Run `/remote-control` in a local Claude Code session, then connect
from the Claude mobile app.

**Link:** https://www.techzine.eu/news/devops/139101/remote-control-extends-claude-code-to-the-mobile-app/

### 4. CodeRabbit — AI Code Review

**What:** The most widely installed AI code review app on GitHub/GitLab, with
13M+ PRs processed. It provides context-aware review comments, auto-generated
PR summaries, and can enforce coding standards automatically.

**Why it matters:** Pairs perfectly with AI-generated PRs. If Claude Code opens
a PR, CodeRabbit can review it before you even look at it — catching issues,
suggesting improvements, and providing a second AI perspective.

**Try it:** Install the CodeRabbit GitHub App on your repo.

### 5. Greptile — Deep Codebase-Aware Review

**What:** Uses the Claude Agent SDK for autonomous investigation. Shows evidence
from your actual codebase for every flagged issue. Version 3 (late 2025)
introduced multi-step reasoning across files.

**Why it matters:** For React Native projects with cross-platform concerns,
Greptile can flag platform-specific issues (e.g., a web-incompatible API used
in a shared component) that simpler review tools miss.

**Link:** https://www.greptile.com

### 6. Gitar — Autonomous CI Fix Engine

**What:** A free AI code review platform that doesn't just suggest fixes — it
actually implements them. When CI fails, Gitar's "healing engine" generates
working fixes and commits them. Teams report CI issue resolution time dropping
from 1 hour to 15 minutes per developer per day.

**Why it matters:** This is the natural next step after the workflow in this
talk. Instead of getting a PR notification that CI failed and manually
investigating, the CI fixes itself.

**Link:** https://gitar.ai

### 7. Dagger — Self-Healing Pipelines

**What:** Built by the creators of Docker, Dagger provides containerized CI/CD
pipelines with AI agent integration for self-healing. Pipelines are defined in
code (Go, Python, TypeScript) rather than YAML, making them easier for AI to
reason about and modify.

**Why it matters:** Moving from YAML-based GitHub Actions to code-based Dagger
pipelines makes the CI itself more "AI-friendly" — agents can modify pipeline
logic, not just application code.

**Link:** https://dagger.io/blog/automate-your-ci-fixes-self-healing-pipelines-with-ai-agents/

### 8. GitHub Copilot Coding Agent

**What:** The evolution of Copilot Workspace — now GA for all paid Copilot
subscribers. Assign a GitHub Issue to Copilot and it autonomously writes code,
creates PRs, and responds to review feedback. Supports multi-model selection
including Claude Opus 4.5.

**Why it matters:** An alternative (or complement) to the Claude Code workflow.
You could assign issues to Copilot from your phone via the GitHub mobile app,
achieving a similar prompt-to-PR flow.

### 9. Builder.io Fusion — Visual AI Canvas

**What:** A visual editing canvas that integrates with your codebase and design
system. Import Figma designs, edit visually, and it outputs real code with
automatic PR creation.

**Why it matters:** For the UI-heavy parts of a meme library app, Fusion could
generate pixel-perfect components from mockups — feeding into the same PR
preview pipeline.

### 10. React Native ExecuTorch — On-Device AI

**What:** Meta's inference engine for running AI models directly on mobile
devices, now available as a React Native library. Powers on-device features in
Instagram and Facebook.

**Why it matters:** Could add on-device meme tagging, image classification, or
search to the meme library — features that run locally without an API call. The
intersection of "AI-built app" and "AI-powered app."

**Link:** https://expo.dev/blog/how-to-run-ai-models-with-react-native-executorch
