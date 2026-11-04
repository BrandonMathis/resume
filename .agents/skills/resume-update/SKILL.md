---
name: resume-update
description: Apply a requested resume adjustment, build a fresh PDF, follow the resume-layout audit and visual inspection workflow, and open the checked PDF in macOS Preview for the user's review. Use when asked to update or revise this resume and show the result, or to build and preview an adjustment the user already made.
compatibility: Requires macOS Preview and the dependencies documented by the project's resume-layout skill.
---

# Update and preview the resume

Treat the user's arguments as the requested adjustment. Complete the edit, layout review, and Preview handoff in one workflow; do not stop after changing YAML or merely suggest that the user open the PDF.

## 1. Establish the requested change

- Work from the resume project root, three directories above this skill directory.
- Read `../resume-layout/SKILL.md` in full and follow its audit workflow. Its policy is mandatory; this skill does not replace it.
- Inspect `git status --short`, the relevant existing changes, the selected YAML, and the Makefile before editing. Preserve unrelated and uncommitted work.
- Default to `resume.yaml`, the authoritative source. If the user names a variation, use that YAML consistently. Create a variation alongside `resume.yaml` only when requested; give it distinct output paths under `settings.render_command` so it cannot overwrite the main resume's outputs.
- If the user describes a change they already made, inspect the source/diff first. Do not duplicate an existing adjustment; build and review it instead.
- If no adjustment or source change is supplied, ask what to change. Ask about materially ambiguous facts rather than inventing roles, dates, achievements, or metrics.

## 2. Apply the adjustment

Edit the YAML with the smallest changes that satisfy the request. Never edit generated Typst/PDF files or the frozen `resume.tex` reference. Do not overwrite original reference PDFs.

Keep exactly two readable US Letter pages:

- Page 1: name/contact details, summary, and all professional experience.
- Page 2: education, community leadership, and all other supporting sections.
- Preserve the single explicit break before the first supporting section, Helvetica, 10 pt body text, 12 pt baselines, and the layout skill's other locked sizes and margin rules.

Shorten repetitive wording before tightening permitted positive spacing. Preserve facts and meaningful results; do not silently remove work history or substantive content. If fitting requires material cuts outside the request, propose them and ask for approval. Never weaken the layout policy to obtain a pass.

## 3. Build and audit fresh output

From the project root, set `SOURCE` to the selected YAML path (the example is the default). Run these commands separately so a failed build or audit cannot be hidden by a later successful command:

```sh
SOURCE=resume.yaml
make pdf SOURCE="$SOURCE"
```

```sh
SOURCE=resume.yaml
make check-layout SOURCE="$SOURCE"
```

For a variation, replace `resume.yaml` in both commands. Require successful exits and read the fresh `report.json` and `compile.log` under `build/layout-audit/<source-stem>/`. The audit artifact is named `resume.pdf` even when the source is a variation.

Follow the layout skill's diagnosis/fix order if anything fails. After any meaningful revision, rebuild and repeat the audit. A stale PDF, successful compilation alone, or automated audit alone is not approval. If a dependency or unresolved violation blocks progress, report it; do not open an old PDF as if it were the update.

## 4. Inspect every page

Render the freshly audited PDF to images. For the default source:

```sh
pdftoppm -scale-to 1600 -png \
  build/layout-audit/resume/resume.pdf \
  build/layout-audit/resume/page
```

Use the selected source stem instead of the directory `resume` for a variation. Read every actual page image with an image-reading tool; do not assume a two-page count or inspect only page one. Check clipping, collisions, wrapping, readability, spacing, hierarchy, and stranded headings or entries. Fix issues and repeat the fresh build, audit, and image inspection.

If image inspection is unavailable, explicitly mark visual inspection as blocked. You may still open the fresh artifact for the user's review, but do not claim layout approval. A failing artifact may be opened only as a clearly labeled diagnostic, not a finished update.

## 5. Open the exact reviewed PDF in Preview

After automated and agent visual checks pass, open the same audited artifact you inspected, not an older published PDF. On macOS, explicitly select Preview:

```sh
open -a Preview "build/layout-audit/resume/resume.pdf"
```

For a variation, substitute its source-stem directory. Check the command's exit status. If opening fails or the desktop session is unavailable, report the handoff as blocked and provide the exact PDF path; do not claim Preview opened. A successful launch request is not evidence of the user's visual approval.

End with a concise handoff stating:

- What changed and the YAML source path.
- Layout PASS / FAIL / BLOCKED, actual page count, section page spans, confirmed body font/baseline, and whether agent visual inspection passed.
- The exact audited PDF path and whether it was opened in Preview for the user's review.

Leave final user approval to the user. Do not make additional changes while waiting for their feedback.
