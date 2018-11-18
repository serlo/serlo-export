Repository Structure
====================

Here is a high-level overview over the most important files and directories:
* `mk`: Corresponds to the `src` directory of other projekcts. Holds makefiles and scripts of the build system, but also binaries of the helper tools.
* `doc`: Documentation artifacts, including this book.
* `include`: Static files which can be included in books from a *marker* in their sitemap.
* `templates`: Various templates and static files used in export recipes.
* `config`: Configuration files for tools used in the build process. Includes `config/mfnf.yml` which defines the targets with their configuration (subtargets) for our rust helper tools.
* `Makefile`: The main *Makefile* from which all functionality of this project can be accessed.

Additionally, some directories may be created at run time:
* `exports`: The directory structure for exported books and articles (see [User Guide](./guide.md)).
* `articles`: Downloaded articles and their intermediate representation.
* `sections`: Sections of downloaded articles in intermediate representation.
* `media`: Downladed media files and metadata, as well as converted versions.
* `revisions.json`: Global revision lock file. Whenever the latest revision of an article, book, section or media file is requested, the revision is taken from this file.\
If the latest revision is not yet known, it will immediately be recorded in this file after it was queried.

The `mk` Directory
------------------

The `mk` directory can be considered as the structured body of the `Makefile`: All `*.mk` files present in `mk` are included by `Makefile`. Additionally `mk` contains the scripts and custom tools necessary for `Makefile` to operate.

```
mk
├── article_book.mk
├── articles.mk
├── artifacts           // various artifacts like dummy files
│   ├── ...
├── bin                 // binaries of some tools build via "make init"
│   ├── ...
├── book.mk
├── dependencies.mk
├── doc.mk
├── macros.mk
├── media.mk
├── scripts             // helper scripts
│   ├── collect_stats.py
│   ├── download_article.py
│   ├── download_image.py
│   ├── fill_sitemap_revisions.py
│   ├── get_image_license.py
│   ├── get_image_revision.py
│   ├── get_revision.sh // resolves revisions and maintains `revisions.json`
│   ├── lib
│   │   ├── api.py
│   │   └── utils.py
│   └── unescape_make.py
├── sections.mk
├── targets             // target-specific makefiles
│   ├── html.mk
│   ├── latex.mk
│   ├── pdf.mk
│   └── stats.mk
└── utils.mk
```
