from typing import List, Dict

# MISSING:
#   videos                  -> simply files
#   reuse chapter contents  -> task of parser
#   CC-BY 4.0               -> no editing/hyperlinks on print pages
#   review                  -> also impractible on print pages ;)

DEFINITION_LIST = {...}

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
