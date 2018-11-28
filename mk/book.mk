# Implements rules for exporting a whole book, with the exception of
# the $(ARTICLE_BOOK) dummy book, which is handled in another file.

# paths to book dependency files of all supplied export goals.
# use sort to remove duplicates
BOOK_DEP_FILES := $(sort $(foreach P,$\
	$(filter-out $(EXPORT_DIR)/$(ARTICLE_BOOK)/%,$(filter $(EXPORT_DIR)/%,$(MAKECMDGOALS))),\
	$(parse_bookpath_and_revision)\
	$(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dep\
))

# parse the sitemap and replace references to latest with the latest revision.
# this is done by first querying the revisions of all articles, to make sure
# they are present in $(REVISION_LOCK_FILE). Then replace latest with the current
# revision using jq.
%.sitemap.json: $(PARSE_PATH_SECONDARY) $(ARTICLE_DIR)/$$(BOOK)/$$(BOOK_REVISION).json
	@$(call create_directory,$(dir $@))
	$(info parsing sitemap and resolving revisions for $(BOOK)...)
	@$(MK)/bin/parse_bookmap \
		--input $< \
		--texvccheck-path $(MK)/bin/texvccheck \
	> $@
	@jq '.parts[] | .chapters[] | .path' $@ \
		| xargs -n1 --max-procs=1 -I {} \
		$(MK)/scripts/get_revision.sh $(REVISION_LOCK_FILE) 'articles' '{}'	> /dev/null
	@flock $(REVISION_LOCK_FILE) -c ' \
		jq -c "import \"mk/scripts/lib\" as lib; lib::fill_sitemap_revisions" \
		--argfile revisions $(REVISION_LOCK_FILE) $@ | sponge $@'

# the subtargetmap is like the sitemap, but with exclusions
# for a specific subtarget applied.
$(EXPORT_DIR)/%.subtargetmap.json: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	@$(call create_directory,$(dir $@))
	$(info generating subtarget map for $(BOOK)...)
	@jq -c 'import "mk/scripts/lib" as lib; lib::exclude_chapters' \
		--arg subtarget $(SUBTARGET) \
	< $< > $@

# Generate the book dependencies for every supplied goal
$(EXPORT_DIR)/%.book.dep: $(EXPORT_DIR)/%.subtargetmap.json
	$(eval $(parse_booktarget))
	$(eval ANCHORS_FILE = $(ALL_ANCHORS_SECONDARY))
	$(info generating dependency file for $(BOOK)...)
	@jq -r 'import "mk/scripts/lib" as lib; lib::generate_book_deps' \
		--arg book_dep_target $(BOOK_DEP_INTERMEDIATE) \
		--arg book_anchors_target $(ANCHORS_FILE) \
		--arg target $(TARGET) \
		--arg prefix $(dir $@) \
	< $< > $@

# extract article markers from sitemap and create its directory
$(EXPORT_DIR)/%.markers: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	@$(call create_directory,$(BOOK_ROOT)/$(ARTICLE))
	$(info extracting markers for $(ARTICLE)...)
	@jq 'import "mk/scripts/lib" as lib; lib::article_markers' -c \
		--arg target '$(TARGET)' \
		--arg article '$(ARTICLE)' $< > $@

# concatenate the supplied anchors of all articles
# prerequisites for this target specified in the generated book dependencies
$(EXPORT_DIR)/%.book.anchors:
	$(info collecting anchors...)
	$(shell cat $(filter %.anchors,$^) > $@)

# build and include book dependency files
-include $(BOOK_DEP_FILES)
