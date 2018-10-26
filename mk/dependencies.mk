include $(MK)/utils.mk

# this will be expanded to the original article location,
# circumventing make's filename manipulation
ORIGIN_SECONDARY := $$(BASE)/articles/$$(call dir_head,$$@)/$$*.yml

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
		--base-path $(BASE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		section-deps $(TARGET).$(SUBTARGET) \
		< $< \
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
		--base-path $(BASE) \
		--texvccheck-path $(MK)/bin/texvccheck \
		media-deps $(TARGET).$(SUBTARGET) \
		< $< \
		> $@

# extracts the reference anchors (link targets) provided by an article.
.SECONDEXPANSION:
%.anchors: $(ORIGIN_SECONDARY) %.markers %.sections
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval UNQUOTED:= $(shell python $(MK)/unescape_make.py $(ARTICLE)))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title "$(UNQUOTED)" \
		--revision "$(REVISION)" \
		--markers $(ARTICLE)/$(REVISION).markers \
		--texvccheck-path $(MK)/bin/texvccheck \
		--base-path $(BASE) \
		anchors $(TARGET).$(SUBTARGET) \
		< $< \
		> $@
	
# generate files from article tree serialization 
# $(ALL_ANCHORS) must be defined before this file is loaded
# and points to a file containing a list of all available anchors in the export.
.SECONDEXPANSION:
%.stats.yml %.tex %.raw_html: $(ORIGIN_SECONDARY) $(ALL_ANCHORS) $(ALL_ARTICLES) %.media-dep %.section-dep %.markers %.sections %.media
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval UNQUOTED:= $(shell python $(MK)/unescape_make.py $(ARTICLE)))
	$(eval REVISION := $(call dir_tail,$*))
	$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title "$(UNQUOTED)" \
		--revision $(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--base-path $(BASE) \
		--available-anchors $(ALL_ANCHORS) \
		--texvccheck-path $(MK)/bin/texvccheck \
		$(TARGET).$(SUBTARGET) \
		< $< \
		> $@

$(BASE)/articles/%.yml:
	$(MAKE) -C $(BASE) articles/$*.yml

# Build included artifacts 
$(BASE)/media/%:
	$(MAKE) -C $(BASE) media/$*

$(BASE)/sections/%:
	$(eval SECS := $(dir $*))
	$(eval REVID := $(basename $(notdir $*)))
	$(MAKE) -C $(BASE) sections/$(dir $(SECS:%/=%))$(REVID)

.DELETE_ON_ERROR:
.SECONDARY:
