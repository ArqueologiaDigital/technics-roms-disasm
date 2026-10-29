"""floppy/kn7000/formats.py -- the SX-KN7000 file-format describers: floppy/tools/kd/kn_formats.py."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "tools", "kd"))
import kn_formats  # noqa: E402


def describe(ctx):
    return kn_formats.describe(ctx, "kn7000")
