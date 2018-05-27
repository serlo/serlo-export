
.SECONDEXPANSION:
%.lints.yml: $(ORIGIN_SECONDARY)
	$(MK)/bin/mwlint \
		--texvccheck-path $(MK)/bin/texvccheck \
	< $< > $@

$(BOOK_REVISION).stats.yml: articles.dep
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/lint_list \
		--data $(SITEMAP) \
	> $(BOOK_REVISION).lint_list

	touch $(BOOK_REVISION).stats.yml

.DELETE_ON_ERROR:
