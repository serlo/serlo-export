#
# Definitions of non-static variables which are expanded multiple times at
# runtime (mostly in secondary expansion)
#

# compute the article source path from an article export target
ORIGIN_SECONDARY := $(ARTICLE_DIR)/$$(lastword $$(call dirsplit,$$(dir $$@)))/$$(call filebase,$$@).json

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

# This is a intermediate target for which book dependencies are generated.
# This file should never actually exist!
# careful: This depends on the variables beeing defined. So when used in a 
# prerequisite list another prerquisite must have created them through secondary 
# expansion (calling parse_booktarget)
BOOK_DEP_INTERMEDIATE = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dependencies


# expands to the book anchors file for normal books,
# expands to to article's own anchors file for article export (dummy book)
ALL_ANCHORS_SECONDARY := $$(if $$(findstring $(EXPORT_DIR)/$(ARTICLE_BOOK)/$(ARTICLE_BOOK_REVISION),$$@),$\
	$$(dir $$@)$$(call filebase,$$@).anchors,$\
	$(EXPORT_DIR)/$$(BOOK)/$$(BOOK_REVISION)/$$(TARGET)/$$(SUBTARGET)/$$(BOOK_REVISION).book.anchors$\
)

# compute the sitemap path from the target
SITEMAP_SECONDARY := $$(call dirmerge,$$(wordlist 1,3,$$(call dirsplit,$$@)))/$$(word 3,$$(call dirsplit,$$@)).sitemap.json
SITEMAP_PATH = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(BOOK_REVISION).sitemap.json

# expands to IMPOSSIBLE if the book revision or the path suffix contains latest
NO_LATEST_GUARD := $$(filter %.IMPOSSIBLE,$$(subst latest,$$*.IMPOSSIBLE,$$(word 3,$$(call dirsplit,$$@))) $$(subst latest,$$*.IMPOSSIBLE,$$(call filebase,$$@)))
# does the opposite of NO_LATEST_GUARD
HAS_LATEST_GUARD := $$(if $(NO_LATEST_GUARD),, $$*.IMPOSSIBLE)

# splits the current target path and defines the according variables
PARSE_PATH_SECONDARY := $$(eval $$(parse_booktarget))

# splits the current target path as a section path and defines the according variables.
PARSE_SECTION_TARGET := $$(call parse_section_target,$$@)
PARSE_RESOLVED_SECTION_TARGET := $$(call parse_section_target_and_revision,$$@)

# like NO_LATEST_GUARD, but for section paths
SECTION_NO_LATEST_GUARD := $$(filter IMPOSSIBLE,$$(subst latest,IMPOSSIBLE,$$(ARTICLE_REVISION)))
