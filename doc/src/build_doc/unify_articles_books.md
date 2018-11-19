Unifying Articles and Books
===========================

In the past, we had separate build systems for exporting articles and books. And indeed, exporting a single article is different from exporting books for the following reasons:

* Post-processing is different: For books, the exported article must work in the context of a collection (e.g. as includes in the `.book.tex` file), while single articles must work on their own (e.g. full LaTeX file with preamble)
* A book can manipulate its articles, e.g. through *markers*.
* In the context of a book, an article depends on every other article through the book-wide anchor list (`.anchors`).

In the current build system, we try to unify these targets to reduce duplication and reduce maintainance work. The issues above are now adressed by:

* Having a dummy book. The file `article_book.mk` overrides some book rules for the special `$(ARTICLE_BOOK)`. \
There are no book dependencies and the book anchor list macro `$(ALL_ANCHORS_SECONDARY)` expands to the article's `.anchors` file instead of the book's `.anchors` file. \
Markers are created from a dummy file, which defindes no inclusions, exclusions or other special markers.
* Having separate rules for articles in the target files.\
Every target makefile (`mk/target/<target>.mk`) must contain rules for building a book as well as standalone articles. Since we know the name of the dummy book (`$(ARTICLE_BOOK)`), we can simply exploit the precedence of rules with shorter stems to separate article and book rules in the makefile.

