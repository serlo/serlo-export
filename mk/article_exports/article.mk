include $(MK)/utils.mk

TO_TARGET = target

$(TO_TARGET):
	$(eval TARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export TARGET)
	$(call create_directory,$(TARGET))
	$(MAKE) -C $(TARGET) -f $(MK)/article_exports/target.mk $(NEXTHOP)

% :: $(TO_TARGET) ;

.PHONY: $(TO_TARGET)
