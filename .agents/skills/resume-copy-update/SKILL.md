---
name: resume-copy-update
description: Update resume wording and content only, never layout or style. Batch edits, then at finalization run one fresh resume-layout audit and visual inspection per selected variant and open the exact reviewed PDF in macOS Preview. Use for summaries, bullets, experience wording, or other resume copy changes.
compatibility: Requires macOS Preview and the dependencies documented by the project's resume-layout skill.
---

# Update resume copy and preview

Treat the user's arguments as a copy-change request. Complete the requested content edits first, then finalize with a fresh layout audit, visual review, and Preview handoff. Do not run layout audits during drafting or after each small revision. If the user only requests proposals or a working draft, stop there without finalization and label any draft PDF unaudited. Do not modify presentation to accommodate the new copy.

## 1. Always ask which variant to update

- Work from the project root, three directories above this skill directory.
- Read the project `README.md` and Makefile; consult `../resume-layout/SKILL.md` for layout constraints as needed, and read it in full at finalization. Reading it does not trigger an audit. Inspect `git status --short`, relevant diffs, the baseline, and existing overlays without modifying anything.
- Discover available variants with `make variants`. The variants include `default` and the audience-specific overlays; do not hard-code the list.
- Ask once at the start of each new copy-update operation. A clear answer authorizes the selected target(s) for subsequent revisions in that same operation; do not repeatedly ask during drafting or finalization.
- Never default to all variants or to `variants/default.yml`. Request confirmation before modifying that default/baseline resume. Prefer making new variants.
- This workflow edits variant copy only; the shared baseline is read-only. If the user wants shared baseline or identity/contact changes, explain their broader inheritance impact and handle that as a separately scoped request rather than silently making a variant edit global.
- If the adjustment itself is unspecified, ask what to change as well. Ask about ambiguous facts; never invent roles, dates, achievements, technologies, or metrics.

## 2. Apply only copy changes

Edit `variants/<variant-name>.yml`, never its generated RenderCV input. Preserve unrelated and uncommitted work. If the user already made the copy adjustment, inspect the diff and validate it rather than duplicating it.

- Read the effective content: default `cv.sections` plus every parent overlay and the selected overlay's replacements, in inheritance order. Do not start from baseline content when that would discard an existing tailored section.
- Overlays declare `inherits: default` (or another parent variant), contain a `sections` mapping, and may set an optional single-line `headline` (audience-specific copy under the name; its style is shared). Editing a variant's headline is in scope. For a previously inherited section, copy its complete list from the resolved parent content into the overlay **unchanged first**, then apply only the requested copy adjustment. For an existing override, edit its current list in place.
- A section override replaces the whole list; arrays are not appended or merged by index. Retain all untouched entries/bullets and the existing facts. Leave unrelated sections inheriting, and explain that an overridden section no longer receives baseline copy updates automatically. Never silently remove or reorder work history or substantive content.
- Limit changes to requested wording/content in existing sections, such as summary prose and bullet text. Factual corrections need user-supplied information or confirmation. Preserve existing presentation markup unless its change is explicitly part of the wording request; do not use markup as a style workaround.
- Do not rename/reorder shared headings, add variant-only section headings, change shared identity/contact text, or edit `variants/default.yml`, `design`, `settings`, `locale`, `classic/`, the Makefile, composition tooling, or layout policy. Requests needing those changes are outside this copy-only workflow: explain the conflict and obtain a separately scoped request.
- Never edit generated Typst/PDF/YAML, generated template copies under `build/`, frozen `resume.tex`, or original reference PDFs. Do not modify any unselected variant.
- Compare parsed shared configuration and unselected overlay values against their pre-edit state, not Git HEAD, and inspect the final diff to confirm only authorized copy changed.

Keep the two-page layout contract and all current style settings unchanged. You may refine the requested copy to fit while preserving its meaning and confirmed facts. If fitting requires material cuts beyond the request, propose them and ask approval. If it requires styling changes, report BLOCKED and propose a separate `resume-update` operation; do not tighten spacing, shrink type, or weaken policy here. The layout skill's spacing/margin fallback suggestions do not expand this skill's scope.

## 3. Finalize and audit the confirmed variant

Once the requested copy edits and source/diff checks are complete and ready for final PDF handoff, read `../resume-layout/SKILL.md` in full and run its finalization workflow once per selected variant:

```sh
VARIANT=react-native
make check-layout VARIANT="$VARIANT"
```

Require a successful exit. Substitute the actual variant name. Never pass the overlay as `SOURCE`; it is not a complete RenderCV document. Do not combine `SOURCE` with `VARIANT`.

The audit renders its own fresh PDF; no preceding `make pdf` is needed. Use `make pdf VARIANT="$VARIANT"` only for a requested draft or a separately needed build-path PDF (`build/variants/<variant>/resume.pdf`). A draft build does not trigger an audit.

Read the fresh `report.json` and `compile.log` under `build/layout-audit/<variant>/`; the audit artifact is named `resume.pdf`. Complete the layout skill's agent visual inspection on that artifact. If the audit or review fails, batch authorized fixes before re-auditing affected variants. Reuse a passing audit/review for unchanged effective source; do not repeat it for each calling skill or repeated handoff.

## 4. Open the exact reviewed PDF in Preview

After automated and agent visual checks pass, open the same audited artifact inspected above:

```sh
VARIANT=react-native
open -a Preview "build/layout-audit/$VARIANT/resume.pdf"
```

Check the command's exit status. If Preview or the desktop session is unavailable, report the handoff as blocked and provide the exact path. A successful launch request is not evidence of the user's approval.

End with a concise handoff stating:

- The variant(s), copy changes, and overlay source paths; shared layout/style and unselected variants were unchanged.
- Per-variant layout PASS / FAIL / BLOCKED, actual page count, section page spans, body font/baseline, and agent visual-review status.
- Exact audited PDF paths and whether they were opened in Preview.

Leave final approval to the user. Do not make additional changes while waiting for feedback.
