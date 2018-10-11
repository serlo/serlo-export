
.SECONDEXPANSION:
%.lints.yml: $(ORIGIN_SECONDARY)
	$(MK)/bin/mwlint \
		--texvccheck-path $(MK)/bin/texvccheck \
	< $< > $@

$(BOOK_REVISION).stats.html: $(BOOK_REVISION).stats.yml
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/stats.html \
		--data $(BOOK_REVISION).stats.yml \
		book "$(shell python3 $(MK)/unescape_make.py $(BOOK))" \
		book_revision $(BOOK_REVISION) \
	> $(BOOK_REVISION).stats.html

$(BOOK_REVISION).stats.yml: articles.dep
	$(file >$(BOOK_REVISION).article_list,$(filter %.stats.yml,$^))
	python3 $(MK)/book_exports/stats/collect_stats.py $(BOOK_REVISION) \
		> $(BOOK_REVISION).stats.yml

.DELETE_ON_ERROR:

