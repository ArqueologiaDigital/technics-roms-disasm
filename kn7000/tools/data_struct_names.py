# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""data_struct_names.py -- names for the record kinds and fields tools/data_structs.py finds.

Keyed by the array's label (the same in every program build: the labels port)
and its stride.  Each entry: (kind name, {field offset: field name}), with the
evidence for each name in the comment above it.  A field not named here keeps
its offset name (f<off>, p<off>, s<off>, x<off>).
"""

NAMES = {
}


def lookup(label, stride):
    e = NAMES.get((label, stride)) or NAMES.get(label)
    if e is None:
        return None, {}
    return e
