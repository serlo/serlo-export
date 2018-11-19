User Guide
==========

This document tries to present the basic usage of this tool. Do not expect a detailed guide of every feature and intricacy. I assume some some technical knowledge and the familiarity with the purpose of this software.

Installation
------------

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
If you want to build the documentation for yourself, install `mdbook` as well:
```sh
cargo install mdbook
make doc
```
Done!

Basic Usage
-----------

Note that whenever an article name or path is passed to `make`, it must be escaped:
 
| original | escaped   |
|-----|-----------|
| (space) |  `_` |
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

To build the example article we have to tell `make` to build the file:
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
