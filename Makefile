# Absolute path to the directory of this Makefile
BASE := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

# Define variables for different directories
MK := $(BASE)/mk
ARTICLES := articles
MEDIA := media
ARTICLE_EXPORTS := article_exports
BOOK_EXPORTS := book_exports
SECTIONS := sections
DOCS := docs
TMP_BIN_DIR := .build
OUTPUT_DIRS := $(ARTICLES) $(MEDIA) $(ARTICLE_EXPORTS) $(SECTIONS) $(BOOK_EXPORTS) $(DOCS)

export BASE
export MK

include $(MK)/utils.mk

.PHONY: clean clean_all init $(OUTPUT_DIRS)

$(ARTICLES):
	$(eval NEXTGOAL := $(MAKECMDGOALS:articles/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $(ARTICLES) -f $(MK)/articles/article.mk $(NEXTGOAL)

$(MEDIA):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/media/media.mk $(NEXTGOAL)

$(ARTICLE_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/article_exports/article.mk $(NEXTGOAL)

$(BOOK_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/book_exports/book.mk $(NEXTGOAL)

$(SECTIONS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/sections/sec_article.mk $(NEXTGOAL)

init:
	$(call map,check_dependency,ocamlopt inkscape convert qrencode latex sed cmark)
	pip install -r requirements.txt
	$(call map,create_directory,$(TMP_BIN_DIR) $(MK)/bin)
	$(call build_rust_dep,mediawiki-peg-rust, \
		https://github.com/vroland/mediawiki-peg-rust,mwtoast)
	$(call build_rust_dep,mfnf-export, \
		https://github.com/vroland/mfnf-export,mfnf_ex)
	$(call build_rust_dep,handlebars-cli-rs, \
		https://github.com/vroland/handlebars-cli-rs,handlebars-cli-rs,mediawiki,mfnf)
	$(call build_rust_dep,mfnf-sitemap-parser, \
		https://github.com/vroland/mfnf-sitemap-parser,parse_bookmap)
	$(call build_rust_dep,mfnf-sitemap-parser, \
		https://github.com/vroland/mfnf-sitemap-parser,sitemap_utils)
	$(call build_rust_dep,mwlint, \
		https://github.com/vroland/mwlint,mwlint)
	$(call git_clone,extension-math, \
		https://phabricator.wikimedia.org/diffusion/EMAT/extension-math.git)
	(cd $(TMP_BIN_DIR)/extension-math \
		&& git reset --hard 8879b5b7a1c2a983ad6d191c1b9f2fdf2b40956e \
		&& cd texvccheck \
		&& make && \
		cp texvccheck $(MK)/bin)

mfnf-docs:
	mkdir -p $(BASE)/$(DOCS)
	$(MAKE) -C $(BASE)/$(DOCS) -f $(MK)/doc.mk $(@)


clean:
	$(call map,remove_file,$(OUTPUT_DIRS))

clean_all:
	git clean -ffdx

.SUFFIXES:

Makefile : ;

$(ARTICLES)/% :: $(ARTICLES) ;

$(MEDIA)/% :: $(MEDIA) ;

$(ARTICLE_EXPORTS)/% :: $(ARTICLE_EXPORTS) ;

$(BOOK_EXPORTS)/% :: $(BOOK_EXPORTS) ;

$(SECTIONS)/% :: $(SECTIONS) ;
