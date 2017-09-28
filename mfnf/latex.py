import collections
import json
import os
import re
import textwrap
import logging

from itertools import chain, repeat, count
from mfnf.utils import log_parser_error, lookup
from mfnf.transformations import ChainedAction, NotInterested, \
                                 NodeTypeTransformation, Transformation

report_logger = logging.getLogger("report_logger")

BOX_TEMPLATES = [
    "definition", "theorem", "solution", "solutionprocess", "proof",
    "proofsummary", "alternativeproof", "hint", "warning", "example",
    "exercise", "importantparagraph", "explanation",
]

BOX_SUBTEMPLATES = {
    "theorem": ["explanation", "example", "proofsummary", "solutionprocess",
                "solution", "proof"],  # TODO: "alternativeproof"

    "exercise": ["explanation", "example", "proofsummary", "solutionprocess",
                 "solution", "proof"], # TODO: "alternativeproof"
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
    '↯':  '\\Lightning{}',
}

SMILEY_UNICODE_OUTPUT = {
    ":)": "\U0001F60A",
    ":(": "\U0001F61E",
    "sad": "\U0001F61E",
    ":-]": "\U0001F60A",
    ":-[": "\U0001F61E",
    ">:(": "\U0001F620",
    ":D": "\U0001F604",
    "lol": "\U0001F604",
    "lach": "\U0001F604",
    ":-D": "\U0001F604",
    ";-]": "\U0001F60F",
    "8-]": "\U0001F60E",
    ":-/": "\U0001F615",
    ":-S": "\U0001F616",
    ":-O": "\U0001F62E",
    "staun": "\U0001F62E",
    ":-P": "\U0001F61B",
    ":'(": "\U0001F622",
    "wein": "\U0001F622",
    "cry": "\U0001F622",
    ">:[": "\U0001F620",
    "wütend": "\U0001F620",
    "angry": "\U0001F620",
    ">:-D": "\U0001F608",
    "Daumen": "\U0001F64C",
    "Facepalm": "\U0001F625",
    "#default": "\U0001F60A",
}

def shorten(line):
    indent = re.match(r"^\s*", line).group()

    return indent + textwrap.shorten(line, 60)

def escape_latex(text):
    return "".join((LATEX_SPECIAL_CHARS.get(c, c) for c in text))

def escape_latex_math(formula):
    # TODO: Is this function needed?
    return formula

def escape_latex_verbatim(code):
    code = re.sub(r"\\end\s*{\s*verbatim\s*}", "", code)
    return "\n".join((shorten(line) for line in code.splitlines()))

