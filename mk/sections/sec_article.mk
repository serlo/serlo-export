include $(MK)/utils.mk

ARTICLE_SECTS = article_sects

$(ARTICLE_SECTS):
	$(eval ARTICLE := $(patsubst %/,%,$(dir $(MAKECMDGOALS))))
	$(eval export ARTICLE)
	$(call create_directory,$(ARTICLE))
	$(eval export REVISION := $(call latest_revision,$(call unescape,$(ARTICLE))))
	$(MAKE) -C $(ARTICLE) -f $(MK)/sections/section.mk $(REVISION)

% :: $(ARTICLE_SECTS) ;

.PHONY: $(ARTICLE_SECTS)
.NOTPARALLEL:
