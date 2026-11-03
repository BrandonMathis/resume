---
name: resume-layout
description: Build and audit this project's LaTeX resumes for exactly two readable pages. Use whenever editing resume content or formatting, generating a tailored resume or PDF, checking overflow, or suggesting layout fixes. Keep name/contact details, summary, and all professional experience on page one; keep education, community leadership, and other supporting sections on page two. Preserve font sizes and line height.
compatibility: Requires Ruby with REXML, Tectonic or pdfLaTeX, and Poppler tools (pdftohtml and pdftoppm for visual inspection).
---

# Resume layout

## Contract

`resume.tex` is authoritative. Never edit PDFs. Apply this workflow to the main source and every tailored variation. Work from the project root; resolve bundled paths relative to this skill's directory.

A finished resume must have:

1. **Exactly two nonempty pages**, US Letter, readable and searchable.
2. **Page 1:** name/contact header, a concise professional summary, and **all** professional experience, in that order. No experience heading, entry, bullet, or continuation line may cross onto page 2.
3. **Page 2:** education, leadership/community activities, and any other supporting sections (skills, certifications, etc.). None may start on page 1 or continue onto page 3.
4. An explicit `\newpage` or `\clearpage` immediately before the first supporting section. This does not, by itself, prevent natural overflow before the break.
5. No clipped text, overlapping content, orphaned headings/entry titles, isolated bullet continuations, or overfull boxes. Preserve breathing room and visual hierarchy.

A missing summary is a failure, not permission to invent facts. Propose a short summary grounded in existing experience; obtain approval before adding substantive wording when the request is audit-only.

## Readability is not an overflow escape hatch

The locked baseline is in `policy.json`:

- Body and bullets: **10 pt**, with **12 pt baseline spacing** (1.2×). Do not shrink either to make content fit.
- Contact details only: **9 pt**; do not use that size for body content.
- Section headings: **12 pt**; name: approximately **17.28 pt** (`\LARGE` in this 10 pt article).
- Keep the existing font family, single-column reading order, and contrast.
- Maintain at least **0.5-inch margins** on every side. Current margins already meet this floor, so reducing them is not a valid fix here.

For this project, 10–12 pt body text with about 1.15–1.3× line spacing is the readability target, not a claim that one universal resume standard exists. Preserve this resume's 10/12 baseline rather than toggling sizes between edits. If the user explicitly wants a larger base size, get approval, update the baseline deliberately, and rework content to fit. Never quietly weaken `policy.json` to obtain a pass.

Do not use `\small`, `\footnotesize`, `\scriptsize`, negative tracking, condensed fonts, `\resizebox`, `\scalebox`, reduced `\baselinestretch`/`\linespread`, negative vertical space, or hidden/white text to squeeze content. Font and baseline measurements are checked, but the script is not a complete TeX interpreter: manually inspect local formatting overrides, font changes, and scaling commands too.

## Run the audit

From the project root:

```sh
ruby .agents/skills/resume-layout/scripts/check_layout.rb
```

Or, for a tailored source:

```sh
ruby .agents/skills/resume-layout/scripts/check_layout.rb --source tailored.tex
```

Equivalent main-resume command: `make check-layout`.

The checker **always compiles fresh source** into a temporary directory. A stale PDF cannot satisfy the audit. It copies the audit artifact and logs into `build/layout-audit/<source-stem>/`, writes `report.json`, and exits:

- `0`: automated checks passed; visual inspection still required.
- `1`: layout/readability violations; artifact is diagnostic, not approved.
- `2`: compiler, dependency, extraction, or unsupported-source error; do not claim a pass.

It reads actual rendered PDF text and font sizes, follows each section's contents across page boundaries (including experience continuation lines before Education), checks page count, order/placement, blank pages, page size, font sizes, margins, header/name presence, and overfull boxes. It measures the document's normal font size and baseline spacing in TeX. Its section headings come from literal `\resumesection{...}` calls in the main source. Use **Summary**, **Professional Summary**, or **Profile** for the summary and a heading containing **Experience** or **Employment** for work history. Other section headings are supporting material. Complex macro-generated/included headings, image-only text, local line-height overrides, unusual fonts, or decorative text require manual validation and may need a checker update; never bypass unknown/unmatched heading errors.

Read the report and compiler log, then render **every actual page** for visual review:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/resume/resume.pdf build/layout-audit/resume/page
```

Inspect the images with available image-reading tools. Check name/contact readability, section hierarchy, line spacing, wrapping, crowding, clipping, and whether any heading/entry is stranded at the foot of a page. The tool cannot prove visual readability or detect every orphan/overlap. If image inspection is unavailable, explicitly report that limitation; don't declare the full layout approved.

## Diagnose, then suggest the smallest honest fix

For audit-only requests, report suggestions without editing source. When edits are requested, apply bounded changes, rebuild, and re-audit after every meaningful revision. Keep exactly one explicit supporting-section break. Never move professional history onto page 2 merely to make the count pass.

Prioritize fixes in this order:

1. **Text:** remove repetition/filler and verbose qualifiers; replace duty descriptions with concise action/impact bullets; merge overlapping bullets. Preserve facts, dates, roles, meaningful keywords, and important quantified results. Do not invent metrics.
2. **Content allocation:** compress older/less relevant jobs to 1–2 high-value bullets, while retaining the employer, role, and dates; retain more detail for recent/relevant work. Suggest cuts explicitly; don't silently delete work history. Keep the summary brief, usually 2–3 lines.
3. **Spacing/padding:** modestly reduce section/entry gaps or list top/item spacing, consistently through the shared helpers. Current controls: `\resumesection` (9 pt before / 5 pt after), `\resumeentry` (6 pt before), and `resumebullets` (1 pt itemsep / 3 pt topsep). Prefer positive separation; do not use negative space or change baseline spacing. Recheck the rendered result, not just the arithmetic.
4. **Margins/layout:** if a variation has margins larger than 0.5 inch, consider moving toward that floor only after text edits. Never go below the floor, compress glyphs, switch to a less readable font, or introduce an ATS-hostile multi-column layout.
5. If content still does not fit at the locked sizes/spacing, explain the conflict and propose specific additional cuts. Do not present an unreadable or three-page PDF as finished.

If supporting material overflows, summarize that material rather than stealing page-one space. If page 2 is sparse, improve section/entry spacing naturally without changing body font size/line height or adding filler.

## Completion report

Give a short PASS / FAIL / BLOCKED report with:

- Actual page count; summary/experience/supporting-section page spans.
- Violations and, for overflow, a short excerpt of the misplaced rendered text.
- Confirmed body font/baseline and any readability concerns.
- Prioritized, concrete suggestions with before/after wording where useful; distinguish measured results from estimated savings.
- Source and audited PDF paths; whether visual inspection was completed.

Do not call the resume finished until both the automated audit and visual checks pass. Keep the original PDF references untouched. `make pdf` alone only compiles; it does not certify the layout.
