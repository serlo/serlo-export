import collections
import json
import os
import re
import textwrap

from itertools import chain, repeat, count

from mfnf.transformations import ChainedAction, NotInterested, \
                                 NodeTypeTransformation

BOX_TEMPLATES = [
    "definition", "theorem", "solution", "solutionprocess", "proof",
    "proofsummary", "alternativeproof", "hint", "warning", "example",
    "exercise", "importantparagraph", "explanation", 
]

BOX_SUBTEMPLATES = {
    "theorem": ["explanation", "example", "proofsummary", "solution", "proof",
                "solutionprocess", "alternativeproof"],

    "exercise": ["explanation", "example", "proofsummary", "solution", "proof",
                 "solutionprocess", "alternativeproof"],
}

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
        self._notimplemented = []

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

    def print_box(self, box_type, obj, out):
        assert box_type in BOX_TEMPLATES, box_type

        out.write("\n\n\\begin{" + box_type + "}")

        if obj.get("title", None):
            out.write("[")
            out.write(escape_latex(obj["title"]))
            out.write("]")

        self(obj[box_type], out)

        out.write("\n\\end{" + box_type + "}")


    def act_on_dict(self, obj, out):
        node_type = obj["type"]

        if node_type in BOX_TEMPLATES:
            self.print_box(node_type, obj, out)

            for subbox in BOX_SUBTEMPLATES.get(node_type, []):
                if obj.get(subbox, None):
                    self.print_box(subbox, obj, out)
        else:
            try:
                    getattr(self, "export_" + node_type)(obj, out)
            except AttributeError:
                message = "LaTeX-Output of object `{}`".format(node_type)

                self.export_notimplemented({"message": message,
                                            "target": obj}, out)

    def print_message(self, message_type, message, out, color="Red"):
        print(message_type + ":", message)

        out.write("\n\n{\\color{" + escape_latex(color) + "} ")
        out.write("\\textbf{" + escape_latex(message_type) + ":} ")
        out.write(escape_latex(message))
        out.write("}")

    def print_notimplemented(self, out):
        out.write("\n\n\chapter{Not implemented objects}")

        for obj in self._notimplemented:
            out.write("\n\n\section{" + escape_latex(obj["message"]) + "}")
            out.write("\n\\begin{verbatim}\n")
            out.write(escape_latex_verbatim(json.dumps(obj["target"], indent=1)))
            out.write("\n\\end{verbatim}")

    def export_error(self, obj, out):
        self.print_message("Error", obj["message"], out)

    def export_notimplemented(self, obj, out):
        self.print_message("Not implemented", obj["message"], out, "RedOrange")
        self._notimplemented.append(obj)

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

        out.write("\n\n\\tableofcontents")
        out.write("\n\n\\newpage")
        out.write("\n")

        self(book["children"], out)
        self.print_notimplemented(out)

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
        self(header["content"], out)
        out.write("}")

    def export_proofbycases(self, obj, out):
        for n, case, proof in zip(count(1), obj["cases"], obj["proofs"]):
            out.write("\n\n\\textbf{Fall " + str(n) + ":} ")
            self(case, out)

            with LatexEnvironment(out, "indentblock"):
                self(proof, out)

    def export_i(self, i, out):
        out.write("\\emph{")
        self(i["content"], out)
        out.write("}")

    def export_b(self, b, out):
        out.write("\\textbf{")
        self(b["content"], out)
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

    def export_definitionlist(self, definitionlist, out):
        with LatexEnvironment(out, "description"):
            self(definitionlist["items"], out)

    def export_definitionlistitem(self, definitionlistitem, out):
        out.write("\n\\item[")
        self(definitionlistitem["definition"], out)
        out.write("] ")
        self(definitionlistitem["explanation"], out)

    def export_href(self, href, out):
        with LatexMacro(out, "href"):
            out.write(escape_latex(href["url"]))

        out.write("{")
        self(href["content"], out)
        out.write("}")

    def export_question(self, question, out):
        with LatexEnvironment(out, "question"):
            self(question["question"], out)
        with LatexEnvironment(out, "answer"):
            self(question["answer"], out)

class LatexEnvironment:
    def __init__(self, out, environment):
        self.out = out
        self.environment = environment
    def __enter__(self):
        self.out.write("\n\n\\begin{" + self.environment + "}\n")
    def __exit__(self, exc_type, exc_value, traceback):
        self.out.write("\n\\end{" + self.environment + "}")

class LatexMacro:
    def __init__(self, out, macro):
        self.out = out
        self.macro = macro
    def __enter__(self):
        self.out.write("\n\\" + self.macro + "{")
    def __exit__(self, exc_type, exc_value, traceback):
        self.out.write("}")
