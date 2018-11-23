# Implements rules for exporting a whole book, with the exception of
# the $(ARTICLE_BOOK) dummy book, which is handled in another file.

# paths to book dependency files of all supplied export goals.
# use sort to remove duplicates
BOOK_DEP_FILES := $(sort $(foreach P,$\
	$(filter-out $(EXPORT_DIR)/$(ARTICLE_BOOK)/%,$(filter $(EXPORT_DIR)/%,$(MAKECMDGOALS))),\
	$(parse_bookpath_and_revision)\
	$(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dep\
))

# parse the sitemap and replace references to latest with the latest revision
%.sitemap.json: $(PARSE_PATH_SECONDARY) $(ARTICLE_DIR)/$$(BOOK)/$$(BOOK_REVISION).json
	@$(call create_directory,$(dir $@))
	$(info parsing sitemap and resolving revisions for $(BOOK)...)
	@$(MK)/bin/parse_bookmap \
		--input $< \
		--texvccheck-path $(MK)/bin/texvccheck \
	> $@
	@sponge < $@ \
		| jq '.parts[] | .chapters[] | .path' \
		| xargs -n1 --max-procs=0 -I {} \
			$(MK)/scripts/update_chapter_revision.sh $@ 'revisions.json' '{}'

# Generate the book dependencies for every supplied goal
$(EXPORT_DIR)/%.book.dep: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	@$(call create_directory,$(dir $@))
	$(eval ANCHORS_FILE = $(ALL_ANCHORS_SECONDARY))
	$(info generating book dependency file...)
	@$(MK)/bin/sitemap_utils --input $< \
		deps $(TARGET) $(SUBTARGET) \
		--prefix $(dir $@) \
		--book-target $(BOOK_DEP_INTERMEDIATE) \
		--anchors-target $(ANCHORS_FILE) \
		> $@

# extract article markers from sitemap and create its directory
$(EXPORT_DIR)/%.markers: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	@$(call create_directory,$(BOOK_ROOT)/$(ARTICLE))
	$(eval UNQUOTED := $(call unescape,$(ARTICLE)))
	$(info extracting markers for '$(UNQUOTED)'...)
	@$(MK)/bin/sitemap_utils --input $< \
		markers '$(UNQUOTED)' '$(TARGET)' > $@

# concatenate the supplied anchors of all articles
# prerequisites for this target specified in the generated book dependencies
$(EXPORT_DIR)/%.book.anchors:
	$(info collecting anchors...)
	$(shell cat $(filter %.anchors,$^) > $@)

# build and include book dependency files
-include $(BOOK_DEP_FILES)
