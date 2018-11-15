
# generate article dependencies 
$(EXPORT_DIR)/%.section-dep: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers
	$(eval $(parse_booktarget))
	$(info generating section dependencies for '$(ARTICLE)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title '$(ARTICLE)' \
		--revision '$(ARTICLE_REVISION)' \
		--markers '$(word 2,$^)' \
		--base-path '$(BOOK_ROOT)/$(ARTICLE)/' \
		--section-path '$(SECTION_DIR)/' \
		--texvccheck-path $(MK)/bin/texvccheck \
		section-deps $(TARGET).$(SUBTARGET) \
		< $< \
		> $@

$(EXPORT_DIR)/%.media-dep: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers $(EXPORT_DIR)/%.sections
	$(eval $(parse_booktarget))
	$(info generating media dependencies for '$(ARTICLE)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title '$(ARTICLE)' \
		--revision '$(ARTICLE_REVISION)' \
		--markers '$(word 2,$^)' \
		--base-path '$(BOOK_ROOT)/$(ARTICLE)/' \
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
	$(info generating reference anchors for '$(ARTICLE)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
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
	$(PARSE_PATH_SECONDARY) \
	$(ORIGIN_SECONDARY) $(ALL_ANCHORS_SECONDARY) $$(BOOK_DEP_FILE) \
	$(EXPORT_DIR)/%.markers \
	$(EXPORT_DIR)/%.media-dep \
	$(EXPORT_DIR)/%.section-dep \
	$(EXPORT_DIR)/%.sections \
	$(EXPORT_DIR)/%.media \
	$(NO_LATEST_GUARD) \

	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(info exporting '$(ARTICLE)' as $(suffix $@)...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
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
