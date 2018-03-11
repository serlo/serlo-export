ARTICLE_SECTS = article_sects

$(ARTICLE_SECTS):
	$(eval ARCTICLE := $(patsubst %/,%,$(dir $(MAKECMDGOALS))))
	$(eval REVISION := $(notdir $(MAKECMDGOALS)))
	$(call create_directory,$(ARTICLE))
	$(MAKE) -C $(ARCTICLE) -f $(MK)/section.mk ARTICLE=$(ARCTICLE) MK=$(MK) $(REVISION)

% :: $(ARTICLE_SECTS) ;

.PHONY: $(ARTICLE_SECTS)
