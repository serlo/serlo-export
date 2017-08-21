"""Module with utility functions."""

def lookup(obj, *path):
    """Lookups repeatedly the items in the list `path` of the object `obj`. In
    case any `IndexError` or `KeyError` is thrown, `None` is returned. For
    example the call `safe_lookup(obj, "a", 0, "b")` returns
    `obj["a"][0]["b"]` when it exists and `None` otherwise."""
    try:
        result = obj

        for key in path:
            result = result[key]

        return result
    except (IndexError, KeyError, TypeError):
        return None

def remove_prefix(text, prefix):
    """Removes the prefix `prefix` from string `text` in case it is present."""
    return text[len(prefix):] if text.startswith(prefix) else text

def add_dict(dct1, dct2):
    """Returns a new dictionaries where the content of the dictionaries `dct1`
    and `dct2` are merged together."""
    result = dct1.copy()
    result.update(dct2)

    return result
