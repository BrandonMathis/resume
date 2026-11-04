# RenderCV supplies Typst; no LaTeX installation is needed.
RENDERCV = uv tool run --python 3.13 --from 'rendercv[full]==2.8' rendercv
SOURCE ?= resume.yaml

.DEFAULT_GOAL := pdf
COMMANDS := pdf watch check-layout preview open variants compose pdfs check-layouts previews test-variants test-layout test clean
VARIANT_COMMANDS := pdf watch check-layout preview open compose
VARIANTS := $(basename $(notdir $(wildcard variants/*.yaml)))

# Accept `make preview full-stack` without swallowing typos or changing normal
# multi-target invocations such as `make pdf check-layout VARIANT=full-stack`.
ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(VARIANT_COMMANDS)),)
POSITIONAL_VARIANT := $(filter-out $(COMMANDS),$(word 2,$(MAKECMDGOALS)))
ifneq ($(POSITIONAL_VARIANT),)
ifneq ($(words $(MAKECMDGOALS)),2)
$(error Use one command and one positional variant)
endif
ifeq ($(filter $(POSITIONAL_VARIANT),$(VARIANTS)),)
$(error Unknown variant '$(POSITIONAL_VARIANT)'; choose: $(VARIANTS))
endif
ifneq ($(strip $(VARIANT)),)
ifneq ($(VARIANT),$(POSITIONAL_VARIANT))
$(error Positional variant conflicts with VARIANT=$(VARIANT))
endif
endif
VARIANT := $(POSITIONAL_VARIANT)
.PHONY: $(POSITIONAL_VARIANT)
$(POSITIONAL_VARIANT): ;
endif
endif

.PHONY: $(COMMANDS)

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

compose preview open:
	ruby scripts/resume_variant.rb $@ "$(VARIANT)"

# Discover variants rather than maintaining a second list in the Makefile.
pdfs check-layouts previews:
	@set -e; for variant in $$(ruby scripts/resume_variant.rb list); do \
		$(MAKE) $(if $(filter pdfs,$@),pdf,$(if $(filter previews,$@),preview,check-layout)) VARIANT="$$variant"; \
	done

test-variants:
	ruby scripts/test_resume_variant.rb

test: test-variants test-layout

test-layout:
	ruby .agents/skills/resume-layout/scripts/test_check_layout.rb
	ruby .agents/skills/resume-layout/scripts/test_rendercv.rb

clean:
	rm -rf build
