---
name: resume-layout
description: Finalize this project's RenderCV resumes with a fresh layout audit after the requested edits are ready for PDF handoff/publishing, or run an explicitly requested layout audit. Not a per-edit, research, proposal, or draft-build workflow. Keep name/contact details, summary, and all professional experience on page one; keep education, community leadership, and other supporting sections on page two. Preserve font sizes and line height.
compatibility: Requires uv (RenderCV 2.8 with Python 3.13), Helvetica, Ruby with REXML, and Poppler tools (pdftohtml and pdftoppm). Legacy TeX audits additionally require Tectonic or pdfLaTeX.
---

# Resume layout

## When to run: finalization only

Treat this skill as a finalization gate, not an automatic hook for every edit or PDF build. Its layout constraints still guide editing; reading those constraints does not require running the audit.

- Finish the requested batch of copy/style edits and source/diff checks first. Run one fresh audit per affected resume when ready for final PDF handoff/publishing, or when the user explicitly requests a layout audit.
- Do not audit for research, copy proposals, instruction/tooling-only edits, each bullet or file change, intermediate drafts, or `make pdf` / `make watch` working previews. Draft previews must be identified as unaudited, not finished resumes.
- Scope finalization to the selected variants for variant-only copy edits; include all discovered variants (including `default`) once each for shared presentation edits. Do not repeat audits through each calling skill: all workflows share this single finalization gate.
- If finalization fails, diagnose the result and batch the authorized fixes before re-running affected audits. Do not re-audit after each small correction. An explicit diagnostic request may run an audit earlier.
- Reuse a passing audit and completed review while the effective content, design, templates, and audit policy/tooling are unchanged. Later changes affecting the result require a fresh audit at the next finalization; an unrelated file edit or repeated status request does not. Never use an old artifact to approve changed source.
- `make check-layout` already builds a fresh PDF. Do not precede it with `make pdf` merely to make the audit fresh; build separately only when the user also needs the conventional build-path PDF or an intermediate preview.

Documentation-only changes to these skills or `AGENTS.md` do not themselves require generating or auditing resumes.

## Contract

`variants/default.yml` is authoritative. Never edit generated Typst or PDFs. `resume.tex` is a frozen pre-migration reference, not a second active source. Apply this finalization workflow to each affected source or tailored variation, using the scope above. Work from the project root; resolve bundled paths relative to this skill's directory.

A finished resume must have:

1. **Exactly two nonempty pages**, US Letter, readable and searchable.
2. **Page 1:** name/contact header, a concise professional summary, and **all** professional experience, in that order. No experience heading, entry, bullet, or continuation line may cross onto page 2.
3. **Page 2:** education, leadership/community activities, and any other supporting sections (skills, certifications, etc.). None may start on page 1 or continue onto page 3.
4. Exactly one explicit page break immediately before the first supporting section. `classic/Preamble.j2.typ` splits at **Education** and calls `pagebreak()` between the two styled groups. This does not, by itself, prevent natural overflow before the break. If renaming Education, update the template split as well; the auditor checks that it matches the first supporting section.
5. No clipped text, overlapping content, orphaned headings/entry titles, isolated bullet continuations, or overfull boxes. Preserve breathing room and visual hierarchy.

A missing summary is a failure, not permission to invent facts. Propose a short summary grounded in existing experience; obtain approval before adding substantive wording when the request is audit-only.

## Readability is not an overflow escape hatch

The locked baseline is in `policy.json` (the `*_tex_pt` key names are retained for compatibility with legacy audits):

- Body and bullets: **10 pt**, with **12 pt baseline spacing** (1.2×). Do not shrink either to make content fit.
- Contact details only: **9 pt**; do not use that size for body content.
- Section headings: **12 pt**; name: approximately **17.28 pt**.
- Keep **Helvetica**, single-column reading order, and contrast. Install the font if missing; never accept silent fallback.
- Maintain at least **0.5-inch margins** on every side. Current margins already meet this floor, so reducing them is not a valid fix here.

Typst/PDF points are 1/72 inch, versus 1/72.27 inch for legacy TeX. RenderCV uses the same nominal 10/12 pt sizes, fractionally larger in physical units. Do not change the locked sizes as a side effect of a migration or update.

For this project, 10–12 pt body text with about 1.15–1.3× line spacing is the readability target, not a claim that one universal resume standard exists. If the user explicitly wants a larger base size, get approval, update the baseline deliberately, and rework content to fit. Never quietly weaken `policy.json` to obtain a pass.

RenderCV's `design.typography.line_spacing: 2pt` is **leading between text frames**, not the total baseline distance. The preamble fixes the frame at `top-edge: 0.8em, bottom-edge: -0.2em`, giving 10 pt frame height plus 2 pt leading = 12 pt baselines. The negative bottom-edge coordinate places descenders below the baseline; it is not negative spacing. Preserve both this frame and the YAML leading. The auditor checks the generated configuration and actual rendered row spacing.

Do not use smaller local text, negative tracking, condensed fonts, glyph scaling, negative vertical space, hidden/white text, or reduced line height to squeeze content. For legacy TeX, this includes `\small`/`\footnotesize` for body content, `\resizebox`, `\scalebox`, and reduced `\baselinestretch`/`\linespread`. Manually inspect local Typst/TeX overrides: the script is not a complete interpreter and cannot certify arbitrary executable content or detect every collision.

