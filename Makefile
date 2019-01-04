SHELL:=/bin/sh

# Absolute path to the directory of this Makefile
BASE := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
MK := $(BASE)/mk

# define the concrete build directories
EXPORT_DIR := exports
ARTICLE_DIR := articles
MEDIA_DIR := media
SECTION_DIR := sections
DOCS_DIR := docs
ASSET_DIR := assets
TMP_BIN_DIR := .build
REVISION_LOCK_FILE := revisions.json

# name of the dummy book for article exports
ARTICLE_BOOK := articles
ARTICLE_BOOK_REVISION := dummy

# files which might be created (for clean target)
OUTPUT_DIRS := $(ARTICLE_DIR) $(MEDIA_DIR) $(SECTION_DIR) $(EXPORT_DIR) $(DOCS_DIR)
TEMP_FILES := $(REVISION_LOCK_FILE)

.SECONDARY:
.DELETE_ON_ERROR:
.SECONDEXPANSION:

include $(MK)/utils.mk
include $(MK)/macros.mk
include $(MK)/articles.mk
include $(MK)/sections.mk
include $(MK)/media.mk
include $(MK)/dependencies.mk
include $(MK)/article_book.mk
include $(MK)/book.mk
include $(MK)/targets/html.mk
include $(MK)/targets/latex.mk
include $(MK)/targets/pdf.mk
include $(MK)/targets/stats.mk

init:
	$(call map,check_dependency,ocamlopt inkscape convert qrencode latex sed jq curl sponge)
	$(call map,create_directory,$(TMP_BIN_DIR) $(MK)/bin)
	$(call build_rust_dep,mediawiki-peg-rust, \
		https://github.com/vroland/mediawiki-peg-rust, \
		0c5dbd47ee0fe592313c222c91e160bc52769be5, \
		mwtoast)
	$(call build_rust_dep,mfnf-export, \
		https://github.com/vroland/mfnf-export, \
		c4a905eb16233e9ede5dac62ae79de19335a6570, \
		mfnf_ex)
	$(call build_rust_dep,handlebars-cli-rs, \
		https://github.com/vroland/handlebars-cli-rs, \
		52fd6dbb01ddf67747c37f4d7d17cfc70e2548bd, \
		handlebars-cli-rs,mediawiki)
	$(call build_rust_dep,mfnf-sitemap-parser, \
		https://github.com/vroland/mfnf-sitemap-parser, \
		4d8002c6d9d7e1addda2bee3ea9514d19271ce6d, \
		parse_bookmap)
	$(call build_rust_dep,mwlint, \
		https://github.com/vroland/mwlint, \
		bc21869b4ce9550a8a709b395c4a8fba66406e4c, \
		mwlint)
	$(call git_clone,extension-math, \
		https://phabricator.wikimedia.org/diffusion/EMAT/extension-math.git)
	(cd $(TMP_BIN_DIR)/extension-math \
		&& git reset --hard 8879b5b7a1c2a983ad6d191c1b9f2fdf2b40956e \
		&& cd texvccheck \
		&& make && \
		cp texvccheck $(MK)/bin)
	(cd .build/ && wget -q https://github.com/KaTeX/KaTeX/releases/download/v0.10.0/katex.tar.gz -O katex.tar.gz)
	(cd $(ASSET_DIR)/html/html_book_assets && tar -xf $(BASE)/.build/katex.tar.gz)
	
# font cache clearing might be necessary after font changes
	(luaotfload-tool  --cache=erase || echo "could not clear LaTeX font cache!")
doc:
	(cd doc \
		&& $(MK)/bin/mwlint --dump-docs > src/template_specification.md \
		&& mdbook build)
clean:
	$(call map,remove_file,$(OUTPUT_DIRS))
	$(call map,remove_file,$(TEMP_FILES))

clean_all:
	git clean -ffdx

.PHONY: clean clean_all init doc
