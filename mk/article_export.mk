REVISIONS = revisions

$(REVISIONS):
	$(eval ARTICLE := $(patsubst %/,%,$(dir $(MAKECMDGOALS))))
	$(eval REVISION := $(notdir $(MAKECMDGOALS)))
	@[ -d $(ARTICLE) ] || mkdir $(ARTICLE)
	$(MAKE) -C $(ARTICLE) -f $(MK)/revision_export.mk ARTICLE=$(ARTICLE) MK=$(MK) $(REVISION)

% :: $(REVISIONS) ;

.PHONY: $(REVISIONS)
