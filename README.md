# Brandon Mathis resume

The resume is maintained in [RenderCV](https://docs.rendercv.com/) YAML and rendered with Typst. **`variants/default.yml` is authoritative.** No LaTeX installation is needed.

## Career knowledge base

Start at [`knowledge-base/README.md`](knowledge-base/README.md) for sourced career history, projects, skills, AI engineering, open-source contributions, writing, speaking, and community leadership. It includes structured claims, downloaded source snapshots, complete retrieved GitHub inventories, and unresolved factual questions. Research is dated **November 4, 2026**; self-reported metrics and conflicting dates are explicitly flagged.

This is reference material for future tailoring, not a second resume source of truth. No resume copy or layout was changed to create it. Follow the existing variant-confirmation and layout-audit workflow when applying any evidence to a resume.

```sh
ruby knowledge-base/tools/build_indexes.rb  # Offline: rebuild inventories from saved sources
ruby knowledge-base/tools/validate.rb       # Check evidence references and archive integrity
```

## Files

- `variants/default.yml` — full RenderCV configuration: authoritative baseline copy, shared identity, design, locale, and settings (moved unchanged from `resume.yaml`).
- `variants/enhanced-kimi-k3.yml`, `variants/full-stack.yml`, `variants/react-native.yml` — content-only overrides with `inherits: default`. `enhanced-kimi-k3` and `full-stack` replace selected sections; `full-stack` also sets a headline. `react-native` inherits all default copy unchanged.
- `scripts/resume_variant.rb` — composes overlays with the baseline and runs the shared build/audit workflow.
- `classic/Preamble.j2.typ` — local RenderCV template override for the explicit page break before Education and fixed body line height.
- `classic/Header.j2.typ` — header rule and a scoped Typst link renderer: plain email, bold contact links using `design.colors.links`. RenderCV still supplies escaped contact text, icons, and ordering; no generated-code string parsing is used. Body links keep RenderCV's normal styling. Review the link wrapper when upgrading RenderCV.
- `resume.tex` — retained pre-migration reference; do not edit it for new resumes.
- `Brandon Resume 2026 Q3.pdf`, `Fullstack Brandon Resume 2026.pdf` — original references, unchanged.
- `phantom wallet suggested-changes.md` — existing notes, unchanged.
- `.agents/skills/resume-layout/` — layout policy, fresh-render auditor, and regression tests.

All original experience and community bullets, roles, dates, and quantified results are retained. A short summary, grounded in the existing experience, was added to satisfy the layout contract. LaTeX escapes were removed and date/contact formatting normalized.

## Setup and build

On macOS:

```sh
brew install uv poppler
make pdf
open build/variants/default/default.pdf
```

The Makefile uses **RenderCV 2.8** with Python 3.13 through `uv tool run`; uv provisions Python and dependencies as needed. First use requires internet access for the runtime, fonts, and Typst packages. RenderCV includes its Typst compiler. The design uses the **Helvetica** family supplied by macOS; other systems need that font installed. The audit rejects font fallback rather than silently changing the appearance. The auditor also needs Ruby with REXML (`gem install rexml` if missing); tests need Minitest (`gem install minitest` if missing).

Generated files are ignored by Git:

- `build/variants/default/default.pdf` — searchable, tagged default PDF.
- `build/variants/default/default.typ` — generated Typst; inspect, but do not edit.
- `build/variants/<name>/<name>.yaml` — generated, fully resolved RenderCV input; never edit.

Builds produce PDFs only; Markdown, HTML, and PNG exports are disabled (`dont_generate_*` in `settings.render_command`, also forced for variants).

```sh
make watch       # Re-render on changes; Ctrl-C to stop
make clean       # Remove build output, not source or reference PDFs
```

## Edit or tailor

Edit `cv` in `variants/default.yml` for shared baseline changes. Each section is a list of RenderCV entries; each `highlights` item is a bullet. Text supports Markdown links, bold, and italics. Use plain `&` instead of LaTeX `\&`; quote YAML strings containing `: ` or `#`.

`design` controls typography and spacing; `settings.render_command` controls output paths. Keep the two-page contract:

1. Page one: name/contact details, Summary, and **all** Recent Work Experience.
2. Page two: Education and Leadership & Community Activities (plus any supporting sections).

Keep Helvetica, 10 pt body text, **12 pt baseline distance**, 9 pt contacts, 12 pt section titles, and at least 0.5-inch margins. Typst's `line_spacing` is a gap, not a baseline multiplier: `2pt` plus the template's 10 pt text frame yields 12 pt baselines. The negative bottom-edge coordinate denotes the descender below the baseline; it is not negative spacing or glyph scaling. The old TeX points were 1/72.27 inch; Typst/PDF points are 1/72 inch, so the new 10/12 pt text is fractionally larger.

`classic/Preamble.j2.typ` starts a new page at **Education**. If that heading changes, update the split in the template too; the auditor checks that the break matches the first supporting section. It renders two styled content groups because RenderCV does not permit a raw page break inside its section containers. The preamble configuration is copied from RenderCV 2.8; review it when upgrading RenderCV. Shorten text before tightening positive gaps; never shrink type or line height to fit.

### Content-only variants

Do **not** copy the entire baseline for each audience. The flow is:

```text
variants/default.yml → variants/<name>.yml (inherits: default)
    + classic/ (shared templates)
    → build/variants/<name>/<name>.yaml (generated RenderCV input)
    → build/variants/<name>/<name>.pdf
    → fresh layout audit → visual inspection → publish
```

The available variants are `default`, `enhanced-kimi-k3`, `full-stack`, and `react-native`. `default` is a complete RenderCV document; every other variant declares a parent using `inherits: default` and supplies a `sections` mapping. An overlay may also set an optional single-line `headline:` (for example `headline: Full Stack Software Engineer`), rendered under the name at the shared 12 pt bold headline style in `variants/default.yml` and checked by the auditor (`headline_tex_pt`). The default has no headline. Name/contact information, section order/headings, design, locale, templates, and PDF title always come from default. Only generated output filenames differ.

Parents are variant names, not paths or filenames. An overlay can inherit from another overlay (for example `inherits: full-stack`); chains resolve parent-first and must ultimately reach `default`. Missing parents, unsafe names, and inheritance cycles fail before rendering. Both `.yml` and `.yaml` variant files are supported, but duplicate names across extensions are rejected. Keep new source files as `.yml`.

```sh
make variants                         # List all variants, including default
make pdf                              # Build default
make preview default                  # Build, audit, and open default
make preview full-stack               # Build, audit, then open the fresh audit PDF in Preview
make open react-native                # Open existing build PDF without rebuilding or auditing
make previews                         # Build, audit, and open every variant; stop on failure
make pdf VARIANT=full-stack
make pdf VARIANT=react-native
make pdfs                             # Build every variant
make compose VARIANT=full-stack       # Inspect resolved YAML without rendering
make watch react-native               # Rebuild watch.pdf on edits; open Preview once
make check-layout VARIANT=full-stack  # Fresh audit of the composed source
make check-layouts                    # Audit every variant; stop on first failure
make test-variants                    # Fast composition/guardrail regression tests
make test                             # Variant tests plus existing layout tests
open build/variants/full-stack/full-stack.pdf
```

For `preview`, `open`, `pdf`, `watch`, `check-layout`, and `compose`, you can use either `make <command> <variant>` or `make <command> VARIANT=<variant>`. For example, `make watch react-native` updates a live preview as you edit. Use one command with a positional variant; for multiple commands, keep `VARIANT=...` (e.g. `make pdf check-layout VARIANT=full-stack`). Unknown variants and conflicting selections fail before running.

`preview` defaults to `default` and opens `build/layout-audit/<variant>/resume.pdf` only after both the build and fresh automated audit succeed. A failed audit never opens an old PDF. **Opening a preview is not visual approval:** inspect both pages before publishing. `open` likewise defaults to `default`; it opens `build/variants/<variant>/<variant>.pdf` as-is, which may be stale, and reports an error if missing. Both use macOS Preview and report launch failures. `previews` discovers variants automatically and stops at the first failed build, audit, or launch.

All single-variant commands default to `default` when no variant is selected, using the same composition, build, and audit pipeline as other variants. The default PDF is `build/variants/default/default.pdf`; its audit is under `build/layout-audit/default/`. There is no root `resume.yaml` to edit or render. `SOURCE=tailored.yaml` remains available for standalone/legacy `pdf`, `watch`, and `check-layout` commands; do not combine `SOURCE` with an explicit `VARIANT`.

### Live preview

```sh
make watch full-stack
# Or: make watch react-native
# Ctrl-C to stop
```

The variant watcher builds `build/variants/<variant>/watch.pdf` directly and opens it in macOS Preview once. It polls default, every overlay in the selected inheritance chain, and shared templates once per second and rebuilds that same PDF whenever their contents change. The watcher does not copy PDFs, replace them with audit artifacts, or repeatedly reopen the viewer. Preview can retain a stale view even after a successful rebuild; close and reopen `watch.pdf` if changes are not visible. For dependable automatic reloads, Skim supports checking for file changes and reloading automatically; the current watcher still opens Preview.

Live output is an **unaudited working draft**: layout failures do not suppress updates. Use `make preview <variant>` or `make check-layout <variant>` and inspect both pages before publishing. Invalid YAML and renderer errors are logged, and the watcher keeps running so corrected edits can rebuild. Edits made during a build are picked up on the next poll. Restart the watcher after changing the watcher script itself; an already-running Ruby process otherwise keeps its old code.

Variant section overrides still apply: changes to an overridden section in `variants/default.yml` will not change that variant's copy. Shared design changes and non-overridden sections are inherited normally.

No extra viewer or dependencies are required. Plain `make watch` uses this same watcher for `default`; `make watch SOURCE=tailored.yaml` uses RenderCV's standalone render-only watcher.

**When copy changes are requested later:**

1. For shared changes, edit `cv` in `variants/default.yml`. Every section not overridden inherits that update on the next build.
2. For audience-specific changes, copy only the relevant section's complete list from `cv.sections` into the variant's `sections` mapping, then edit that list. For example, to start tailoring only the summary *without changing its wording*, the overlay would be:

   ```yaml
   inherits: default
   sections:
     Summary:
       - >-
         Engineering leader and former CTO building web, mobile, and real-time platforms.
         Hands-on experience in enterprise delivery, engineering management, and AI-enabled products.
   ```

3. A section override **replaces its whole list**; arrays are never concatenated or merged by position. Untouched sections continue to inherit. Once overridden, a section no longer receives baseline copy updates: review it deliberately when shared facts change. Delete an override to restore inheritance.
4. New/renamed headings belong in the baseline and shared template/audit policy, not individual overlays. Unknown headings, empty section lists, empty or multi-line headlines, missing `inherits`, and overlay-level design/settings/name/contact overrides are rejected. RenderCV validates the entries themselves.
5. Build, audit, and visually inspect each changed variant before publishing. Different copy lengths can overflow even though the layout is identical. Never fix a variant by introducing a private layout or shrinking type.

To add another audience, create `variants/<lowercase-hyphenated-name>.yml` with:

```yaml
inherits: default
sections: {}
```

This inherits the entire default without duplicating copy, design, or settings. The list and bulk commands discover it automatically. No Makefile or shared-layout copy is needed. Generated YAML and template copies under `build/` are disposable; never edit them. `make clean` removes them without touching overlays.

The legacy TeX source remains in Git for comparison; it is not another active source of truth.

## Update skills

- **`resume-update`** — layout/style only, in the shared design/templates. Preserves all copy, batches edits, then audits every discovered variant (including `default`) once at finalization and opens the exact audited PDFs in Preview. Agent image inspection is not required by this workflow; visual approval remains pending your review.
- **`resume-copy-update`** — copy only, in the selected variant overlays. Always asks you to confirm which variant(s) before editing, even if you already named one. Batches edits, then audits, visually inspects, and opens each confirmed variant's reviewed PDF in Preview at finalization; never changes shared layout/style or unselected variants.

Both use `resume-layout` as a single finalization gate, not a per-edit hook. Research, copy proposals, instruction/tooling-only edits, and draft/watch builds do not trigger audits. Audit once per affected resume when ready for final PDF handoff/publishing, or on an explicit audit request. If finalization fails, batch authorized fixes before re-auditing. Reuse passing audits/reviews while effective content, design, templates, and audit policy/tooling are unchanged; later changes require a fresh check at the next finalization. The audit renders its own fresh PDF, so no preceding `make pdf` is needed unless a separate build-path PDF is wanted. If a fix needs changes outside a skill's scope, it stops and asks rather than silently changing copy to fix style or style to fit copy.

## Audit before publishing

```sh
make test-layout
make check-layout
```

The Ruby checker always renders **fresh YAML** in a temporary output directory, then extracts the actual PDF. It checks exactly two nonempty US Letter pages, section order and page spans (including experience continuations), the explicit break, typography, font family, rendered body-row spacing, and minimum margins. It does not modify build-path PDFs or the original PDFs. Missing dependencies or unsupported measurements fail closed. The existing REXML dependency-error handling is preserved.

Artifacts are saved under `build/layout-audit/<source-stem>/`: `resume.pdf`, `resume.typ`, `compile.log`, and `report.json`. Exit codes: `0` automated pass, `1` layout violation, `2` blocked/error. Legacy `.tex` audits remain available with `--source resume.tex` if Tectonic or pdfLaTeX is installed; the old source lacks a summary and is not the approved resume.

**A successful build or automated pass is not visual approval.** Read the report and compiler log, render every actual page, and inspect for clipping, collisions, stranded headings, crowded text, and awkward wrapping:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/default/resume.pdf build/layout-audit/default/page
```

Variant audit artifacts are isolated under `build/layout-audit/<name>/`, including `default`, `enhanced-kimi-k3`, `full-stack`, and `react-native`. For example:

```sh
make check-layout VARIANT=react-native
pdftoppm -scale-to 1600 -png build/layout-audit/react-native/resume.pdf build/layout-audit/react-native/page
```

Inspect **both** page images and read that directory's `report.json` and `compile.log`. Variant build PDFs and baseline/reference PDFs are not overwritten by an audit.

The full workflow and troubleshooting order are in `.agents/skills/resume-layout/SKILL.md`.
