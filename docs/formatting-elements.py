from typing import List, Dict

# MISSING:
#   videos                  -> simply files
#   reuse chapter contents  -> task of parser
#   CC-BY 4.0               -> no editing/hyperlinks on print pages
#   review                  -> also impractible on print pages ;)

# \begin{align} ... \end{align} in LaTeX
EQUATION = {"type": "equation", "formula": str}

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
