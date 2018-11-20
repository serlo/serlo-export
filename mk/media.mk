include $(MK)/utils.mk

INKSCAPE = \
	$(info converting $(notdir $<) to $(suffix $@)...) \
	@inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<
CONVERT_IMG = \
	$(info converting $(notdir $<) to $(suffix $@)...) \
	@convert $< $@

# create a qr code for media files not supported in some targets
$(MEDIA_DIR)/%.gif.qr.svg $(MEDIA_DIR)/%.GIF.qr.svg $(MEDIA_DIR)/%.webm.qr.svg \
$(MEDIA_DIR)/%.WEBM.qr.svg $(MEDIA_DIR)/%.mp4.qr.svg $(MEDIA_DIR)/%.MP4.qr.svg: | $(MEDIA_DIR)
	$(eval FILENAME := $(shell echo $@ | sed 's/.qr.*//g'))
	$(info generating qr code for '$(FILENAME)'...)
	@qrencode -o - -t SVG "https://commons.wikimedia.org/wiki/File:$(FILENAME)" > $@

$(MEDIA_DIR)/%.jpg.pdf: $(MEDIA_DIR)/%.jpg
	$(CONVERT_IMG)

$(MEDIA_DIR)/%.JPG.pdf: $(MEDIA_DIR)/%.JPG
	$(CONVERT_IMG)

$(MEDIA_DIR)/%.png.pdf: $(MEDIA_DIR)/%.png
	$(CONVERT_IMG)

$(MEDIA_DIR)/%.PNG.pdf: $(MEDIA_DIR)/%.PNG
	$(CONVERT_IMG)

$(MEDIA_DIR)/%.svg.pdf: $(MEDIA_DIR)/%.svg
	$(INKSCAPE)

$(MEDIA_DIR)/%.SVG.pdf: $(MEDIA_DIR)/%.SVG
	$(INKSCAPE)

$(MEDIA_DIR)/%.eps.pdf: $(MEDIA_DIR)/%.eps
	$(INKSCAPE)

$(MEDIA_DIR)/%.EPS.pdf: $(MEDIA_DIR)/%.EPS
	$(INKSCAPE)

$(MEDIA_DIR)/%.qr.pdf: $(MEDIA_DIR)/%.qr.svg
	$(INKSCAPE)

$(MEDIA_DIR)/%.plain.pdf $(MEDIA_DIR)/%.plain.PDF: | $(MEDIA_DIR)
	$(eval IMAGE_REVISION := $(call image_revision,$*))
	$(info fetching image '$*' ($(IMAGE_REVISION))...)
	@python $(MK)/scripts/download_image.py '$*.pdf' '$(IMAGE_REVISION)' > $@

$(MEDIA_DIR)/%.dummy: | $(MEDIA_DIR);

$(MEDIA_DIR)/%.svg $(MEDIA_DIR)/%.SVG $(MEDIA_DIR)/%.png \
	$(MEDIA_DIR)/%.PNG $(MEDIA_DIR)/%.jpg $(MEDIA_DIR)/%.JPG \
	$(MEDIA_DIR)/%.jpeg $(MEDIA_DIR)/%.JPEG $(MEDIA_DIR)/%.gif \
	$(MEDIA_DIR)/%.GIF $(MEDIA_DIR)/%.webm $(MEDIA_DIR)/%.WEBM: | $(MEDIA_DIR)

	$(eval FILENAME := $(notdir $@))
	$(eval IMAGE_REVISION := $(call image_revision,$(FILENAME)))
	$(info fetching image '$(FILENAME)' ($(IMAGE_REVISION))...)
	@python $(MK)/scripts/download_image.py '$(FILENAME)' '$(IMAGE_REVISION)' > $@

$(MEDIA_DIR)/%.meta: | $(MEDIA_DIR)
	$(eval IMAGE_REVISION := $(call image_revision,$*))
	$(info fetching metadata of '$*' ($(IMAGE_REVISION))...)
	@python $(MK)/scripts/get_image_license.py '$*' '$(IMAGE_REVISION)' > $@

# create the media directory
# use with | (order-only prerequisite) to ignore timestamp
$(MEDIA_DIR):
	@$(call create_directory,$(MEDIA_DIR))
