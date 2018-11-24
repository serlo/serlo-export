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
		jq -c "(.parts[] | .chapters[] | select(.revision==\"latest\")) \
			|= (.revision=\$$revisions.articles[(.path | gsub(\" \";\"_\"))])" \
		--argfile revisions $(REVISION_LOCK_FILE) $@ | sponge $@'

# Generate the book dependencies for every supplied goal
$(EXPORT_DIR)/%.book.dep: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	@$(call create_directory,$(dir $@))
	$(eval ANCHORS_FILE = $(ALL_ANCHORS_SECONDARY))
	$(info generating book dependency file...)
	jq -r -f $(MK)/scripts/generate_book_deps.jq \
		--arg book_dep_target $(BOOK_DEP_INTERMEDIATE) \
		--arg book_anchors_target $(ANCHORS_FILE) \
		--arg target $(TARGET) \
		--arg prefix $(dir $@) \
	< $< > $@

# extract article markers from sitemap and create its directory
$(EXPORT_DIR)/%.markers: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	@$(call create_directory,$(BOOK_ROOT)/$(ARTICLE))
	$(eval UNQUOTED := $(call unescape,$(ARTICLE)))
	$(info extracting markers for '$(UNQUOTED)'...)
	@jq '.parts[] | .chapters[] | select(.path=="$(UNQUOTED)") | .markers'\
	'| (.exclude.subtargets[] | .name) |= ("$(TARGET)." + .)'\
	'| (.include.subtargets[] | .name) |= ("$(TARGET)." + .)' $< > $@

# concatenate the supplied anchors of all articles
# prerequisites for this target specified in the generated book dependencies
$(EXPORT_DIR)/%.book.anchors:
	$(info collecting anchors...)
	$(shell cat $(filter %.anchors,$^) > $@)

# build and include book dependency files
-include $(BOOK_DEP_FILES)
