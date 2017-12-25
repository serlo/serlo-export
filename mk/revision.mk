%.md:
	python $(MK)/download_article.py $(ARTICLE) $* > $@

%.json: %.md
	python $(MK)/transform_article.py $(ARTICLE) $* < $< > $@

%.tex: %.json
	python $(MK)/article_to_tex.py < $< > $@

%.dep: %.json
	python $(MK)/article_dependencies.py $* < $< > $@

.DELETE_ON_ERROR:

.SECONDARY:
