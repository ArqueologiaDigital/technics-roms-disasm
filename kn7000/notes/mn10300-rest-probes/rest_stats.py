#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""rest_stats.py -- what lane mn10300-rest's generator rules change, per gen_data_s.py profile.

QUESTION IT ANSWERS
  "For one gen_data_s.py profile (941, sp7001, b935, b893, kn6000, kn6500, kn2400, hdsx3), with the
   lane's rules off (the generator as main had it) and on (all of them, or one alone with --only R,
   or all but one with --drop R): how many bytes of the data region are typed, how many reader-row
   pieces / bytes and opaque pieces / bytes are left, how many record fields are still named only by
   their offset although a reader touches them, how many lines of the generated sources change, and
   which bytes are typed in one run only (does a rule lose coverage)?"

  The rules are the lane's keys of gen_data_s.FEATURES (top_tested, fld_slots, the typing passes the
  lane added) and the field-use switches of tools/data_field_uses.py (field_pos, field_slots,
  field_bra, field_keyloop, field_merge, field_screen); GEN_DATA_S_OFF (a comma list) turns them off.
  The "off" run must reproduce main's committed sources byte for byte (checked for 941 at 43242446d).

HOW
  Runs tools/gen_data_s.py in two processes (the "off" run is cached as <scratch>/<profile>_off.pkl),
  each writing its sources into <scratch>/<profile>_<run>/, and reads them with
  ../mn10300-typer-probes/typer_stats.py's helpers (typed bytes from the generator's items; reader rows
  and opaque pieces from the headers it writes; line churn by diff) and
  ../mn10300-formats-probes/field_names_census.py (offset-named fields with a reader, in
  data_structs.inc).  Needs the previous build's labels (kn7000/build/*.labels, from a verify run).

RUN (from the repository root; a KN7000 profile takes about 2 minutes a run)
  python3 kn7000/notes/mn10300-rest-probes/rest_stats.py --profile 941 --scratch ~/compartilhado/tmp/<dir>
  python3 kn7000/notes/mn10300-rest-probes/rest_stats.py --profile kn6000 --scratch DIR --only field_slots
"""
import argparse
import os
import pickle
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "mn10300-typer-probes"))
sys.path.insert(0, os.path.join(HERE, "..", "mn10300-formats-probes"))
import typer_stats as TS          # noqa: E402
import field_names_census as FN   # noqa: E402

RULES = ("top_tested", "fld_slots", "fx_streams", "field_pos", "field_slots", "field_bra", "field_keyloop",
         "field_merge", "field_screen")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--profile", required=True)
    ap.add_argument("--scratch", required=True)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--only", choices=RULES, help="the 'on' run has this rule alone")
    g.add_argument("--drop", choices=RULES, help="the 'on' run has every rule but this one")
    ap.add_argument("--one", nargs=2, help=argparse.SUPPRESS)
    a = ap.parse_args()
    scratch = os.path.abspath(os.path.expanduser(a.scratch))
    if a.one:
        TS.run_one(a.profile, [x for x in a.one[0].split(",") if x], a.one[1])
        return 0
    on_off = [r for r in RULES if r != a.only] if a.only else [a.drop] if a.drop else []
    tag = f"only_{a.only}" if a.only else f"drop_{a.drop}" if a.drop else "on"
    runs = {"off": list(RULES), tag: on_off}
    procs = []
    for name, off in runs.items():
        out = os.path.join(scratch, f"{a.profile}_{name}")
        if os.path.exists(out + ".pkl") and name == "off":
            continue
        procs.append(subprocess.Popen([sys.executable, os.path.abspath(__file__), "--profile", a.profile,
                                       "--scratch", scratch, "--one", ",".join(off), out],
                                      stdout=subprocess.DEVNULL))
    if any(p.wait() for p in procs):
        sys.exit("rest_stats: a generator run failed")
    res = {}
    for name in runs:
        out = os.path.join(scratch, f"{a.profile}_{name}")
        res[name] = (pickle.load(open(out + ".pkl", "rb")),) + TS.text_stats(out) + (FN.census(out),)
    (io, ro, qo, bo, fo), (in_, rn, qn, bn, fn) = res["off"], res[tag]
    co, cn = TS.cover(io), TS.cover(in_)
    fmt = lambda c: f"{c[0]:,} / {c[1]:,}"   # noqa: E731
    print(f"{a.profile} ({tag} vs off): typed bytes {len(co):,} -> {len(cn):,} ({len(cn) - len(co):+,})")
    tro = [sum(ro[k][0] for k in ro), sum(ro[k][1] for k in ro)]
    trn = [sum(rn[k][0] for k in rn), sum(rn[k][1] for k in rn)]
    print(f"  reader rows all      {fmt(tro)} -> {fmt(trn)}")
    print(f"  opaque               {fmt([sum(qo.values()), sum(bo.values())])} -> "
          f"{fmt([sum(qn.values()), sum(bn.values())])}")
    print(f"  record fields        {fo[1]:,} -> {fn[1]:,} (kinds {fo[0]:,} -> {fn[0]:,})")
    print(f"  offset-named with a reader {fo[2]:,} -> {fn[2]:,}; no reader {fo[3]:,} -> {fn[3]:,}")
    print(f"  line churn           {TS.churn(os.path.join(scratch, f'{a.profile}_off'), os.path.join(scratch, f'{a.profile}_{tag}')):,}")
    lost = sorted(set(co) - set(cn))
    print(f"  typed in the off run only: {len(lost):,} bytes")
    seen = set()
    for i in lost:
        k, lab, o = co[i]
        if o not in seen:
            seen.add(o)
            print(f"    {lab or k} (item at file offset 0x{o:X}, {k})")
            if len(seen) >= 30:
                break
    return 0


if __name__ == "__main__":
    sys.exit(main())
