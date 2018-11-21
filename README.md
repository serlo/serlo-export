# mfnf-pdf-export
mfnf-pdf-export is a set of tools to create documents from MediaWiki articles. Target formats are currently LaTeX, PDF and HTML (an a statistics target), more are planned.
Building on our previous experiences, the main design goals of this project are simplicity and extensibility. 

The heart of this repository is a collection of Makefiles, which build the target file step-by-step using small, unix-like tools.
We try to use existing / standard tools where possible. Most of the helper programs we develop ourselves are written in [Rust](https://www.rust-lang.org)
or [Python 3](https://www.python.org).

For more information, please refer to the [documentation](https://lodifice.github.io/mfnf-pdf-export/).
