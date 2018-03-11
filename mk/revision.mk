%.md:
	python $(MK)/download_article.py $(ARTICLE) $* > $@

%.yml: %.md
	$(MK)/transform_article.sh < $< > $@

.DELETE_ON_ERROR:

.SECONDARY:
