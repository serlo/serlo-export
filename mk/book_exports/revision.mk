include $(MK)/utils.mk

TO_TARGET = target

$(TO_TARGET): 
	$(eval BOOK_REVISION := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export BOOK_REVISION)
	$(call create_directory,$(BOOK_REVISION))
	$(MAKE) -C $(BOOK_REVISION) -f $(MK)/book_exports/target.mk $(NEXTHOP)
	
% :: $(TO_TARGET) ;

.DELETE_ON_ERROR:
.NOTPARALLEL:
.PHONY: $(TO_TARGET)
