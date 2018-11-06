# section path format is $(SECTION_DIR)/<article name>/<section name>/latest.yml

# expands to article name and article revision from mid part of section path
SECTION_ORIGIN_SECONDARY := $(ARTICLE_DIR)/$$(call dir_head,$$*)/$$(call latest_revision,$$(call unescape,$$(call dir_head,$$*))).yml

# lock input file to prevent overwriting of sections 
# since make does not know this builds all sections...
$(SECTION_DIR)/%/latest.yml: $(SECTION_ORIGIN_SECONDARY) | $(SECTION_DIR)
	$(eval ARTICLE := $(firstword $(call dirsplit,$*)))
	flock $< $(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--base-path $(BASE) \
		--section-path $(SECTION_DIR)/$(ARTICLE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		sections $(ARTICLE) < $<

$(SECTION_DIR):
	$(call create_directory,$(SECTION_DIR))
