# article paths always have the form $(ARTICLE_DIR)/<article name>/<revision>.yml

$(ARTICLE_DIR)/%.yml: $(ARTICLE_DIR)/%.md
	$(MK)/bin/mwtoast < $< > $@

$(ARTICLE_DIR)/%.md:
	$(call create_directory,$(dir $@))
	python $(MK)/download_article.py $(word 2,$(call dirsplit,$@)) $(notdir $*) > $@
