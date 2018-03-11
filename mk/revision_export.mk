LATEX = lualatex
LATEXFLAGS = -halt-on-error -no-shell-escape
LATEXMK = latexmk
LATEXMKFLAGS = -f -quiet

ARTICLES_SYMLINK_HACK := articles
DEP := $(MAKECMDGOALS:%.pdf=%.dep)

BUILD_DEP := build_dep
BUILD_TEX := build_tex

export TEXINPUTS=$(BASE):
export openout_any=a

%.tex: | $(ARTICLES_SYMLINK_HACK)
	cp $(BASE)/templates/article.tex $@
	sed -i -e 's/__ARTICLE__/$(ARTICLE:%/=%)/' -e 's/__REVISION__/$*/' $@

$(ARTICLES_SYMLINK_HACK):
	ln -s $(BASE)/$@ $@

%.pdf: %.tex $(BASE)/articles/$(ARTICLE)/%.tex $(BASE)/articles/$(ARTICLE)/%.dep
	echo $(BASE)/articles/$(ARTICLE)/$(DEP)
	$(LATEXMK) $(LATEXMKFLAGS) -pdflatex="openout_any=a $(LATEX) $(LATEXFLAGS) %O %S" \
		-pdf "$*"

$(BASE)/articles/%.tex :: $(BUILD_TEX) ;

$(BASE)/articles/%.dep :: $(BUILD_DEP) ;

.PHONY: $(BUILD_TEX) $(BUILD_DEP)

$(BUILD_TEX):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(MAKECMDGOALS:%.pdf=%.tex)

$(BUILD_DEP):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(MAKECMDGOALS:%.pdf=%.dep)

media/%:
	$(MAKE) -C $(BASE) media/$*

sections/%:
	$(eval SECS := $(dir $*))
	$(eval REVID := $(basename $(notdir $*)))
	$(MAKE) -C $(BASE) sections/$(dir $(SECS:%/=%))$(REVID)

include $(BASE)/articles/$(ARTICLE)/$(DEP)

.DELETE_ON_ERROR:

.SECONDARY:
