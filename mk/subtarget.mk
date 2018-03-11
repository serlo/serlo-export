include $(MK)/utils.mk

ARTICLES = articles

$(ARTICLES):
	$(eval ARTICLE := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(call create_directory,$(ARTICLE))
	$(MAKE) -C $(ARTICLE) -f $(MK)/lp_revision_export.mk TARGET=$(TARGET) SUBTARGET=$(SUBTARGET) ARTICLE=$(ARTICLE) MK=$(MK) $(NEXTHOP)

% :: $(ARTICLES) ;

.PHONY: $(ARTICLES)
