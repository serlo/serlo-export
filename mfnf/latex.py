import collections
import json
import os

from itertools import chain, repeat

BOX_TEMPLATES = [
    "definition", "theorem", "solution", "solutionprocess", "proof",
    "proofsummary", "alternativeproof", "hint", "warning", "example"
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

def escape_latex(text):
    return "".join((LATEX_SPECIAL_CHARS.get(c,c) for c in text))

def escape_math_latex(formula):
    return formula.replace("$", "\\$")

class LatexExporter:
    def __init__(self, api, directory):
        self.api = api
        self.directory = directory

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
                if "title" in obj:
                    out.write("[")
                    out.write(escape_latex(obj["title"]))
                    out.write("]")

                self(obj[node_type], out)

                out.write("\n\\end{" + node_type + "}")
            else:
                getattr(self, "export_" + node_type)(obj, out)
        except AttributeError:
            self.export_notimplemented({"target": obj,
                "message": "LaTeX-Output of object"}, out)

    def export_error(self, obj, out):
        print("ERROR:", obj["message"])
        out.write("\n\n\\error{")
        out.write(escape_latex(obj["message"]))
        out.write("}")

    def export_notimplemented(self, obj, out):
        out.write("\n\n{\\color{RedOrange} \\textbf{Not Implemented:} ")
        out.write(escape_latex(obj["message"]))
        out.write("\n\\begin{verbatim}\n")
        out.write(json.dumps(obj["target"], indent=1))
        out.write("\n\\end{verbatim}\n}")

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
        out.write(escape_math_latex(obj["formula"]))
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
        out.write(escape_math_latex(inlinemath["formula"]))
        out.write("$")

    def export_header(self, header, out):
        header_types = ["section", "subsection", "subsubsection", "paragraph"]
        out.write("\n\n\\" + header_types[header["depth"]] + "{")
        self(header["content"], out)
        out.write("}")

    def export_i(self, i, out):
        out.write("\\emph{")
        self(i["content"], out)
        out.write("}")

    def export_b(self, b, out):
        out.write("\\textbf{")
        self(b["content"], out)
        out.write("}")

    def export_image(self, image, out):
        if image["name"].endswith(".gif"):
            if not image["thumbnail"]:
                print("Warning: ignored GIF", image["name"])
            return

        if image["thumbnail"]:
            out.write("\n\n\\begin{figure}\n")
        else:
            out.write("\n\n")

        image_name = image["name"].replace(".svg", ".png")
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
            self(image["caption"], out)
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
