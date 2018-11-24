def substitutions: {
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
def escape_make: reduce (substitutions | keys | .[]) as $item (.; . = (. | gsub("[" + $item + "]";substitutions[$item])));
def unescape_make: reduce (substitutions | to_entries | .[]) as $item (.; . = (. | gsub($item.value;$item.key)));
