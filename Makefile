ROOT_DIR:=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
SOURCES = $(shell git ls-tree -r master --name-only)
PYTHON = $(shell if which pyenv > /dev/null; \
                 then echo python ; else echo python3 ; fi)

inotify = while inotifywait -e modify ${SOURCES}; do ${1} ; done
create_book = make -C "${1}" -f ${ROOT_DIR}/build-book.mk

.PHONY: all
all:
	$(PYTHON) create_books.py
	for BOOK_DIR in out/*; do \
		$(call create_book,$$BOOK_DIR); \
	done

% :: out/% out
	$(PYTHON) create_books.py "$@"
	$(call create_book,$<)

.PHONY: init
init:
	pip install -r requirements.txt

.PHONY: test
test:
	$(PYTHON) -m nose --with-doctest

.PHONY: watch
watch:
	$(call inotify,make all)

.PHONY: watch_test
watch_test:
	$(call inotify,make test)

.PHONY: upload
upload:
	rsync -v -r out/ -e ssh --exclude 'file*' hp:~/mfnf-pdf-export

.PHONY: clean
clean:
	git clean -ffdx
