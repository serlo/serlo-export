import collections
import json
import os
import re
import textwrap

from itertools import chain, repeat

from mfnf.transformations import ChainedAction, NotInterested, \
                                 NodeTypeTransformation

BOX_TEMPLATES = [
    "definition", "theorem", "solution", "solutionprocess", "proof",
    "proofsummary", "alternativeproof", "hint", "warning", "example",
    "exercise"
]

LATEX_SPECIAL_CHARS = {
    '$':  '\\$',
    '%':  '\\%',
    '&':  '\\&',
    '#':  '\\#',
    '_':  '\\_',
    '{':  '\\{',
    '}':  '\\}',
    '[':  '{[}',
    ']':  '{]}',
    '"':  "{''}",
    '\\': '\\textbackslash{}',
    '~':  '\\textasciitilde{}',
    '<':  '\\textless{}',
    '>':  '\\textgreater{}',
    '^':  '\\textasciicircum{}',
    '`':  '{}`',   # avoid ?` and !`
    '\n': '\\\\',
}

def shorten(line):
    indent = re.match(r"^\s*", line).group()

    return indent + textwrap.shorten(line, 60)

def quote_image_name(text):
    return re.sub(r"[^a-zA-Z0-9]", lambda x: str(ord(x.group())), text)

def escape_latex(text):
    return "".join((LATEX_SPECIAL_CHARS.get(c, c) for c in text))

def escape_latex_math(formula):
    return formula.replace("$", "\\$")

def escape_latex_verbatim(code):
    code = re.sub(r"\\end\s*{\s*verbatim\s*}", "", code)
    return "\n".join((shorten(line) for line in code.splitlines()))

class MediaWiki2Latex(ChainedAction):
    class DeleteNotPrintableContent(NodeTypeTransformation):
        def transform_mainarticle(self, obj):
            return None

        def transform_image(self, obj):
            _, ext = os.path.splitext(obj["name"])

            if ext in (".webm", ".gif"):
                return None
            elif ext in (".jpg", ".svg", ".png"):
                raise NotInterested()
            else:
                return {"type": "error",
                        "message": "Unrecognized image with extension " + ext}

