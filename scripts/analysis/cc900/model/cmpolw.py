#!/usr/bin/env python3
"""cmpordl_ast.py -- the cc900 oracle's code for the functions of probe cmpordl.c (corpus/probes/cmpordl.c, oracle
run 2026-11-10-16-micro-cmpordl: long and char compares, cl_* and cc_*) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    python3 cmpordl_ast.py --check [SET] [--show N] [--only REGEX]   (model directory on sys.path)

The engine is cmpord_ast.py (same directory / module path), which answers the int family of cmpord.c; this module is
that engine restricted to the long and char families.  The rules are in cmpord-FAMILIES.md.
"""
import cmpow as E

SETS = E.SETS
FAMILIES = 'lc'
PROBE, ORACLE = E.PROBES['cmpordl']


def whole(f, set='none'):
    return E.whole(f, set, FAMILIES)


def check(s, show=0, only=None):
    return E.check('cmpordl', s, show, only, FAMILIES)


if __name__ == '__main__':
    E.main('cmpordl', FAMILIES)
