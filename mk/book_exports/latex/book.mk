
$(BOOK_REVISION).tex: articles.dep
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book.tex \
		--data $(SITEMAP) \
		subtarget $(SUBTARGET) \
	 > $(BOOK_REVISION).tex	

.DELETE_ON_ERROR:
