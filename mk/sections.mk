# section path format is $(SECTION_DIR)/<article name>/<section name>/latest.yml


# create "latest" from concrete revision
$(SECTION_DIR)/%/latest.json: $(PARSE_RESOLVED_SECTION_TARGET) \
	$$(SECTION_DIR)/$$(ARTICLE)/$$(SECTION)/$$(ARTICLE_REVISION).json
	
	$(info linking latest section for '$(ARTICLE)'...)
	@ln -n -s -f $(notdir $<) $@

# lock input file to prevent overwriting of sections 
# since make does not know this builds all sections...
$(SECTION_DIR)/%.json: $(PARSE_SECTION_TARGET) $(SECTION_NO_LATEST_GUARD) \
	$$(ARTICLE_DIR)/$$(ARTICLE)/$$(ARTICLE_REVISION).json | $(SECTION_DIR)
	
	$(eval $(PARSE_SECTION_TARGET))
	$(info extracting sections from $(ARTICLE)...)
	@$(call create_directory,$(SECTION_DIR)/$(ARTICLE)/$(SECTION))
	@$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		sections \
		-- \
		$(ARTICLE) \
		$(call unescape,$(SECTION)) \
		$(ARTICLE_REVISION) \
		< $< > $@

$(SECTION_DIR):
	@$(call create_directory,$(SECTION_DIR))
