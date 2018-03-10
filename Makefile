# Absolute path to the directory of this Makefile
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

# Define variables for different directories
MK := $(ROOT_DIR)/mk
ARTICLES := articles
MEDIA := media
ARTICLE_EXPORTS := article_exports
TMP_BIN_DIR := .build

include $(MK)/utils.mk

.PHONY: clean init $(ARTICLES) $(MEDIA) $(ARTICLE_EXPORTS)

$(ARTICLES):
	$(eval NEXTGOAL := $(MAKECMDGOALS:articles/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $(ARTICLES) -f $(MK)/article.mk MK=$(MK) $(NEXTGOAL)

$(MEDIA):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/media.mk MK=$(MK) $(NEXTGOAL)

$(ARTICLE_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	$(call create_directory,$@)
	$(MAKE) -C $@ -f $(MK)/article_export.mk MK=$(MK) $(NEXTGOAL)

init:
	$(call check_dependency,ocamlopt)
	$(call check_dependency,inkscape)
	$(call check_dependency,convert)
	$(call check_dependency,qrencode)
	$(call check_dependency,latex)
	pip install -r requirements.txt
	$(call create_directory,$(TMP_BIN_DIR))
	$(call create_directory,$(MK)/bin)
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
