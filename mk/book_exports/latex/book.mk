include $(MK)/utils.mk

SITEMAP := $(BASE)/book_exports/$(BOOK)/bookmap.yml

$(SUBTARGET).tex:
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book.tex \
		--data $(SITEMAP) \
	> $(SUBTARGET).tex	

.PHONY: $(SUBTARGET).tex
.DELETE_ON_ERROR:
