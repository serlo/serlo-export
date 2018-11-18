Concepts
========

The export software operates on books and articles created for *Serlo Hochschulmathematik (Mathe für Nicht-Freaks)* and transforms them into various output formats.

This page explains some terms and concepts we refer to in the [user guide](./guide.md) , the source code or [other documentation](./make.md).

The first set of terms are general concepts not specific to the export toolchain:

* __Article__: Currently, an article is a *monothematic text document*, enriched with semantic information, regardless of the format. Usually, the article exists as [WikiText](https://de.wikibooks.org/w/index.php?title=Mathe_f%C3%BCr_Nicht-Freaks:_Folgerungen_der_Anordnungsaxiome&action=edit) first. Even after beeing exported to a different format we still refer to it as *this article*.
* __Book__: A *collection of articles* covering a a more general topic. E.g. [Analysis 1](https://de.wikibooks.org/wiki/Mathe_f%C3%BCr_Nicht-Freaks:_Analysis_1) is made up of the articles [Was ist Analysis](https://de.wikibooks.org/wiki/Mathe_f%C3%BCr_Nicht-Freaks:_Was_ist_Analysis%3F), [Körperaxiome](https://de.wikibooks.org/wiki/Mathe_f%C3%BCr_Nicht-Freaks:_K%C3%B6rperaxiome), [Definition Grenzwert](https://de.wikibooks.org/wiki/Mathe_f%C3%BCr_Nicht-Freaks:_Grenzwert:_Konvergenz_und_Divergenz) and many more. Note that one article may appear in many *books*. Which articles make up a book and how is specified in a *sitemap article*.
* __Section__: Sections are text snippets extracted from an article. They do *not* have to correspond to headings or semantic elements! This means of reusing article content is not based on semantics and we discurage its use, but for the forseeable future we need compatibility with the [Labeled Section Transclusion MediaWiki plugin](https://www.mediawiki.org/wiki/Extension:Labeled_Section_Transclusion).

Now to some export-related concepts:

* __Sitemap__: (or __Bookmap__) A *special article* specifying which articles belong to a *book*. Additionally, it defines the *structure of the book*, dividing articles into *parts* and annotating them with *markers*.
* __Target__: (or __Target Format__) Refers to an output format like *LaTeX*, *PDF* or *HTML*. Note that the target is *othorgonal to the subtarget*! 
* __Subtarget__: (or __Target Configuration__) Although "target configuration" is probably a lot more descriptive, "subtarget" is widely used throughout the code base. \
Usually, a subtarget is treated like a *class of export configurations*, like *minimal*, *print* or *verbose*. This is because every *subtarget class* should be defined *for every target*, though this is not enforced.\
As a convention, we refer to a concrete target configuration as `<target>.<subtarget>` (e.g. `latex.print, html.print`), while the semantic class of similar configurations is just called `<subtarget>` (`print`).\
For example: `latex.print` is a *configuration of the latex target*, and `html.print` is a *configuration of the html target*. Programmatically, have nothing todo with each other, since they configure different targets. But they are *semantically similar*, since they both generate an output that is less verbose and suitable for printing. This is why they are often collectively referred to as the `print`-subtarget.
* __Marker__: An annotation in the sitemap of a book, which allows to include or exclude parts of an article, add metadata or include additional files. See [Sitemap Structure](./sitemap_structure.md) for details.
