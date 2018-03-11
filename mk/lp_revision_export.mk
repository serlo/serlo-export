REVISION := $(basename $(MAKECMDGOALS))

ORIGIN := $(MK)/../articles/$(ARTICLE)

RECURSE_TO_ORIGIN := recurse_to_origin

%.tex: $(ORIGIN)/%.yml %.dep
	$(MK)/article_to_tex.sh $(ARTICLE) $* $(TARGET).$(SUBTARGET) < $< > $@

%.dep: $(ORIGIN)/%.yml
	$(MK)/article_dependencies.sh $(ARTICLE) $* $(TARGET).$(SUBTARGET) < $< > $@

$(ORIGIN)/% :: $(RECURSE_TO_ORIGIN) ;

.PHONY: $(RECURSE_TO_ORIGIN)

$(RECURSE_TO_ORIGIN):
	$(MAKE) -C $(MK)/.. articles/$(ARTICLE)/$(REVISION).yml

media/%:
	$(MAKE) -C $(MK)/.. media/$*

sections/%:
	$(eval SECS := $(dir $*))
	$(eval REVID := $(basename $(notdir $*)))
	$(MAKE) -C $(MK)/.. sections/$(dir $(SECS:%/=%))$(REVID)

include $(REVISION).dep

.DELETE_ON_ERROR:

.SECONDARY:
