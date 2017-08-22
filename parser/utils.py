"""Module with utility functions."""

import hashlib
import collections
import shelve

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
    except (IndexError, KeyError):
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

def sha256(text):
    """Returns SHA256 of the string `text`."""
    return hashlib.sha256(text.encode("utf8")).hexdigest()

def stablehash(obj):
    """Returns an unique hash of object `obj`."""
    try:
        return obj._stablehash_()
    except AttributeError:
        if isinstance(obj, str):
            return sha256(obj)
        elif isinstance(obj, collections.abc.Sequence):
            return sha256("|".join([stablehash(x) for x in obj]))
        elif isinstance(obj, collections.abc.Mapping):
            return stablehash(["<" + stablehash(k) + ";" + stablehash(v) + ">"
                               for k, v in obj.items()])
        else:
            raise NotImplementedError()

class CachedFunction:

    def __init__(self, file_name):
        self.db = shelve.open(file_name, "c", writeback=True)

    def __call__(self, func):
        def new_func(*args, **kwargs):
            key = stablehash([func.__name__, args, kwargs])

            if key in self.db:
                return self.db[key]
            else:
                result = func(*args, **kwargs)

                self.db[key] = result
                self.db.sync()

                return result

        return new_func

cached_function = CachedFunction(".cache.db")
