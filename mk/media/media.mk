INKSCAPE = inkscape --without-gui --export-area-page --export-text-to-path \
	--export-ignore-filters --export-pdf=$@ $<
CONVERT = convert $< $@
DOWNLOAD_PDF = python $(MK)/download_image.py $*.pdf > $@

%.gif.qr.svg %.GIF.qr.svg %.webm.qr.svg %.WEBM.qr.svg %.mp4.qr.svg %.MP4.qr.svg:
	qrencode -o - -t SVG "https://commons.wikimedia.org/wiki/File:`echo $@ | sed 's/.qr.*//g'`" > $@

%.jpg.pdf: %.jpg
	$(CONVERT)

%.JPG.pdf: %.JPG
	$(CONVERT)

%.png.pdf: %.png
	$(CONVERT)

%.PNG.pdf: %.PNG
	$(CONVERT)

%.svg.pdf: %.svg
	$(INKSCAPE)

%.SVG.pdf: %.SVG
	$(INKSCAPE)

%.eps.pdf: %.eps
	$(INKSCAPE)

%.EPS.pdf: %.EPS
	$(INKSCAPE)

%.qr.pdf: %.qr.svg
	$(INKSCAPE)

%.plain.pdf:
	$(DOWNLOAD_PDF)

%.plain.PDF:
	$(DOWNLOAD_PDF)

%.dummy:;

%.svg %.SVG %.png %.PNG %.jpg %.JPG %.jpeg %.JPEG %.gif %.GIF %.webm %.WEBM:
	python $(MK)/download_image.py $@ > $@

.DELETE_ON_ERROR:
.NOTPARALLEL:
.SECONDARY:
