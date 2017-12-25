%.md:
	python $(MK)/download_article.py $(ARTICLE) $* > $@

.DELETE_ON_ERROR:

.SECONDARY:
