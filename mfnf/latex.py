import collections
import os

from textwrap import dedent

from mfnf.utils import intersperse

class LatexExporter:
    def __init__(self, api, directory):
        self.api = api
        self.directory = directory

    def __call__(self, obj, out):
        if isinstance(obj, str):
            self.export_str(obj, out)
        elif isinstance(obj, collections.abc.Sequence):
            self.export_list(obj, out)
        elif isinstance(obj, collections.abc.Mapping):
            self.export_dict(obj, out)

    def export_str(self, text, out):
        out.write(text)

    def export_list(self, lst, out):
        for element in lst:
            self(element, out)

    def export_dict(self, obj, out):
        try:
            getattr(self, "export_" + obj["type"])(obj, out)
        except AttributeError:
            self.notimplemented(obj, out)

    def notimplemented(self, obj, out):
        print("Not Implemented:", obj["type"])

    def export_book(self, book, out):
        with open("mfnf/latex_template.tex", "r") as template:
            out.write(template.read())

        out.write("\\title{" + book["name"].strip() + "}\n")
        out.write("\\begin{document}")

        self(book["children"], out)

        out.write("\\end{document}")

    def export_chapter(self, chapter, out):
        # TODO chapter -> part in all functions and dicts
        out.write("\\part{" + chapter["name"] +"}\n")
        self(chapter["children"], out)

    def export_article(self, article, out):
        out.write("\\chapter{" + article["name"] +"}\n")
        self(article["content"], out)

    def export_paragraph(self, paragraph, out):
        self(paragraph["children"], out)
        out.write("\n\n")

    def export_text(self, text, out):
        self(text["data"], out)

    def export_inlinemath(self, inlinemath, out):
        out.write(" $")
        self(inlinemath["formula"], out)
        out.write("$ ")

    def export_header(self, header, out):
        header_types = ["section", "subsection", "subsubsection", "paragraph"]
        out.write("\\" + header_types[header["depth"]] + "{")
        self(header["children"], out)
        out.write("}\n")

    def export_i(self, i, out):
        out.write("\\textit{")
        self(i["children"], out)
        out.write("}\n")

    def export_b(self, b, out):
        out.write("\\textbf{")
        self(b["children"], out)
        out.write("}\n")

    def export_image(self, image, out):
        if image["name"].endswith(".gif"):
            if not image["thumbnail"]:
                print("Warning: ignored GIF", image["name"])
            return
        if image["thumbnail"]:
            out.write("\\begin{figure}\n")
        image_file = os.path.join(self.directory,
                                  image["name"].replace("./Datei:",
                                                        "").replace("_",
                                                                    "").replace("svg",
                                                                                "png"))
        image_url = "http:" + image["url"]
        self.api.download_image(image_url, image_file)
        out.write("\\begin{center}\n")
        out.write("\\includegraphics[width=0.7\\textwidth]{" + image_file + "}\n")
        out.write("\\end{center}\n")
        if image["thumbnail"]:
            out.write("\\caption{")
            self(image["caption"], out)
            out.write("}\n")
            out.write("\\end{figure}\n")

    def export_table(self, table, out):
        # TODO intermediate conversion
        ncolumns = len(table["children"][0]["children"])
        out.write("\n\\begin{tabular}{" + ncolumns * 'c' + "} \\\\ \\toprule \n")
        self(table["children"][0], out)
        out.write("\\midrule\n")
        self(table["children"][1:], out)
        out.write("\\bottomrule\n")
        out.write("\\end{tabular}\n")

    def export_tr(self, tr, out):
        columns_with_delimiters = list(intersperse(" & ", tr["children"]))
        self(columns_with_delimiters, out)
        out.write(" \\\\ \n")

    def export_td(self, td, out):
        self(td["children"], out)

    def export_th(self, th, out):
        self(th["children"], out)
