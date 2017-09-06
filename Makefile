ROOT_DIR:=$(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
SOURCES = $(shell git ls-tree -r master --name-only)

inotify = while inotifywait -e modify ${SOURCES}; do ${1} ; done
create_book = make -C "${1}" -f ${ROOT_DIR}/build-book.mk

.PHONY: all
all: out
	for BOOK_DIR in out/*; do \
		$(call create_book,$$BOOK_DIR); \
	done

% :: out/% out
	$(call create_book,$<)

.PHONY: out
out:
	python create_books.py

.PHONY: test
test:
	nosetests3 --with-doctest

.PHONY: watch
watch:
	$(call inotify,make all)

.PHONY: watch_test
watch_test:
	$(call inotify,make test)

.PHONY: upload
upload:
	rsync -v -r out/ -e ssh hp:~/mfnf-pdf-export

.PHONY: clean
clean:
	git clean -ffdx
