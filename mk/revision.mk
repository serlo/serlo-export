%.md:
	python $(MK)/download_article.py $(ARTICLE) $* > $@

%.json: %.md
	python $(MK)/transform_article.py $(ARTICLE) $* < $< > $@

%.yml: %.md
	$(MK)/transform_article.sh < $< > $@

%.tex: %.yml
	$(MK)/article_to_tex.sh $(ARTICLE) $* $< > $@

%.dep: %.json
	python $(MK)/article_dependencies.py $* < $< > $@

.DELETE_ON_ERROR:

.SECONDARY:
