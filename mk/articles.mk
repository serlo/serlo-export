# article paths always have the form $(ARTICLE_DIR)/<article name>/<revision>.yml

$(ARTICLE_DIR)/%.yml $(ARTICLE_DIR)/%.json: $(ARTICLE_DIR)/%.md
	$(info parsing '$*'...)
	@$(MK)/bin/mwtoast --json < $< > $@

$(ARTICLE_DIR)/%.md:
	@$(call create_directory,$(dir $@))
	$(info fetching source of '$*'...)
	$(eval UNESCAPED := $(call unescape,$(word 2,$(call dirsplit,$@))))
	@curl -sgsf -G 'https://de.wikibooks.org/w/index.php' \
		--data-urlencode 'action=raw' \
		--data-urlencode 'title=$(UNESCAPED)' \
		--data-urlencode 'oldid=$(notdir $*)' \
	> $@
