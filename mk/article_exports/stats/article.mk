
.SECONDEXPANSION:
%.lints.yml: $(ORIGIN_SECONDARY)
	$(MK)/bin/mwlint \
		--texvccheck-path $(MK)/bin/texvccheck \
	< $< > $@

# TODO: stats.html does not contain lint info.
%.stats.html: %.stats.yml %.lints.yml
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/article_stats.html \
		--data $< \
		article "$(call unescape,$(ARTICLE))" \
		revision $(REVISION) \
	> $@
