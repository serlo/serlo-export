include $(MK)/utils.mk

# postprocess html articles
%.html: %.raw_html
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/article.html \
		--data $(ARTICLE)/$(REVISION).markers \
		article "$(shell python3 $(MK)/unescape_make.py $(ARTICLE))" \
		subtarget "$(SUBTARGET)" \
	> $@
	sed -i -e '/<!-- @ARTICLE_CONTENT@ -->/{r $*.raw_html' -e 'd' -e '}' $@
	cp -r $(BASE)/templates/html_book_assets $(ARTICLE)/static/
	ln -s -f $(BASE)/media/ $(ARTICLE)/
