# Absolute path to the directory of this Makefile
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

# Define variables for different directories
MK := $(ROOT_DIR)/mk
ARTICLES := articles
MEDIA := media
ARTICLE_EXPORTS := article_exports
SECTIONS := sections
TMP_BIN_DIR := .build

include $(MK)/utils.mk

.PHONY: clean init $(ARTICLES) $(MEDIA) $(ARTICLE_EXPORTS) $(SECTIONS)

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

$(SECTIONS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	@[[ -d $@ ]] || mkdir $@
	$(MAKE) -C $@ -f $(MK)/sec_article.mk MK=$(MK) $(NEXTGOAL)

init:
	$(call check_dependency,ocamlopt)
	$(call check_dependency,inkscape)
	$(call check_dependency,convert)
	$(call check_dependency,qrencode)
	$(call check_dependency,latex)
	pip install -r requirements.txt
	$(call create_directory,$(TMP_BIN_DIR))
	$(call create_directory,$(MK)/bin)
	$(call build_rust_dep,mediawiki-peg-rust,https://github.com/vroland/mediawiki-peg-rust,mwtoast)
	$(call build_rust_dep,mfnf-export,https://github.com/vroland/mfnf-export,mfnf_ex)
	$(call git_clone,extension-math,https://phabricator.wikimedia.org/diffusion/EMAT/extension-math.git)
	(cd $(TMP_BIN_DIR)/extension-math/texvccheck && make && cp texvccheck $(MK)/bin)

clean:
	git clean -ffdx

.SUFFIXES:

Makefile : ;

$(ARTICLES)/% :: $(ARTICLES) ;

$(MEDIA)/% :: $(MEDIA) ;

$(ARTICLE_EXPORTS)/% :: $(ARTICLE_EXPORTS) ;

$(SECTIONS)/% :: $(SECTIONS) ;
