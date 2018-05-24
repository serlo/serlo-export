# Utility functions
create_directory = mkdir -p '$(strip $1)'

remove_file = rm -rf '$(strip $1)'

check_dependency = which '$(strip $1)' > /dev/null || \
                     { echo 'Please install $(strip $1)'; exit 1; }

git_clone = [ -d '$(TMP_BIN_DIR)/$1' ] || \
              git clone '$(strip $2)' '$(TMP_BIN_DIR)/$1'

define build_rust_dep
	$(call git_clone,$1,$2)
	(cd $(TMP_BIN_DIR)/$1 && git pull && cargo build --release --all-features && \
		cp target/release/$3 $(MK)/bin)
endef

map = $(foreach a,$(2),$(call $(1),$(a)) ;)

dir_head = $(shell echo $1 | sed -e 's,/.*$$,,')
dir_tail = $(shell echo $1 | sed -e 's,^[^/]*/,,')
