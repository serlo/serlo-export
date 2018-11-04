include $(MK)/utils.mk

INKSCAPE = inkscape --without-gui --export-area-page --export-text-to-path \
	--export-ignore-filters --export-pdf=$@ $<
CONVERT_IMG = convert $< $@
DOWNLOAD_PDF = python $(MK)/download_image.py $*.pdf > $@


# create a qr code for media files not supported in some targets
media/%.gif.qr.svg media/%.GIF.qr.svg media/%.webm.qr.svg \
media/%.WEBM.qr.svg media/%.mp4.qr.svg media/%.MP4.qr.svg: | media
	$(eval FILENAME := $(shell echo $@ | sed 's/.qr.*//g'))
	qrencode -o - -t SVG "https://commons.wikimedia.org/wiki/File:$(FILENAME)" > $@

media/%.jpg.pdf: media/%.jpg
	$(CONVERT_IMG)

media/%.JPG.pdf: media/%.JPG
	$(CONVERT_IMG)

media/%.png.pdf: media/%.png
	$(CONVERT_IMG)

media/%.PNG.pdf: media/%.PNG
	$(CONVERT_IMG)

media/%.svg.pdf: media/%.svg
	$(INKSCAPE)

media/%.SVG.pdf: media/%.SVG
	$(INKSCAPE)

media/%.eps.pdf: media/%.eps
	$(INKSCAPE)

media/%.EPS.pdf: media/%.EPS
	$(INKSCAPE)

media/%.qr.pdf: media/%.qr.svg
	$(INKSCAPE)

media/%.plain.pdf: | media
	$(DOWNLOAD_PDF)

media/%.plain.PDF: | media
	$(DOWNLOAD_PDF)

media/%.dummy: | media;

media/%.svg media/%.SVG media/%.png media/%.PNG media/%.jpg media/%.JPG \
media/%.jpeg media/%.JPEG media/%.gif media/%.GIF media/%.webm media/%.WEBM: | media
	$(eval FILENAME := $(call dir_tail,$@))
	python $(MK)/download_image.py "$(FILENAME)" "$(call image_revision,$(FILENAME))" > $@

media/%.meta: | media
	python $(MK)/get_image_license.py "$*" "$(call image_revision,$*)" > $@

# create the media directory
# use with | (order-only prerequisite) to ignore timestamp
media:
	$(call create_directory,media)
