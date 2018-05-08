include $(MK)/utils.mk

ARTICLES = articles

$(ARTICLES):
	$(eval SUBTARGET := $(call dir_head,$(MAKECMDGOALS)))
	$(eval NEXTHOP := $(call dir_tail,$(MAKECMDGOALS)))
	$(eval export SUBTARGET)
	$(call create_directory,$(SUBTARGET))
	$(MAKE) -C $(SUBTARGET) -f $(MK)/book_$(TARGET).mk $(NEXTHOP)

% :: $(ARTICLES) ;
	
.PHONY: $(ARTICLES)
