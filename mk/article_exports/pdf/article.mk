RECURSE_TO_LATEX_ARTICLE := recurse_to_latex_article

LATEX_ARTICLE := article_exports/latex/$(SUBTARGET)/$(ARTICLE)/$(REVISION).tex
LATEX := lualatex

%.pdf: %_preamble.tex
		$(eval TEX := $(call dir_tail,$<))
		(cd $(ARTICLE) && latexmk \
			-pdflatex="$(LATEX) %O %S -no-shell-escape" -pdf $(TEX) \
			-interaction=batchmode \
			-quiet \
			-norc )

# make a compilable preamble
%_preamble.tex: %_opts.yml $(BASE)/$(LATEX_ARTICLE)
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/article.tex \
		--data $< \
		content $(word 2,$^) \
		article $(ARTICLE) \
		revision $(REVISION) \
		fontpath $(BASE)/karmilla/ttf/ \
		graphics_path "$(BASE)/" \
		> $@

# generate pdf options
.SECONDEXPANSION:
%_opts.yml: $(ORIGIN_SECONDARY)
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(shell date +"%F:%T") \
	$(TARGET).$(SUBTARGET) < $(MK)/dummy.yml > $@

$(BASE)/$(LATEX_ARTICLE):
	$(MAKE) -C $(BASE) $(LATEX_ARTICLE)

.PHONY: $(BASE)/$(LATEX_ARTICLE)
.DELETE_ON_ERROR:
