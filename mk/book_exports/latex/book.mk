include $(MK)/utils.mk

$(SUBTARGET).tex:
	$(MK)/bin/handlebars-cli-rs \
		--input $(BASE)/templates/book.tex \
		--data $(SITEMAP) \
	> $(SUBTARGET).tex	

.PHONY: $(SUBTARGET).tex
.DELETE_ON_ERROR:
