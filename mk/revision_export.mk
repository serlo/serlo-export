LATEX = lualatex
LATEXFLAGS = -halt-on-error -no-shell-escape
LATEXMK = latexmk
LATEXMKFLAGS = -f -quiet

ARTICLES_SYMLINK_HACK := articles
DEP := $(MAKECMDGOALS:%.pdf=%.dep)

BUILD_DEP := build_dep
BUILD_TEX := build_tex

export TEXINPUTS=$(MK)/..:
export openout_any=a

%.tex: | $(ARTICLES_SYMLINK_HACK)
	cp $(MK)/../templates/article.tex $@
	sed -i -e 's/__ARTICLE__/$(ARTICLE:%/=%)/' -e 's/__REVISION__/$*/' $@

$(ARTICLES_SYMLINK_HACK):
	ln -s $(MK)/../$@ $@

%.pdf: %.tex $(MK)/../articles/$(ARTICLE)/%.tex $(MK)/../articles/$(ARTICLE)/%.dep
	echo $(MK)/../articles/$(ARTICLE)/$(DEP)
	$(LATEXMK) $(LATEXMKFLAGS) -pdflatex="openout_any=a $(LATEX) $(LATEXFLAGS) %O %S" \
		-pdf "$*"

$(MK)/../articles/%.tex :: $(BUILD_TEX) ;

$(MK)/../articles/%.dep :: $(BUILD_DEP) ;

.PHONY: $(BUILD_TEX) $(BUILD_DEP)

$(BUILD_TEX):
	$(MAKE) -C $(MK)/.. articles/$(ARTICLE)/$(MAKECMDGOALS:%.pdf=%.tex)

$(BUILD_DEP):
	$(MAKE) -C $(MK)/.. articles/$(ARTICLE)/$(MAKECMDGOALS:%.pdf=%.dep)

images/%:
	$(MAKE) -C $(MK)/.. images/$*

include $(MK)/../articles/$(ARTICLE)/$(DEP)

.DELETE_ON_ERROR:

.SECONDARY:
