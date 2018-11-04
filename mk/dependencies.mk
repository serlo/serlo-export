include $(MK)/utils.mk

# this will be expanded to the original article location,
# circumventing make's filename manipulation
ORIGIN_SECONDARY := articles/$$(call dir_head,$$@)/$$*.yml

# generate article dependencies 
.SECONDEXPANSION:
%.section-dep: $(ORIGIN_SECONDARY) %.markers
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(ARTICLE)/$(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--texvccheck-path $(MK)/bin/texvccheck \
		section-deps $(TARGET).$(SUBTARGET) \
		< $(BASE)/$< \
		> $@

.SECONDEXPANSION:
%.media-dep: $(ORIGIN_SECONDARY) %.markers %.sections
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(ARTICLE)/$(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--texvccheck-path $(MK)/bin/texvccheck \
		media-deps $(TARGET).$(SUBTARGET) \
		< $(BASE)/$< \
		> $@

# extracts the reference anchors (link targets) provided by an article.
.SECONDEXPANSION:
%.anchors: $(ORIGIN_SECONDARY) %.markers %.sections
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval UNQUOTED:= $(call unescape,$(ARTICLE)))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title "$(UNQUOTED)" \
		--revision "$(REVISION)" \
		--markers $(ARTICLE)/$(REVISION).markers \
		--texvccheck-path $(MK)/bin/texvccheck \
		anchors $(TARGET).$(SUBTARGET) \
		< $(BASE)/$< \
		> $@
	
# generate files from article tree serialization 
# $(ALL_ANCHORS) must be defined before this file is loaded
# and points to a file containing a list of all available anchors in the export.
.SECONDEXPANSION:
%.stats.yml %.tex %.raw_html: $(ORIGIN_SECONDARY) $(ALL_ANCHORS) $(ALL_ARTICLES) %.media-dep %.section-dep %.markers %.sections %.media
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval UNQUOTED:= $(call unescape,$(ARTICLE)))
	$(eval REVISION := $(call dir_tail,$*))
	$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title "$(UNQUOTED)" \
		--revision $(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--available-anchors $(ALL_ANCHORS) \
		--texvccheck-path $(MK)/bin/texvccheck \
		$(TARGET).$(SUBTARGET) \
		< $(BASE)/$< \
		> $@

articles/%.yml:
	$(MAKE) -C $(BASE) $@

# Build included artifacts 
media/%:
	$(MAKE) -C $(BASE) $@

sections/%:
	$(MAKE) -C $(BASE) $@

.DELETE_ON_ERROR:
.SECONDARY:
