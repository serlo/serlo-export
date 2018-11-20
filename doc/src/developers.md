# Makefile Developer Documentation

Building on the exeriences of previous interations and prototypes, this build systems for MediaWiki exports is designed to be more *modular*, use *standard tools* where possible and *communicate errors* as soon as possible. Less dependency on the environment (including network connection) is desirable as well.

The heart of the system is a *Makefile*, which glues standard and custom tools together to allow building books, articles and documentation. 
