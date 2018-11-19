Adding a new Target
===================

A checklist of things to do when adding a new target format:

* Add a new `mk/targets/<target>.mk` makefile. This file should be the entry point when for building books and articles in the new format. Make sure to have a rule for
    1. building a concrete book revision (`$(NO_LATEST_GUARD)`). The resulting file of a book export is named `<revision>.book.<extension>`.
    2. building a book where some revision is `latest` (`$(HAS_LATEST_GUARD)`), you can use `$(TARGET_RESOLVED_REVISION)` to add the concrete latest revision as prerequisite.
    3. building a concrete an article revision (`$(NO_LATEST_GUARD)`). Exported standalone article files are named `<revision>.<extension>`. You can make this rule take precedence over the book rule by making the pattern stem `%` shorter (`$(EXPORT_DIR)/$(ARTICLE_BOOK)/%...` instead of `$(EXPORT_DIR)/%...`)
    4. building an article with either article or book revision beeing `latest`. See 2.
* Include this makefile in `Makefile`.
* Add a pattern for your new format (`%.<extension>`) to the appropriate rule in `mk/dependencies.mk`.
* Add the target to `mfnf_ex` (the mfnf-export tool).
* Instantiate your target for every subtarget in `config/mfnf.yml`.
* Add your target to `sitemap_utils` (the mfnf-sitemap-utils tool) for book dependency generation (this may change).
