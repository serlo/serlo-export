
articles/%.yml: articles/%.md
	$(MK)/bin/mwtoast < $< > $@

articles/%.md:
	$(call create_directory,articles/$(PATTERN_HEAD))
	python $(MK)/download_article.py $(PATTERN_HEAD) $(PATTERN_TAIL) > $@
	
.DELETE_ON_ERROR:
.SECONDARY:
