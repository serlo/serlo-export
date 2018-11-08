#
# Definitions of non-static variables which are expanded multiple times at
# runtime (mostly in secondary expansion)
#

# compute the article source path from an article export target
ORIGIN_SECONDARY := $(ARTICLE_DIR)/$$(lastword $$(subst /,$(space),$$(dir $$@)))/$$(call filebase,$$@).yml

# resolves revision numbers in book / article target paths
TARGET_RESOLVED_REVISION := $$(eval $$(parse_booktarget_and_revision))$\
	$(EXPORT_DIR)/$$(BOOK)/$$(BOOK_REVISION)/$$(TARGET)/$$(SUBTARGET)/$\
		$$(if $$(subst $$(notdir $$@),,$$(ARTICLE)),$\
			$$(ARTICLE)/$$(eval ARTICLE_REVISION=$$(call article_revision,$$(call unescape,$$(ARTICLE))))$\
				$$(subst latest,$$(ARTICLE_REVISION),$$(notdir $$@))$\
			,$\
			$$(subst latest,$$(BOOK_REVISION),$$(notdir $$@))\
		)

# expands to empty string if $(BOOK_REVISION) is the latest revision number
IS_NOT_LATEST_REVISION = $(subst $(BOOK_REVISION),$(call article_revision,$(call unescape,$(ARTICLE))),$(BOOK_REVISION))


# compute the path the book dependency file
BOOK_DEP_FILE = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dep

BOOK_ROOT = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)

# these describe intermediate targets for which dependencies are generated
# These should never actually exist!
# careful: These depend on the variables beeing defined. So when used in a 
# prerequisite list another prerquisite must have created them through secondary 
# expansion (calling parse_booktarget)
BOOK_DEP_INTERMEDIATE = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dependencies
BOOK_ANCHORS_INTERMEDIATE = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.anchors

# compute the sitemap path from the target
SITEMAP_SECONDARY := $$(call dirmerge,$$(wordlist 1,3,$$(call dirsplit,$$@)))/$$(word 3,$$(call dirsplit,$$@)).sitemap.yml
SITEMAP_PATH = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(BOOK_REVISION).sitemap.yml

# expands to IMPOSSIBLE if the book revision variable or the path suffix contains latest
NO_LATEST_GUARD := $$(filter IMPOSSIBLE,$$(subst latest,IMPOSSIBLE,$$(BOOK_REVISION)) $$(subst latest,IMPOSSIBLE,$$(call filebase,$$@)))
