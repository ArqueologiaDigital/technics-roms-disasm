#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""data_stats.py -- what lane mn10300-data's generator rules change, per gen_data_s.py profile.

QUESTION IT ANSWERS
  "For one gen_data_s.py profile (941, sp7001, b935, b893, kn6000, kn6500, kn2400, hdsx3), with the
   lane's rules off (the generator as main c240d1c0b had it) and on (all, one alone with --only R, all
   but one with --drop R): how many bytes of the data region are typed, how many reader-row pieces /
   bytes and opaque pieces / bytes are left, how many record fields are still named only by their
   offset although a reader touches them, how many lines change, and which bytes are typed in the off
   run only (does a rule lose typed coverage)?"

  The rules are the lane's keys of gen_data_s.FEATURES (RULES below); GEN_DATA_S_OFF (a comma list)
  turns them off.  The "off" run reproduces main's committed sources (checked: `diff -r` of the off
  run's data_*.s against <tree>/src/.../data/ for each profile, kn7000/notes/mn10300-data/README.md).

HOW
  ../mn10300-rest-probes/rest_stats.py's method with this lane's rules: two generator processes write
  <scratch>/<profile>_off/ and <scratch>/<profile>_<tag>/; ../mn10300-typer-probes/typer_stats.py reads
  typed bytes (the generator's items), reader rows and opaque pieces (the `# census: opaque` headers and
  the `.incbin_range` after them) and line churn; ../mn10300-formats-probes/field_names_census.py the
  offset-named fields.  --brief prints one Markdown row (for the notes' table).

COMMITTED SOURCES (--dirs BEFORE AFTER)
  The same figures from two data directories as they are (no generator run): typed bytes are the sizes
  labels.sym gives the typed items (its third column; it sums to the generator's own "typed" figure),
  the bytes typed in BEFORE only are the labelled items' ranges compared, the rest is as above.  BEFORE is
  main's data directory (e.g. a `git archive c240d1c0b` of it), AFTER this branch's.

RUN (from the repository root; the KN7000 profiles need kn7000/build/*.labels, i.e. one verify run)
  python3 kn7000/notes/mn10300-data-probes/data_stats.py --profile 941 --scratch ~/compartilhado/tmp/<dir>
  python3 kn7000/notes/mn10300-data-probes/data_stats.py --profile kn2400 --scratch DIR --only widget_vars
  python3 kn7000/notes/mn10300-data-probes/data_stats.py --dirs MAIN/kn2400/src/program/data kn2400/src/program/data --brief
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

RULES = ("widget_vars", "maps128", "sentinel_lists", "chord_voicings", "index_bounds", "fx_presets", "table_terminators",
         "msg_readers", "count_notes", "doubles_text", "table_ptrs", "sib_fieldret", "sib_loopslots", "sib_reloadbound", "sib_setlb")


def sym_items(d):
    """{file offset stand-in (the CPU address): (size, kind, label)} of the typed items labels.sym lists."""
    out = {}
    for ln in open(os.path.join(d, "labels.sym"), encoding="latin-1"):
        if ln.startswith(";"):
            continue
        a, n, sz = ln.split()
        if int(sz):
            out[int(a, 16)] = (int(sz), "item", n)
    return out


def dirs_mode(a):
    before, after = a.dirs
    res = [(sym_items(d),) + TS.text_stats(d) + (FN.census(d),) for d in (before, after)]
    (io, ro, qo, bo, fo), (in_, rn, qn, bn, fn) = res
    co, cn = TS.cover(io), TS.cover(in_)
    lost = sorted(set(co) - set(cn))
    tro = [sum(ro[k][0] for k in ro), sum(ro[k][1] for k in ro)]
    trn = [sum(rn[k][0] for k in rn), sum(rn[k][1] for k in rn)]
    name = a.name or after
    if a.brief:
        print(f"| {name} | {len(co):,} | {len(cn):,} | {len(cn) - len(co):+,} | {tro[0]:,} / {tro[1]:,} | "
              f"{trn[0]:,} / {trn[1]:,} | {sum(qo.values()):,} / {sum(bo.values()):,} | "
              f"{sum(qn.values()):,} / {sum(bn.values()):,} | {fo[2]:,} | {fn[2]:,} | {len(lost):,} |")
    else:
        print(f"{name}: typed {len(co):,} -> {len(cn):,}; reader rows {tro[0]:,} / {tro[1]:,} -> {trn[0]:,} / "
              f"{trn[1]:,}; opaque {sum(qo.values()):,} / {sum(bo.values()):,} -> {sum(qn.values()):,} / "
              f"{sum(bn.values()):,}; offset-named with a reader {fo[2]:,} -> {fn[2]:,}; typed before only {len(lost):,}")
        seen = set()
        for i in lost:
            if co[i][2] not in seen and len(seen) < 30:
                seen.add(co[i][2])
                print(f"    {co[i][1]} (0x{co[i][2]:08X})")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dirs", nargs=2, metavar=("BEFORE", "AFTER"), help="compare two committed data directories")
    ap.add_argument("--name", help="(--dirs) the row's name")
    ap.add_argument("--profile")
    ap.add_argument("--scratch")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--only", choices=RULES, help="the 'on' run has this rule alone")
    g.add_argument("--drop", choices=RULES, help="the 'on' run has every rule but this one")
    ap.add_argument("--fresh", action="store_true", help="re-run the cached off run too")
    ap.add_argument("--brief", action="store_true", help="one Markdown table row")
    ap.add_argument("--one", nargs=2, help=argparse.SUPPRESS)
    a = ap.parse_args()
    if a.dirs:
        return dirs_mode(a)
    if not (a.profile and a.scratch):
        ap.error("--profile and --scratch (or --dirs)")
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
        if os.path.exists(out + ".pkl") and name == "off" and not a.fresh:
            continue
        procs.append(subprocess.Popen([sys.executable, os.path.abspath(__file__), "--profile", a.profile,
                                       "--scratch", scratch, "--one", ",".join(off), out],
                                      stdout=subprocess.DEVNULL))
    if any(p.wait() for p in procs):
        sys.exit("data_stats: a generator run failed")
    res = {}
    for name in runs:
        out = os.path.join(scratch, f"{a.profile}_{name}")
        res[name] = (pickle.load(open(out + ".pkl", "rb")),) + TS.text_stats(out) + (FN.census(out),)
    (io, ro, qo, bo, fo), (in_, rn, qn, bn, fn) = res["off"], res[tag]
    co, cn = TS.cover(io), TS.cover(in_)
    tro = [sum(ro[k][0] for k in ro), sum(ro[k][1] for k in ro)]
    trn = [sum(rn[k][0] for k in rn), sum(rn[k][1] for k in rn)]
    lost = sorted(set(co) - set(cn))
    if a.brief:
        print(f"| {a.profile} | {len(co):,} | {len(cn):,} | {len(cn) - len(co):+,} | {tro[0]:,} / {tro[1]:,} | "
              f"{trn[0]:,} / {trn[1]:,} | {sum(qo.values()):,} / {sum(bo.values()):,} | "
              f"{sum(qn.values()):,} / {sum(bn.values()):,} | {fo[2]:,} | {fn[2]:,} | {len(lost):,} |")
        return 0
    fmt = lambda c: f"{c[0]:,} / {c[1]:,}"   # noqa: E731
    print(f"{a.profile} ({tag} vs off): typed bytes {len(co):,} -> {len(cn):,} ({len(cn) - len(co):+,})")
    print(f"  reader rows all      {fmt(tro)} -> {fmt(trn)}")
    print(f"  opaque               {fmt([sum(qo.values()), sum(bo.values())])} -> "
          f"{fmt([sum(qn.values()), sum(bn.values())])}")
    print(f"  record fields        {fo[1]:,} -> {fn[1]:,} (kinds {fo[0]:,} -> {fn[0]:,})")
    print(f"  offset-named with a reader {fo[2]:,} -> {fn[2]:,}; no reader {fo[3]:,} -> {fn[3]:,}")
    print(f"  line churn           {TS.churn(os.path.join(scratch, f'{a.profile}_off'), os.path.join(scratch, f'{a.profile}_{tag}')):,}")
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
