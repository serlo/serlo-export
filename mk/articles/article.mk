include $(MK)/utils.mk

REVISIONS = revisions

$(REVISIONS):
	$(eval ARTICLE := $(patsubst %/,%,$(dir $(MAKECMDGOALS))))
	$(eval REVISION := $(notdir $(MAKECMDGOALS)))
	$(call create_directory,$(ARTICLE))
	$(eval export ARTICLE)
	$(MAKE) -C $(ARTICLE) -f $(MK)/articles/revision.mk $(REVISION)

% :: $(REVISIONS) ;

.PHONY: $(REVISIONS)
.NOTPARALLEL:
