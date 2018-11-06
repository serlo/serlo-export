#
# Definitions of non-static variables which are expanded multiple times at
# runtime (mostly in secondary expansion)
#

# this will be expanded to the original article location,
# circumventing make's filename manipulation
ORIGIN_SECONDARY := $(ARTICLE_DIR)/$$(lastword $$(subst /,$(space),$$(dir $$@)))/$$(call filebase,$$@).yml

# parses the target path and constructs
BOOK_RESOLVED_REVISION_SECONDARY := $$(eval $$(parse_booktarget_and_revision))$(EXPORT_DIR)/$$(BOOK)/$$(BOOK_REVISION)/$$(TARGET)/$$(SUBTARGET)/$$(subst latest,$$(BOOK_REVISION),$$(notdir $$@))

# compute the path to books dependency file with resolved revisions
BOOK_DEP_SECONDARY := $$(eval $$(parse_booktarget))$(EXPORT_DIR)/$$(BOOK)/$$(BOOK_REVISION)/$$(TARGET)/$$(SUBTARGET)/$$(BOOK_REVISION).book.dep

# phony book dependency targets which as articles as dependencies (generated)
BOOK_DEP_PHONY_SECONDARY := $$(eval $$(parse_booktarget_and_revision))$(EXPORT_DIR)/$$(BOOK)/$$(BOOK_REVISION)/$$(TARGET)/$$(SUBTARGET)/$$(BOOK_REVISION).book.dependencies
BOOK_DEP_PHONY = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.dependencies
BOOK_ANCHORS_PHONY_SECONDARY := $$(eval $$(parse_booktarget_and_revision))$(EXPORT_DIR)/$$(BOOK)/$$(BOOK_REVISION)/$$(TARGET)/$$(SUBTARGET)/$$(BOOK_REVISION).book.anchors
BOOK_ANCHORS_PHONY = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(TARGET)/$(SUBTARGET)/$(BOOK_REVISION).book.anchors

# compute the sitemap name from the book dependency file as target
SITEMAP_SECONDARY := $$(call dirmerge,$$(wordlist 1,3,$$(call dirsplit,$$@)))/$$(word 3,$$(call dirsplit,$$@)).sitemap.yml
SITEMAP_PATH = $(EXPORT_DIR)/$(BOOK)/$(BOOK_REVISION)/$(BOOK_REVISION).sitemap.yml
