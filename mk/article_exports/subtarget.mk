include $(MK)/utils.mk

TO_EXPORT = export

$(TO_EXPORT):
	$(eval ARTICLE := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export ARTICLE)
	$(call create_directory,$(ARTICLE))
	# resolve "latest" placeholder
	$(eval RAW_ARTICLE := $(call unescape,$(ARTICLE)))
	$(eval export NEXTHOP := $(subst latest,$(call latest_revision,$(RAW_ARTICLE)),$(NEXTHOP)))
	# revision is only until the first dot, not anything else
	$(eval export REVISION := $(word 1,$(subst ., ,$(NEXTHOP))))

	$(MAKE) -C . -f $(MK)/article_exports/export.mk $(ARTICLE)/$(NEXTHOP)

% :: $(TO_EXPORT) ;

.PHONY: $(TO_EXPORT)
