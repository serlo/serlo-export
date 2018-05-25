include $(MK)/utils.mk

SITEMAP := $(BASE)/book_exports/$(BOOK)/bookmap.yml
TEXBOOK := $(BASE)/book_exports/$(BOOK)/latex/$(SUBTARGET)/$(SUBTARGET).tex
LATEX := lualatex

$(SUBTARGET)_opts.yml:
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(BOOK) \
		--revision $(shell date +"%F:%T") \
	$(TARGET).$(SUBTARGET) < $(MK)/dummy.yml > $@

$(SUBTARGET).tex: $(SUBTARGET)_opts.yml $(TEXBOOK)
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book_export.tex \
		--data $< \
		content $(SUBTARGET).tex \
		fontpath $(BASE)/karmilla/ttf/ \
		articlespath $(BASE)/book_exports/$(BOOK)/latex/$(SUBTARGET) \
	> $(SUBTARGET).tex

$(SUBTARGET).pdf: $(SUBTARGET).tex
	TEXINPUTS=$(BASE): latexmk -pdflatex="$(LATEX) %O %S" -pdf $<

.DELETE_ON_ERROR:
.NOTPARALLEL:
