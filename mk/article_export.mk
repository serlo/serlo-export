include $(MK)/utils.mk

TARGETS = targets

$(TARGETS):
	$(eval TARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export TARGET)
	$(call create_directory,$(TARGET))
	$(MAKE) -C $(TARGET) -f $(MK)/target.mk $(NEXTHOP)

% :: $(TARGETS) ;

.PHONY: $(TARGETS)
