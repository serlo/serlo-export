%.svg:
	python $(MK)/download_image.py $@ > $@

%.gif.qr.eps %.webm.qr.eps %.mp4.qr.eps:
	qrencode -o $@ -t EPS "$@"

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

%.webm.qr.pdf: %.webm.qr.eps
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

%.gif.qr.pdf: %.gif.qr.eps
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<

%.mp4.qr.pdf: %.mp4.qr.eps
	inkscape --without-gui --export-area-page --export-text-to-path \
		--export-ignore-filters --export-pdf=$@ $<


.DELETE_ON_ERROR:

.SECONDARY:
