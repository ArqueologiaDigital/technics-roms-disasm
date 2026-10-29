#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""sigmap.py -- which KN7000 propdata type character is each KN6000 / KN6500 one?

QUESTION ANSWERED
  "The MILK classes describe their fields with one type character each (propdata).
   Do the SX-KN6000 (or SX-KN6500) and the KN7000 use the same alphabet?"  For every
   class name both firmwares define, it pairs the type characters of the fields with
   the same name, and counts each (KN6xxx char, KN7000 char) pair.  The answer backs
   milk_model.SIGMAP_NAKA: every KN6xxx character maps to one KN7000 character only.

SIGNAL READ
  The class tables the start-up code registers (milk_model.Model, raw propdata
  strings: Klass.propdata_raw), of KN7000 program 941 and of the sibling.

RUN (from the repository root; needs kn7000/baserom/kn7000_program.rom and the
sibling's baserom, i.e. `make -C kn7000 baserom` and `make -C kn6000 baserom`)
    python3 kn6000/notes/data-region-probes/sigmap.py [kn6000|kn6500]

RESULT (2026-10-29): kn6000, 591 field pairs, one KN7000 character per KN6000
character: ] -> \\, ^ -> ], _ -> ^, m -> l, n -> m, r -> q, s -> r, t -> s, u -> t,
v -> u, w -> v, every other character itself.
"""
import collections
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
import gen_data_s as G   # noqa: E402
import milk_model as MM  # noqa: E402


def model(profile):
    G.configure(profile)
    return MM.Model(rom_path=os.path.join(G.KN7, G.P["rom"]), src_glob=G.code_glob(),
                    sym_paths=[os.path.join(G.KN7, f) for f in G.P["syms"]],
                    label_paths=[os.path.join(G.KN7, G.OUTDIR, "labels.sym"),
                                 os.path.join(G.KN7, G.OUTDIR, "gui_code_ids.inc")])


def main():
    sib = sys.argv[1] if len(sys.argv) > 1 else "kn6000"
    m6 = model(sib)
    m7 = model("941")
    pairs = collections.defaultdict(collections.Counter)
    n = 0
    for k6 in m6.classes.values():
        k7 = m7.class_by_name.get(k6.name)
        if not k7:
            continue
        f7 = dict(zip(k7.propnames, k7.propdata_raw))
        for c, nm in zip(k6.propdata_raw, k6.propnames):
            if nm and nm in f7:
                pairs[c][f7[nm]] += 1
                n += 1
    print(f"{sib}: {n} field pairs")
    bad = 0
    for c in sorted(pairs):
        print(f"  {c!r} -> " + ", ".join(f"{k!r} x{v}" for k, v in pairs[c].most_common()))
        bad += len(pairs[c]) > 1
        if pairs[c].most_common(1)[0][0] != MM.SIGMAP_NAKA.get(c, c):
            print(f"    differs from SIGMAP_NAKA ({MM.SIGMAP_NAKA.get(c, c)!r})")
            bad += 1
    print("one way each, as SIGMAP_NAKA says" if not bad else f"{bad} characters disagree")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
