include $(MK)/utils.mk

SITEMAP = $(BASE)/book_exports/$(BOOK)/$(BOOK_REVISION)/$(BOOK_REVISION).yml
ALL_ANCHORS = $(BOOK_REVISION).anchors

include $(MK)/dependencies.mk

# extract article markers from sitemap 
%.markers: $(SITEMAP)
	$(eval ARTICLE:= $(call dir_head,$@))
	$(eval UNQUOTED:= $(shell python $(MK)/unescape_make.py $(ARTICLE)))
	$(call create_directory,$(ARTICLE))
	$(MK)/bin/sitemap_utils --input $(SITEMAP) \
		markers "$(UNQUOTED)" $(TARGET) > $@

# concatenates individual anchors file to a whole
$(BOOK_REVISION).anchors: articles.dep
	# extract anchor files from dependencies and concatenate
	$(shell cat $(filter %.anchors,$^) > $@)

# Generate / include article dependencies                           
#                                                                   
# (which include article deps)                                      
# make will check and maybe rebuild articles.dep before including, 
# producing a target named like $(MAKECMDGOALS)                     
articles.dep: $(SITEMAP)
	$(MK)/bin/sitemap_utils --input $(SITEMAP) \
		deps $(TARGET) $(SUBTARGET) > articles.dep

include articles.dep

# build rules for the current target
include $(MK)/book_exports/$(TARGET)/book.mk
