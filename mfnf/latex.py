import collections

class LatexExporter:

    def export_book(self, book, out):
        out.write(book["name"])

    def export_str(self, text, out):
        out.write(text)

    def export_list(self, lst, out):
        for element in lst:
            self(element)

    def notimplemented(self, obj, out):
        print("Not Implemented!")

    def export_dict(self, obj, out):
        try:
            getattr(self, "export_" + obj["type"])(obj, out)
        except AttributeError:
            self.notimplemented(obj, out)

    def __call__(self, obj, out):
        if isinstance(obj, str):
            self.export_str(obj, out)
        elif isinstance(obj, collections.abc.Sequence):
            self.export_list(obj, out)
        elif isinstance(obj, collections.abc.Mapping):
            self.export_dict(obj, out)
