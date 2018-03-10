THE_SECTIONS = the_sections
BUILD_YML = build_yml
REVID := $(shell $(MK)/resolve_revid.sh $(ARTICLE) $(MAKECMDGOALS))

$(THE_SECTIONS): $(MK)/../articles/$(ARTICLE)/$(REVID).yml
	$(MK)/article_sections.sh $(ARTICLE) < $<

$(MK)/../articles/%.yml :: $(BUILD_YML) ;

% :: $(THE_SECTIONS) ;

$(BUILD_YML):
	$(MAKE) -C $(MK)/.. articles/$(ARTICLE)/$(REVID:%=%.yml)

.PHONY: $(THE_SECTIONS) $(BUILD_YML)
