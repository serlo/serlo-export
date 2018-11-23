Sitemap Structure
=================

As explained in [Concepts](./concepts.md), the structure of a book is described in a special article, called the *sitemap*. A book is structured in *parts*, which each contain a list of articles, called *chapters* in this context.

A sitemap article always starts with a *first-level heading*:
```markdown
= Book Title =
```
Followed by multiple *second-level headings*, which marke books *parts*:
```markdown
= Book Title =

== Part 1 ==

== Part 2 ==
```
Finally, every part contains a list of internal references to articles, which will appear as *chapters* in the book:
```markdown
= My little Book =
== Introduction ==

* [[Article 1|The first Chapter]]
* [[Article 2|Chapter Two]]
```
The resulting book will be called `My little Book`, have one part called `Introduction`, which has two chapters called `The first Chapter` and `Chapter Two`. Keep in mind that the chapter list must be **one coherent list**! If you break it into multiple lists, only the first one will be considered when looking for chapters.

**Mind the Gap** between the article list and the part heading. The gap is a visual hint to separate *part markers* from the article list!

*Hint:* Any text after the internal references is currently ignored, but it might become relevant in the future.

Sitemap Markers
---------------

The structure described above is nice and simple, but it can't express any additional information about the parts and articles. We might want to include or exclude parts of the article depending on the *target configuration* (or *subtarget*), add some files which are not articles and so on. This is where *markers* come in! These are the currently allowed markers:

* __todo__: Add a todo message to a book, a part or a chapter. It will not be exported.
* __after__: When available for the export target, include a file after this chapter. This marker is currently ignored on the book root and parts.
* __include__: Include some parts of an article exclusively. For more details, see [include and exclude](#include-and-exclude).
* __exclude__: Exclude some parts of an article and include everything else. For more details, see [include and exclude](#include-and-exclude).
* __alias__: Define an alias for a subtarget for this book, part or chapter. You can use this to avoid duplication for very similar subtargets, e.g. when the subtarget only changes paper size, but should have the same content.

In the sitemap article, markers are added as a *list immediately after* the book title or part heading, or as a *sublist* of a chapter:
```markdown
= My little Book =
* todo: write more content

== Introduction ==
* todo: say hello! 

* [[Article 1|The first Chapter]]
* [[Article 2|Chapter Two]]
** todo: add an image
** after: part_footer
```
The example above adds todo notes to the whole book and the introduction chapter. It also adds a todo note to *Chapter Two* and includes the file `part_footer` after *Chapter Two*.
These simple markers only influence the specific thing they're marking. They are always written like `<todo|after|...>: Some freeform text on one line`.\
`include`, `exclude` and `alias` have a more complex behaviour though.

Include and Exclude
-------------------

The `include` and `exclude` markers are arguably the most important ones. They allow omitting or including parts of a chapter (article) on a per-heading basis. But first, let's see how we can include or exclude whole articles:
```markdown
* [[Article|Chapter Name]]
** exclude:
*** minimal
** include:
*** all
*** print
```
This article is *excluded* for the `minimal` subtarget, but included for `all` and `print`. 

By default, every article (chapter) is wholly included in the export for every subtarget. This is equivalent to adding every subtarget to an `include` marker (without supplied headings).

Keep in mind that a subtarget can never be included and excluded at the same time!

### Include / Exclude Inheritance

Nice, we now can include or exclude articles depending on the subtarget. But excluding nearly every article manually for a target like `minimal` seems very tideous. Instead, we can use the fact that includes and excludes are *inherited* from parts and the book root:
```markdown
= My little Book =
* exclude:
** minimal

== Introduction ==

* [[Article 1|The first Chapter]]
* [[Article 2|Chapter Two]]
* [[Article 3|Something Important]]
** include:
*** minimal
```
Adding `minimal` to the exclude marker of the whole book makes excluding `minimal` the *default*. Articles will always be excluded in `minimal`, except they are explicitly `included` at a lower level.

You can think of this inheritance as setting the default for a subtarget, where more specific markers override more general ones: chapter overrides part, which overrides book root. Another example:
```markdown
= My little Book =
* exclude:
** minimal

== Introduction ==
* include:
** minimal

* [[Article 1|The first Chapter]]
* [[Article 2|Chapter Two]]
** exclude:
*** minimal
* [[Article 3|Something Important]]
== Main ==

* [[Article 4|Some Content]]
```
For this sitemap, the `minimal` subtarget will only export `Article 1` and `Article 3`: At the book level, exclude is set as the default for `minimal`. This is why everything in `Main` is excluded. `Introduction` on the other hand overrides this setting and makes `minimal` included by default. Only `Article 2` is left out, because it is excluded by its chapter marker.

### Including / Excluding Headings

In addition to excluding or including whole articles, it is also possible to specifiy that only certain parts should be included or left out. This is done by supplying the include or exclude marker *of a chapter* an additional list of arguments for the subtarget:
```markdown
* [[Article Name|Article Caption]]
** exclude:
*** print:
**** Alternative Proof
**** Exercises
*** minimal
```
This means: In `print`, we __include everything but__ the headings `Alternative Proof` and `Exercises`. Note that although the subtarget is listed under exclude, we still include most of the article! In this case, the exclude only applies to the list of headings written as a sublist of `print`.

`minimal`, on the other hand, has no special parameters. This means the whole chapter `Article Name` is excluded.

The same applies to the include marker: given an additional list of headings, it will __exclude everything but__ the headings listed!

| marker | arguments | semantics |
|--------|-----------|-----------|
| `include` | `subtarget` | include whole article |
| `include` | `subtarget` + headings | exclude everything but the headings |
| `exclude` | `subtarget` | exclude whole article |
| `exclude` | `subtarget` + headings | include everything but the headings |

Subtarget Aliases
-----------------

Sometimes, subtargets are very similar in their semantics and use the same or nearly the same sitemap markers (mainly includes / excludes). To avoid copying these, you can use the *alias marker* to specify that `alias` should behave the same as `subtarget` for this part of the document:
```markdown
= Book =
* include:
** print
* alias:
** letterpaper_print: print

== Introduction ==
...
```
`letterpaper_print` will now behave exactly the same as `print` for the purposes of the sitemap! 

Note that you can add an alias on parts or chapters as well, meaning that the alias should only be valid for this part or chapter. You could, for example, just declare an alias on a chapter instead of typing out a long list of excluded headings twice. 

Unlike include and exclude markers though, *alias markers cannot be overridden!*. This means: if you add an alias marker at a part, you cannot define specific includes or excludes for that alias on its chapters. Making aliases not overridable makes it easier to reason about them, since once you declare an alias you can be sure there are to exceptions to these subtargets beeing equal (in the scope of the alias, of course).
