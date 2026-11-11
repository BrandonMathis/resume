# Applied AI, coding harnesses, and SDLC improvement

The public evidence supports **AI integration and agent-workflow engineering**, not foundation-model research. Keep three categories distinct: AI inside products, AI inside the development process, and leadership/adoption work.

## 1. AI inside products

### Watson image-recognition Slack bot — public code from 2017

**[WATSON]** Gist created **April 27, 2017** (last update in metadata: Jan 31, 2019).

Inspected JavaScript:
- Slack RTM client receives messages and ignores the bot's own messages.
- Image URLs are downloaded to a temporary file.
- IBM Watson Visual Recognition V3 classifies the image.
- Slack Web API posts the primary class and secondary labels/confidence percentages.
- Credentials are referenced through environment variables.

**Defensible evidence:** hands-on third-party AI API integration predating the recent LLM wave. **Not established:** commercial deployment, production hardening, trained models, customer adoption, or recognition accuracy.

### vTestify / eLitigate testimony transcription

**[BASELINE, ESQUIRE]** Existing resume claims real-time multichannel testimony transcription using **Web Audio API + OpenAI Whisper**. Esquire independently describes the product's speech-to-text feature in 2021, but does not identify Whisper or Brandon. Do not date Whisper integration to that 2021 announcement.

**Useful follow-up:** browser audio routing; speaker/channel attribution; streaming architecture; latency; operating cost; failure handling; customer use. No answers should be inferred from the API name.

**Questionnaire addition (first-party, Nov 2026):** vTestify was an early adopter of **OpenAI SDKs for evidence/information processing** and built a **vector database used for RAG-style search** over deposition material. This is the first mention of vector retrieval anywhere in the library and it is self-reported only: no code, dates, embedding model, store, or evaluation evidence was retrieved. Treat “built a vector database for RAG search at vTestify” as an unverified first-party claim, not as contradicting the Oracle boundary below. [QUESTIONNAIRE]

**Partner transcription context:** Stenograph's CaseViewNet real-time (stenographer) transcript was integrated into the vTestify room in Oct 2021, and the 2022 licensing agreement references Stenograph's **Phoenix automatic speech recognition**. These are partner products; they neither confirm nor replace the baseline's Whisper claim. [STENO_2021, STENO_2022]

### D&D Oracle — document-context chat application

**[ORACLE, ORACLE_FETCH]** Inspected commit-pinned TypeScript:
- Next.js POST route accepts a messages array and uses the Anthropic SDK.
- Calls a named Claude model with streaming enabled.
- Converts text deltas to server-sent events; returns completion/error events.
- Fetches public Google Doc plain text and includes it in a system prompt.
- Prompt asks the assistant to restrict campaign lore to the supplied document.
- Separate token utilities exist; their presence does not establish sophisticated context management or evaluation.

**Important correction:** a route comment calls the document retrieval “MCP integration,” but the actual helper uses **ordinary HTTP fetch to Google Docs' text export endpoint**. Do not claim this implementation uses MCP, vector search, embeddings, or a vector database. It is document-context injection, not demonstrated retrieval-augmented search infrastructure. Prompt restrictions are intentions, not a proven guarantee against hallucination.

Repository ownership and implementation are public; personal authorship of every line and production deployment are unverified.

## 2. AI inside software delivery

### my-pi — public personal harness configuration and extensions

**[MY_PI, PI_LOOP]** Repository tree and selected implementation pinned at commit `5dbdfc4d750e82a4cf4a794aa0f09d7b9c65361c`.

Observed capabilities:
- **Recurring fresh sessions:** fixed-delay scheduler, no overlapping runs, idle checks, cancellation, independent worker processes, explicit timeout, bounded output excerpts, private log permissions, captured model/thinking/trust settings.
- **Planning/execution separation:** documented read-only plan phase; saved plan; rewind to pre-plan context; execute on a fresh branch.
- **Handoffs:** transcript extraction including compaction summaries, length limit, streamed model-generated handoff report.
- **Task queues:** persisted JSON todo store and status-oriented workflow.
- **Git worktrees:** create/switch/remove flows, choose retained or fresh conversation context, rebind session working directory, dirty-worktree confirmation.

**Boundary:** the recurring loop explicitly is **not a sandbox**, durable cron service, automatic success detector, cost-budget controller, or independent worktree. Several of those are listed as future ideas. Do not promote roadmap items into accomplishments.

These sources show practical customization and systems thinking. They do **not** establish that every extension was originated from scratch, that this is upstream Pi core work, or that client teams adopted it. Confirm original versus adapted work for authorship-sensitive claims.

### agent-loop — separate shell-driven task runner

**[AGENT_LOOP]** README describes a Bash utility running Pi over tasks in `Prompt.md`, defaulting to non-approved project-local resources and exposing explicit opt-in trust. This is separate from the recurring scheduler in `my-pi`.

Evidence level is **README-backed**; implementation was not separately audited in this research batch. No throughput/quality metric established.

### pi-working-phrase — developer-experience extension

**[PI_PHRASES]** TypeScript Pi extension for shuffled status phrases, theme-aware spinner/shine, validated sidecar configuration, and restoring default state when responses finish. A small concrete harness/TUI customization, not a large agent platform or safety feature.

### Claude agent definitions

**[CLAUDE_AGENTS]** Public `pr-code-reviewer.md` and `github-pr-commenter.md`:
- Structured PR review instructions and prioritized findings.
- GitHub MCP-based access instructions.
- File/line references and actionable review output.

Configuration is evidence of workflow design, not evidence that the agent always follows it or that Brandon wrote a GitHub MCP server. The review prompt is static-analysis oriented and explicitly does not run tests; do not describe it as automated runtime verification.

### Roo custom modes — published workflow design

**[ROO]** Four authored modes:
1. **Documenter:** legacy-code understanding; documentation-only scope; file/line references.
2. **Pair Programmer:** collaborative, human-guided iteration with explicit authorization boundaries.
3. **Project Manager:** decomposes features into business rationale and actionable acceptance criteria.
4. **Agent Consultant:** uses Context7 MCP documentation to refine modes/rules/prompts.

This is unusually direct evidence connecting AI practice with **SDLC process design**, not just chatbot usage. Productivity benefits are qualitative self-report, not measured client ROI.

### AI-assisted mobile delivery

**[MEME_CI, MEME_TALK, EXPO_UPDATES]** Strong evidence is the implemented Expo validation/update/preview workflow and Skylight release transcript. The meme-library talk draft describes a larger phone-to-Claude-to-PR experience; distinguish that narrative from what the inspected CI actually implements.

Useful themes: fast feedback, previewable changes on real devices, explicit review, release-channel management, and maintaining validation around AI-generated changes.

### AI-directed presentation application

**[AI_SLIDES]** The Next.js slideshow README explicitly says the application was generated by AI under Brandon's direction using VS Code, Anthropic, and Roo; even the README was AI-generated. Features include responsive slides, touch/keyboard navigation, QR access, and image loading.

Describe this as **directed/iterated AI-assisted development**, not “hand-coded everything.” README token/cost totals are first-party estimates; the speculative carbon estimate should not become a professional impact claim.

## 3. Adoption, consulting, and leadership

### Team enablement after HUDL (questionnaire, first-party)

After the FastModel engagement, Brandon was assigned to a new team and **onboarded them to agentic coding practices using Claude Code**, covering when to use plan mode, when to start new sessions, and how to manage context. No client name, team size, or before/after measurement was supplied. [QUESTIONNAIRE]

### Tooling breadth (questionnaire, first-party)

Reports day-to-day use of **Claude Code, ChatGPT, Codex, OpenCode, Pi, and Cursor**, with Pi, Codex, and Claude Code used most at the time of writing, and hands-on experience across **GPT, Anthropic, DeepSeek, GLM, and Kimi** model families. States that agentic workflows pay off most when the design is settled and implementation is mostly routine, and for sustaining **security updates, test suites, coverage, and other quality work** that is often deprioritized against features. These are practice descriptions, not benchmarks. [QUESTIONNAIRE]

### The Context Window podcast (This Dot Labs)

Apple Podcasts lists Brandon as a host alongside Tracy Lee and A.D. Slaton; the show (2025–2026, 25 episodes at retrieval) covers AI development tooling. Episodes with Brandon include **“How to Make Your Codebase Agent-Ready”** (60-second dev setup, deterministic versioning, validation loops), **“Building Deterministic AI Coding Workflows with Claude Code”**, **“Scale AI Development With Engineering and Agent Control Planes?”** (loop engineering, worktrees), **“Local LLMs for Secure, Predictable AI Development”** (quantization, VRAM planning, sandboxes), and interviews with Gant Laborde, Dev Agrawal, Jeff Escalante (Clerk), and OpenAI's Jon Abrams (GPT Sites). Episode descriptions are publisher summaries; recordings were not transcribed. This is strong evidence of public thought leadership on agent workflows, not of client outcomes. [CONTEXT_WINDOW]

### Other public positions

- User explicitly reports consulting on AI systems, coding harnesses, AI workflows, and improving SDLCs. **[BRIEF]**
- Baseline describes This Dot talks/content on coding agents, LLMs, and change management for AI enablement. **[BASELINE]**
- HUDL project account describes mentoring engineers during the growth of agentic coding. **[LINKEDIN]**
- Published public evidence includes Roo modes, AI Ignite talk material/recap, the Pi talk listing, and ATO interviews about AI economics and open-source quality. **[ROO, AI_SLIDES, AI_IGNITE_RECAP, REACT_ATL, ATO_AI_SLOP]**

**Still needed for consulting-focused resumes:** named/disclosable engagements, before/after process, team size, adoption measurement, code quality/cycle-time changes, governance/evaluation approach, cost controls, and exact personal role.

## Avoid these unsupported leaps

- “Built or trained large language models.”
- “Designed production vector/RAG infrastructure” based on Oracle. (The vTestify vector-database account is a separate, self-reported claim that still needs artifacts.)
- “Created Pi” or “merged agent-runtime changes upstream” based on a fork/custom extensions.
- “Implemented all ten AI tools” listed in the meme talk's **enhancements to explore** section.
- “Delivered 20× productivity” based on future-looking interview commentary.
- “Led AI transformation at OpenAI” merely because OpenAI is listed as a This Dot customer.
- “Guaranteed safe autonomous execution” based on prompt rules or subprocess cleanup.
