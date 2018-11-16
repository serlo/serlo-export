# Implements rules for the "$(ARTICLE_BOOK)" dummy book, in which
# articles do not depend on the sitemap.

# articles dependency files of all supplied export goals.
# this only includes dependencies of individual articles supplied as targets.
# This is is like $(BOOK_DEP_FILES) but for article (dummy book) export.
ARTICLE_BOOK_DEP_FILES := $(sort $(foreach P,$\
	$(filter $(EXPORT_DIR)/$(ARTICLE_BOOK)/%,$(MAKECMDGOALS)),\
	$(parse_bookpath_and_revision)\
	$(eval ARTICLE_REVISION := $(subst latest,$(call article_revision,$(call unescape,$(ARTICLE))),$(ARTICLE_REVISION)))\
	$(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(ARTICLE)/$(ARTICLE_REVISION).section-dep \
	$(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(ARTICLE)/$(ARTICLE_REVISION).media-dep\
))

# dummy sitemap
$(EXPORT_DIR)/$(ARTICLE_BOOK)/$(ARTICLE_BOOK_REVISION)/%.sitemap.yml:
	@$(call create_directory,$(dir $@))
	$(info creating dummy sitemap...)
	@touch $@

$(EXPORT_DIR)/$(ARTICLE_BOOK)/$(ARTICLE_BOOK_REVISION)/%.book.dep:
	@$(call create_directory,$(dir $@))
	$(info generating dummy book dependencies...)
	@touch $@

$(EXPORT_DIR)/$(ARTICLE_BOOK)/$(ARTICLE_BOOK_REVISION)/%.book.anchors:
	@$(call create_directory,$(dir $@))
	$(info generating empty book anchors file...)
	@touch $@

$(EXPORT_DIR)/$(ARTICLE_BOOK)/$(ARTICLE_BOOK_REVISION)/%.markers:
	@$(call create_directory,$(dir $@))
	$(info generating dummy markers...)
	@cp $(MK)/artifacts/dummy.markers $@


# build and include dependency files for books
-include $(ARTICLE_BOOK_DEP_FILES)
