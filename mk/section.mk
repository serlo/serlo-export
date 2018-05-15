THE_SECTIONS = the_sections
BUILD_YML = build_yml
REVID := $(shell $(MK)/resolve_revid.sh $(ARTICLE) $(MAKECMDGOALS))

$(THE_SECTIONS): $(BASE)/articles/$(ARTICLE)/$(REVID).yml
	$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--section-path $(BASE)/sections \
		--externals-path $(BASE)/media \
		--texvccheck-path $(MK)/bin/texvccheck \
		sections $(ARTICLE) < $<

$(BASE)/articles/%.yml :: $(BUILD_YML) ;

% :: $(THE_SECTIONS) ;

$(BUILD_YML):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(REVID:%=%.yml)

.PHONY: $(THE_SECTIONS) $(BUILD_YML)
