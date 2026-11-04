# RenderCV supplies Typst; no LaTeX installation is needed.
RENDERCV = uv tool run --python 3.13 --from 'rendercv[full]==2.8' rendercv
SOURCE ?= resume.yaml

.PHONY: pdf watch check-layout test-layout clean

pdf:
	$(RENDERCV) render "$(SOURCE)"

watch:
	$(RENDERCV) render "$(SOURCE)" --watch

# Fresh diagnostic render; never approves an old PDF.
check-layout:
	ruby .agents/skills/resume-layout/scripts/check_layout.rb --source "$(SOURCE)"

test-layout:
	ruby .agents/skills/resume-layout/scripts/test_check_layout.rb
	ruby .agents/skills/resume-layout/scripts/test_rendercv.rb

clean:
	rm -rf build
