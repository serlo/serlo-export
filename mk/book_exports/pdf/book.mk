TEXBOOK := $(BASE)/book_exports/$(BOOK)/$(BOOK_REVISION)/latex/$(SUBTARGET)/$(BOOK_REVISION).tex
LATEX := lualatex

$(BOOK_REVISION)_opts.yml:
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(BOOK) \
		--revision $(shell date +"%F:%T") \
	$(TARGET).$(SUBTARGET) < $(MK)/dummy.yml > $@

$(BOOK_REVISION).tex: $(BOOK_REVISION)_opts.yml $(TEXBOOK)
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book_export.tex \
		--data $< \
		content $(BOOK_REVISION).tex \
		fontpath $(BASE)/karmilla/ttf/ \
		articlespath texfiles \
		graphics_path "$(BASE)/" \
	> $(BOOK_REVISION).tex

$(BOOK_REVISION).pdf: $(BOOK_REVISION).tex articles.dep
	rm -f texfiles
	rm -f include
	ln -s $(BASE)/book_exports/$(BOOK)/$(BOOK_REVISION)/latex/$(SUBTARGET)/ texfiles
	ln -s $(BASE)/include include
	TEXINPUTS=$(BASE): latexmk \
		-pdflatex="$(LATEX) %O %S -no-shell-escape" -pdf $< \
		-interaction=batchmode \
		-quiet \
		-norc \
		-logfilewarninglist \
		
.DELETE_ON_ERROR:
.NOTPARALLEL:
