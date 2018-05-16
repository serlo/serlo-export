"""Unescape a make-escaped string"""

from lib.utils import unquote_filename
import argparse

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("input")
    args = arg_parser.parse_args()
    print(unquote_filename(args.input))
