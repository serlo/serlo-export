REVISION := $(basename $(MAKECMDGOALS))

ORIGIN := $(BASE)/articles/$(ARTICLE)

RECURSE_TO_ORIGIN := recurse_to_origin

%.html %.css: $(ORIGIN)/%.yml %.section-dep %.media-dep
	$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(REVISION) \
		--base-path $(BASE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		$(TARGET).$(SUBTARGET) < $< > $*.body
	cp $(BASE)/templates/article.html $@

	sed -i -e '/{{content}}/{r $*.body' -e 'd' -e '}' $@
	cp $(BASE)/templates/article.css .
	ln -s $(BASE)/media media

%.section-dep: $(ORIGIN)/%.yml
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(REVISION) \
		--base-path $(BASE) \
		section-deps $(TARGET).$(SUBTARGET) \
		< $< > $@

# %.sections is a target defined by %.section-dep
%.media-dep: $(ORIGIN)/%.yml %.section-dep %.sections
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(REVISION) \
		--base-path $(BASE) \
		media-deps $(TARGET).$(SUBTARGET) \
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

include $(REVISION).section-dep 
# media-dep cannot be made initially, needs sections
-include $(REVISION).media-dep

.PHONY: $(RECURSE_TO_ORIGIN)
.DELETE_ON_ERROR:
.SECONDARY:
