# catch rules for targets with references to latest revision
$(EXPORT_DIR)/$(ARTICLE_BOOK)/%stats.html : $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%book.stats.html $(EXPORT_DIR)/%book.stats.json: $(TARGET_RESOLVED_REVISION) $(HAS_LATEST_GUARD)
	$(LINK_BOOK_LATEST)
	$(LINK_LATEST_TARGET)

$(EXPORT_DIR)/%.lints.json: $(NO_LATEST_GUARD) $(PARSE_PATH_SECONDARY) $$(ARTICLE_DIR)/$$(ARTICLE)/$$(ARTICLE_REVISION).raw.json 
	$(info linting article '$(lastword $(call dirsplit,$(dir $@)))'...)
	@$(MK)/bin/mwlint \
		--texvccheck-path $(MK)/bin/texvccheck \
	< $< > $@ 2>/dev/null

# TODO: stats.html does not contain lint info.
$(EXPORT_DIR)/%.stats.html: $(EXPORT_DIR)/%.stats.json $(NO_LATEST_GUARD)
	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(info rendering article stats for $(UNESCAPED)...)
	@$(MK)/bin/handlebars-cli-rs \
		--base-templates '$(ASSET_DIR)/stats/article.html' '$(ASSET_DIR)/stats/stat_table.hbs' \
		--input $(ASSET_DIR)/stats/base.html \
		article $(UNESCAPED) \
		document $(UNESCAPED) \
		revision $(ARTICLE_REVISION) \
		content 'article.html' \
	< $< > $@

$(EXPORT_DIR)/%.book.stats.json: $(EXPORT_DIR)/%.subtargetmap.json $(PARSE_PATH_SECONDARY) $$(BOOK_DEP_FILE) $$(BOOK_DEP_INTERMEDIATE) $(NO_LATEST_GUARD)
	$(info collecting stats for book '$(BOOK)' from articles...)
	$(eval PREFIX := $(call dirmerge,$(wordlist 1,5,$(call dirsplit,$@))))
	@echo '{"articles": []}' > $@
	@jq 'import "mk/scripts/lib" as lib; .parts[] | .chapters[] | "$(PREFIX)/" + (.path | lib::escape_make) + "/" + .revision + ".stats.json"' $< \
		| xargs -n1 -I {} \
		$(SHELL) -c 'jq "import \"mk/scripts/lib\" as lib; .articles += \$$article | lib::addmerge(\$$article[0])" --slurpfile article {} $@ | sponge $@'

# final book index, depends dependency file which adds its dependencies
# only applies for resolved dependencies
$(EXPORT_DIR)/%.book.stats.html: $(EXPORT_DIR)/%.book.stats.json $(NO_LATEST_GUARD)
	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(BOOK)))
	$(info rendering stats for book $(UNESCAPED)...)
	@$(MK)/bin/handlebars-cli-rs \
		--base-templates '$(ASSET_DIR)/stats/book.html' '$(ASSET_DIR)/stats/stat_table.hbs' \
		--input $(ASSET_DIR)/stats/base.html \
		book $(UNESCAPED) \
		document $(UNESCAPED) \
		book_revision $(BOOK_REVISION) \
		content 'book.html' \
	< $< > $@

# combine lint stats and article stats
$(EXPORT_DIR)/%.stats.json: $(NO_LATEST_GUARD) $(EXPORT_DIR)/%.rawstats.json $(EXPORT_DIR)/%.lints.json
	$(eval $(parse_booktarget))
	$(eval UNESCAPED := $(call unescape,$(ARTICLE)))
	$(info combining stats for $(UNESCAPED)...)
	@jq 'import "mk/scripts/lib" as lib; . + ($$lints[0] | lib::lint_stats) | (.name |= ("$(ARTICLE)" | lib::unescape_make)) | (.revision |= "$(ARTICLE_REVISION)")' \
		--slurpfile lints $(word 2,$^) \
	< $< > $@
