

$(EXPORT_DIR)/%/latest.book.html: $(BOOK_RESOLVED_REVISION_SECONDARY)
	$(info linking latest...)
	ln -s -f $(BOOK_REVISION) $(EXPORT_DIR)/$(BOOK)/latest
	ln -s -f $(notdir $<) $@

# final book index, depends dependency file which adds its dependencies
$(EXPORT_DIR)/%.book.html: $(BOOK_DEP_SECONDARY) $(BOOK_DEP_INTERMEDIATE) 
	$(eval $(parse_bootarget))
	$(eval BOOK_PATH := $(call book_path,$<))
	$(MK)/bin/handlebars-cli-rs \
		--input 'templates/book_index.html' \
		book "$(call unescape,$(BOOK))" \
		subtarget "$(SUBTARGET)" \
	< $(SITEMAP_PATH) \
	> $(basename $<).html
	cp -r templates/html_book_assets $(BOOK_PATH)/static/
	ln -s -f $(BASE)/$(MEDIA_DIR)/ $(BOOK_PATH)

# postprocess html articles
$(EXPORT_DIR)/%.html: $(EXPORT_DIR)/%.raw_html $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(MK)/bin/handlebars-cli-rs \
		--input 'templates/book_article.html' \
		book '$(call unescape,$(BOOK))' \
		article '$(call unescape,$(ARTICLE))' \
		subtarget '$(SUBTARGET)' \
		target '$(TARGET)' \
	< $(SITEMAP_PATH) \
	> $@
	sed -i -e '/<!-- @ARTICLE_CONTENT@ -->/{r $<' -e 'd' -e '}' $@

