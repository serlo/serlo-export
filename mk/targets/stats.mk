# catch rules for targets with references to latest revision
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%stats.html: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%book.stats.html: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%.lints.yml: $(ORIGIN_SECONDARY)
	$(MK)/bin/mwlint \
		--texvccheck-path $(MK)/bin/texvccheck \
	< $< > $@

# postprocess articles for article export (dummy book)
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%.html: $(EXPORT_DIR)/$(ARTICLE_BOOK)/%.raw_html $(PARSE_PATH_SECONDARY) $(NO_LATEST_GUARD)
	$(eval $(parse_booktarget))
	$(MK)/bin/handlebars-cli-rs \
		--input 'templates/article.html' \
		article '$(call unescape,$(ARTICLE))' \
		subtarget '$(SUBTARGET)' \
		target '$(TARGET)' \
	< $(MK)/artifacts/dummy.yml \
	> $@
	sed -i -e '/<!-- @ARTICLE_CONTENT@ -->/{r $<' -e 'd' -e '}' $@

$(EXPORT_DIR)/%.book.stats.yml: $(PARSE_PATH_SECONDARY) $$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) $(NO_LATEST_GUARD)
	(cd $(dir $@) && python $(MK)/scripts/collect_stats.py > $(notdir $@))

# final book index, depends dependency file which adds its dependencies
# only applies for resolved dependencies
$(EXPORT_DIR)/%.book.stats.html: $(EXPORT_DIR)/%.book.stats.yml $(PARSE_PATH_SECONDARY) $(NO_LATEST_GUARD)
	$(eval $(parse_booktarget))
	$(MK)/bin/handlebars-cli-rs \
		--input templates/stats.html \
		--data $< \
		book '$(call unescape,$(BOOK))' \
		book_revision $(BOOK_REVISION) \
	> $@
