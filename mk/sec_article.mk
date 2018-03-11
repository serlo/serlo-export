include $(MK)/utils.mk

ARTICLE_SECTS = article_sects

$(ARTICLE_SECTS):
	$(eval override ARTICLE := $(patsubst %/,%,$(dir $(MAKECMDGOALS))))
	$(eval override REVISION := $(notdir $(MAKECMDGOALS)))
	$(call create_directory,$(ARTICLE))
	$(MAKE) -C $(ARTICLE) -f $(MK)/section.mk ARTICLE=$(ARTICLE) MK=$(MK) $(REVISION)

% :: $(ARTICLE_SECTS) ;

.PHONY: $(ARTICLE_SECTS)
