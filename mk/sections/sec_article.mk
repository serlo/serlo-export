include $(MK)/utils.mk

ARTICLE_SECTS = article_sects

$(ARTICLE_SECTS):
	$(eval ARTICLE := $(patsubst %/,%,$(dir $(MAKECMDGOALS))))
	$(eval REVISION := $(notdir $(MAKECMDGOALS)))
	$(eval export ARTICLE)
	$(call create_directory,$(ARTICLE))
	$(MAKE) -C $(ARTICLE) -f $(MK)/sections/section.mk $(REVISION)

% :: $(ARTICLE_SECTS) ;

.PHONY: $(ARTICLE_SECTS)
