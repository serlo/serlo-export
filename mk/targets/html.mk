
# catch rules for targets with references to latest revision
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%html: $(HAS_LATEST_GUARD) $(TARGET_RESOLVED_REVISION) 
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%book.html: $(HAS_LATEST_GUARD) $(TARGET_RESOLVED_REVISION)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

# postprocess articles for article export (dummy book)
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%.html: $(NO_LATEST_GUARD) $(EXPORT_DIR)/$(ARTICLE_BOOK)/%.raw_html 
	$(eval $(parse_booktarget))
	$(eval ARTICLE_UNESCAPED := $(call unescape,$(ARTICLE)))
	$(info rendering article $(ARTICLE_UNESCAPED)...)
	@$(MK)/bin/handlebars-cli-rs \
		--base-templates '$(ASSET_DIR)/html/article_nav.html' \
		--input '$(ASSET_DIR)/html/base.html' \
		title $(ARTICLE_UNESCAPED) \
		navigation 'article_nav.html' \
		content '$<' \
		base_path '.' \
	< $(MK)/artifacts/dummy.json \
	> $@

# postprocess html articles in books
$(EXPORT_DIR)/%.html: $(NO_LATEST_GUARD) $(EXPORT_DIR)/%.raw_html $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(eval ARTICLE_UNESCAPED := $(call unescape,$(ARTICLE)))
	$(eval BOOK_UNESCAPED := $(call unescape,$(BOOK)))
	$(info rendering article $(ARTICLE_UNESCAPED)...)
	@$(MK)/bin/handlebars-cli-rs \
		--base-templates '$(ASSET_DIR)/html/book_nav.html' \
		--input '$(ASSET_DIR)/html/base.html' \
		title $(ARTICLE_UNESCAPED) \
		navigation 'book_nav.html' \
		book $(BOOK_UNESCAPED) \
		article $(ARTICLE_UNESCAPED) \
		subtarget '$(SUBTARGET)' \
		target '$(TARGET)' \
		content '$<' \
		base_path '../' \
	< $(SITEMAP_PATH) \
	> $@

# final book index, depends dependency file which adds its dependencies
# only applies for resolved dependencies
$(EXPORT_DIR)/%.book.html: $(PARSE_PATH_SECONDARY) $(NO_LATEST_GUARD) $$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) 
	$(eval $(parse_booktarget))
	$(eval BOOK_UNESCAPED := $(call unescape,$(BOOK)))
	$(info rendering book index for $(BOOK_UNESCAPED) and linking resources...)
	@$(MK)/bin/handlebars-cli-rs \
		--base-templates '$(ASSET_DIR)/html/book_nav.html' \
		--input '$(ASSET_DIR)/html/base.html' \
		title $(BOOK_UNESCAPED) \
		navigation 'book_nav.html' \
		content '$(ASSET_DIR)/html/book_index_body.html' \
		book $(BOOK_UNESCAPED) \
		subtarget '$(SITEMAP_PATH)' \
		base_path '.' \
	< $(SITEMAP_PATH) \
	> $(basename $<).html
	@ln -s -f -n $(BASE)/$(ASSET_DIR)/html/html_book_assets $(BOOK_ROOT)/static
	@ln -s -f -n $(BASE)/$(MEDIA_DIR)/ $(BOOK_ROOT)
