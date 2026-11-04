---
name: resume-copy-update
description: Update resume wording and content only, never layout or style. Always ask the user to confirm which resume variant to update before editing, even when one is named. Build that variant's fresh PDF, run the resume-layout audit and visual inspection, and open the exact reviewed PDF in macOS Preview. Use for summaries, bullets, experience wording, or other resume copy changes.
compatibility: Requires macOS Preview and the dependencies documented by the project's resume-layout skill.
---

# Update resume copy and preview

Treat the user's arguments as a copy-change request. Complete the variant confirmation, permitted content edit, fresh build, layout review, and Preview handoff in one workflow. Do not modify presentation to accommodate the new copy.

## 1. Always ask which variant to update

- Work from the project root, three directories above this skill directory.
- Read `../resume-layout/SKILL.md` in full, plus the project `README.md` and Makefile. Inspect `git status --short`, relevant diffs, the baseline, and existing overlays without modifying anything.
- Discover available variants with `make variants`. The initial variants are `full-stack` and `react-native`; do not hard-code the list if it has changed.
- **Always ask the user which variant(s) to update and wait for an explicit answer before any edits, builds, audits, or Preview launch.** If they already named a variant in the initiating request, ask them to confirm that selection anyway. Do not infer the target from conversation history, the current file, previous builds, or the type of copy requested.
- Example when no target was supplied: “Which resume variant should I update: full-stack or react-native?” If one was supplied: “Please confirm: should I apply these copy changes to the react-native variant only?”
- Ask once at the start of each new copy-update operation. A clear answer authorizes the selected target(s) for subsequent revisions in that same operation; do not repeatedly ask during its build/audit loop. Changing targets requires new confirmation.
- Never default to all variants or to `resume.yaml`. Multiple variants require explicit confirmation, and each gets its own edit and audit. If a new variant is requested, confirm its name and creation before creating a content-only overlay.
- This workflow edits variant copy only; the shared baseline is read-only. If the user wants shared baseline or identity/contact changes, explain their broader inheritance impact and handle that as a separately scoped request rather than silently making a variant edit global.
- If the adjustment itself is unspecified, ask what to change as well. Ask about ambiguous facts; never invent roles, dates, achievements, technologies, or metrics.

## 2. Apply only copy changes to the confirmed overlay

Edit `variants/<confirmed-name>.yaml`, never its generated RenderCV input. Preserve unrelated and uncommitted work. If the user already made the copy adjustment, inspect the diff after confirming the target and validate it rather than duplicating it.

- Read the effective content: baseline `cv.sections` plus the selected overlay's existing replacements. Do not start from baseline content when that would discard an existing tailored section.
- Overlays contain only a `sections` mapping. For a previously inherited section, copy its complete list from `resume.yaml` into the overlay **unchanged first**, then apply only the requested copy adjustment. For an existing override, edit its current list in place.
- A section override replaces the whole list; arrays are not appended or merged by index. Retain all untouched entries/bullets and the existing facts. Leave unrelated sections inheriting, and explain that an overridden section no longer receives baseline copy updates automatically. Never silently remove or reorder work history or substantive content.
- Limit changes to requested wording/content in existing sections, such as summary prose and bullet text. Factual corrections need user-supplied information or confirmation. Preserve existing presentation markup unless its change is explicitly part of the wording request; do not use markup as a style workaround.
- Do not rename/reorder shared headings, add variant-only section headings, change shared identity/contact text, or edit `resume.yaml`, `design`, `settings`, `locale`, `classic/`, the Makefile, composition tooling, or layout policy. Requests needing those changes are outside this copy-only workflow: explain the conflict and obtain a separately scoped request.
- Never edit generated Typst/PDF/YAML, generated template copies under `build/`, frozen `resume.tex`, or original reference PDFs. Do not modify any unselected variant.
- Compare parsed shared configuration and unselected overlay values against their pre-edit state, not Git HEAD, and inspect the final diff to confirm only authorized copy changed.

Keep the two-page layout contract and all current style settings unchanged. You may refine the requested copy to fit while preserving its meaning and confirmed facts. If fitting requires material cuts beyond the request, propose them and ask approval. If it requires styling changes, report BLOCKED and propose a separate `resume-update` operation; do not tighten spacing, shrink type, or weaken policy here. The layout skill's spacing/margin fallback suggestions do not expand this skill's scope.

## 3. Build and audit the confirmed variant

After target confirmation and the permitted edit, set `VARIANT` to that confirmed name. Run these commands separately and require successful exits:

```sh
VARIANT=react-native
make pdf VARIANT="$VARIANT"
```

```sh
VARIANT=react-native
make check-layout VARIANT="$VARIANT"
```

Substitute the confirmed name consistently in both commands. Never pass the overlay as `SOURCE`; it is not a complete RenderCV document. Do not combine `SOURCE` with `VARIANT`.

The generated build PDF is `build/variants/<variant>/<variant>.pdf`. Read the fresh `report.json` and `compile.log` under `build/layout-audit/<variant>/`; the audit artifact is named `resume.pdf`.

After any meaningful copy revision, rebuild and repeat the fresh audit. If multiple variants were confirmed, repeat the workflow for each without touching unselected variants. A stale PDF, compilation alone, or automated audit alone is not approval. Report unresolved errors rather than opening old output as if it were current.

## 4. Inspect every actual page

Render the freshly audited PDF, using the confirmed variant name:

```sh
VARIANT=react-native
pdftoppm -scale-to 1600 -png \
  "build/layout-audit/$VARIANT/resume.pdf" \
  "build/layout-audit/$VARIANT/page"
```

Read every actual page image with an image-reading tool. Check wrapping, clipping, collisions, readability, hierarchy, and stranded headings/entries. Require exactly two pages: header, summary, and all experience on page one; education/community/supporting content on page two. Confirm the requested copy is present without losing unrelated content.

Fix only in-scope copy issues, then repeat build, audit, and image inspection. If image inspection is unavailable, mark visual review BLOCKED. A fresh artifact may still be opened for user review, but do not claim approval. A failing artifact may be opened only as a clearly labeled diagnostic.

## 5. Open the exact reviewed PDF in Preview

After automated and agent visual checks pass, open the same audited artifact inspected above:

```sh
VARIANT=react-native
open -a Preview "build/layout-audit/$VARIANT/resume.pdf"
```

Check the command's exit status. If Preview or the desktop session is unavailable, report the handoff as blocked and provide the exact path. A successful launch request is not evidence of the user's approval.

End with a concise handoff stating:

- The confirmed variant(s), copy changes, and overlay source paths; confirm shared layout/style and unselected variants were unchanged.
- Per-variant layout PASS / FAIL / BLOCKED, actual page count, section page spans, body font/baseline, and agent visual-review status.
- Exact audited PDF paths and whether they were opened in Preview.

Leave final approval to the user. Do not make additional changes while waiting for feedback.
