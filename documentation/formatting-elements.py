from enum import Enum

# Representation of the format elements in
# https://de.wikibooks.org/wiki/Mathe_f%C3%BCr_Nicht-Freaks:_Formatierung_von_Kapiteln
class Format(Enum):
    PlainText = 0
    TextLine = 1
    Paragraph = 2
    Heading = 3
    Bold = 4
    Italic = 5
    UnorderedList = 6
    OrderedList = 7
    ComplexList = 8
    DefinitionList = 9
    EmphasizedParagraph = 10
    Image = 11
    File = 12
    Gallery = 13
    Definition = 14
    Example = 15
    Theorem = 16
    Exercise = 17
    Hint = 18
    Warning = 19
    Proof = 20
    AlternativeProof = 21
    ProofSummary = 22
    Solution = 23
    SolutionExplanation = 24
    Question = 25
    ProofStep = 26
    CaseDiscrimination = 27
    MathInline = 28
    Formula = 29
    Hyperlink = 30
    Reference = 31
# MISSING:
#   videos                  -> simply files
#   reuse chapter contents  -> task of parser
#   CC-BY 4.0               -> no editing/hyperlinks on print pages
#   review                  -> also impractible on print pages ;)

# A piece of plain text without format modifiers
# contents:str  just the plain text
plain_text = {"type": Format.PlainText, "contents": ""}

# A line of text (line continuation applied)
# It was terminated either by a double line break (end of paragraph) or in the
# means of a semantic block
# contents:List[Dict]   all contained text elements
text_line = {"type": Format.TextLine, "contents": []}

# A paragraph (a logical line of text separated by a double line break, but
# also containing semantic elements)
# contents:List[Dict]   a list of the text objects and semantic elements the
#                       paragraph is made of
paragraph = {"type": Format.Paragraph, "contents": []} 

# A heading
# Although it may only be at the start of a paragraph, we do not treat is
# specially and simply put it into the "contents" of its paragraph, because
# there are many paragraphs without a heading
# depth:int     the level of the heading in the chapter hierarchy
# contents:Dict the actual heading as a TextLine
# anchor:str    identifier to reference it from elsewhere
heading = {"type": Format.Heading, "depth": 0, "contents": {}, "anchor": ""}

# Bold text
# contents:str    text that should be displayed in bold
bold = {"type": Format.Bold, "contents": ""}

# Italic text
# contents:str    text that should be displayed in italic
bold = {"type": Format.Italic, "contents": ""}

# An unordered list
# contents:List[Dict]   the list elements, each as a TextLine 
unordered_list = {"type": Format.UnorderedList, "contents": []}

# An ordered list
# contents:List[Dict]   the list elements, each as a TextLine 
unordered_list = {"type": Format.OrderedList, "contents": []}

# A complex list (Vorlage)
# ordererd:bool         Ordered list or not
# contents:List[Dict]   the list elements, each as a TextLine 
unordered_list = {"type": Format.OrderedList, "ordered": True, "contents": []}

# A definition list
# contents:List[Dict]   the list elements, each as a Dict of:
#   term:str                defined term as plain text
#   definition:Dict         definition of the term as a TextLine
complex_list = {"type": Format.DefinitionList, "contents": []}

# An emphasized paragraph
# OMITTED AS I COULD NOT FIND ANY IN THE WHOLE BOOK

# An embedded image
# This only contains the description, the image itself must be downloaded
# either when this node is processed (bad, because it is an IO action) or
# afterwards
# file:str          name of the image file
# description:str   descriptive text (plain)
image = {"type": Format.Image, "file": "", "description": ""}

# An embedded file
# This only contains the description, the file itself must be downloaded
# either when this node is processed (bad, because it is an IO action) or
# afterwards
# file:str          name of the file
# description:str   descriptive text (plain)
# thumbnail:bool    whether only a thumbnail shall be displayed
# centered:bool     whether the file is centered
# size:str          the size (format: Xpx, X in N)
file = {"type": Format.File, "file": "", "description": "", "thumbnail":
       False, "centered": False, "size": "500px"}

# An embedded image gallery
# This only contains the description, the files theirselves must be downloaded
# either when this node is processed (bad, because it is an IO action) or
# afterwards
# widths:int            width for each single image
# heights:int           height for each single image
# contents:List[Dict]   elements of the gallery, each as a Dict of:
#   file:str                name of the image file
#   description:str         descriptive text (plain)
file = {"type": Format.Gallery, "widhts": 500, "heights": 500, "contents": []}

# A definition
# title:Dict    the defined term as a TextLine
# contents:Dict the definition text as a TextLine
definition = {"type": Format.Defintion, "title": {}, "contents": {}}

# An example
# title:Dict    the term for which an example is given as a TextLine
# contents:Dict the example text as a TextLine
example = {"type": Format.Example, "title": {}, "contents": {}}

# A theorem
# title:Dict        the name of the theorem as a TextLine
# contents:Dict     the theorem text as a TextLine
# explanation:Dict  an explanation of the theorem as a TextLine (optional)
# example:Dict      an example for the theorem as a TextLine (optional)
# solution:Dict     how to get to the proof as a TextLine (optional)
# summary:Dict      a proof summary as a TextLine (optional)
# proof:Dict        the proof of the theorem as a TextLine (optional)
theorem = {"type": Format.Theorem, "title": {}, "contents": {}, "explanation":
           {}, "example": {}, "solution": {}, "summary": {}, "proof": {}}

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
