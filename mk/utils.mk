# Utility functions
space :=
space +=

create_directory = mkdir -p '$(strip $1)'

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

article_revision = $(shell $(MK)/get_revision.sh $(REVISION_LOCK_FILE) "articles" '$1')
image_revision = $(shell $(MK)/get_revision.sh $(REVISION_LOCK_FILE) "media" '$1')

unescape = $(shell python3 $(MK)/unescape_make.py $1)
resolve_revision = $(subst latest,$(call article_revision,$2),$1)

parse_booktarget_and_revision = $(eval P:=$@)$(eval $(parse_bookpath_and_revision))
parse_booktarget = $(eval P:=$@)$(eval $(parse_bookpath))
book_path = $(call dirmerge,$(wordlist 1,5,$(call dirsplit,$1)))

parse_bookpath_and_revision := \
	$$(info PATH: $$P)\
	$$(eval S := $$(call dirsplit,$$P))\
	$$(eval BOOK := $$(word 2,$$S))\
	$$(eval BOOK_UNESCAPED := $$(call unescape,$$(BOOK)))\
	$$(eval BOOK_REVISION := $$(firstword $$(subst .,$$(space),$$(notdir $$(word 3,$$S)))))\
	$$(eval BOOK_REVISION := $$(call resolve_revision,$$(BOOK_REVISION),$$(BOOK_UNESCAPED)))\
	$$(eval TARGET := $$(word 4,$$S))\
	$$(eval SUBTARGET := $$(word 5,$$S))\
	$$(eval ARTICLE := $$(word 6,$$S))\
	$$(eval ARTICLE_REVISION := $$(call filebase,$$(word 7,$$S)))\
	$$(info ARTICLE: $$(ARTICLE))\
	$$(info ARTICLE_REVISION: $$(ARTICLE_REVISION))\
	$$(info BOOK: $$(BOOK))\
	$$(info BOOK_REVISION: $$(BOOK_REVISION))\
	$$(info CURRENT_TARGET: $$@)\

parse_bookpath := \
	$$(info PATH: $$P)\
	$$(eval S := $$(call dirsplit,$$P))\
	$$(eval BOOK := $$(word 2,$$S))\
	$$(eval BOOK_REVISION := $$(firstword $$(subst .,$$(space),$$(notdir $$(word 3,$$S)))))\
	$$(eval TARGET := $$(word 4,$$(S)))\
	$$(eval SUBTARGET := $$(word 5,$$(S)))\
	$$(eval ARTICLE := $$(word 6,$$S))\
	$$(eval ARTICLE_REVISION := $$(call filebase,$$(word 7,$$S)))\
	$$(info ARTICLE: $$(ARTICLE))\
	$$(info ARTICLE_REVISION: $$(ARTICLE_REVISION))\
	$$(info BOOK: $$(BOOK))\
	$$(info BOOK_REVISION: $$(BOOK_REVISION))\
	$$(info CURRENT_TARGET: $$@)\
