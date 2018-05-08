include $(MK)/utils.mk

SUBTARGETS = subtargets

$(SUBTARGETS): 
	$(eval TARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export TARGET)
	$(call create_directory,$(TARGET))
	$(MAKE) -C $(TARGET) -f $(MK)/book_subtarget.mk $(NEXTHOP)

bookmap.yml: bookmap.md
	$(MK)/bin/parse_bookmap -i bookmap.md > bookmap.yml
	python $(MK)/fill_sitemap_revisions.py bookmap.yml > bookmap.yml.tmp
	mv bookmap.yml.tmp bookmap.yml

bookmap.md:
	python $(MK)/download_article.py $(BOOK) latest > bookmap.md
	
% :: bookmap.yml $(SUBTARGETS) ;

.DELETE_ON_ERROR:

.PHONY: $(SUBTARGETS)
