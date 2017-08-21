"""Module with utility functions."""

def remove_prefix(text, prefix):
    """Removes the prefix `prefix` from string `text` in case it is present."""
    return text[len(prefix):] if text.startswith(prefix) else text

def add_dict(dct1, dct2):
    """Returns a new dictionaries where the content of the dictionaries `dct1`
    and `dct2` are merged together."""
    result = dct1.copy()
    result.update(dct2)

    return result
