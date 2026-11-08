#!/usr/bin/env python3
"""spell_named_records.py -- step 5 of add_kn5000_ram_names.py (operands inside a `[N bytes]` record become
RECORD+offset) for chosen records of any tree, v6 / v5 included.

JOB IT DOES
  port_ram_names.py gives v6 / v5 a record's base name but not its RECORD+k spellings.  This runs
  add_kn5000_ram_names.spell_structs on TREE with only the named records' .equ lines visible, so no other
  sized record of the tree is respelled.  A number becomes a name of the same value: the image cannot change
  (make gate checks it).  Lane kn5000-naka3 (2026-11-07) used it for AUDIO_STATE / AUDIO_STATE_SENT.
USAGE
  python3 scripts/tools/spell_named_records.py v6 AUDIO_STATE AUDIO_STATE_SENT
"""
import importlib.util
import os
import sys

tree, names = sys.argv[1], sys.argv[2:]
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('add_kn5000_ram_names', os.path.join(here, 'add_kn5000_ram_names.py'))
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)
orig = A.read


def read(f):
    L = orig(f)
    if f == A.path(tree):
        return [l for l in L if any(('.equ %s,' % n) in l for n in names)]
    return L


A.read = read
print('%s: %d operands spelled RECORD+offset (%s)' % (tree, A.spell_structs(tree), ', '.join(names)))