## Edit-scope boundaries

This skill audits both content and presentation; it does not authorize either kind of edit by itself. For update-and-preview requests:

- `../resume-update/SKILL.md` permits shared layout/style edits only, never copy changes. Audit every discovered variant, including `default`, once after shared presentation changes.
- `../resume-copy-update/SKILL.md` permits copy-only edits to confirmed variants and always asks which variant(s) before proceeding. Do not change shared design/templates to make tailored copy fit.
- The troubleshooting suggestions below apply only within the authorized scope. If a fix requires crossing that boundary, explain the conflict and obtain a separately scoped request instead of silently changing copy or style.

## Run the audit

From the project root:

```sh
make check-layout
# Or:
ruby .agents/skills/resume-layout/scripts/check_layout.rb
# Content-only variants are composed with the shared baseline/templates:
make check-layout VARIANT=full-stack
make check-layout VARIANT=react-native
# Standalone tailored YAML still works:
make check-layout SOURCE=tailored.yaml
# Checker regression tests:
make test-layout
```

The checker **always renders fresh source** into a temporary directory with the pinned RenderCV version. A stale PDF cannot satisfy the audit. It copies the audit artifact and logs into `build/layout-audit/<source-stem>/`, writes `report.json`, and exits:

- `0`: automated checks passed; visual inspection still required.
- `1`: layout/readability violations; artifact is diagnostic, not approved.
- `2`: renderer, dependency, extraction, or unsupported-source error; do not claim a pass.

It reads actual rendered PDF text, follows each section's contents across page boundaries (including experience continuation lines before Education), and checks page count, order/placement, blank pages, page size, font family/sizes, margins, header/name presence, and body-row spacing. It reads resolved dimensions from freshly generated Typst and validates the explicit supporting-section split. Its headings come from `cv.sections` keys. Use **Summary**, **Professional Summary**, or **Profile** for the summary and a heading containing **Experience** or **Employment** for work history. Other headings are supporting material. Never bypass unknown/unmatched heading errors.

The checker retains legacy `--source resume.tex` support, compiling fresh TeX with Tectonic or pdfLaTeX. Legacy headings must be literal `\resumesection{...}` calls with an explicit `\newpage` or `\clearpage` before supporting sections. The reference TeX has no summary and is not approved for publication.

Read the report and compiler log, then render **every actual page** for visual review:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/default/resume.pdf build/layout-audit/default/page
```

Inspect the images with available image-reading tools. Check name/contact readability, section hierarchy, line spacing, wrapping, crowding, clipping, and whether any heading/entry is stranded at the foot of a page. The tool cannot prove visual readability or detect every orphan/overlap. If image inspection is unavailable, explicitly report that limitation; don't declare the full layout approved.

## Diagnose, then suggest the smallest honest fix

For audit-only requests, report suggestions without editing source. When edits are requested, apply bounded changes in a batch, then audit at finalization. If that audit fails, batch the authorized fixes and re-audit the affected resumes before handoff. Keep exactly one explicit supporting-section break. Never move professional history onto page 2 merely to make the count pass.

Prioritize fixes in this order:

1. **Text:** remove repetition/filler and verbose qualifiers; replace duty descriptions with concise action/impact bullets; merge overlapping bullets. Preserve facts, dates, roles, meaningful keywords, and important quantified results. Do not invent metrics.
2. **Content allocation:** compress older/less relevant jobs to 1–2 high-value bullets, while retaining employer, role, and dates; retain more detail for recent/relevant work. Suggest cuts explicitly; don't silently delete work history. Keep the summary brief, usually 2–3 lines.
3. **Spacing/padding:** modestly reduce section/entry gaps or list top/item spacing, consistently through shared design settings. Current controls: section titles 9 pt above / 5 pt below; entries 6 pt apart; highlights 1 pt between items / 3 pt above. Prefer positive separation; do not use negative space or change baseline spacing. Recheck the rendered result, not just the arithmetic.
4. **Margins/layout:** if a variation has margins larger than 0.5 inch, consider moving toward that floor only after text edits. Never go below the floor, compress glyphs, switch to a less readable font, or introduce an ATS-hostile multi-column layout.
5. If content still does not fit at locked sizes/spacing, explain the conflict and propose specific additional cuts. Do not present an unreadable or three-page PDF as finished.

If supporting material overflows, summarize that material rather than stealing page-one space. If page 2 is sparse, improve section/entry spacing naturally without changing body font size/line height or adding filler.

## Completion report

Give a short PASS / FAIL / BLOCKED report with:

- Actual page count; summary/experience/supporting-section page spans.
- Violations and, for overflow, a short excerpt of misplaced rendered text.
- Confirmed body font/baseline and any readability concerns.
- Prioritized, concrete suggestions with before/after wording where useful; distinguish measured results from estimated savings.
- Source and audited PDF paths; whether visual inspection was completed.

Do not call the resume finished until both the automated audit and visual checks pass. Keep original PDF references untouched. `make pdf` alone only compiles; it does not certify layout.
