REVISION := $(basename $(MAKECMDGOALS))

ORIGIN := $(BASE)/articles/$(ARTICLE)

RECURSE_TO_ORIGIN := recurse_to_origin

%.tex: $(ORIGIN)/%.yml %.dep
	$(MK)/article_to_tex.sh $(ARTICLE) $(REVISION) $(TARGET).$(SUBTARGET) < $< > $@

%.dep: $(ORIGIN)/%.yml
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(REVISION) \
		--section-path $(BASE)/sections \
		--externals-path $(BASE)/media \
		deps $(TARGET).$(SUBTARGET) \
		< $< > $@

$(ORIGIN)/% :: $(RECURSE_TO_ORIGIN) ;

$(RECURSE_TO_ORIGIN):
	$(MAKE) -C $(BASE) articles/$(ARTICLE)/$(REVISION).yml

$(BASE)/media/%:
	$(MAKE) -C $(BASE) media/$*

$(BASE)/sections/%:
	$(eval SECS := $(dir $*))
	$(eval REVID := $(basename $(notdir $*)))
	$(MAKE) -C $(BASE) sections/$(dir $(SECS:%/=%))$(REVID)

# make will try to build $(REVISION).dep before including
include $(REVISION).dep

.PHONY: $(RECURSE_TO_ORIGIN)
.DELETE_ON_ERROR:
.SECONDARY:
