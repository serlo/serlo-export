SOURCE = $(shell git ls-tree -r master --name-only)

.PHONY: all
all:
	python create_books.py
	for BOOK_DIR in out/*; do \
		make -C "$$BOOK_DIR" -f $(CURDIR)/build-book.mk; \
	done

.PHONY: test
test:
	nosetests3

.PHONY: watch
watch:
	while inotifywait -e modify ${SOURCE}; do \
		make all ; \
	done

.PHONY: watch_test
watch_test:
	while inotifywait -e modify ${SOURCE}; do \
		make test ; \
	done
