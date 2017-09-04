# Makefile for creating a PDF from a LaTeX project

TEX_FILE = $(shell basename $$(pwd)).tex
PDF_FILE = $(patsubst %.tex,%.pdf,${TEX_FILE})

FIGURES  = $(patsubst %.svg,%.pdf,$(wildcard *.svg)) \
           $(patsubst %.jpg,%.pdf,$(wildcard *.jpg)) \
           $(patsubst %.png,%.pdf,$(wildcard *.png))

.PHONY: all
all: ${PDF_FILE}

${PDF_FILE}: ${TEX_FILE} ${FIGURES}
	pdflatex -halt-on-error -no-shell-escape $<

%.pdf: %.svg
	inkscape --export-area-drawing --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

%.pdf: %.jpg
	convert $< $@

%.pdf: %.png
	convert $< $@