class MediaWiki2Latex(ChainedAction):
    class HandleBoxTemplates(Transformation):
        def __init__(self, **options):
            super().__init__(**options)
            self._outer_box = None
            self._in_question = False

        def act_on_dict(self, obj):
            if lookup(obj, "type") in BOX_TEMPLATES:
                if self._outer_box:
                    message = "Box {} inside {} is not allowed" \
                              .format(obj["type"], self._outer_box)

                    return {"type": "error", "message": message}
                else:
                    self._outer_box = obj["type"]

                    result = super().act_on_dict(obj)

                    self._outer_box = None

                    return result
            elif (self._outer_box or self._in_question) and \
                    lookup(obj, "type") == "image" and obj["thumbnail"]:
                return None
            elif lookup(obj, "type") == "question":
                self._in_question = True

                result = super().act_on_dict(obj)

                self._in_question = False

                return result
            else:
                return super().act_on_dict(obj)

    class DeleteNotPrintableContent(NodeTypeTransformation):
        def transform_mainarticle(self, obj):
            return None

        def transform_list(self, obj):
            if obj["items"]:
                raise NotInterested()
            else:
                message = "Empty List"
                log_parser_error(message, obj)
                return {"type": "error",
                        "message": message}

        def transform_image(self, obj):
            _, ext = os.path.splitext(obj["name"])

            if ext in (".webm", ".gif") or obj["noprint"]:
                return None
            elif ext in (".jpg", ".svg", ".png"):
                raise NotInterested()
            else:
                message = "Unrecognized image with extension " + ext
                log_parser_error(message, obj)
                return {"type": "error",
                        "message": message}

        def transform_section_start(self, obj):
            return None

        def transform_section_end(self, obj):
            return None

        def transform_question(self, obj):
            if lookup(obj, "questiontype") == "Verständnisfrage":
                return None
            else:
                raise NotInterested()

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

        out.write("\\begin{" + box_type + "*}")
        if obj.get("title", None):
            out.write("[")
            self(obj["title"], out)
            out.write("]")
        out.write("\n")

        self(obj[box_type], out)

        out.write("\\end{" + box_type + "*}\n\n")


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
        out.write("{\\color{" + escape_latex(color) + "} ")
        out.write("\\textbf{" + escape_latex(message_type) + ":} ")
        out.write(escape_latex(message))
        out.write("}\n")

    def print_notimplemented(self, out):
        if self._notimplemented:
            out.write("\chapter{Not implemented objects}\n\n")

            for obj in self._notimplemented:
                out.write("\section{" + escape_latex(obj["message"]) + "}\n\n")

                with LatexEnvironment(out, "verbatim"):
                    out.write(escape_latex_verbatim(json.dumps(obj["target"], indent=1)))

    def export_error(self, obj, out):
        self.print_message("Error", obj["message"], out)

    def export_notimplemented(self, obj, out):
        self.print_message("Not implemented", obj["message"], out, "RedOrange")
        self._notimplemented.append(obj)

    def export_listitem(self, obj, out):
        out.write("\\item ")
        self(obj["content"], out)
        out.write("\n")

    def export_list(self, obj, out):
        list_type = "enumerate" if obj["ordered"] else "itemize"

        with LatexEnvironment(out, list_type):
            self(obj["items"], out)

    def export_equation(self, obj, out):
        with LatexEnvironment(out, "align*"):
            out.write(escape_latex_math(obj["formula"]) + "\n")


    def export_book(self, book, out):
        with open("mfnf/latex_template.tex", "r") as template:
            out.write(template.read())

        out.write("\\title{")
        out.write(escape_latex(book["name"]))
        out.write("}\n\n")
        out.write("\\date{}\n\n")
        out.write("\\begin{document}\n\n")
        out.write("\\maketitle\n\n")

        out.write("\\ColoredTOC\n\n")
        out.write("\\newpage\n\n")

        self(book["children"], out)
        self.print_notimplemented(out)

        out.write("\\end{document}\n")

    def export_chapter(self, chapter, out):
        out.write("\\chapter{")
        out.write(escape_latex(chapter["name"]))
        out.write("}\n\n")

        # TODO: Move to parser calculation of author list
        authors = [x[0] for x in sorted(chapter["authors"].items(), reverse=True,
                                        key=lambda x: x[1])]

        out.write("{\\footnotesize Autoren und Autorinnen: ")
        out.write(", ".join(map(escape_latex, authors)))
        out.write("\par}\n\n")

        self(chapter["children"], out)

    def export_article(self, article, out):
        report_logger.info("== {} ==".format("Export article: " + article["name"]))
        out.write("\\section{")
        out.write(escape_latex(article["name"]))
        out.write("}\n\n")

        self(article["content"], out)

    def export_paragraph(self, paragraph, out):
        self(paragraph["content"], out)
        out.write("\n\n")

    def export_text(self, text, out):
        out.write(escape_latex(text["data"]))

    def export_inlinemath(self, inlinemath, out):
        out.write("$")
        out.write(escape_latex_math(inlinemath["formula"]))
        out.write("$")

    def export_section(self, section, out):
        title_prefix = lookup(section, "title", 0, "data")
        if title_prefix and title_prefix.startswith("Baustelle: "):
            return
        section_types = ["section", "subsection", "subsubsection", "paragraph"]
        out.write("\\" + section_types[section["depth"]] + "{")
        self(section["title"], out)
        out.write("}\n\n")
        self(section["content"], out)

    def export_proofbycases(self, obj, out):
        for n, case, proof in zip(count(1), obj["cases"], obj["proofs"]):
            out.write("\\proofcase{" + str(n) + "}{")
            self(case, out)
            out.write("}\n")

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

    def export_strikethrough(self, strikethrough, out):
        out.write("\\sout{")
        self(strikethrough["content"], out)
        out.write("}")

    def export_image(self, image, out):
        if image["thumbnail"]:
            out.write("\\begin{figure}\n")
        elif not image["inline"]:
            out.write("\n\n")

        image_name = self.api.download_image(image["name"], self.directory)

        if image["inline"]:
            out.write("\\includegraphics[height=\\lineheight]{{{}}}".format(image_name))
        else:
            with LatexEnvironment(out, "center"):
                out.write("\n\\includegraphics[max width=0.5\\textwidth,"
                          "max height=0.2\\textheight]{")
                out.write(image_name)
                out.write("}")

        if image["thumbnail"]:
            out.write("\\caption{")
            self(image["caption"], out)
            out.write("}")
            out.write("\n\\end{figure}\n\n")

    def export_gallery(self, gallery, out):
        with LatexEnvironment(out, "figure", ["H"]):
            out.write("\\hfill")
            for image in gallery["items"]:
                out.write("\\begin{subfigure}{%f\\textwidth}" % (.9/len(gallery["items"])))

                image_name = self.api.download_image(image["name"],
                                                     self.directory)

                out.write("\n\\includegraphics[width=1.\\textwidth]{")
                out.write(image_name)
                out.write("}")

                out.write("\\caption{")
                self(image["caption"], out)
                out.write("}")
                out.write("\\end{subfigure}")
                out.write("\\hfill")

    def export_table(self, table, out):
        out.write("\\begin{adjustbox}{max width=\\textwidth}")
        # TODO intermediate conversion
        ncolumns = len(table["content"][0]["content"])
        out.write("\n\\begin{tabular}{" + ncolumns * 'c' + "} \\\\ \\toprule \n")
        self(table["content"][0], out)
        out.write("\\midrule\n")
        self(table["content"][1:], out)
        out.write("\\bottomrule\n")
        out.write("\\end{tabular}\n")
        out.write("\\end{adjustbox}\n\n")

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
        with LatexEnvironment(out, "description", ["style=nextline"]):
            self(definitionlist["items"], out)

    def export_definitionlistitem(self, definitionlistitem, out):
        out.write("\\item[")
        self(definitionlistitem["definition"], out)
        out.write("]\n")
        self(definitionlistitem["explanation"], out)

    def export_href(self, href, out):
        with LatexMacro(out, "href"):
            out.write(escape_latex(href["url"]))

        out.write("{")
        self(href["content"], out)
        out.write("}")

    def export_question(self, question, out):
        mdframed_options = (["style=semanticbox"] +
                            (["frametitle=Frage"]
                             if not lookup(question, "questiontype")
                             else ["frametitle={" + question["questiontype"] + "}"]))
        with LatexEnvironment(out, "mdframed", mdframed_options):
            self(question["question"], out)
        with LatexEnvironment(out, "answer*"):
            self(question["answer"], out)

    def export_proofstep(self, proofstep, out):
        with LatexMacro(out, "proofstep"):
            self(proofstep["name"], out)
            out.write(":")

        out.write(" ")
        self(proofstep.get("target", []), out)

        with LatexEnvironment(out, "indentblock"):
            self(proofstep["proof"], out)

    def export_blockquote(self, blockquote, out):
        with LatexEnvironment(out, "displayquote"):
            self(blockquote["content"], out)

    def export_induction(self, induction, out):
        # unpack paragraphs to prevent "stretching"
        induction = induction.copy()
        for k, v in induction.items():
            if type(v) == list and len(v) == 1 and v[0]["type"] == "paragraph":
                induction[k] = v[0]["content"]

        out.write("\\begin{induction*}[Für alle ")
        self(induction["baseset"], out)
        out.write(" gilt: ")
        out.write("]")
        self(induction["statement"], out)

        out.write("\\inductionstep{1}{Induktionsanfang}\n")
        with LatexEnvironment(out, "indentblock"):
            self(induction["induction_start"], out)
        out.write("\\inductionstep{2}{Induktionsschritt}\n")
        with LatexEnvironment(out, "indentblock"):
            out.write("\\inductionstep{2a}{Induktionsvoraussetzung}\n")
            with LatexEnvironment(out, "indentblock"):
                self(induction["induction_requirement"], out)
            out.write("\\inductionstep{2b}{Induktionsschritt}\n")
            with LatexEnvironment(out, "indentblock"):
                self(induction["induction_goal"], out)
            out.write("\\inductionstep{2c}{Beweis des Induktionsschritts}\n")
            with LatexEnvironment(out, "indentblock"):
                self(induction["induction_step"], out)
        out.write("\\end{induction*}\n\n")

    def export_entity(self, entity, out):
        if entity["kind"] == " ":
            out.write("~")

    def export_coloredtext(self, coloredtext, out):
        out.write("{\\textcolor{" + escape_latex(coloredtext["color"]) + "}{")
        self(coloredtext["content"], out)
        out.write("}}")

    def export_smiley(self, smiley, out):
        out.write("{{\DejaSans {}}}".format(SMILEY_UNICODE_OUTPUT.get(smiley["name"], "\u26A0")))

class LatexEnvironment:
    def __init__(self, out, environment, parameters=[]):
        self.out = out
        self.environment = environment
        self.parameters = parameters
    def __enter__(self):
        parameter_str = "[" + ",".join(self.parameters) + "]"
        self.out.write("\\begin{" + self.environment + "}" + (parameter_str if self.parameters else "") + "\n")
    def __exit__(self, exc_type, exc_value, traceback):
        self.out.write("\\end{" + self.environment + "}\n\n")

class LatexMacro:
    def __init__(self, out, macro):
        self.out = out
        self.macro = macro
    def __enter__(self):
        self.out.write("\\" + self.macro + "{")
    def __exit__(self, exc_type, exc_value, traceback):
        self.out.write("}\n")
