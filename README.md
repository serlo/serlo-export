# mfnf-pdf-export
mfnf-pdf-export is a set of tools to create documents from MediaWiki articles. Target formats are currently LaTeX, PDF and HTML (an a statistics target), more are planned.
Building on our previous experiences, the main design goals of this project are simplicity and extensibility. 

The heart of this repository is a collection of Makefiles, which build the target file step-by-step using small, unix-like tools.
We try to use existing / standard tools where possible. Most of the helper programs we develop ourselves are written in [Rust](https://www.rust-lang.org)
or [Python 3](https://www.python.org).

## Glossary

* Target: An output format, like LaTeX, PDF or HTML
* Subtarget: A specific configuration of a target. E.g. PDF for print (pdf.print), minimalistic HTML (html.minimal), ...
* Article: A document dealing with a certain topic, equivalent to articles in [WikiBooks](https://de.wikibooks.org/wiki/Hauptseite).
* Sitemap: A special article describing the composition of a book.
* Book: A collection of articles with some modifications like excluded headings or added meta information pages.
* Section: In our code, section usually refers to parts of an article marked with the `<section begin="..." />` tag.
* Marker: Annotation on a Part or Chapter of a book

## Getting started

This tool is only tested on linux so far, so these instructions are for linux only. 
Make sure you have the following software installed:

* python3
* python3-virtualenv
* cargo ([rust package manager](https://www.rust-lang.org/en-US/install.html))
* inkscape
* qrencode
* jq
* cmark
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

Whenever an article name or path is passed to `make`, it must be escaped:
 
| original | escaped   |
|-----|-----------|
| ` ` |  `_` |
| `:` |  `@COLON@` |
| `(` |  `@LBR@` |
| `)` |  `@RBR@` |
| `/` |  `@SLASH@` |
| `'` |  `@SQUOTE@` |
| `"` |  `@DQUOTE@` |
| `*` |  `@STAR@` |
| `=` |  `@EQ@` |
| `$` |  `@DOLLAR@` |
| `#` |  `@SHARP@` |
| `%` |  `@PERC@` |

### Book export

To build a file with make, simply supply the path to the target file and let make do its magic. The directory structure of book exports is as follows:
``` sh
make exports/<sitemap>/<sitemap revision>/<target>/<subtarget>/<sitemap revision>.book.<extension>
```
where
* `<sitemap>`: Name of the sitemap article. (escaped as described above)
* `<sitemap revision>`: Revision of the sitemap article to use. Can be *latest*.
* `<target>`: (latex, pdf, ...) The target format format. Targets and subtargets are defined in `config/mfnf.yml`.
* `<subtarget>`: (all, print, ...) The subtarget. Configuration see `<target>`
* `<extension>`: File extension of your target format. (e.g. `pdf` for PDF, `tex` for LaTeX, `html` for HTML, `stats.html` or `stats.yml` for stats)

This looks complicated, but actually looks quite beatiful when running `tree` on it ;)

### Article export

Exporting only a specific article works similarly, but the export of an article normally depends on its context in the book (e.g. for link targets). When we export a single article, we usually want it exported as if it was its own book. To force this behaviour, we have to export articles in the context of a "dummy book", called *articles*:

``` sh
make exports/articles/latest/<target>/<subtarget>/<article name>/<article revision>.<extension>
```
* `<article name>`: Article names can be extracted from the article url: `https://de.wikibooks.org/wiki/Mathe_für_Nicht-Freaks:_Beispielkapitel:_Grundlegende_Formatierungen -> Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen`.
* `<article revision>`: Revision IDs of an article can be found on its history page. (or use *latest*)
* see [Book export](#book-export)

### Example

Thus, to build the example article we have to tell make to `make` the file:
``` sh
make exports/articles/latest/html/all/Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen/latest.html
```
Make will fetch the latest article revisions and media files included in the article and will continue to export it to HTML.

Now we can use `tree exports` to print the directory structure:
```
exports
└── articles
    ├── dummy
    │   └── html
    │       └── all
    │           ├── dummy.book.dep
    │           └── Mathe_für_Nicht-Freaks@COLON@_Beispielkapitel@COLON@_Grundlegende_Formatierungen
    │               ├── 848617.anchors
    │               ├── 848617.html
    │               ├── 848617.markers
    │               ├── 848617.media-dep
    │               ├── 848617.raw_html
    │               ├── 848617.section-dep
    │               └── latest.html -> 848617.html
    └── latest -> dummy
```
