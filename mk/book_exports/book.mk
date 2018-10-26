include $(MK)/utils.mk

TO_REVISION = book_revision

# make a directory for the book and proceed to make the book revision
$(TO_REVISION):
	$(eval BOOK := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export BOOK)
	$(call create_directory,$(BOOK))
	$(MAKE) -C $(BOOK) -f $(MK)/book_exports/revision.mk $(NEXTHOP)

% :: $(TO_REVISION) ;

.PHONY: $(TO_REVISION)
.NOTPARALLEL:
