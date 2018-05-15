%.md:
	python $(MK)/download_article.py $(ARTICLE) $* > $@

%.yml: %.md
	$(MK)/bin/mwtoast --stdin < $< > $@

.DELETE_ON_ERROR:
.SECONDARY:
