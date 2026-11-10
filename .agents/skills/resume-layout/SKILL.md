---
name: resume-layout
description: Finalize RenderCV resumes as two readable, balanced pages with a comfortably filled first page, clear section spacing, and all professional experience on page one. Measure both overflow and unused space; preserve approved typography and make only the smallest authorized adjustment. Run at final PDF handoff or for an explicitly requested layout audit, not for each edit or draft build.
compatibility: Requires uv (RenderCV 2.8 with Python 3.13), Helvetica, Ruby with REXML, and Poppler tools (pdftohtml, pdftotext, and pdftoppm). Legacy TeX audits additionally require Tectonic or pdfLaTeX.
---

# Resume layout: readable, balanced, and full

## 1. Define success

The goal is a well-composed resume, not merely a PDF that fits. Page one should feel comfortably filled, with distinct sections and jobs, readable bullets, and a modest cushion above the bottom margin. Avoid both overflow and unnecessary compression that leaves a large unused band at the bottom.

A successful resume has:

- **Exactly two nonempty, searchable US Letter pages**, with single-column reading order.
- **Page one:** name/contact header, professional summary, and **all** professional experience, in that order. Every experience title, bullet, and continuation line stays on this page.
- **Page two:** education, leadership/community activities, and other supporting sections. None starts on page one or continues onto page three.
- Clear hierarchy and comfortable positive separation between sections, jobs, and bullets. No clipping, collisions, stranded headings, isolated continuations, or crowding against the margins.
- A first page that uses its available height naturally. Finishing early is not an improvement if readable spacing could occupy that space.

The automated checker verifies structural and readability constraints. **It does not evaluate page fullness or certify that spacing looks balanced.** An automated pass alone does not establish the whole result.

## 2. Establish scope and preserve approved work

Work from the project root, three directories above this skill. Resolve bundled scripts and policy relative to this skill's directory. Read `README.md`, the Makefile, relevant source/diffs, and the calling update skill before making changes.

- `variants/default.yml` is authoritative; all variants share its design and the templates in `classic/`.
- Discover variants with `make variants`; do not use a hard-coded list.
- Preserve existing user edits and approved presentation. An audit is not a request to restyle a passing resume or reset its spacing.
- Never edit generated YAML, Typst, or PDFs, generated template copies in `build/`, frozen `resume.tex`, or original reference PDFs.
- Exactly one explicit supporting-section break belongs immediately before Education. `classic/Preamble.j2.typ` splits the content there and calls `pagebreak()`. This does not prevent natural overflow before the break. A separately authorized heading change must update that split too.

This skill does not independently authorize content or presentation edits:

| Request/workflow | Authorized action |
| --- | --- |
| Audit only | Measure and report; propose fixes without editing source. |
| Layout/style update | Follow `../resume-update/SKILL.md`; edit shared presentation only, preserve all copy, and audit every discovered variant including `default`. |
| Copy update | Follow `../resume-copy-update/SKILL.md`; confirm variants and change only authorized copy. Keep shared design/templates unchanged. |
| Fix outside the active scope | Explain the conflict and obtain a separately scoped request. |

Missing required content, such as a summary, is a failure to resolve with the user—not permission to invent copy. Before crafting any wording, follow the knowledge-base and copy-update requirements. Never remove facts, jobs, bullets, or substantive wording merely to satisfy a layout check without authorization.

## 3. Protect typography and margins

The locked baseline is in `policy.json`; its `*_tex_pt` names also support legacy audits.

| Element | Required baseline |
| --- | --- |
| Body and bullets | Helvetica, **10 pt** |
| Body baseline distance | **12 pt** |
| Contact details only | **9 pt** |
| Section headings and optional headline | **12 pt** |
| Name | Approximately **17.28 pt** |
| Margins | At least **0.5 inch** on every side |

RenderCV's `design.typography.line_spacing: 2pt` is the gap between text frames, not the total baseline distance. The preamble fixes `top-edge: 0.8em, bottom-edge: -0.2em`: a 10 pt frame plus 2 pt leading gives 12 pt baselines. The negative bottom edge locates descenders; it is not negative spacing. Preserve this frame and leading.

Do not change font size or baseline distance to fill space or fix overflow. A user-requested larger body size requires explicit approval, a deliberate policy change, and a separately scoped assessment of content capacity. Do not quietly weaken policy to obtain a pass. Typst/PDF points are 1/72 inch; legacy TeX points are 1/72.27 inch, so equal nominal sizes are not physically identical.

Keep Helvetica and adequate contrast; missing fonts are a dependency blocker, not permission for fallback. Do not use smaller local body text, condensed fonts, negative tracking, glyph scaling, reduced line height, negative vertical space, hidden/white text, or multi-column packing. Legacy TeX restrictions include `\small`, `\footnotesize`, `\resizebox`, `\scalebox`, and reduced `\baselinestretch`/`\linespread`. Review executable template overrides manually; the checker cannot interpret every possible layout trick.

Current margins already meet the minimum. Do not enlarge margins to disguise unused space or reduce them below the floor to fit content.

## 4. Measure before adjusting

Start with the current approved layout and effective variant copy. Determine whether the problem is overflow, underfilling, poor hierarchy, or a combination. Do not assume every copy update needs tighter spacing.

For an existing PDF, record:

1. Actual page count and section spans.
2. The bottom of the final experience line on page one.
3. Unused height **inside** the bottom margin: `page height − configured bottom margin − final text bottom`.
4. Current section, entry, and bullet gaps, and where the page looks crowded or loose.

For Letter with the current 0.5-inch bottom margin, the usable bottom is **756 pt**. Text ending at 737 pt leaves about **19 pt of usable space**, in addition to the margin. Distinguish that cushion from the entire distance to the paper edge.

As a composition guide, aim for roughly **12–36 pt (one to three body baselines)** of usable space after the final experience line. This is a soft target, not a new automated failure threshold or a reason to crowd text. More space calls for a balance check, not automatic stretching. A shorter variant may finish earlier because the same shared design must accommodate a denser one; coherent spacing is more important than identical bottom positions. User-approved layouts take precedence over this heuristic when they meet the hard constraints.

Measure rendered geometry rather than estimating from source length. For example, this reads an existing PDF without rendering or changing source:

```sh
# Use the actual configured bottom margin, in PDF points.
PDF=build/layout-audit/default/resume.pdf BOTTOM_MARGIN_PT=36 ruby <<'RUBY'
require 'open3'
require 'rexml/document'
xml, status = Open3.capture2('pdftotext', '-bbox', ENV.fetch('PDF'), '-')
abort 'PDF text extraction failed' unless status.success?
document = REXML::Document.new(xml)
page = REXML::XPath.first(document, '//*[local-name()="page"]')
abort 'No page found' unless page
words = REXML::XPath.match(page, './/*[local-name()="word"]')
abort 'No extractable text on page one' if words.empty?
bottom = words.map { |word| Float(word.attributes['yMax']) }.max
usable_bottom = Float(page.attributes['height']) - Float(ENV.fetch('BOTTOM_MARGIN_PT'))
puts "Page-one text bottom: #{bottom.round(1)} pt"
puts "Unused height inside bottom margin: #{(usable_bottom - bottom).round(1)} pt"
RUBY
```

Confirm that the final extracted text belongs to experience, and exclude any footer or unrelated annotation when applicable. Bounding boxes approximate visible glyph edges; they support, rather than replace, visual judgment. If overflow exists, inspect the last experience line across all actual pages before interpreting page-one fullness.

An unbreakable job entry may move wholesale onto page two even when only a small amount of extra height is needed. Compare the complete entry's height with the space left on page one; do not treat the entire displaced entry as the amount that must be cut or compressed.

## 5. Balance spacing with the smallest authorized change

Use these approved shared settings as a reference for comfortable rhythm—not as mandatory values to overwrite a future approved design:

| Shared setting in `variants/default.yml` | Reference |
| --- | --- |
| `design.section_titles.space_above` | **15 pt** |
| `design.section_titles.space_below` | **8 pt** |
| `design.sections.space_between_regular_entries` | **10 pt** |
| `design.entries.highlights.space_above` | **3 pt** |
| `design.entries.highlights.space_between_items` | **1.5 pt** |

### If page one is underfilled

When presentation edits are authorized:

- Restore clear space above and below section headings first, especially if those gaps were compressed. Section boundaries should remain more distinct than bullet boundaries.
- Redistribute room naturally between jobs and then between bullets. Prefer small, consistent increases through shared settings; do not insert arbitrary blank blocks, stretch text, or add filler.
- Preserve an already comfortable header and summary. Do not inflate them solely to push the last job downward.
- Evaluate the densest variant before expanding shared gaps. Shorter variants can retain more bottom whitespace rather than forcing all variants to share one bottom position.
- Stop when the page is balanced. Do not consume every last point or enlarge gaps until entries feel disconnected.

When presentation edits are not authorized, report the unused height and suggest a separate layout update instead of changing design.

### If experience overflows

Diagnose the required height savings before choosing a fix:

- If repetition or verbose copy is the problem, propose concise wording within the authorized copy scope. Preserve roles, dates, facts, important keywords, and quantified results. Material cuts require approval; do not automatically reduce older jobs to an arbitrary bullet count.
- If the content is approved and the problem is presentation, use available excess spacing before proposing copy cuts. Adjust the smallest relevant set of positive gaps, in modest increments—usually **1–2 pt per gap**, not a blanket reset of every spacing control.
- Protect section hierarchy. Avoid taking most of the savings from heading space or uniformly tightening headings, jobs, and bullets at once.
- Choose changes that recover the measured shortage with a modest cushion, not the largest possible savings. Do not aim for the tightest layout that passes.
- If reasonable spacing cannot accommodate the content at locked typography, stop and propose specific copy changes or another explicitly approved scope. Never move experience to page two or accept a third page as the solution.

After any authorized adjustment, check **both** fit and remaining usable space. If compression overshoots and leaves a large unused band, release the unnecessary compression before handoff. A two-page result with cramped sections and avoidable bottom whitespace is not the intended outcome.

Page two does not have to match page one's fullness. Keep supporting material comfortably organized; do not steal page-one capacity, add filler, or distort shared spacing merely to fill page two. If supporting material overflows, propose scoped changes to that material.

## 6. Batch work and finalize once

This is a finalization gate, not a per-edit hook:

- Complete the requested batch of edits and source/diff checks before the final audit. Draft calibration can use `make pdf VARIANT=<name>` and existing PDF measurements; label drafts unaudited.
- Do not audit for research, copy proposals, instruction/tooling-only edits, every small edit, or draft/watch builds. Documentation-only changes to this skill do not require generating or auditing resumes.
- Finalize selected variants for variant-only copy edits. Shared presentation edits require **all discovered variants, including `default`**, once each. Do not duplicate default or repeat the audit through calling skills.
- `make check-layout` renders fresh source itself. Do not precede it with `make pdf` just for freshness; build separately only for a draft or a separately needed conventional build-path PDF.
- If finalization fails, diagnose, batch the authorized fixes, and then re-audit affected results. A further shared presentation change invalidates every variant's result.
- Reuse a passing audit and completed review while effective content, design, templates, and audit policy/tooling are unchanged. Never approve changed source using an old artifact.

From the project root:

```sh
make variants
make check-layout VARIANT=default
# Substitute each actual selected/discovered variant as required:
make check-layout VARIANT=full-stack
# Standalone full RenderCV input (not a content overlay):
make check-layout SOURCE=tailored.yaml
# Checker regression tests, when checker code is changed:
make test-layout
```

Do not combine `SOURCE` and `VARIANT`. The direct checker entry point is `ruby .agents/skills/resume-layout/scripts/check_layout.rb`.

The checker uses pinned RenderCV 2.8 with Python 3.13, builds in a temporary directory, and saves the fresh artifact and logs under `build/layout-audit/<variant-or-source-stem>/`:

- `resume.pdf` and `resume.typ`
- `report.json`
- `compile.log`

Read the report and compiler log. Exit `0` means automated checks passed; `1` means layout/readability violations; `2` means a dependency, renderer, extraction, or unsupported-source blocker. A failed artifact is diagnostic, not approved; never substitute a stale PDF.

Automated checks cover page count/size, blank pages, name/header, section order and placement including continuation lines, explicit supporting-section split, fonts/sizes, margins, and rendered body-row spacing. Headings come from `cv.sections`: use **Summary**, **Professional Summary**, or **Profile**, and an experience heading containing **Experience** or **Employment**. Unknown/unmatched headings must be resolved, not bypassed.

Legacy `--source resume.tex` support compiles fresh TeX with Tectonic or pdfLaTeX and requires literal `\resumesection{...}` headings plus an explicit `\newpage` or `\clearpage` before supporting sections. The frozen reference lacks a summary and is not approved for publication.

## 7. Review the result and hand off the exact PDF

On the final audited PDF, verify page-one fullness and spacing as well as the automated result. Compare the final usable-space measurement with the starting point and explain any deliberately larger cushion. Do not claim the checker measured balance; it does not.

Follow the active update skill's visual-review and Preview requirements:

- **Standalone layout audit and copy-update workflow:** render every actual page and inspect the images for hierarchy, readable contacts, wrapping, section/job separation, clipping, collisions, stranded headings, and bottom whitespace.
- **Layout/style update via `resume-update`:** agent image inspection is not required by that skill. Measure geometry, open the audited PDFs in Preview, and leave visual approval pending the user's review. Do not claim to have visually inspected them.

For agent image review when required:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/default/resume.pdf build/layout-audit/default/page
```

Read every actual page image with an image-reading tool. If that capability is unavailable, report the limitation; do not claim visual approval.

For an update-and-preview handoff, open the exact audited artifact after successful checks, using the actual variant name:

```sh
open -a Preview build/layout-audit/default/resume.pdf
```

Check launch exit status. A missing desktop/Preview session blocks the handoff; provide the exact path instead. Launching Preview is not evidence of user approval. Do not make more edits while awaiting feedback.

## 8. Report concisely

State:

- Per-resume automated **PASS / FAIL / BLOCKED**, actual page count, and summary/experience/supporting-section page spans.
- Helvetica body size and baseline, what spacing changed, and whether copy remained unchanged.
- Page-one unused height inside the bottom margin and a brief balance assessment; distinguish measured geometry from visual judgment and estimated savings.
- Any violation, with a short misplaced-text excerpt for overflow, and the smallest concrete next step within scope.
- Source and audited PDF paths, agent visual-review status, Preview launch status when applicable, and any pending user approval.

A finished result must meet the structural/readability contract **and** have the required visual approval. Compilation alone, an automated pass alone, or a maximally compressed first page is not completion.
