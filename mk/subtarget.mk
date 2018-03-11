include $(MK)/utils.mk

ARTICLES = articles

$(ARTICLES):
	$(eval ARTICLE := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export ARTICLE)
	$(call create_directory,$(ARTICLE))
	$(MAKE) -C $(ARTICLE) -f $(MK)/lp_revision_export.mk $(NEXTHOP)

% :: $(ARTICLES) ;

.PHONY: $(ARTICLES)
