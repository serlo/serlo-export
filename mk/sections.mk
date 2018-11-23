# section path format is $(SECTION_DIR)/<article name>/<section name>/latest.yml


# create "latest" from concrete revision
$(SECTION_DIR)/%/latest.yml: $(PARSE_RESOLVED_SECTION_TARGET) \
	$$(SECTION_DIR)/$$(ARTICLE)/$$(SECTION)/$$(ARTICLE_REVISION).yml
	
	$(info linking latest section for '$(ARTICLE)'...)
	@ln -n -s -f $(notdir $<) $@

# lock input file to prevent overwriting of sections 
# since make does not know this builds all sections...
$(SECTION_DIR)/%.yml: $(PARSE_SECTION_TARGET) $(SECTION_NO_LATEST_GUARD) \
	$$(ARTICLE_DIR)/$$(ARTICLE)/$$(ARTICLE_REVISION).json | $(SECTION_DIR)
	
	$(eval $(PARSE_SECTION_TARGET))
	$(info extracting sections from $(ARTICLE)...)
	@flock $< $(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(ARTICLE_REVISION) \
		--section-path $(SECTION_DIR)/$(ARTICLE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		sections $(ARTICLE) < $< > /dev/null

$(SECTION_DIR):
	@$(call create_directory,$(SECTION_DIR))
