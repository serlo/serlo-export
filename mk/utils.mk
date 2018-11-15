# Utility functions
space :=
space +=

create_directory = @mkdir -p '$(strip $1)'

remove_file = rm -rf '$(strip $1)'

check_dependency = which '$(strip $1)' > /dev/null || \
                     { echo 'Please install $(strip $1)'; exit 1; }

git_clone = [ -d '$(TMP_BIN_DIR)/$1' ] || \
              git clone '$(strip $2)' '$(TMP_BIN_DIR)/$1'

define build_rust_dep
	$(call git_clone,$1,$2)
	(cd $(TMP_BIN_DIR)/$1 && git pull && cargo build --release --features=$4,$5,$6,$7 && \
		cp target/release/$3 $(MK)/bin)
endef

map = $(foreach a,$(2),$(call $(1),$(a)) ;)

dirbase = $(dir $1)$(firstword $(subst .,$(space),$(notdir $1)))
filebase = $(firstword $(subst .,$(space),$(notdir $1)))
dirsplit = $(subst /,$(space),$1)
dirmerge = $(subst $(space),/,$1)

fetch_revision = $(eval FETCH_RESULT := $(shell $(MK)/scripts/get_revision.sh $(REVISION_LOCK_FILE) '$2' '$1'))$(if $(FETCH_RESULT),$(FETCH_RESULT),$(error revision fetching failed for "$1"!))

article_revision = $(call fetch_revision,$1,articles)
image_revision = $(call fetch_revision,$1,media)

unescape = $(subst ','\'',$(shell python3 $(MK)/scripts/unescape_make.py $1))
resolve_revision = $(subst latest,$(call article_revision,$2),$1)

parse_booktarget_and_revision = $(eval P:=$@)$(parse_bookpath_and_revision)
parse_booktarget = $(eval P:=$@)$(parse_bookpath)

# parse the variable P and split the path into its semantic elements.
# This will allways create the variable "ARTICLE", although it might be
# empty or wrong for non-article paths.
parse_bookpath = \
	$(eval S := $(call dirsplit,$P))\
	$(eval BOOK := $(word 2,$S))\
	$(eval BOOK_REVISION := $(firstword $(subst .,$(space),$(notdir $(word 3,$S)))))\
	$(eval TARGET := $(word 4,$S))\
	$(eval SUBTARGET := $(word 5,$S))\
	$(eval ARTICLE := $(word 6,$S))\
	$(eval ARTICLE_REVISION := $(call filebase,$(word 7,$S)))\

parse_bookpath_and_revision = \
	$(parse_bookpath)\
	$(eval BOOK_UNESCAPED := $(call unescape,$(BOOK)))\
	$(eval BOOK_REVISION := $(call resolve_revision,$(BOOK_REVISION),$(BOOK_UNESCAPED)))\

# splits the current target path as a section path and defines the according variables.
parse_section_target = $(eval S := $(call dirsplit,$1)) \
	$(eval ARTICLE := $(word 2,$S)) \
	$(eval SECTION := $(word 3,$S)) \
	$(eval ARTICLE_REVISION := $(call filebase,$(word 4,$S)))\

parse_section_target_and_revision = $(parse_section_target) \
	$(eval ARTICLE_REVISION := $(call article_revision,$(call unescape,$(ARTICLE))))

# Recipe lines for linking "latest" to the revision-resolved file (first prerquisite)
LINK_BOOK_LATEST = \
	$(info linking latest version of '$(BOOK)'...) \
	@ln -s -f -n $(BOOK_REVISION) $(EXPORT_DIR)/$(BOOK)/latest
LINK_LATEST_TARGET = \
	$(info linking latest revision of '$(notdir $<)'...) \
	@ln -s -f -n $(notdir $<) $(dir $<)latest.$(subst $(space),.,$(wordlist 2,1000,$(subst ., ,$(@))))
