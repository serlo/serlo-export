Tools Overview
==============

The core *Makefile* depends on various standard tools and software not written by us include:

* __Python 3__: Mainly for helper scripts with some kind of network access, mostly MediaWiki API calls.
* __texvccheck__: A helper tool from the MediaWiki math extension for inline LaTeX sanitization, written in OCaml.
* __jq__: Command line processor for json, allows shell scripts (and `make`) to access and manipulate json data.
* __sed, sponge, ...__: Miscellaneous helpers.
* __lualatex__: For PDF target.
* __Inkscape__: Conversion of SVG to PDF, mainly for LaTeX.
* __Image Magick__: Conversion of various image formats, e.g. for LaTeX.
* __qrencode__: Encode links to interactive media for print.
* __make__: Obviously. We rely on some *GNU Make*-specific extensions.

Some of the most important tools are custom made, though. These are mainly concerned with the actual processing and conversion of our articles. The tools below are written in [Rust](https://www.rust-lang.org), but there are no hard restrictions on the choice of language here.

* __Mediawiki Parser (`mwtoast`)__: [Repository](https://github.com/vroland/mediawiki-parser) | A parser for WikiText, generated using a formal grammar. This approach is not optimal for parsing WikiText in general. But since we only want to allow a well-formed subset for our articles, this makes writing such a parser much easier and faster. Outputs an *abstract syntax tree* of the article, which we sometimes call the *intermediate representation*.
* __MFNF Export (`mfnf_ex`)__: [Repository](https://github.com/vroland/mfnf-export) | Serializes the *intermediate representation* to target formats, such as *LaTeX*, *HTML*, etc. \
Additionally, some targets extract information from an article, rather than serializing the whole thing. `section-deps` and `media-deps`, for example, just extract dependency information from the article and output a makefile, which is subsequently used in the build process. \
This is the reason why this tool will be invoked a number of times even if only a single article is exported.
* __MFNF Linter (`mwlint`)__: [Repository](https://github.com/vroland/mwlint) | A linter for MFNF-specific WikiText markup. Helps authors to adhere to the project guidelines by giving a number of hints and checking the [template specification](./template_specification.md). \
The linter can also be compiled to WebAssembly and run in the browser, showing lints immediately when editing an article using the textual editor on [WikiBooks](https://de.wikibooks.org/wiki/Mathe_f%C3%BCr_Nicht-Freaks).
* __MFNF Sitemap Parser (`parse_bookmap` and `sitemap_utils`)__: [Repository](https://github.com/vroland/mfnf-sitemap-parser) `parse_bookmap` creates a sitemap from the intermediate representation of a [sitemap article](./sitemap_structure.md), which is a more strict and machine-readable version of the sitemap. \
`sitemap_utils` can subsequently be used to generate a *dependency file* from the sitemap, which is used by make to determine which articles it needs to build for a book. \
The latter tool has a second subcommand for extracting the *markers* (see [Concepts](./concepts.md) of an article for the use with other tools like `mfnf_ex`, which will read information like *included and excluded headings* from them.
