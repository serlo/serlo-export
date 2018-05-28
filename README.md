# mfnf-pdf-export
mfnf-pdf-export is a set of tools to create documents from MediaWiki articles. Target formats are currently LaTeX and PDF. 
Our main design goals are extensibility and simplicity. 

The heart of this repository is a collection of Makefiles, which build the target file step-by-step using small, unix-like tools.

## Glossary

* Target: An output format, like LaTeX, PDF or HTML
* Subtarget: A specific configuration of a target. E.g. PDF for print (pdf.print), verbose LaTeX (latex.all), ...

## Getting started

This tool is only tested on linux so far, so these instructions are for linux only. 
Make sure you have the following software installed:

* python3
* bash
* python3-virtualenv
* cargo ([rust package manager](https://www.rust-lang.org/en-US/install.html))
* inkscape
* qrencode
* lualatex (e.g. via texlive-full)
* ocaml
* convert (by image magick)
* sed

In the root of this repository, create a new python virtual environment:
``` sh
virtualenv -p python3.6 venv
```
Source the virtual environment:
``` sh
source venv/bin/activate
```
Now run the init script. This will install some python libraries in your virtual environments and build some tools needed for article parsing / export. 
``` sh
make init
```
Done!

## Usage

To build a file with make, simply supply the path to the target file and let make do its magic. The directory structure of article exports is as follows:
``` sh
article_exports/<target>/<subtarget>/<escaped article name>/<revision id>.<extension>
```
This looks complicated, but actually looks quite beatiful when running `tree` on it ;)

* `<target>`: (latex, pdf, ...) The target format format. Targets and subtargets are defined in `config/mfnf.yml`.
* `<subtarget>`: (all, print, ...) The subtarget. Configuration see `<target>`
* `<escaped article name>`: Article names can be extracted from the article url: `https://de.wikibooks.org/wiki/Mathe_für_Nicht-Freaks:_Beispielkapitel:_Grundlegende_Formatierungen -> Mathe_für_Nicht-Freaks:_Beispielkapitel:_Grundlegende_Formatierungen`.
Unfortunately, make needs some special characters escaped (see table below)
This means: `Mathe_für_Nicht-Freaks:_Beispielkapitel:_Grundlegende_Formatierungen` becomes `Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen`.
* `<revision_id>`: Revision ids can be found on the history page of an article. 
* `<extension>`: File extension of your target format. (e.g. `pdf` for PDF, `tex` for LaTeX)

| original | escaped   |
|-----|-----------|
| `:` | `@COLON@` |
| ` ` | `_`       |
| `(` | `@LBR@`   |
| `)` | `@RBR@`   |

Thus, to build the example article we have to tell make to "make" the file:
``` sh
make article_exports/pdf/all/Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen/843164.pdf
```
Now we can use `tree article_exports` to print the directory structure:
```
article_exports
├── latex <-- pdf depends on latex, so latex is also built.
│   └── all
│       └── Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen
│           ├── 843164.dep
│           └── 843164.tex
└── pdf
    └── all
        └── Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen
            ├── 843164.aux
            ├── 843164.fdb_latexmk
            ├── 843164.fls
            ├── 843164.log
            ├── 843164.out
            ├── 843164.pdf <-- Our pdf file is here
            ├── 843164.tex
            └── 843164.yml
```
