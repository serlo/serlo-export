RAW_DIR = raw
HTML_DIR = html

RAW  = $(shell find $(RAW_DIR) -type f -name '*.txt')
HTML = $(patsubst $(RAW_DIR)/%.txt, $(HTML_DIR)/%.html, $(RAW))

.PHONY: all

all: $(HTML)

$(HTML_DIR)/%.html: $(RAW_DIR)/%.txt
	mkdir -p $(dir $@)
	python convert_to_html.py < $< > $@
