REVISION := $(basename $(MAKECMDGOALS))

ORIGIN := $(BASE)/articles/$(ARTICLE)

RECURSE_TO_ORIGIN := recurse_to_origin

%.tex: $(ORIGIN)/%.yml %.dep
	$(MK)/article_to_tex.sh $(ARTICLE) $* $(TARGET).$(SUBTARGET) < $< > $@

%.dep: $(ORIGIN)/%.yml
	$(MK)/article_dependencies.sh $(ARTICLE) $* $(TARGET).$(SUBTARGET) < $< > $@

$(ORIGIN)/% :: $(RECURSE_TO_ORIGIN) ;

.PHONY: $(RECURSE_TO_ORIGIN)

$(RECURSE_TO_ORIGIN):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(REVISION).yml

media/%:
	$(MAKE) -C $(BASE) media/$*

sections/%:
	$(eval SECS := $(dir $*))
	$(eval REVID := $(basename $(notdir $*)))
	$(MAKE) -C $(BASE) sections/$(dir $(SECS:%/=%))$(REVID)

include $(REVISION).dep

.DELETE_ON_ERROR:

.SECONDARY:
