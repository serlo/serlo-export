%.gif.qr.svg %.webm.qr.svg %.mp4.qr.svg:
	qrencode -o - -t SVG "https://commons.wikimedia.org/wiki/File:`echo $@ | sed 's/.qr.*//g'`" > $@

%.svg %.png %.jpg %.gif:
	python $(MK)/download_image.py $@ > $@

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

%.qr.pdf: %.qr.svg
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

.DELETE_ON_ERROR:

.SECONDARY:
