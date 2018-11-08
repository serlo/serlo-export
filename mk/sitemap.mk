
%.sitemap.md:
	$(eval $(parse_booktarget))
	$(call create_directory,$(dir $@))
	python $(MK)/scripts/download_article.py $(BOOK) $(BOOK_REVISION) > $@
	
%.sitemap.yml: %.sitemap.parsed.yml
	python $(MK)/scripts/fill_sitemap_revisions.py \
		$< $(REVISION_LOCK_FILE) \
	> $@

%.sitemap.parsed.yml: %.sitemap.raw.yml
	$(MK)/bin/parse_bookmap \
		--input $< \
		--texvccheck-path $(MK)/bin/texvccheck \
	> $@

%.sitemap.raw.yml: %.sitemap.md
	$(MK)/bin/mwtoast -i $< > $@
