%.svg:
	python $(MK)/download_image.py $@ > $@

%.pdf: %.svg
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

%.pdf: %.jpg
	convert $< $@

%.pdf: %.png
	convert $< $@

.DELETE_ON_ERROR:

.SECONDARY:
