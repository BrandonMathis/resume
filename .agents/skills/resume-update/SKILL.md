---
name: resume-update
description: Apply layout and style changes only to the shared resume design and templates, without modifying copy. Build fresh PDFs, run the automated layout audit for the baseline and all variants, and open the audited PDFs in macOS Preview for the user's review. Use for resume formatting, spacing, typography, or visual presentation changes; use resume-copy-update for wording or content changes.
compatibility: Requires macOS Preview and the dependencies documented by the project's resume-layout skill.
---

# Update resume layout/style and preview

Treat the user's arguments as a layout/style request. Complete the permitted edit, fresh build, automated layout audit, and Preview handoff in one workflow. Agent visual inspection (rendering pages to images and reviewing them) is **not required** for this skill; this overrides the visual-review step in `../resume-layout/SKILL.md`. The user reviews the opened PDFs. This skill must not change resume copy, even to resolve overflow.

## 1. Establish scope

- Work from the project root, three directories above this skill directory.
- Read `../resume-layout/SKILL.md` in full, plus the project `README.md` and Makefile. The layout contract and automated audit remain mandatory; skip its agent visual-review step.
- Inspect `git status --short`, relevant existing diffs, `resume.yaml`, the content overlays, and shared templates. Preserve unrelated and uncommitted work.
- Allowed edits: shared `design` settings in `resume.yaml` and presentation rules in `classic/`. Do not create per-variant layouts or edit generated files.
- Forbidden edits: any `cv` values, variant copy, section names/order, facts, dates, links, identity/contact text, locale wording, or content-bearing template text. Template changes must preserve which content is shown and its reading order; do not hide, truncate, drop, duplicate, or rewrite content as a formatting fix.
- Capture the pre-edit parsed `cv`, `locale`, and overlay values and verify they remain unchanged after editing. Inspect template diffs for content changes too. Preserve pre-existing user copy changes rather than reverting them to Git HEAD.
- If the request is copy-only, use `../resume-copy-update/SKILL.md` instead and follow its mandatory variant question. For a mixed request, separate the scopes explicitly; this skill does not authorize the copy portion.
- If no adjustment or source change is supplied, ask what layout/style change is wanted. If the user already made the adjustment, inspect the diff and validate it rather than duplicating it.

## 2. Apply only the presentation adjustment

Make the smallest shared design/template change that satisfies the request. `resume.yaml` and `classic/` are the only layout sources; every variant inherits them. A request to style only one variant conflicts with the shared-layout architecture: explain this and ask before proceeding, rather than introducing a private style override.

Never edit generated Typst/PDF files, generated template copies under `build/`, frozen `resume.tex`, or original reference PDFs.

Keep exactly two readable US Letter pages:

- Page 1: name/contact details, summary, and all professional experience.
- Page 2: education, community leadership, and all other supporting sections.
- Preserve the single explicit supporting-section break, Helvetica, 10 pt body text, 12 pt baselines, other locked sizes, and minimum margins. A deliberate change to locked typography requires explicit approval under the layout policy; never weaken the policy merely to pass.

The layout auditor's text-first troubleshooting advice is **not permission to edit copy in this skill**. If the requested styling cannot fit the unchanged content, report the conflict and propose a separate copy-update workflow. Do not shorten wording, remove bullets, or silently change facts to make the layout pass.

## 3. Build and audit every affected resume

Shared presentation edits affect the baseline and all variants. Discover the current variants with `make variants`; do not assume the list is limited to the initial two. Run commands separately and require successful exits:

```sh
make pdf
```

```sh
make check-layout
```

For **each** discovered variant, substitute its actual name:

```sh
VARIANT=full-stack
make pdf VARIANT="$VARIANT"
```

```sh
VARIANT=full-stack
make check-layout VARIANT="$VARIANT"
```

Use the same name for the paired commands; do not combine `SOURCE` and `VARIANT`. Read each fresh `report.json` and `compile.log` under `build/layout-audit/resume/` and `build/layout-audit/<variant>/`. The audit artifact is always named `resume.pdf`.

After any meaningful revision, rebuild and re-audit the baseline and every variant. Compilation alone, a stale PDF, or one passing variant does not approve a shared layout. If blocked by dependencies or unresolved violations, report the affected resumes; do not open an old PDF as if it were the update.

A failing artifact may be opened only as a clearly labeled diagnostic.

## 4. Open the exact audited PDFs in Preview

After the automated checks pass, open each freshly audited PDF, not an older build PDF. Set `STEM=resume` for the baseline or the actual variant name:

```sh
STEM=full-stack
open -a Preview "build/layout-audit/$STEM/resume.pdf"
```

Check each command's exit status. If Preview or the desktop session is unavailable, report the handoff as blocked and provide exact paths. A successful launch request is not evidence of the user's approval.

End with a concise handoff stating:

- What presentation changed, the source/template paths, and confirmation that no copy was modified.
- Per-resume layout PASS / FAIL / BLOCKED, actual page count, section page spans, and body font/baseline. Note that agent visual inspection was not performed; visual review is left to the user.
- Exact audited PDF paths and whether they were opened in Preview.

Leave final approval to the user. Do not make additional changes while waiting for feedback.
