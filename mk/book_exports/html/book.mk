
# catch rules for targets with references to latest revision
$(EXPORT_DIR)/%article.html: $(TARGET_RESOLVED_REVISION)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%book.html: $(TARGET_RESOLVED_REVISION)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)


$(EXPORT_DIR)/%.article.html: $(EXPORT_DIR)/%.html $$(eval $$(parse_booktarget)) $(NO_LATEST_GUARD)
	ln -s -f $(notdir $<) $@

# final book index, depends dependency file which adds its dependencies
# only applies for resolved dependencies
$(EXPORT_DIR)/%.book.html: $$(eval $$(parse_booktarget)) \
	$$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) $(NO_LATEST_GUARD)

	$(MK)/bin/handlebars-cli-rs \
		--input 'templates/book_index.html' \
		book '$(BOOK_UNESCAPED))' \
		subtarget '$(SITEMAP_PATH)' \
	< $(SITEMAP_PATH) \
	> $(basename $<).html
	ln -s -f -n $(BASE)/templates/html_book_assets $(BOOK_ROOT)/static
	ln -s -f -n $(BASE)/$(MEDIA_DIR)/ $(BOOK_ROOT)

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
