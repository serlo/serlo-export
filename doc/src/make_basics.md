Makefile Basics 
===============

This section describes some of the basic concepts a developer should know in order to understand in detail how the build system works.

Building Makefiles
------------------

One of the most important patterns used in this makefile is dynamic generation and inclusion of makefiles. This allows generating dependencies at run time without using [recursive make](http://lcgapp.cern.ch/project/architecture/recursive_make.pdf). The build system relies havily on GNU Make trying to build makefiles included with `-include` before loading them. More information regarding this pattern can be found [here](http://make.mad-scientist.net/constructed-include-files/).

Secondary Expansion
-------------------

Not all dependency information is generated in the form of a makefile and then included. In many cases, prerequisites are generated from the current target via [secondary expansion](https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html). With secondary expansion, prerequisite list are expanded twice every time a rule is tried by make. This also allows calling make functions and defining variables every time the second expansion happens.

Target-specific Variable Values
-------------------------------

Make allows variable values to be [specific to a target](https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html) (and its prerequisites, recusively). Combining secondary expansion and the eval function we can conveniently store some calculation results in variables and use them to construct a prerequisite path:

```makefile
root/%/somefile: $$(eval HEAD := $$(word 2,$$(subst /, ,$$@))) root/$$(HEAD).index
    do --fun-stuff-in-the-shell
```

Note that `$(HEAD)` is specific to this target and its prerequisites and will also be available in the recipe, it not changed by the expansion or recipe of a prerequisite.

Since our target paths hold valuable information, this pattern is fairly common in our code base. Using recursively expanded (`=`-assigned) variables, we can make path parsing look almost sane:

```makefile
root/%/somefile: $(PARSE_PATH) path/to/$$(HEAD)/$$(FOO)/$$(SOMEFILE)
    fun stuff...
```

`$(PARSE_PATH)` expands to the parsing expression in the first expansion, which is evaluated in the second expansion (as is the prerequisite path).

Note that macro expansion in make can to pretty much anything, thanks to `$(eval ....)` and `$(shell ...)`.

Using Secondary Expansion to restrict Rules
-------------------------------------------

Since we can generate prerequisites every time a rule is considerered by make, we can impose restrictions on wether make can use this rule right now. Normally, pattern rules match if the target pattern matches. 

If the rule should only apply in a subset of those cases, we can use the secondary expansion to generate an impossible prerequisite, effectively blocking make from using the rule:

```makefile
%: $$(if $$(subst pdf,,$$(suffix $$@)),,IMPOSSIBLE)
    do things...
```

The above example ony allows make to use this rule if the target file ends with `pdf`. Of course, this would be used with more complex requirements, which cannot be expressed trough make's pattern rules.
