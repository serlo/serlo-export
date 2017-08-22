from typing import List, Dict

# MISSING:
#   videos                  -> simply files
#   reuse chapter contents  -> task of parser
#   CC-BY 4.0               -> no editing/hyperlinks on print pages
#   review                  -> also impractible on print pages ;)

# Plain text without format modifiers stored in attribute `data`
TEXT = {"type": "text", "data": str}

PARAGRAPH = {"type": "paragraph", "children": List[Dict]}

HEADING = {
    "type": "header",
    "depth": int,
    "anchor": str,
    "children": List[Dict] # title of heading
}

LIST = {
    "type": "list",
    "ordered": bool,
    "children": List[Dict]
}

IMAGE = {
    "type": "image",
    "caption": List[Dict],
    "name": str,           # Name of image on Wikimedia Commons
    "url": str,
    "thumbnail": bool      # wether the image is included in thumbnail mode
}

# \begin{align} ... \end{align} in LaTeX
EQUATION = {"type": "equation", "formula": str}

TABLE_ROW = {"type": "tr", "children": List[Dict]}

TABLE_CELL = {"type": "td", "children": List[Dict]}

TABLE_HEADER_CELL = {"type": "th", "children": List[Dict]}

TABLE = {"type": "table", "children": List[TABLE_ROW]}

BOLD_TEXT = {"type": "b", "children": List[Dict]}

ITALIC_TEXT = {"type": "i", "children": List[Dict]}

INLINE_MATH = {"type": "inlinemath", "formula": str}

DEFINITION_LIST = {...}

GALLERY = {"type": "gallery", "widhts": int, "heights": int, "children": []}

GALLERY_ITEM = {"type": "galleryitem" ...}

DEFINITION = {"type": "defintion", "title": str, "definition": List[Dict]}

EXAMPLE = {"type": "example", "title": str, "example": List[Dict]}

THEOREM = {
    "type": "theorem",
    "title": str,
    "theorem": List[Dict],
    "explanation": List[Dict],
    "example": List[Dict],
    "summary": List[Dict],
    "proof": List[Dict],
    "proof2": List[Dict]
}

# An exercise
# title:Dict        the title of the task as a TextLine
# contents:Dict     the task itself as a TextLine
# explanation:Dict  an explanation of the task as a TextLine (optional)
# solution:Dict     how to get to the proof as a TextLine (optional)
# summary:Dict      a proof summary as a TextLine (optional)
# proof:Dict        the proof requesed in the task as a TextLine (optional)
exercise = {"type": Format.Exercise, "title": {}, "contents": {}, "explanation":
            {}, "solution": {}, "summary": {}, "proof": {}}

# A hint
# contents:Dict the hint as a TextLine
hint = {"type": Format.Hint, "contents": {}}

# A warning
# contents:Dict the warning as a TextLine
warning = {"type": Format.Warning, "contents": {}}

# A proof
# title:Dict    the title of the proof as a TextLine
# contents:Dict the proof as a TextLine
proof = {"type": Format.Proof, "contents": {}}

# An alternative proof
# Must this be a separate template?
# title:str     the title of the proof
# contents:Dict the proof as a TextLine
alternative_proof = {"type": Format.AlternativeProof, "title": {},
                     "contents": {}}

# A proof summary
# title:str     the title of the proof
# contents:Dict the proof as a TextLine
proof_summary = {"type": Format.ProofSummary, "title": {},
                 "contents": {}}

# A solution to an exercise
# title:str     the title of the solution
# contents:Dict the solution as a TextLine
solution = {"type": Format.Solution, "title": {},
            "contents": {}}

# A detailed explanation of a solution
# title:str     the title of the solution explanation
# contents:Dict the solution explanation as a TextLine
solution_explanation = {"type": Format.SolutionExplanation, "title": {},
                        "contents": {}}

# A question
# type:str      the question type ("Verständnisfrage") (optional)
# answer:Dict   the answer as a TextLine
# indent:bool   whether list answers should be indented
question = {"type": Format.Question, "type": "", "answer": {}, "indent": True}

# A step in a proof
# name:str      the name of the proof step
# target:Dict   what is proved in this step as a TextLine
# contents:Dict the proof step as a TextLine
proof_step = {"type": Format.ProofStep, "name": "", "target": {}, "contents": {}}

# A case discrimination (e.g. in a proof)
# contents:List[Dict]   the individual cases, each as Dict of
#   case:Dict   what the case is as a TextLine
#   proof:Dict  proof of the case as a TextLine
case_discrimination = {"type": Format.CaseDiscrimination, "contents": []}

# Inline math code (Tex)
# contents:str  the Tex code
math_inline = {"type": Format.MathInline, "contents": ""}

# A piece of math code in its own paragraph
# contents:str  the Tex code
formula = {"type": Format.Formula, "contents": ""}

# A reference to an anchor (e.g. next to a heading) or an exercise
# page: str     the page to which is linked
# anchor:str    the referenced anchor at the page
# contents:str  the text displayed in place of the hyperlink
#               for the print version, we might want to skip this and display a
#               number, e.g. "Exercise 1.2.3"
reference = {"type": Format.Reference, "page": "", "anchor": "", "contents": ""}
