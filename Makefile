# RenderCV supplies Typst; no LaTeX installation is needed.
RENDERCV = uv tool run --python 3.13 --from 'rendercv[full]==2.8' rendercv
SOURCE ?= resume.yaml

.PHONY: pdf watch check-layout test-layout variants compose pdfs check-layouts test-variants test clean

# VARIANT selects a content-only overlay; SOURCE remains available for standalone YAML.
ifneq ($(strip $(VARIANT)),)
ifneq ($(SOURCE),resume.yaml)
$(error Use VARIANT or SOURCE, not both)
endif
pdf watch check-layout:
	ruby scripts/resume_variant.rb $@ "$(VARIANT)"
else
pdf:
	$(RENDERCV) render "$(SOURCE)"

watch:
	$(RENDERCV) render "$(SOURCE)" --watch

# Fresh diagnostic render; never approves an old PDF.
check-layout:
	ruby .agents/skills/resume-layout/scripts/check_layout.rb --source "$(SOURCE)"
endif

variants:
	@ruby scripts/resume_variant.rb list

compose:
	ruby scripts/resume_variant.rb compose "$(VARIANT)"

# Discover variants rather than maintaining a second list in the Makefile.
pdfs check-layouts:
	@set -e; for variant in $$(ruby scripts/resume_variant.rb list); do \
		$(MAKE) $(if $(filter pdfs,$@),pdf,check-layout) VARIANT="$$variant"; \
	done

test-variants:
	ruby scripts/test_resume_variant.rb

test: test-variants test-layout

test-layout:
	ruby .agents/skills/resume-layout/scripts/test_check_layout.rb
	ruby .agents/skills/resume-layout/scripts/test_rendercv.rb

clean:
	rm -rf build
