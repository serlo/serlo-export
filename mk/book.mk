# Implements rules for exporting a whole book, with the exception of
# the $(ARTICLE_BOOK) dummy book, which is handled in another file.

# paths to book dependency files of all supplied export goals.
# use sort to remove duplicates
BOOK_DEP_FILES := $(sort $(foreach P,$\
	$(filter-out $(EXPORT_DIR)/$(ARTICLE_BOOK)/%,$(filter $(EXPORT_DIR)/%,$(MAKECMDGOALS))),\
	$(eval $(parse_bookpath_and_revision))\
	$(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dep\
))

# Generate the book dependencies for every supplied goal
$(BOOK_DEP_FILES): $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(call create_directory,$(dir $@))
	$(eval ANCHORS_FILE = $(ALL_ANCHORS_SECONDARY))
	$(MK)/bin/sitemap_utils --input $< \
		deps $(TARGET) $(SUBTARGET) \
		--prefix $(dir $@) \
		--book-target $(BOOK_DEP_INTERMEDIATE) \
		--anchors-target $(ANCHORS_FILE) \
		> $@

# extract article markers from sitemap and create its directory
$(EXPORT_DIR)/%.markers: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(call create_directory,$(BOOK_ROOT)/$(ARTICLE))
	$(eval UNQUOTED := $(call unescape,$(ARTICLE)))
	$(MK)/bin/sitemap_utils --input $< \
		markers "$(UNQUOTED)" $(TARGET) > $@

# concatenate the supplied anchors of all articles
# prerequisites for this target specified in the generated book dependencies
$(EXPORT_DIR)/%.book.anchors:
	$(info collecting anchors...)
	$(shell cat $(filter %.anchors,$^) > $@)

# build and include book dependency files
-include $(BOOK_DEP_FILES)
