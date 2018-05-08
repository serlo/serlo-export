include $(MK)/utils.mk

ARTICLES := articles
SITEMAP := $(BASE)/book_exports/$(BOOK)/bookmap.yml

articles.dep: $(SITEMAP)
	$(MK)/bin/sitemap_utils -i $(SITEMAP) --articles tex $(SUBTARGET) > articles.dep

# Make target $(SUBTARGET) is defined by articles.dep
$(SUBTARGET).tex: $(SUBTARGET)
	touch $(SUBTARGET).tex

%.tex:
	$(eval ARTICLE := $(call dir_head,$@))
	$(eval ARTICLE_FILE := $(call dir_tail,$@))
	$(eval export ARTICLE)
	$(call create_directory,$(ARTICLE))
	$(MAKE) -C $(ARTICLE) -f $(MK)/latex.mk $(ARTICLE_FILE)

include articles.dep

.DELETE_ON_ERROR:

.SECONDARY:
