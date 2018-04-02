REVISION := $(basename $(MAKECMDGOALS))

LATEX_ARTICLE := $(BASE)/article_exports/latex/$(SUBTARGET)/$(ARTICLE)
ORIGIN := $(BASE)/articles/$(ARTICLE)

RECURSE_TO_LATEX_ARTICLE := recurse_to_latex_article
RECURSE_TO_ORIGIN := recurse_to_origin

LATEX := lualatex

%.pdf: %.tex
	TEXINPUTS=$(BASE): latexmk -pdflatex="$(LATEX) %O %S" -pdf $<

%.tex: %.yml $(LATEX_ARTICLE)/%.tex
	$(MK)/article_tex_template.sh $(CURDIR)/$< $(word 2,$^) $(ARTICLE) $* > $@

%.yml: $(ORIGIN)/%.yml
	$(MK)/article_to_pdf.sh $(ARTICLE) $* $(TARGET).$(SUBTARGET) < $< > $@

$(LATEX_ARTICLE)/% :: $(RECURSE_TO_LATEX_ARTICLE) ;

$(ORIGIN)/% :: $(RECURSE_TO_ORIGIN) ;

.PHONY: $(RECURSE_TO_LATEX_ARTICLE) $(RECURSE_TO_ORIGIN)

$(RECURSE_TO_LATEX_ARTICLE):
	$(MAKE) -C $(BASE) article_exports/latex/$(SUBTARGET)/$(ARTICLE)/$(REVISION).tex

$(RECURSE_TO_ORIGIN):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(REVISION).yml

.DELETE_ON_ERROR:

.SECONDARY:
