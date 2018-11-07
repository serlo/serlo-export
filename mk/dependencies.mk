
# book dependency files of all supplied export goals
BOOK_DEP_FILES := $(foreach P,$(filter $(EXPORT_DIR)/%,$(MAKECMDGOALS)),\
	$(info evaluating make targets...)\
	$(eval $(parse_bookpath_and_revision))\
	$(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dep)

# Generate / include book dependencies (articles it depends on) for every supplied goal
$(BOOK_DEP_FILES): $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(call create_directory,$(dir $@))
	$(MK)/bin/sitemap_utils --input $< \
		deps $(TARGET) $(SUBTARGET) \
		--prefix $(dir $@) \
		--book-target $(BOOK_DEP_INTERMEDIATE) \
		--anchors-target $(BOOK_ANCHORS_INTERMEDIATE) \
		> $@

# build / include dependency files for books
-include $(BOOK_DEP_FILES)

# concatenates individual anchors file to a whole
# dependencies specified in generated book deps
$(EXPORT_DIR)/%.book.anchors: 
	$(info collecting anchors...)
	$(shell cat $(filter %.anchors,$^) > $@)

# extract article markers from sitemap and create its directory
$(EXPORT_DIR)/%.markers: $(SITEMAP_SECONDARY)
	$(eval $(parse_booktarget))
	$(call create_directory,$(call book_path,$@)/$(ARTICLE))
	$(eval UNQUOTED := $(call unescape,$(ARTICLE)))
	$(MK)/bin/sitemap_utils --input $< \
		markers "$(UNQUOTED)" $(TARGET) > $@

# generate article dependencies 
$(EXPORT_DIR)/%.section-dep: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers
	$(eval $(parse_booktarget))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title '$(ARTICLE)' \
		--revision '$(ARTICLE_REVISION)' \
		--markers '$(word 2,$^)' \
		--base-path '$(call book_path,$@)/$(ARTICLE)/' \
		--section-path '$(SECTION_DIR)/' \
		--texvccheck-path $(MK)/bin/texvccheck \
		section-deps $(TARGET).$(SUBTARGET) \
		< $< \
		> $@

$(EXPORT_DIR)/%.media-dep: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers $(EXPORT_DIR)/%.sections
	$(eval $(parse_booktarget))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title '$(ARTICLE)' \
		--revision '$(ARTICLE_REVISION)' \
		--markers '$(word 2,$^)' \
		--base-path '$(call book_path,$@)/$(ARTICLE)/' \
		--section-path '$(SECTION_DIR)/' \
		--media-path '$(MEDIA_DIR)' \
		--texvccheck-path $(MK)/bin/texvccheck \
		media-deps $(TARGET).$(SUBTARGET) \
		< $< \
		> $@

# extracts the reference anchors (link targets) provided by an article.
$(EXPORT_DIR)/%.anchors: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers $(EXPORT_DIR)/%.sections
	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title '$(UNESCAPED)' \
		--revision '$(ARTICLE_REVISION)' \
		--markers '$(word 2,$^)' \
		--section-path '$(SECTION_DIR)/' \
		--texvccheck-path $(MK)/bin/texvccheck \
		anchors $(TARGET).$(SUBTARGET) \
		< $< \
		> $@
	
# generate files from article tree serialization 
# $(ALL_ANCHORS) must be defined before this file is loaded
# and points to a file containing a list of all available anchors in the export.
$(EXPORT_DIR)/%.stats.yml $(EXPORT_DIR)/%.tex $(EXPORT_DIR)/%.raw_html: \
	$(ORIGIN_SECONDARY) $(BOOK_ANCHORS_INTERMEDIATE) $(BOOK_DEP_SECONDARY) \
	$(EXPORT_DIR)/%.markers \
	$(EXPORT_DIR)/%.media-dep \
	$(EXPORT_DIR)/%.section-dep \
	$(EXPORT_DIR)/%.sections \
	$(EXPORT_DIR)/%.media\

	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title '$(UNESCAPED)' \
		--revision '$(ARTICLE_REVISION)' \
		--markers '$(word 4,$^)' \
		--section-path '$(SECTION_DIR)/' \
		--media-path '$(MEDIA_DIR)' \
		--available-anchors '$(word 2,$^)' \
		--texvccheck-path $(MK)/bin/texvccheck \
		$(TARGET).$(SUBTARGET) \
		< $< \
		> $@
