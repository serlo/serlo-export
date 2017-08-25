SOURCE = $(shell git ls-tree -r master --name-only)

.PHONY: all
all:
	python create_books.py
	for DIR in out/*; do \
		( cd "$$DIR" && \
		pdflatex -interaction nonstopmode -no-shell-escape *tex ); \
	done

.PHONY: test
test:
	nosetest3

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
