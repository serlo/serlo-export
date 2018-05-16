include $(MK)/utils.mk

$(SUBTARGET).tex:
	touch $(SUBTARGET).tex	

.PHONY: $(SUBTARGET).tex
.DELETE_ON_ERROR:
