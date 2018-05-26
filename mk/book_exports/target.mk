include $(MK)/utils.mk

SUBTARGETS = subtargets

$(SUBTARGETS): 
	$(eval BOOK_REVISION := $(basename $(notdir $(MAKECMDGOALS))))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export BOOK_REVISION)
	$(call create_directory,$(BOOK_REVISION))
	$(MAKE) -C $(BOOK_REVISION) -f $(MK)/book_exports/revision.mk $(NEXTHOP)
	
% :: $(SUBTARGETS) ;

.DELETE_ON_ERROR:
.NOTPARALLEL:
.PHONY: $(SUBTARGETS)
