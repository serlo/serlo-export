# Utility functions
create_directory = [ -d '$(strip $1)' ] || mkdir '$(strip $1)'

check_dependency = which '$(strip $1)' > /dev/null || \
                     { echo 'Please install $(strip $1)'; exit 1; }

git_clone = [ -d '$(TMP_BIN_DIR)/$1' ] || \
              git clone '$(strip $2)' '$(TMP_BIN_DIR)/$1'

define build_rust_dep
	$(call git_clone,$1,$2)
	(cd $(TMP_BIN_DIR)/$1 && git pull && cargo build --release && \
		cp target/release/$3 $(MK)/bin)
endef

map = $(foreach a,$(2),$(call $(1),$(a)) ;)

dir_head = $(shell echo $1 | sed -e 's,/.*$$,,')
dir_tail = $(shell echo $1 | sed -e 's,^[^/]*/,,')
