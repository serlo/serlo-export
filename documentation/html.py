"""Documentation of the JSON representing HTML."""

# an html element
ELEMENT = {
  "type": "element",
  "name": "",        # name of HTML tag
  "attrs": {},       # dictionary of type dice[str,str] for tag attrbutes
  "children": []     # list of children (also HTML elements)
}

# Attributes of an HTML element
ATTRIBUTES = {
    "type": "attrs",
    "...": "..."
}
