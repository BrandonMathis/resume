# Prefer Tectonic; fall back to an existing pdfLaTeX installation.
.PHONY: pdf check-layout test-layout clean

pdf:
	@mkdir -p build
	@if command -v tectonic >/dev/null 2>&1; then \
		tectonic --outdir build resume.tex; \
	elif command -v pdflatex >/dev/null 2>&1; then \
		pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build resume.tex && \
		pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build resume.tex; \
	else \
		printf '%s\n' 'No LaTeX compiler found. Install Tectonic (brew install tectonic) or a TeX distribution.' >&2; \
		exit 1; \
	fi

# Fresh diagnostic build plus layout/readability checks; see the project skill.
check-layout:
	ruby .agents/skills/resume-layout/scripts/check_layout.rb

test-layout:
	ruby .agents/skills/resume-layout/scripts/test_check_layout.rb

clean:
	rm -rf build
