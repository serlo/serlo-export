# article paths always have the form $(ARTICLE_DIR)/<article name>/<revision>.yml

$(ARTICLE_DIR)/%.yml: $(ARTICLE_DIR)/%.md
	$(info parsing '$*'...)
	@$(MK)/bin/mwtoast < $< > $@

$(ARTICLE_DIR)/%.md:
	$(call create_directory,$(dir $@))
	$(info fetching source of '$*'...)
	@python $(MK)/scripts/download_article.py $(word 2,$(call dirsplit,$@)) $(notdir $*) > $@
