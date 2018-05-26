include $(MK)/utils.mk

$(BOOK_REVISION).tex:
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book.tex \
		--data $(SITEMAP) \
	> $(BOOK_REVISION).tex	

.PHONY: $(BOOK_REVISION).tex
.DELETE_ON_ERROR:
