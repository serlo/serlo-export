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
    "solution_process": List[Dict]
    "proof": List[Dict],
    "alternative_proof": List[Dict]
}

PROOF = {
    "type": "proof",
    "title": str,
    "proof": List[Dict]
}

ALTERNATIVE_PROOF = {
    "type": "alternative_proof",
    "title": str,
    "alternative_proof": List[Dict]
}

PROOF_SUMMARY = {
    "type": "proof_summary",
    "title": str,
    "proof_summary": List[Dict]
}

SOLUTION_PROCESS = {
    "type": "solution_process",
    "title": str,
    "solution_process": List[Dict]
}

SOLUTION = {
    "type": "solution",
    "title": str,
    "solution": List[Dict]
}

EXERCISE = {
    "type": "exercise",
    "title": str,
    "explanation": List[Dict],
    "exercise": List[Dict],
    "solution": List[Dict],
    "summary": List[Dict],
    "solution_process": List[Dict]
    "proof": List[Dict],
    "alternative_proof": List[Dict]
}

HINT = {
    "type": "hint",
    "hint": List[Dict]
}

WARNING = {
    "type": "warning",
    "warning": List[Dict]
}

QUESTION = {
    "type": "question",
    "question": List[Dict],
    "answer": List[Dict]
}

PROOF_STEP = {
    "type": "proof_step",
    "target": List[Dict],
    "name": str,
    "children": List[Dict]
}

CASE_DISCRIMINATION = {...}

REFERENCE = {...}
