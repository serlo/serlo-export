
$(REVISION): $(BASE)/articles/$(ARTICLE)/$(REVISION).yml
	$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--base-path $(BASE) \
		--section-path sections/$(ARTICLE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		sections $(ARTICLE) < $<

$(BASE)/articles/%.yml:
	$(MAKE) -C $(BASE) articles/$*.yml

.PHONY: $(REVISION)
.NOTPARALLEL:
