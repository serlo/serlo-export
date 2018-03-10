# Absolute path to the directory of this Makefile
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

MK := $(ROOT_DIR)/mk

#topdir = $(shell echo $(1) | sed 's,^[^/]*/,,')

ARTICLES := articles
MEDIA := media
ARTICLE_EXPORTS := article_exports
TMP_BIN_DIR := .build

.PHONY: clean init $(ARTICLES) $(MEDIA) $(ARTICLE_EXPORTS)

$(ARTICLES):
	$(eval NEXTGOAL := $(MAKECMDGOALS:articles/%=%))
	@[ -d $(ARTICLES) ] || mkdir $(ARTICLES)
	$(MAKE) -C $(ARTICLES) -f $(MK)/article.mk MK=$(MK) $(NEXTGOAL)

$(MEDIA):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	@[ -d $@ ] || mkdir $@
	$(MAKE) -C $@ -f $(MK)/media.mk MK=$(MK) $(NEXTGOAL)

$(ARTICLE_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	@[ -d $@ ] || mkdir $@
	$(MAKE) -C $@ -f $(MK)/article_export.mk MK=$(MK) $(NEXTGOAL)

init:
	which ocamlopt &>/dev/null || { echo "Please install ocaml"; exit 1; }
	pip install -r requirements.txt
	[ -d $(TMP_BIN_DIR) ] || mkdir $(TMP_BIN_DIR)
	[ -d $(MK)/bin ] || mkdir $(MK)/bin
	[ -d $(TMP_BIN_DIR)/mediawiki-peg-rust ] || (cd $(TMP_BIN_DIR) && git clone https://github.com/vroland/mediawiki-peg-rust)
	[ -d $(TMP_BIN_DIR)/mfnf-export ] || ( cd $(TMP_BIN_DIR) && git clone https://github.com/vroland/mfnf-export)
	[ -d $(TMP_BIN_DIR)/extension-math ] || ( cd $(TMP_BIN_DIR) && git clone https://phabricator.wikimedia.org/diffusion/EMAT/extension-math.git)
	(cd $(TMP_BIN_DIR)/mediawiki-peg-rust && git pull && cargo build --release && cp target/release/mwtoast $(MK)/bin )
	(cd $(TMP_BIN_DIR)/mfnf-export && git pull && cargo build --release && cp target/release/mfnf_ex $(MK)/bin)
	(cd $(TMP_BIN_DIR)/extension-math/texvccheck && make && cp texvccheck $(MK)/bin)

clean:
	git clean -ffdx

.SUFFIXES:

Makefile : ;

$(ARTICLES)/% :: $(ARTICLES) ;

$(MEDIA)/% :: $(MEDIA) ;

$(ARTICLE_EXPORTS)/% :: $(ARTICLE_EXPORTS) ;
