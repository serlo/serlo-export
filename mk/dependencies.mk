
# generate article dependencies 
$(EXPORT_DIR)/%.section-dep: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers
	$(eval $(parse_booktarget))
	$(info generating section dependencies for '$(ARTICLE)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		default section-deps \
		--markers '$(word 2,$^)' \
		--base-file '$(EXPORT_DIR)/$*.sections' \
		--section-path '$(SECTION_DIR)/' \
		< $< > $@

# generate the final article source tree (with included sections and excluded headings)
$(EXPORT_DIR)/%.composed.json: $(ORIGIN_SECONDARY) $(EXPORT_DIR)/%.markers $(EXPORT_DIR)/%.sections
	$(eval $(parse_booktarget))
	$(info composing '$(ARTICLE)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		default compose \
		--markers '$(word 2,$^)' \
		--section-path '$(SECTION_DIR)/' \
		< $< > $@

$(EXPORT_DIR)/%.media-dep: $(EXPORT_DIR)/%.composed.json 
	$(eval $(parse_booktarget))
	$(info generating media dependencies for '$(ARTICLE)'...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--media-path '$(MEDIA_DIR)' \
		default media-deps \
		$(TARGET) \
		--base-file '$(EXPORT_DIR)/$*.media' \
		< $< > $@

# extracts the reference anchors (link targets) provided by an article.
$(EXPORT_DIR)/%.anchors: $(EXPORT_DIR)/%.composed.json 
	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(info generating reference anchors for $(UNESCAPED)...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		default anchors \
		$(UNESCAPED) \
		< $< > $@
	
# generate files from article tree serialization 
# $(ALL_ANCHORS) must be defined before this file is loaded
# and points to a file containing a list of all available anchors in the export.
$(EXPORT_DIR)/%.rawstats.json $(EXPORT_DIR)/%.tex $(EXPORT_DIR)/%.raw_html: \
	$(PARSE_PATH_SECONDARY) \
	$(NO_LATEST_GUARD) \
	$(EXPORT_DIR)/%.composed.json \
   	$(ALL_ANCHORS_SECONDARY) $$(BOOK_DEP_FILE) \
	$(EXPORT_DIR)/%.media-dep \
	$(EXPORT_DIR)/%.section-dep \
	$(EXPORT_DIR)/%.media \

	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(info exporting $(UNESCAPED) as $(suffix $@)...)
	@$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--media-path '$(MEDIA_DIR)' \
		$(SUBTARGET) $(TARGET) \
		$(UNESCAPED) \
		'$(word 2,$^)' \
		< $< > $@
