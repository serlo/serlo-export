SOURCE = $(shell git ls-tree -r master --name-only)

.PHONY: all
all:
	python create_books.py
	for DIR in out/*; do \
		(cd "$$DIR" && \
        for f in $$(find -name "*.svg"); do (echo "converting $$f ..." && inkscape "$$f" --export-pdf "$$f".pdf --export-ignore-filters); done && \
		pdflatex -halt-on-error -no-shell-escape *tex); \
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
