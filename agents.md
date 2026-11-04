# Project guidance

This project is simply a directory for maintaining a resume, not an application or software package.

- `resume.yaml` is the main source of truth for the resume (RenderCV 2.8).
- Generate PDFs from the YAML with `make pdf`; do not edit generated Typst or PDFs. `resume.tex` is a frozen pre-migration reference, not an active source.
- Maintain audience-specific copy in `variants/<name>.yaml` as content-only section overrides; do not duplicate design or templates. `resume.yaml` remains the authoritative baseline. Build/audit with `make pdf VARIANT=<name>` and `make check-layout VARIANT=<name>`; generated inputs and PDFs live under `build/variants/<name>/`. See `README.md` for inheritance and whole-section replacement rules.
- Keep changes focused on resume content, formatting, and the tooling needed to generate the documents.
- For any resume content/formatting edit or PDF generation, load `.agents/skills/resume-layout/SKILL.md` and follow its audit workflow. Do not declare a resume finished until the fresh layout check and visual inspection pass.
- Require exactly two pages: name/contact details, summary, and all experience on page one; education, community leadership, and other supporting sections on page two. Preserve the existing readable font sizes and line height; shorten text before tightening spacing.
