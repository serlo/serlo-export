%.md:
	python $(MK)/download_article.py $(ARTICLE) $* > $@

%.yml: %.md
	$(MK)/transform_article.sh < $< > $@

%.tex: %.yml
	$(MK)/article_to_tex.sh $(ARTICLE) $* < $< > $@

%.dep: %.yml
	$(MK)/article_dependencies.sh $(ARTICLE) $* < $< > $@

.DELETE_ON_ERROR:

.SECONDARY:
