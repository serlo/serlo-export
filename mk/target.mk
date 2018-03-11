include $(MK)/utils.mk

SUBTARGETS = subtargets

$(SUBTARGETS):
	$(eval SUBTARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(call create_directory,$(SUBTARGET))
	$(MAKE) -C $(SUBTARGET) -f $(MK)/subtarget.mk TARGET=$(TARGET) SUBTARGET=$(SUBTARGET) MK=$(MK) $(NEXTHOP)

% :: $(SUBTARGETS) ;

.PHONY: $(SUBTARGETS)
