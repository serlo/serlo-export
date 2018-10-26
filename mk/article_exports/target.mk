include $(MK)/utils.mk

TO_SUBTARGET = subtarget

$(TO_SUBTARGET):
	$(eval SUBTARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export SUBTARGET)
	$(call create_directory,$(SUBTARGET))
	$(MAKE) -C $(SUBTARGET) -f $(MK)/article_exports/subtarget.mk $(NEXTHOP)

% :: $(TO_SUBTARGET) ;

.PHONY: $(TO_SUBTARGET)