class LatexExporter:
    def __init__(self, api, directory):
        self.api = api
        self.directory = directory
        self._inlinemode = False

    def __call__(self, obj, out):
        if isinstance(obj, str):
            # There shouldn't be a case where self(obj) is called with obj
            # beeing a string. String output should occur only in the
            # export_... functions with the apporiate escaping function.
            raise TypeError("obj is a string, value: {}".format(obj))
        elif isinstance(obj, collections.abc.Sequence):
            for element in obj:
                self(element, out)
        elif isinstance(obj, collections.abc.Mapping):
            self.act_on_dict(obj, out)

    def act_on_dict(self, obj, out):
        try:
            node_type = obj["type"]

            if node_type in BOX_TEMPLATES:
                out.write("\n\n\\begin{" + node_type + "}")

                if obj.get("title", None):
                    out.write("[")
                    out.write(escape_latex(obj["title"]))
                    out.write("]")

                self(obj[node_type], out)

                out.write("\n\\end{" + node_type + "}")
            else:
                getattr(self, "export_" + node_type)(obj, out)
        except AttributeError:
            self.export_notimplemented({"message": "LaTeX-Output of object",
                                        "target": obj}, out)

    def print_message(self, message_type, message, out, color="Red", target_obj=None):
        print(message_type + ":", message)

        if self._inlinemode:
            out.write("}")

        out.write("\n\n{\\color{" + escape_latex(color) + "} ")
        out.write("\\textbf{" + escape_latex(message_type) + ":} ")
        out.write(escape_latex(message))
        out.write("}")

        if target_obj:
            out.write("\n\\begin{verbatim}\n")
            out.write(escape_latex_verbatim(json.dumps(target_obj, indent=1)))
            out.write("\n\\end{verbatim}")

        if self._inlinemode:
            out.write("\n\n{")

    def export_error(self, obj, out):
        self.print_message("Error", obj["message"], out)

    def export_notimplemented(self, obj, out):
        self.print_message("Not implemented", obj["message"], out, "RedOrange",
                           obj["target"])

    def export_listitem(self, obj, out):
        out.write("\n\\item ")
        self(obj["content"], out)

    def export_list(self, obj, out):
        list_type = "enumerate" if obj["ordered"] else "itemize"
        out.write("\n\n\\begin{" + list_type + "}")
        self(obj["items"], out)
        out.write("\n\\end{" + list_type + "}")

    def export_equation(self, obj, out):
        out.write("\n\n\\begin{align*}\n")
        out.write(escape_latex_math(obj["formula"]))
        out.write("\n\\end{align*}")

    def export_book(self, book, out):
        with open("mfnf/latex_template.tex", "r") as template:
            out.write(template.read())

        out.write("\n\\title{")
        out.write(escape_latex(book["name"]))
        out.write("}")
        out.write("\n\n\\begin{document}")

        self(book["children"], out)

        out.write("\n\\end{document}")

    def export_chapter(self, chapter, out):
        # TODO chapter -> part in all functions and dicts
        out.write("\n\n\\part{")
        out.write(escape_latex(chapter["name"]))
        out.write("}")

        self(chapter["children"], out)

    def export_article(self, article, out):
        out.write("\n\n\\chapter{")
        out.write(escape_latex(article["name"]))
        out.write("}")
        self(article["content"], out)

    def export_paragraph(self, paragraph, out):
        out.write("\n\n")
        self(paragraph["content"], out)

    def export_text(self, text, out):
        out.write(escape_latex(text["data"]))

    def export_inlinemath(self, inlinemath, out):
        out.write("$")
        out.write(escape_latex_math(inlinemath["formula"]))
        out.write("$")

    def export_header(self, header, out):
        header_types = ["section", "subsection", "subsubsection", "paragraph"]
        out.write("\n\n\\" + header_types[header["depth"]] + "{")
        self._inlinemode = True
        self(header["content"], out)
        self._inlinemode = False
        out.write("}")

    def export_i(self, i, out):
        out.write("\\emph{")
        self._inlinemode = True
        self(i["content"], out)
        self._inlinemode = False
        out.write("}")

    def export_b(self, b, out):
        out.write("\\textbf{")
        self._inlinemode = True
        self(b["content"], out)
        self._inlinemode = False
        out.write("}")

    def export_image(self, image, out):
        if image["thumbnail"]:
            out.write("\n\n\\begin{figure}\n")
        else:
            out.write("\n\n")

        name, ext = os.path.splitext(image["name"])

        if ext not in (".jpg",):
            ext = ".png"

        image_name = quote_image_name(name) + ext
        image_file = os.path.join(self.directory, image_name)
        image_url = "http:" + image["url"]

        self.api.download_image(image_url, image_file)

        out.write("\\begin{center}")
        out.write("\n\\includegraphics[width=0.5\\textwidth]{")
        out.write(os.path.basename(image_file))
        out.write("}")
        out.write("\n\\end{center}")

        if image["thumbnail"]:
            out.write("\\caption{")
            self._inlinemode = True
            self(image["caption"], out)
            self._inlinemode = False
            out.write("}")
            out.write("\n\\end{figure}")

    def export_table(self, table, out):
        # TODO intermediate conversion
        ncolumns = len(table["content"][0]["content"])
        out.write("\n\n\\begin{tabular}{" + ncolumns * 'c' + "} \\\\ \\toprule \n")
        self(table["content"][0], out)
        out.write("\\midrule\n")
        self(table["content"][1:], out)
        out.write("\\bottomrule\n")
        out.write("\\end{tabular}")

    def export_tr(self, tr, out):
        for cell, delimiter in zip(tr["content"], chain([""], repeat(" & "))):
            out.write(delimiter)
            self(cell, out)
        out.write(" \\\\ \n")

    def export_td(self, td, out):
        self(td["content"], out)

    def export_th(self, th, out):
        self(th["content"], out)
