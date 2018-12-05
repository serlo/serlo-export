
# list of known targets
def targets: ["html", "latex", "pdf", "stats"];
# extensions of the result files for each target
def target_extensions: {
    "html": [".html"],
    "stats": [".stats.json"],
    "latex": [".tex"]
};

# list of targets which do not have book dependencies
def no_dep_targets: ["pdf"];

def make_substitutions: {
    " ": "_",
    ":": "@COLON@",
    "(": "@LBR@",
    ")": "@RBR@",
    "/": "@SLASH@",
    "'": "@SQUOTE@",
    "\"": "@DQUOTE@",
    "*": "@STAR@",
    "=": "@EQ@",
    "$": "@DOLLAR@",
    "#": "@SHARP@",
    "%": "@PERC@"
};

# escape / unescape file paths for make
def escape_make: 
    reduce (make_substitutions | keys | .[]) as $item (.; . = (. | gsub("[" + $item + "]";make_substitutions[$item])));
def unescape_make: 
    reduce (make_substitutions | to_entries | .[]) as $item (.; . = (. | gsub($item.value;$item.key)));

# remove excluded chapters for $subtarget and empty parts from the sitemap.
def exclude_chapters: 
    del(.parts[] | .chapters[] | select([.markers.exclude.subtargets[] | .name==$subtarget and .parameters==[]] | any == true)) |
    del(.parts[] | select(.chapters == []));

# generate a makefile specifying the dependencies for a book
# from the sutarget map
def generate_book_deps:
    # check if the given target is known
    if (targets | index($target) == null) then 
        error("unknown target: " + $target) 
    else . end |
    # output empty dependencies for no-dependency targets
    if (no_dep_targets | index($target) != null) then empty else . end |
    # produce target-independent dependencies
    (.parts[] | .chapters[] | $prefix + (.path | escape_make) + "/" + .revision) |
    $book_dep_target + ": " + . + ".section-dep",
    $book_dep_target + ": " + . + ".media-dep",
    $book_anchors_target + ": " + . + ".anchors",
    "include " + . + ".section-dep",
    "-include " + . + ".media-dep",
    $book_dep_target + ": " + . + (target_extensions[$target][] | . );

# extract article markers from the sitemap for an article,
# substituting the subtarget name by "current".
def article_markers:
    .parts[] | .chapters[] | select(.path==($article | unescape_make)) | .markers
    | del(.exclude.subtargets[] | select(.name != $subtarget)) 
    | del(.include.subtargets[] | select(.name != $subtarget)) 
	| (.exclude.subtargets[] | .name) |= "current"
	| (.include.subtargets[] | .name) |= "current";

# replace "latest" in chapter revision with the current revision,
# revisions are given by $revisions
def fill_sitemap_revisions:
    (.parts[] | .chapters[] | select(.revision=="latest"))
        |= (.revision=$revisions.articles[(.path | gsub(" ";"_"))]);

# extract some stats from the linter output of an article.
def lint_stats:
    reduce .[] as $item ({"kind": {}, "severity": {}, "lints_total": 0}; 
        (.kind[$item.kind] += 1)
        | (.severity[$item.severity] += 1)
        | (.lints_total += 1)
    );

def walk(f):
    . as $in
    | if type == "object" then
        reduce keys[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
    elif type == "array" then map( walk(f) ) | f
    else f
    end;

def addmerge(o):
    reduce (o | paths(type != "object" and type != "string")) as $i (.;setpath($i; getpath($i) + (o | getpath($i))));
