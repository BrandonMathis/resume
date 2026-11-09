---
name: resume-update
description: Apply layout and style changes only to the shared resume design and templates, without modifying copy. Batch edits, then at finalization audit the baseline and all variants once and open the audited PDFs in macOS Preview for the user's review. Use for resume formatting, spacing, typography, or visual presentation changes; use resume-copy-update for wording or content changes.
compatibility: Requires macOS Preview and the dependencies documented by the project's resume-layout skill.
---

# Update resume layout/style and preview

Treat the user's arguments as a layout/style request. Complete the requested presentation edits first, then finalize with a fresh automated layout audit and Preview handoff. Do not run layout audits during drafting or after each small revision. If the user only requests proposals or a working draft, stop there without finalization and label any draft PDF unaudited. Agent visual inspection (rendering pages to images and reviewing them) is **not required** for this skill; this overrides the visual-review step in `../resume-layout/SKILL.md`. The user reviews the opened PDFs. This skill must not change resume copy, even to resolve overflow.

## 1. Establish scope

- Work from the project root, three directories above this skill directory.
- Read the project `README.md` and Makefile; consult `../resume-layout/SKILL.md` for layout constraints as needed, and read it in full at finalization. Reading it does not trigger an audit. The layout contract remains mandatory throughout; the automated audit is the finalization gate. Skip its agent visual-review step.
- Inspect `git status --short`, relevant existing diffs, `variants/default.yml`, the content overlays, and shared templates. Preserve unrelated and uncommitted work.
- Allowed edits: shared `design` settings in `variants/default.yml` and presentation rules in `classic/`. Do not create per-variant layouts or edit generated files.
- Forbidden edits: any `cv` values, variant copy, section names/order, facts, dates, links, identity/contact text, locale wording, or content-bearing template text. Template changes must preserve which content is shown and its reading order; do not hide, truncate, drop, duplicate, or rewrite content as a formatting fix.
- Capture the pre-edit parsed `cv`, `locale`, and overlay values and verify they remain unchanged after editing. Inspect template diffs for content changes too. Preserve pre-existing user copy changes rather than reverting them to Git HEAD.
- If the request is copy-only, use `../resume-copy-update/SKILL.md` instead and follow its mandatory variant question. For a mixed request, separate the scopes explicitly; this skill does not authorize the copy portion.
- If no adjustment or source change is supplied, ask what layout/style change is wanted. If the user already made the adjustment, inspect the diff and validate it rather than duplicating it.

## 2. Apply only the presentation adjustment

Make the smallest shared design/template change that satisfies the request. `variants/default.yml` and `classic/` are the only layout sources; every variant inherits them. A request to style only one variant conflicts with the shared-layout architecture: explain this and ask before proceeding, rather than introducing a private style override.

Never edit generated Typst/PDF files, generated template copies under `build/`, frozen `resume.tex`, or original reference PDFs.

Keep exactly two readable US Letter pages:

- Page 1: name/contact details, summary, and all professional experience.
- Page 2: education, community leadership, and all other supporting sections.
- Preserve the single explicit supporting-section break, Helvetica, 10 pt body text, 12 pt baselines, other locked sizes, and minimum margins. A deliberate change to locked typography requires explicit approval under the layout policy; never weaken the policy merely to pass.

The layout auditor's text-first troubleshooting advice is **not permission to edit copy in this skill**. If the requested styling cannot fit the unchanged content, report the conflict and propose a separate copy-update workflow. Do not shorten wording, remove bullets, or silently change facts to make the layout pass.

## 3. Finalize and audit every affected resume

Once the requested presentation edits and source/diff checks are complete and ready for final PDF handoff, read `../resume-layout/SKILL.md` in full. Shared presentation edits affect all variants, including `default`. Discover them with `make variants` and audit each exactly once; do not separately audit default a second time. Require successful exits. For **each** discovered variant, substitute its actual name:

```sh
VARIANT=full-stack
make check-layout VARIANT="$VARIANT"
```

Do not combine `SOURCE` and `VARIANT`. Each audit renders its own fresh PDF; no preceding `make pdf` is needed. Use separate `make pdf` builds only for requested drafts or separately needed build-path PDFs; draft builds do not trigger audits. Read each fresh `report.json` and `compile.log` under `build/layout-audit/<variant>/` (including `default`). The audit artifact is always named `resume.pdf`.

If finalization fails, batch authorized fixes before re-auditing affected resumes. Further shared presentation changes invalidate all affected results; re-audit at the next finalization, not after each small edit. Reuse passing audits while effective source is unchanged, without repeating them through calling skills or repeated handoffs. Compilation alone, a stale PDF, or one passing variant does not approve a shared layout. If blocked by dependencies or unresolved violations, report the affected resumes; do not open an old PDF as if it were the update.

A failing artifact may be opened only as a clearly labeled diagnostic.

## 4. Open the exact audited PDFs in Preview

After the automated checks pass, open each freshly audited PDF, not an older build PDF. Set `STEM=default` for the baseline or the actual variant name:

```sh
STEM=full-stack
open -a Preview "build/layout-audit/$STEM/resume.pdf"
```

Check each command's exit status. If Preview or the desktop session is unavailable, report the handoff as blocked and provide exact paths. A successful launch request is not evidence of the user's approval.

End with a concise handoff stating:

- What presentation changed, the source/template paths, and confirmation that no copy was modified.
- Per-resume automated layout PASS / FAIL / BLOCKED, actual page count, section page spans, and body font/baseline. Note that agent visual inspection was not performed; visual approval is pending the user's review. Do not call the resume finished based on automated checks or a successful Preview launch alone.
- Exact audited PDF paths and whether they were opened in Preview.

Leave final approval to the user. Do not make additional changes while waiting for feedback.
