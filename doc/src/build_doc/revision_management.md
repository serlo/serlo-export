Revision Management
===================

Since most input data we use currently comes in the form of WikiBooks articles, we need a way to keep track which version of the article we are using. MediaWiki uses numeric revision IDs vor this.

But most references to articles, like internal links or even sitemaps do not specify a specific article revision. Instead, they implicitly point to the `latest` revision of an article. 

If we would just use the currently latest revision available on the server, we risk introducing inconsistencies: If we export the same book to different output formats, an article might change in the middle of the process and we end up with the content beeing different in HTML and PDF. Or even worse, a definition included from another article differs from the actual article, because it changed after section extraction. Yes, these cases are rare, but there is another important reason:

*Reproducible builds*. We want to be able to build a book exactly as it was three weeks ago, even if the articles and included media files have been changed since then. This is primarily useful to be able to fall back on a known good state if some change in an article breaks the build. But it also helps with tracking down errors or tracking the evolution of the book content.

Implementation
--------------

The revision of an article or media file which is currently considered `latest` is stored in a *revision lock file* (`$(REVISION_LOCK_FILE)`), when it is first queried. By default, this file is called `revisions.json`.

Every subseqent reference to `latest` for an article or media file is then resolved through this file, which effectively locks the article to this revision for every subsequent export, until `revisions.json` is updated or deleted.

This functionality is implemented in `mk/scripts/get_revisions.sh`. However, when a revision needs to be resolved in the build process, you should use the `article_revision` or `media_revision` functions defined in `utils.mk`, since they make sure to use the revision lock file properly.

Article revisions are a string of numbers (`812312`), while media revisions are timestamps (`2017-04-02T09:54:57Z`).

Handling Build Targets with `latest`
------------------------------------

For most targets, the build system allows to specify `latest` instead of a static article or book revision (like `812312`). These are resolved as early as possible in both phases described above:
* During dependency generation phase, revision resolving happens during the parsing of `$(MAKECMDGOALS)` in `book.mk` or `article_book.mk`. 
* When a target is to be built, we need to make sure `make` cannot just assume `latest` as the correct revision. This is why every target makefile (`mk/targets/<target>.mk`) has a rule to catch these and has the same target with the actual revision ID as prerequisite.

The first phase is (straight forward) functional make programming. The second measure is a bit more tricky to achieve:

```makefile
$(EXPORT_DIR)/%book.tex: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%.book.tex: $(PARSE_PATH_SECONDARY) $(NO_LATEST_GUARD) $$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) 
    ...
```
Through this pattern, we force `make` to use the first rule if the book revision (or article revision for article exports) is `latest`. Only if no revision in the target path is `latest`, the latter rule may be used.

The most important macros here are:
* `$(NO_LATEST_GUARD)`: Expands to an impossible prerequisite if there is any revision in the target path is `latest`, otherwise expands to nothing.
* `$(HAS_LATEST_GUARD)`: The logical opposite (there needs to be at least one `latest` revision).
* `$(TARGET_RESOLVED_REVISION)`: Expands to the the target path, but with every reference to `latest` revision resolved.
