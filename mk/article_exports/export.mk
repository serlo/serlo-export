include $(MK)/utils.mk

ALL_ANCHORS = $(ARTICLE)/$(REVISION).anchors
MARKERS = $(MK)/dummy.markers
# no special accumulated dependencies
ALL_ARTICLES = 

include $(MK)/dependencies.mk

# no inclusions / exclusions for article
%.markers:
	cp $(MARKERS) $@

include $(ARTICLE)/$(REVISION).section-dep 
# media-dep cannot be made initially, needs sections
-include $(ARTICLE)/$(REVISION).media-dep

# build rules for the current target
include $(MK)/article_exports/$(TARGET)/article.mk
