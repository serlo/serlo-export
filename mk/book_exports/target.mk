include $(MK)/utils.mk

SUBTARGETS = subtargets

$(SUBTARGETS): 
	$(eval TARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export TARGET)
	$(call create_directory,$(TARGET))
	$(MAKE) -C $(TARGET) -f $(MK)/book_exports/subtarget.mk $(NEXTHOP)

bookmap.md:
	python $(MK)/download_article.py $(BOOK) latest > bookmap.md

bookmap.raw.yml: bookmap.md
	$(MK)/bin/mwtoast -i bookmap.md > bookmap.raw.yml

bookmap.pre.yml: bookmap.raw.yml
	$(MK)/bin/parse_bookmap \
		--input bookmap.raw.yml \
		--texvccheck-path $(MK)/bin/texvccheck \
	> bookmap.pre.yml	

bookmap.yml: bookmap.pre.yml
	python $(MK)/fill_sitemap_revisions.py bookmap.pre.yml > bookmap.yml
	
% :: bookmap.yml $(SUBTARGETS) ;

.DELETE_ON_ERROR:
.NOTPARALLEL:
.PHONY: $(SUBTARGETS)
