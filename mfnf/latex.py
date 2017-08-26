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
            for element in obj:
                self(element, out)
        elif isinstance(obj, collections.abc.Mapping):
            self.export_dict(obj, out)

    def export_str(self, text, out):
        out.write(text)

    def export_listitem(self, obj, out):
        out.write("\n\\item ")
        self(obj["content"], out)

    def export_list(self, obj, out):
        list_type = "enumerate" if obj["ordered"] else "itemize"
        out.write("\n\n\\begin{" + list_type + "}")
        self(obj["items"], out)
        out.write("\n\\end{" + list_type + "}")

    def export_dict(self, obj, out):
        try:
            getattr(self, "export_" + obj["type"])(obj, out)
        except AttributeError:
            self.export_notimplemented({"target": obj}, out)

    def export_equation(self, obj, out):
        out.write("\n\n\\begin{align*}\n  ")
        self(obj["formula"], out)
        out.write("\n\\end{align*}")

    def export_error(self, obj, out):
        print("ERROR:", obj["message"])
        out.write("\n\n\\error{" + obj["message"] + "}\n\n")

    def export_todo(self, todo, out):
        print("TODO:", todo)
        out.write("\n\n\\todo{" + todo + "}\n\n")

    def export_notimplemented(self, obj, out):
        self.export_todo("`{}` not implemented".format(obj["target"]["type"]), out)

    def export_book(self, book, out):
        with open("mfnf/latex_template.tex", "r") as template:
            out.write(template.read())

        out.write("\n\\title{" + book["name"].strip() + "}")
        out.write("\n\n\\begin{document}")

        self(book["children"], out)

        out.write("\n\\end{document}")

    def export_chapter(self, chapter, out):
        # TODO chapter -> part in all functions and dicts
        out.write("\n\n\\part{" + chapter["name"] +"}")
        self(chapter["children"], out)

    def export_article(self, article, out):
        out.write("\n\n\\chapter{" + article["name"] +"}")
        self(article["content"], out)

    def export_paragraph(self, paragraph, out):
        out.write("\n\n")
        self(paragraph["content"], out)

    def export_text(self, text, out):
        self(text["data"], out)

    def export_inlinemath(self, inlinemath, out):
        out.write("$")
        self(inlinemath["formula"], out)
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
        columns_with_delimiters = list(intersperse(" & ", tr["content"]))
        self(columns_with_delimiters, out)
        out.write(" \\\\ \n")

    def export_td(self, td, out):
        self(td["content"], out)

    def export_th(self, th, out):
        self(th["content"], out)
