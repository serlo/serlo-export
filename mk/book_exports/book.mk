include $(MK)/utils.mk

TARGETS = targets

$(TARGETS):
	$(eval BOOK := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export BOOK)
	$(call create_directory,$(BOOK))
	$(MAKE) -C $(BOOK) -f $(MK)/book_exports/target.mk $(NEXTHOP)

% :: $(TARGETS) ;

.PHONY: $(TARGETS)
