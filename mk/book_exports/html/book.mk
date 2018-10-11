
$(BOOK_REVISION).html: articles.dep	
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book_index.html \
		--data $(SITEMAP) \
		book "$(shell python3 $(MK)/unescape_make.py $(BOOK))" \
		subtarget "$(SUBTARGET)" \
	> $(BOOK_REVISION).html
	cp -r $(BASE)/templates/html_book_assets static/
	ln -s -f $(BASE)/media/ .

# postprocess html articles
%.html: %.raw_html
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval REVISION := $(call dir_tail,$*))
	
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book_article.html \
		--data $(SITEMAP) \
		book "$(shell python3 $(MK)/unescape_make.py $(BOOK))" \
		article "$(shell python3 $(MK)/unescape_make.py $(ARTICLE))" \
		subtarget "$(SUBTARGET)" \
	> $@	

	sed -i -e '/<!-- @ARTICLE_CONTENT@ -->/{r $*.raw_html' -e 'd' -e '}' $@
	
.DELETE_ON_ERROR:
