
mfnf-docs:
	$(MK)/bin/mwlint --dump-docs > mfnf-template-doc.md
	cmark --to html --safe mfnf-template-doc.md > mfnf-template-doc.raw
	cp $(BASE)/templates/mfnf-template-doc.html .
	sed -i -e '/<!-- @DOC_CONTENT@ -->/{r mfnf-template-doc.raw' -e 'd' -e '}' mfnf-template-doc.html
	rm mfnf-template-doc.raw
