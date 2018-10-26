include $(MK)/utils.mk

TO_ARTICLES = articles

$(TO_ARTICLES):
	$(eval SUBTARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export SUBTARGET)
	$(call create_directory,$(SUBTARGET))
	$(MAKE) -C $(SUBTARGET) -f $(MK)/book_exports/book_articles.mk $(NEXTHOP)

% :: $(TO_ARTICLES) ;

.NOTPARALLEL:
.PHONY: $(TO_ARTICLES)
