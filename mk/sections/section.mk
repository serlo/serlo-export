
# expands to article name and article revision from mid part of section path
SECTION_ORIGIN := articles/$$(call dir_head,$$*)/$$(call latest_revision,$$(call unescape,$$(call dir_head,$$*))).yml

.SECONDEXPANSION:
# format is sections/article_name/section_name/latest.yml
# lock input file to prevent overwriting of sections 
# since make does not know this builds all sections...
sections/%/latest.yml: $(SECTION_ORIGIN) | sections
	$(eval ARTICLE := $(call dir_head,$*))
	flock $< $(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--base-path $(BASE) \
		--section-path sections/$(ARTICLE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		sections $(ARTICLE) < $<

sections:
	$(call create_directory,sections)
