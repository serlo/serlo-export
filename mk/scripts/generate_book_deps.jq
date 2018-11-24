import "mk/scripts/escape_make" as em;
# check if the given target is known
if (["html", "latex", "pdf", "stats"] | contains([$target]) | not) then error("unknown target: " + $target) else . end |
# pdf needs and empty dep file, since it does not really export anything
if $target=="pdf" then empty else . end |
# produce target-independent dependencies
(.parts[] | .chapters[] | $prefix + (.path | em::escape_make) + "/" + .revision) |
$book_dep_target + ": " + . + ".section-dep",
$book_dep_target + ": " + . + ".media-dep",
$book_anchors_target + ": " + . + ".anchors",
"include " + . + ".section-dep",
"-include " + . + ".media-dep",
if $target=="html" then $book_dep_target + ": " + . + ".html" else empty end,
if $target=="stats" then $book_dep_target + ": " + . + ".stats.yml" else empty end,
if $target=="stats" then $book_dep_target + ": " + . + ".lints.yml" else empty end,
if $target=="latex" then $book_dep_target + ": " + . + ".tex" else empty end
