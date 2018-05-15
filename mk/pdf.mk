REVISION := $(basename $(MAKECMDGOALS))

LATEX_ARTICLE := $(BASE)/article_exports/latex/$(SUBTARGET)/$(ARTICLE)
ORIGIN := $(BASE)/articles/$(ARTICLE)

RECURSE_TO_LATEX_ARTICLE := recurse_to_latex_article
RECURSE_TO_ORIGIN := recurse_to_origin

LATEX := lualatex

%.pdf: %.tex
	TEXINPUTS=$(BASE): latexmk -quiet -pdflatex="$(LATEX) %O %S" -pdf $<

%.tex: %.yml $(LATEX_ARTICLE)/%.tex
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/article.tex \
		--data $< \
		content $(word 2,$^) \
		article $(ARTICLE) \
		revision $(REVISION) \
		fontpath $(BASE)/karmilla/ttf/ \
		> $@

# generate article template values
%.yml: $(ORIGIN)/%.yml
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(REVISION) \
		$(TARGET).$(SUBTARGET) < $< > $@

$(LATEX_ARTICLE)/% :: $(RECURSE_TO_LATEX_ARTICLE) ;

$(ORIGIN)/% :: $(RECURSE_TO_ORIGIN) ;

$(RECURSE_TO_LATEX_ARTICLE):
	$(MAKE) -C $(BASE) article_exports/latex/$(SUBTARGET)/$(ARTICLE)/$(REVISION).tex

$(RECURSE_TO_ORIGIN):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(REVISION).yml

.PHONY: $(RECURSE_TO_LATEX_ARTICLE) $(RECURSE_TO_ORIGIN)
.DELETE_ON_ERROR:
.SECONDARY:
