from typing import List, Dict

# MISSING:
#   videos                  -> simply files
#   reuse chapter contents  -> task of parser
#   CC-BY 4.0               -> no editing/hyperlinks on print pages
#   review                  -> also impractible on print pages ;)

DEFINITION_LIST = {...}

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
