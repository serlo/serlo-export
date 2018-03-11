include $(MK)/utils.mk

SUBTARGETS = subtargets

$(SUBTARGETS):
	$(eval SUBTARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export SUBTARGET)
	$(call create_directory,$(SUBTARGET))
	$(MAKE) -C $(SUBTARGET) -f $(MK)/subtarget.mk $(NEXTHOP)

% :: $(SUBTARGETS) ;

.PHONY: $(SUBTARGETS)
