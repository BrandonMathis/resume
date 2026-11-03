# Brandon Mathis resume

## Files

- `resume.tex` — editable LaTeX source converted from `Brandon Resume 2026 Q3.pdf`.
- `Brandon Resume 2026 Q3.pdf` — original reference PDF, unchanged.
- `Fullstack Brandon Resume 2026.pdf` — existing alternate resume, unchanged.
- `phantom wallet suggested-changes.md` — existing notes, unchanged.
- `Makefile` — builds the resume into `build/resume.pdf`.

The source preserves the original wording and section order, with normalized typography and no invisible PDF extraction characters. It uses a similar, not pixel-identical, two-page layout: work experience on page one; education and community activities on page two.

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
