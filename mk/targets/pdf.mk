# catch rules for targets with references to latest revision
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%pdf: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%book.pdf: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

# LaTeX binary to use
LATEX := lualatex

# path to the latex export of this book
LATEX_BOOK := $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/latex/$(SUBTARGET)/$(BOOK_REVISION).book.tex

# write pdf options for books
$(EXPORT_DIR)/%.pdfopts.yml:
	$(eval $(parse_booktarget))
	$(info writing pdf options for book '$(BOOK)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(BOOK) \
		--revision $(BOOK_REVISION) \
	$(TARGET).$(SUBTARGET) < $(MK)/artifacts/dummy.json > $@

$(EXPORT_DIR)/%.book.pdf.tex: $(EXPORT_DIR)/%.pdfopts.yml $(PARSE_PATH_SECONDARY)  $$(LATEX_BOOK)
	
	$(info writing compilable latex index for book '$(BOOK)'...)
	@$(MK)/bin/handlebars-cli-rs \
		--input '$(ASSET_DIR)/latex/book_export.tex' \
		--base-templates './$(ASSET_DIR)/latex/preamble.tex' \
		--data $< \
		content $(notdir $(word 2,$^)) \
		fontpath $(BASE)/$(ASSET_DIR)/karmilla/ttf/ \
		articlespath texfiles \
		graphics_path "$(BASE)/" \
	> $@

$(EXPORT_DIR)/%.book.pdf: $(EXPORT_DIR)/%.book.pdf.tex $(NO_LATEST_GUARD)
	
	$(eval $(parse_booktarget))
	$(info building book '$(BOOK)' with $(LATEX)...)
	@ln -s -f -n $(BASE)/$(dir $(LATEX_BOOK)) $(dir $@)texfiles
	@ln -s -f -n $(BASE)/$(ASSET_DIR)/include $(dir $@)include
	@(cd $(BOOK_ROOT) && latexmk \
		-pdflatex="$(LATEX) %O %S \
			-no-shell-escape" \
		-pdf $(notdir $<) \
		-interaction=batchmode \
		-quiet \
		-jobname=$(basename $(basename $(notdir $<)))\
		-norc )

$(EXPORT_DIR)/$(ARTICLE_BOOK)/%.article.opts.yml: $(ORIGIN_SECONDARY)
	$(eval $(parse_booktarget))
	$(info writing export options for '$(ARTICLE)'...) 
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(ARTICLE_REVISION) \
	$(TARGET).$(SUBTARGET) < $(MK)/artifacts/dummy.yml > $@
	
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%.article.tex: $(EXPORT_DIR)/$(ARTICLE_BOOK)/%.article.opts.yml $(PARSE_PATH_SECONDARY) $$(EXPORT_DIR)/$$(ARTICLE_BOOK)/$$(BOOK_REVISION)/latex/$$(SUBTARGET)/$$(ARTICLE)/$$(ARTICLE_REVISION).tex
	
	$(eval $(parse_booktarget))
	$(info rendering article '$(ARTICLE)'...)
	@$(MK)/bin/handlebars-cli-rs \
		--input $(ASSET_DIR)/latex/article.tex \
		--base-templates './$(ASSET_DIR)/latex/preamble.tex' \
		--data $< \
		content '$(BASE)/$(word 2,$^)' \
		article $(ARTICLE) \
		revision $(ARTICLE_REVISION) \
		fontpath $(BASE)/$(ASSET_DIR)/karmilla/ttf/ \
		graphics_path "$(BASE)/" \
	> $@

# export articles of dummy book
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%.pdf: $(NO_LATEST_GUARD) $(EXPORT_DIR)/$(ARTICLE_BOOK)/%.article.tex 
	
	$(eval $(parse_booktarget))
	$(info building article '$(ARTICLE)' with $(LATEX)...)
	@(cd $(BOOK_ROOT)/$(ARTICLE) && latexmk \
		-pdflatex="$(LATEX) %O %S \
			-no-shell-escape" \
		-pdf $(notdir $<) \
		-interaction=batchmode \
		-quiet \
		-jobname=$(call filebase,$(notdir $@))\
		-norc )

# for every pdf target add the corresponding latex target to a list
TEX_DEP_FILES := $(sort $(foreach P,$(BOOK_DEP_FILES) $(ARTICLE_BOOK_DEP_FILES),$\
	$(parse_bookpath)$\
	$(if $(subst pdf,,$(TARGET)),,$\
		$(call dirmerge,$(subst $(space)pdf$(space),$(space)latex$(space),$(call dirsplit,$P)))$\
	)$\
))

# include the latex target dependencies
-include $(TEX_DEP_FILES)
