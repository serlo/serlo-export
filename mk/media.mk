%.svg %.png %.jpg %.gif:
	python $(MK)/download_image.py $@ > $@

%.gif.qr.eps %.webm.qr.eps %.mp4.qr.eps:
	qrencode -o $@ -t EPS "https://commons.wikimedia.org/wiki/File:`echo $@ | sed s/.qr.*//g`"

%.jpg.pdf: %.jpg
	convert $< $@

%.png.pdf: %.png
	convert $< $@

%.svg.pdf: %.svg
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

%.eps.pdf: %.eps
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

%.qr.pdf: %.qr.eps
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

.DELETE_ON_ERROR:

.SECONDARY:
