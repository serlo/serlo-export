include $(MK)/utils.mk

REVISIONS = subtargets
BOOK_REVISION := $(basename $(notdir $(MAKECMDGOALS)))

$(REVISIONS): 
	$(eval TARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export TARGET)
	$(eval export BOOK_REVISION)
	$(call create_directory,$(TARGET))
	$(MAKE) -C $(TARGET) -f $(MK)/book_exports/subtarget.mk $(NEXTHOP)

$(BOOK_REVISION).md:	
	python $(MK)/download_article.py $(BOOK) $(BOOK_REVISION) > $(BOOK_REVISION).md

$(BOOK_REVISION).raw.yml: $(BOOK_REVISION).md
	$(MK)/bin/mwtoast -i $(BOOK_REVISION).md > $(BOOK_REVISION).raw.yml

$(BOOK_REVISION).pre.yml: $(BOOK_REVISION).raw.yml
	$(MK)/bin/parse_bookmap \
		--input $(BOOK_REVISION).raw.yml \
		--texvccheck-path $(MK)/bin/texvccheck \
	> $(BOOK_REVISION).pre.yml	

$(BOOK_REVISION).yml: $(BOOK_REVISION).pre.yml
	python $(MK)/fill_sitemap_revisions.py $(BOOK_REVISION).pre.yml > $(BOOK_REVISION).yml
	
% :: $(BOOK_REVISION).yml $(REVISIONS) ;

.DELETE_ON_ERROR:
.NOTPARALLEL:
.PHONY: $(REVISIONS)
