include $(MK)/utils.mk

TO_EXPORT = export

$(TO_EXPORT):
	$(eval ARTICLE := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export ARTICLE)
	$(call create_directory,$(ARTICLE))
	$(eval export REVISION := $(basename $(NEXTHOP)))
	$(MAKE) -C . -f $(MK)/article_exports/export.mk $(ARTICLE)/$(NEXTHOP)

% :: $(TO_EXPORT) ;

.PHONY: $(TO_EXPORT)
