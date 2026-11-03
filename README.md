# Brandon Mathis resume

## Files

- `resume.tex` — editable LaTeX source converted from `Brandon Resume 2026 Q3.pdf`.
- `Brandon Resume 2026 Q3.pdf` — original reference PDF, unchanged.
- `Fullstack Brandon Resume 2026.pdf` — existing alternate resume, unchanged.
- `phantom wallet suggested-changes.md` — existing notes, unchanged.
- `Makefile` — builds the resume into `build/resume.pdf`.
- `.agents/skills/resume-layout/` — project skill, readability policy, and fresh-build layout checker.

The source preserves the original wording and section order, with normalized typography and no invisible PDF extraction characters. The required layout is exactly two pages: name/contact details, summary, and all work experience on page one; education and community activities on page two. The current source has no summary yet, so the layout audit will report that until an approved summary is added.

## Edit

Edit the text in `resume.tex`:

- `\resumeentry{Organization}{Location}{Role}{Dates}` defines an entry.
- Each `\item` is one bullet.
- Formatting helpers near the top control spacing and appearance globally.
- `\newpage` sets the original page break before Education.

LaTeX special characters need escaping: use `\&`, `\%`, `\$`, `\#`, and `\_` for literal characters.

## Build

Install [Tectonic](https://tectonic-typesetting.github.io/) on macOS:

```sh
brew install tectonic
```

Then:

```sh
make pdf
open build/resume.pdf
```

Tectonic downloads required LaTeX packages on first use, so the first build needs internet access. An existing pdfLaTeX installation also works; the Makefile detects it automatically.

To remove generated files:

```sh
make clean
```

Build output is ignored by Git; the original PDFs are not.

## Enforce layout

The project-local skill is `.agents/skills/resume-layout/SKILL.md`. In Pi, use `/reload` to discover it, then run `/skill:resume-layout`. It also applies whenever editing or tailoring a resume. It suggests content and spacing changes without shrinking fonts or line height; audit-only runs do not edit the resume.

Install the checker dependencies (Ruby with REXML is also required):

```sh
brew install poppler
# Only if your Ruby installation lacks REXML:
# gem install rexml
```

Run a fresh diagnostic build and audit:

```sh
make check-layout
# Or check a tailored source:
ruby .agents/skills/resume-layout/scripts/check_layout.rb --source tailored.tex
# Run checker regression tests:
make test-layout
```

The checker exits nonzero for violations or blocked validation. It checks the actual rendered pages, including experience continuation text on page two, and preserves the 10 pt body / 12 pt baseline policy with at least 0.5-inch margins. Reports, compiler logs, and the diagnostic PDF go into `build/layout-audit/<source-stem>/`. This does not overwrite `build/resume.pdf` or the reference PDFs. `make pdf` only compiles; a successful compile is not layout approval. Do not publish a PDF unless the audit and visual review both pass.

Visual inspection remains required for crowding, orphaned headings, overlaps, and local typography overrides. Render every page of the audited PDF and inspect the resulting images:

```sh
pdftoppm -scale-to 1600 -png build/layout-audit/resume/resume.pdf build/layout-audit/resume/page
```
