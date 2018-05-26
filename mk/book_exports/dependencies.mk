include $(MK)/utils.mk

RECURSE_TO_LATEX := recurse_to_latex
SITEMAP := $(BASE)/book_exports/$(BOOK)/bookmap.yml

# this will be expanded to the original article location,
# circumventing make's filename manipulation
ORIGIN_SECONDARY := $$(BASE)/articles/$$(call dir_head,$$@)/$$*.yml


# build the actual target file 
$(MAKECMDGOALS): articles.dep
	$(export $(SITEMAP))
	$(MAKE) -f $(MK)/book_exports/$(TARGET)/book.mk $(MAKECMDGOALS)

# generate article dependencies 
.SECONDEXPANSION:
%.section-dep: $(ORIGIN_SECONDARY) articles.dep %.markers
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(ARTICLE)/$(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--section-path $(BASE)/sections \
		--externals-path $(BASE)/media \
		--texvccheck-path $(MK)/bin/texvccheck \
		section-deps $(TARGET).$(SUBTARGET) \
		< $< > $@

.SECONDEXPANSION:
%.media-dep: $(ORIGIN_SECONDARY) articles.dep %.markers %.sections
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/mfnf_ex -c $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(ARTICLE)/$(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--section-path $(BASE)/sections \
		--externals-path $(BASE)/media \
		--texvccheck-path $(MK)/bin/texvccheck \
		media-deps $(TARGET).$(SUBTARGET) \
		< $< > $@

# extract article markers from sitemap 
%.markers: $(SITEMAP)
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval UNQUOTED:= $(shell python $(MK)/unescape_make.py $(ARTICLE)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/sitemap_utils --input $(SITEMAP) \
		markers "$(UNQUOTED)" $(TARGET) > $@

# generate files from article tree serialization 
.SECONDEXPANSION:
%.tex %.html: $(ORIGIN_SECONDARY) articles.dep %.media-dep %.section-dep %.markers
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval REVISION := $(basename $(call dir_tail,$@)))
	$(MK)/bin/mfnf_ex --config $(BASE)/config/mfnf.yml \
		--title $(ARTICLE) \
		--revision $(REVISION) \
		--markers $(ARTICLE)/$(REVISION).markers \
		--section-path $(BASE)/sections \
		--externals-path $(BASE)/media \
		--texvccheck-path $(MK)/bin/texvccheck \
		$(TARGET).$(SUBTARGET) < $< > $@

$(BASE)/articles/%.yml:
	$(MAKE) -C $(BASE) articles/$*.yml


# Generate / include article dependencies                           
#                                                                   
# (which include article deps)                                      
# make will check and maybe rebuild articles.dep before including, 
# producing a target named like $(MAKECMDGOALS)                     
articles.dep: $(SITEMAP)
	$(MK)/bin/sitemap_utils --input $(SITEMAP) \
		deps $(TARGET) $(SUBTARGET) > articles.dep

include articles.dep

# Build included artifacts 
$(BASE)/media/%:
	$(MAKE) -C $(BASE) media/$*

$(BASE)/sections/%:
	$(eval SECS := $(dir $*))
	$(eval REVID := $(basename $(notdir $*)))
	$(MAKE) -C $(BASE) sections/$(dir $(SECS:%/=%))$(REVID)

# recurse back for targets depending on other targets.
$(BASE)/book_exports/$(BOOK)/latex/$(SUBTARGET)/$(SUBTARGET).tex :: $(RECURSE_TO_LATEX) ;

$(RECURSE_TO_LATEX):
	$(MAKE) -C $(BASE) book_exports/$(BOOK)/latex/$(SUBTARGET)/$(SUBTARGET).tex

.PHONY: $(RECURSE_TO_LATEX)
.DELETE_ON_ERROR:
.SECONDARY:
