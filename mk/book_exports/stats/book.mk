
.SECONDEXPANSION:
%.lints.yml: $(ORIGIN_SECONDARY)
	$(MK)/bin/mwlint \
		--texvccheck-path $(MK)/bin/texvccheck \
	< $< > $@

$(BOOK_REVISION).stats.yml $(BOOK_REVISION).article_list: articles.dep
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/article_list \
		--data $(SITEMAP) \
	> $(BOOK_REVISION).article_list

	python3 $(MK)/book_exports/stats/collect_stats.py $(BOOK_REVISION) \
		> $(BOOK_REVISION).stats.yml

	cat $(BOOK_REVISION).stats.yml

.DELETE_ON_ERROR:
