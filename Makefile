ROOT_DIR:=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
SOURCES = $(shell git ls-tree -r master --name-only)
PYTHON = $(shell if which pyenv > /dev/null; \
                 then echo python ; else echo python3 ; fi)

MK := $(ROOT_DIR)/mk

#topdir = $(shell echo $(1) | sed 's,^[^/]*/,,')

ARTICLES := articles
IMAGES := images
ARTICLE_EXPORTS := article_exports
TMP_BIN_DIR := .build

inotify = while inotifywait -e modify ${SOURCES}; do ${1} ; done
create_book = make -C "${1}" -f ${ROOT_DIR}/build-book.mk

.PHONY: clean watch_test watch test init all $(ARTICLES) $(IMAGES) $(ARTICLE_EXPORTS)

all:
	$(PYTHON) create_books.py
	for BOOK_DIR in out/*; do \
		$(call create_book,$$BOOK_DIR); \
	done

% :: out/% out
	$(PYTHON) create_books.py "$@"
	$(call create_book,$<)

$(ARTICLES):
	$(eval NEXTGOAL := $(MAKECMDGOALS:articles/%=%))
	@[[ -d $(ARTICLES) ]] || mkdir $(ARTICLES)
	$(MAKE) -C $(ARTICLES) -f $(MK)/article.mk MK=$(MK) $(NEXTGOAL)

$(IMAGES):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	@[[ -d $@ ]] || mkdir $@
	$(MAKE) -C $@ -f $(MK)/image.mk MK=$(MK) $(NEXTGOAL)

$(ARTICLE_EXPORTS):
	$(eval NEXTGOAL := $(MAKECMDGOALS:$@/%=%))
	@[[ -d $@ ]] || mkdir $@
	$(MAKE) -C $@ -f $(MK)/article_export.mk MK=$(MK) $(NEXTGOAL)

init:
	which ocamlopt &>/dev/null || { echo "Please install ocaml"; exit 1; }
	pip install -r requirements.txt
	[[ -d $(TMP_BIN_DIR) ]] || mkdir $(TMP_BIN_DIR)
	[[ -d $(MK)/bin ]] || mkdir $(MK)/bin
	[[ -d $(TMP_BIN_DIR)/mediawiki-peg-rust ]] || (cd $(TMP_BIN_DIR) && git clone https://github.com/vroland/mediawiki-peg-rust)
	[[ -d $(TMP_BIN_DIR)/mfnf-export ]] || ( cd $(TMP_BIN_DIR) && git clone https://github.com/vroland/mfnf-export)
	[[ -d $(TMP_BIN_DIR)/extension-math ]] || ( cd $(TMP_BIN_DIR) && git clone https://phabricator.wikimedia.org/diffusion/EMAT/extension-math.git)
	(cd $(TMP_BIN_DIR)/mediawiki-peg-rust && git pull && cargo build --release && cp target/release/mwtoast $(MK)/bin )
	(cd $(TMP_BIN_DIR)/mfnf-export && git pull && cargo build --release && cp target/release/mfnf_ex $(MK)/bin)
	(cd $(TMP_BIN_DIR)/extension-math/texvccheck && make && cp texvccheck $(MK)/bin)

test:
	$(PYTHON) -m nose --with-doctest

watch:
	$(call inotify,make all)

watch_test:
	$(call inotify,make test)

clean:
	git clean -ffdx

.SUFFIXES:

Makefile : ;

$(ARTICLES)/% :: $(ARTICLES) ;

$(IMAGES)/% :: $(IMAGES) ;

$(ARTICLE_EXPORTS)/% :: $(ARTICLE_EXPORTS) ;
