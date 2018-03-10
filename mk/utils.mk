# Utility functions
create_directory = [ -d '$(1)' ] || mkdir '$(1)'
check_dependency = which '$(1)' > /dev/null || \
                       { echo 'Please install $(1)'; exit 1; }

git_clone = [ -d '$(TMP_BIN_DIR)/$1' ] || git clone '$2' '$(TMP_BIN_DIR)/$1'
