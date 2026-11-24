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
- `variants/<name>.yml` — optional audience-specific, content-only overrides with `inherits: default`; create these as needed rather than duplicating the baseline.
- `scripts/resume_variant.rb` — composes overlays with the baseline and runs the shared build/audit workflow.
- `classic/Preamble.j2.typ` — local RenderCV template override for the explicit page break before Education and fixed body line height.
- `classic/Header.j2.typ` — header rule and a scoped Typst link renderer: plain email, bold contact links using `design.colors.links`. RenderCV still supplies escaped contact text, icons, and ordering; no generated-code string parsing is used. Body links keep RenderCV's normal styling. Review the link wrapper when upgrading RenderCV.
- `resume.tex` — frozen pre-migration reference; not used for builds or audits.
- [`pdf-archive/`](pdf-archive/) — the two original reference PDFs, unchanged.
- `.agents/skills/resume-layout/` — layout policy, fresh-render auditor, and regression tests.

All original experience and community bullets, roles, dates, and quantified results are retained. A short summary, grounded in the existing experience, was added to satisfy the layout contract. LaTeX escapes were removed and date/contact formatting normalized.

## Setup and build

On macOS:

```sh
brew install uv poppler
make pdf       # Build only the default variant
make open      # Open that draft PDF in Preview
```

The Makefile uses **RenderCV 2.8** with Python 3.13 through `uv tool run`; uv provisions Python and dependencies as needed. First use requires internet access for the runtime, fonts, and Typst packages. RenderCV includes its Typst compiler. The design uses the **Helvetica** family supplied by macOS; other systems need that font installed. The audit rejects font fallback rather than silently changing the appearance. The auditor also needs Ruby with REXML (`gem install rexml` if missing); tests need Minitest (`gem install minitest` if missing).

### Commands and output paths

`make` and `make pdf` build **only `default`**, at `build/brandonmathis-default.pdf`. Use **`make pdfs`** to build all variants, including `build/brandonmathis-tpm.pdf` for `technical-product-owner`. Run `make variants` to list the variant names used in commands.

| Command | What it does | PDF location |
| --- | --- | --- |
| `make pdf [<name>]` | Builds one unaudited draft. | `build/brandonmathis-<slug>.pdf` |
| `make watch [<name>]` | Builds and opens a draft in macOS Preview, then rebuilds on edits. Ctrl-C stops it. | `build/brandonmathis-<slug>.pdf` |
| `make open [<name>]` | Opens an existing draft in Preview without rebuilding or auditing. | `build/brandonmathis-<slug>.pdf` |
| `make check-layout [<name>]` | Renders a fresh PDF and checks its layout without changing the draft. | `build/layout-audit/<name>/resume.pdf` |
| `make preview [<name>]` | Runs the layout check and opens its fresh PDF in Preview only if it passes. Does not refresh the draft. | `build/layout-audit/<name>/resume.pdf` |
| `make pdfs` | Builds drafts for all variants, including `default`. | `build/brandonmathis-<slug>.pdf` for each variant |
| `make check-layouts` | Runs a fresh layout check for each variant. | `build/layout-audit/<name>/resume.pdf` for each variant |
| `make previews` | Checks and opens each variant's PDF in Preview. | `build/layout-audit/<name>/resume.pdf` for each variant |

Brackets mark an optional name; omit it to select `default`. For example, `make pdf technical-product-owner` and `make pdf VARIANT=technical-product-owner` build the same variant. Use a positional name with one command, or `VARIANT=...` with multiple commands (e.g. `make pdf check-layout VARIANT=technical-product-owner`). Bulk commands discover variants automatically, include `default`, and stop on the first failure.

Variant draft builds leave only the PDF: the resolved YAML, copied templates, and generated Typst are temporary. To inspect the resolved YAML without rendering, run `make compose [<name>]`; it writes `build/variants/<name>/<name>.yaml` and prints its path. Layout audits still keep Typst alongside their diagnostic artifacts. Generated files are ignored by Git; `make clean` removes the repository's entire `build/` directory, including old draft filenames and audit artifacts, not sources or reference PDFs. Run `make test-variants` for variant tooling tests, or `make test` for both variant and layout tests.

#### Standalone YAML

There is no root `resume.yaml`. To render a standalone RenderCV file instead of a variant, use `make pdf SOURCE=path/to/tailored.yaml` or `make watch SOURCE=path/to/tailored.yaml`. Both write `build/resume.pdf` **relative to the YAML file's directory**, not necessarily the repository root, and generate Typst in a temporary directory. Standalone watch uses RenderCV's watcher and does not open Preview. `make check-layout SOURCE=path/to/tailored.yaml` writes its audit under `build/layout-audit/tailored/` in the repository. Do not combine `SOURCE` and `VARIANT`.

## Edit or tailor

Edit `cv` in `variants/default.yml` for shared baseline changes. Each section is a list of RenderCV entries; each `highlights` item is a bullet. Text supports Markdown links, bold, and italics. Use plain `&` instead of LaTeX `\&`; quote YAML strings containing `: ` or `#`.

`design` controls typography and spacing. The variant utility sets the generated output paths. Keep the two-page contract:

1. Page one: name/contact details, Summary, and **all** Recent Work Experience.
2. Page two: Education and Leadership & Community Activities (plus any supporting sections).

Keep Helvetica, 10 pt body text, **12 pt baseline distance**, 9 pt contacts, 12 pt section titles, and at least 0.5-inch margins. Typst's `line_spacing` is a gap, not a baseline multiplier: `2pt` plus the template's 10 pt text frame yields 12 pt baselines. The negative bottom-edge coordinate denotes the descender below the baseline; it is not negative spacing or glyph scaling. The old TeX points were 1/72.27 inch; Typst/PDF points are 1/72 inch, so the new 10/12 pt text is fractionally larger.

`classic/Preamble.j2.typ` starts a new page at **Education**. If that heading changes, update the split in the template too; the auditor checks that the break matches the first supporting section. It renders two styled content groups because RenderCV does not permit a raw page break inside its section containers. The preamble configuration is copied from RenderCV 2.8; review it when upgrading RenderCV. Shorten text before tightening positive gaps; never shrink type or line height to fit.

### Content-only variants

Do **not** copy the entire baseline for each audience. The flow is:

```text
variants/default.yml → variants/<name>.yml (inherits: default)
    + classic/ (shared templates)
    → resolved RenderCV input
    ├─ make pdf → build/brandonmathis-<slug>.pdf (draft)
    └─ make check-layout → build/layout-audit/<name>/resume.pdf
                           → visual inspection → publish
```

#### Customize the PDF filename

Set a top-level `slug:` in a variant YAML file to change the part after `brandonmathis-`. For example, `slug: tpm` in `variants/technical-product-owner.yml` produces `build/brandonmathis-tpm.pdf` when you run `make pdf technical-product-owner`.

If omitted, the slug is the variant filename without `.yml` or `.yaml` (`default` for `variants/default.yml`). Slugs are not inherited. Use lowercase letters and digits, with single hyphens between words. Slugs must be unique across variants. They do not change the name used in Make commands or audit paths. Changing a slug does not delete the older PDF.

#### Create a variant

The examples below use **`example-role`**, a hypothetical audience-specific variant, not a bundled file. Create `variants/example-role.yml` first:

```yaml
inherits: default
sections: {}
```

This inherits all baseline copy and shared presentation. To tailor it, copy a section's complete list from the resolved parent into `sections`, then edit that list. See the copy-change rules below. The list and bulk commands discover new files automatically; no Makefile changes are needed.

An overlay may also set an optional single-line `headline:` (for example `headline: Software Engineer`), rendered under the name at the shared 12 pt bold headline style in `variants/default.yml` and checked by the auditor (`headline_tex_pt`). Name/contact information, section order/headings, design, locale, templates, and PDF title always come from default.

Parents are variant names, not paths or filenames. An overlay can inherit from another overlay (for example `inherits: example-role`, after creating that parent); chains resolve parent-first and must ultimately reach `default`. Missing parents, unsafe names, and inheritance cycles fail before rendering. Both `.yml` and `.yaml` variant files are supported, but duplicate names across extensions are rejected. Keep new source files as `.yml`.

### Live preview

```sh
make watch               # Watch default; no extra variant needed
# Or, after creating the example overlay:
make watch example-role
# Ctrl-C to stop
```

The variant watcher builds `build/brandonmathis-<slug>.pdf` and opens it in macOS Preview once per output filename. It polls default, every overlay in the selected inheritance chain, and shared templates once per second, and replaces the draft only after a successful render. Preview can retain a stale view even after a successful rebuild; close it and use `make open <name>` if changes are not visible. For dependable automatic reloads, Skim supports checking for file changes and reloading automatically; the current watcher still opens Preview.

Live output is an **unaudited working draft**: layout failures do not suppress updates. Use `make preview <variant>` or `make check-layout <variant>` and inspect both pages before publishing. Invalid YAML and renderer errors are logged, and the watcher keeps running so corrected edits can rebuild. Edits made during a build are picked up on the next poll. Restart the watcher after changing the watcher script itself; an already-running Ruby process otherwise keeps its old code.

Variant section overrides still apply: changes to an overridden section in `variants/default.yml` will not change that variant's copy. Shared design changes and non-overridden sections are inherited normally.

**When copy changes are requested later:**

1. For shared changes, edit `cv` in `variants/default.yml`. Every section not overridden inherits that update on the next build.
2. For audience-specific changes, copy only the relevant section's complete list from the resolved parent's `cv.sections` into the variant's `sections` mapping, then edit that list. For example, to tailor only the summary, copy the current `Summary` list into `sections.Summary` in `variants/example-role.yml`. Start with the actual inherited wording, not a stale example.
3. A section override **replaces its whole list**; arrays are never concatenated or merged by position. Untouched sections continue to inherit. Once overridden, a section no longer receives baseline copy updates: review it deliberately when shared facts change. Delete an override to restore inheritance.
4. New/renamed headings belong in the baseline and shared template/audit policy, not individual overlays. Unknown headings, empty section lists, empty or multi-line headlines, missing `inherits`, and overlay-level design/settings/name/contact overrides are rejected. RenderCV validates the entries themselves.
5. Audit and visually inspect each changed variant before publishing. Different copy lengths can overflow even though the layout is identical. Never fix a variant by introducing a private layout or shrinking type.

For another audience, repeat the creation steps with a lowercase, hyphenated name such as `another-role`. Generated YAML and template copies under `build/` are disposable; never edit them. `make clean` removes them without touching overlays.

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

Artifacts are saved under `build/layout-audit/<source-stem>/`: `resume.pdf`, `resume.typ`, `compile.log`, and `report.json`. Exit codes: `0` automated pass, `1` layout violation, `2` blocked/error.

**A successful build or automated pass is not visual approval.** Read the report and compiler log, render every actual page, and inspect for clipping, collisions, stranded headings, crowded text, and awkward wrapping:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/default/resume.pdf build/layout-audit/default/page
```

For another variant, pass its name to `make check-layout` and replace `default` in the paths above. Inspect **both** page images and read that directory's `report.json` and `compile.log`. Use `make preview <name>` instead of `make check-layout <name>` if you want Preview to open the audited PDF automatically.

The full workflow and troubleshooting order are in `.agents/skills/resume-layout/SKILL.md`.
