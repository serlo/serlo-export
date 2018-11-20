
# catch rules for targets with references to latest revision
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%tex: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%book.tex: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

# final book index, depends dependency file which adds its dependencies
# only applies for resolved dependencies
$(EXPORT_DIR)/%.book.tex: $(PARSE_PATH_SECONDARY) $$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) $(NO_LATEST_GUARD)
	$(eval $(parse_booktarget))
	$(info rendering book index for '$(BOOK)'...)
	@$(MK)/bin/handlebars-cli-rs \
		--input '$(ASSET_DIR)/latex/book.tex' \
		subtarget $(SUBTARGET) \
	< $(SITEMAP_PATH) \
	> $@
