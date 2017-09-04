LATEX = pdflatex
LATEXFLAGS = -halt-on-error -no-shell-escape
LATEXMK = latexmk
LATEXMKFLAGS = -f

.PHONY: all
all:
	$(LATEXMK) $(LATEXMKFLAGS) -pdflatex="$(LATEX) $(LATEXFLAGS) %O %S" -pdf "$(notdir $(CURDIR:%/=%))"
