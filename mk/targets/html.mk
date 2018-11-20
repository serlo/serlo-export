
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
	$(info rendering article '$(ARTICLE)'...)
	@$(MK)/bin/handlebars-cli-rs \
		--input 'templates/article.html' \
		article '$(call unescape,$(ARTICLE))' \
		subtarget '$(SUBTARGET)' \
		target '$(TARGET)' \
	< $(MK)/artifacts/dummy.yml \
	> $@
	@sed -i -e '/<!-- @ARTICLE_CONTENT@ -->/{r $<' -e 'd' -e '}' $@

# postprocess html articles in books
$(EXPORT_DIR)/%.html: $(NO_LATEST_GUARD) $(EXPORT_DIR)/%.raw_html $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(info rendering article '$(ARTICLE)'...)
	@$(MK)/bin/handlebars-cli-rs \
		--input 'templates/book_article.html' \
		book '$(call unescape,$(BOOK))' \
		article '$(call unescape,$(ARTICLE))' \
		subtarget '$(SUBTARGET)' \
		target '$(TARGET)' \
	< $(SITEMAP_PATH) \
	> $@
	@sed -i -e '/<!-- @ARTICLE_CONTENT@ -->/{r $<' -e 'd' -e '}' $@

# final book index, depends dependency file which adds its dependencies
# only applies for resolved dependencies
$(EXPORT_DIR)/%.book.html: $(PARSE_PATH_SECONDARY) $(NO_LATEST_GUARD) $$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) 
	$(eval $(parse_booktarget))
	$(info rendering book index for '$(BOOK)' and linking resources...)
	@$(MK)/bin/handlebars-cli-rs \
		--input 'templates/book_index.html' \
		book '$(call unescape,$(BOOK))' \
		subtarget '$(SITEMAP_PATH)' \
	< $(SITEMAP_PATH) \
	> $(basename $<).html
	@ln -s -f -n $(BASE)/templates/html_book_assets $(BOOK_ROOT)/static
	@ln -s -f -n $(BASE)/$(MEDIA_DIR)/ $(BOOK_ROOT)