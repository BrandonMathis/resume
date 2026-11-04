# Brandon Mathis resume

The resume is maintained in [RenderCV](https://docs.rendercv.com/) YAML and rendered with Typst. **`resume.yaml` is authoritative.** No LaTeX installation is needed.

## Files

- `resume.yaml` — resume content, design, and output settings.
- `classic/Preamble.j2.typ` — local RenderCV template override for the explicit page break before Education and fixed body line height. Other templates use RenderCV's defaults.
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
open build/resume.pdf
```

The Makefile uses **RenderCV 2.8** with Python 3.13 through `uv tool run`; uv provisions Python and dependencies as needed. First use requires internet access for the runtime, fonts, and Typst packages. RenderCV includes its Typst compiler. The design uses the **Helvetica** family supplied by macOS; other systems need that font installed. The audit rejects font fallback rather than silently changing the appearance. The auditor also needs Ruby with REXML (`gem install rexml` if missing); tests need Minitest (`gem install minitest` if missing).

Generated files are ignored by Git:

- `build/resume.pdf` — searchable, tagged PDF.
- `build/resume.typ` — generated Typst; inspect, but do not edit.
- `build/resume.md`, `build/resume.html` — content exports (not the paginated layout).

```sh
make watch       # Re-render on changes; Ctrl-C to stop
make clean       # Remove build output, not source or reference PDFs
```

## Edit or tailor

Edit `cv` in `resume.yaml`. Each section is a list of RenderCV entries; each `highlights` item is a bullet. Text supports Markdown links, bold, and italics. Use plain `&` instead of LaTeX `\&`; quote YAML strings containing `: ` or `#`.

`design` controls typography and spacing; `settings.render_command` controls output paths. Keep the two-page contract:

1. Page one: name/contact details, Summary, and **all** Recent Work Experience.
2. Page two: Education and Leadership & Community Activities (plus any supporting sections).

Keep Helvetica, 10 pt body text, **12 pt baseline distance**, 9 pt contacts, 12 pt section titles, and at least 0.5-inch margins. Typst's `line_spacing` is a gap, not a baseline multiplier: `2pt` plus the template's 10 pt text frame yields 12 pt baselines. The negative bottom-edge coordinate denotes the descender below the baseline; it is not negative spacing or glyph scaling. The old TeX points were 1/72.27 inch; Typst/PDF points are 1/72 inch, so the new 10/12 pt text is fractionally larger.

`classic/Preamble.j2.typ` starts a new page at **Education**. If that heading changes, update the split in the template too; the auditor checks that the break matches the first supporting section. It renders two styled content groups because RenderCV does not permit a raw page break inside its section containers. The preamble configuration is copied from RenderCV 2.8; review it when upgrading RenderCV. Shorten text before tightening positive gaps; never shrink type or line height to fit.

For a variation, copy `resume.yaml` alongside the original so it uses the same `classic/` template. Set distinct output paths in its `settings.render_command`, then run:

```sh
make pdf SOURCE=tailored.yaml
make check-layout SOURCE=tailored.yaml
```

The legacy TeX source remains in Git for comparison; there are not two active sources of truth.

## Audit before publishing

```sh
make test-layout
make check-layout
```

The Ruby checker always renders **fresh YAML** in a temporary output directory, then extracts the actual PDF. It checks exactly two nonempty US Letter pages, section order and page spans (including experience continuations), the explicit break, typography, font family, rendered body-row spacing, and minimum margins. It does not modify `build/resume.pdf` or the original PDFs. Missing dependencies or unsupported measurements fail closed. The existing REXML dependency-error handling is preserved.

Artifacts are saved under `build/layout-audit/<source-stem>/`: `resume.pdf`, `resume.typ`, `compile.log`, and `report.json`. Exit codes: `0` automated pass, `1` layout violation, `2` blocked/error. Legacy `.tex` audits remain available with `--source resume.tex` if Tectonic or pdfLaTeX is installed; the old source lacks a summary and is not the approved resume.

**A successful build or automated pass is not visual approval.** Read the report and compiler log, render every actual page, and inspect for clipping, collisions, stranded headings, crowded text, and awkward wrapping:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/resume/resume.pdf build/layout-audit/resume/page
```

The full workflow and troubleshooting order are in `.agents/skills/resume-layout/SKILL.md`.
