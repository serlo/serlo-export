# Absolute path to the directory of this Makefile
BASE := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

# Define variables for different directories
MK := $(BASE)/mk
ARTICLE_EXPORTS := article_exports
BOOK_EXPORTS := book_exports
DOCS := docs
TMP_BIN_DIR := .build
REVISION_LOCK_FILE = $(BASE)/revisions.json
OUTPUT_DIRS := articles media sections $(ARTICLE_EXPORTS) $(BOOK_EXPORTS) $(DOCS)
TEMP_FILES := $(REVISION_LOCK_FILE)

# helper variables with dir head / tails for the target 
# pattern (value of $*) where they are expanded
PATTERN_HEAD = $(call dir_head,$*)
PATTERN_TAIL = $(call dir_tail,$*)

export BASE
export MK
export REVISION_LOCK_FILE

include $(MK)/utils.mk

.PHONY: clean clean_all init $(OUTPUT_DIRS)

include $(MK)/articles/articles.mk
include $(MK)/media/media.mk
include $(MK)/sections/section.mk

$(ARTICLE_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/article_exports/article.mk $(NEXTGOAL)

$(BOOK_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/book_exports/book.mk $(NEXTGOAL)

init:
	$(call map,check_dependency,ocamlopt inkscape convert qrencode latex sed cmark jq curl sponge)
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
	$(call map,remove_file,$(TEMP_FILES))


clean_all:
	git clean -ffdx

.SUFFIXES:
.DELETE_ON_ERROR:

Makefile : ;

$(ARTICLE_EXPORTS)/% :: $(ARTICLE_EXPORTS) ;

$(BOOK_EXPORTS)/% :: $(BOOK_EXPORTS) ;
