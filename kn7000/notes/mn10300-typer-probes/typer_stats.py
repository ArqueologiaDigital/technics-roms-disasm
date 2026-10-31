#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""typer_stats.py -- what the typer and walk rules of lane mn10300-typer change, per rule and in all.

QUESTION IT ANSWERS
  "For one gen_data_s.py profile (941, sp7001, b935, b893, kn6000, kn6500, kn2400, hdsx3), run with the
   lane's rules off (the generator as before the lane) and on: how many data-region bytes are typed
   items, how many pieces / bytes are reader rows and opaque pieces, how many lines of the generated
   sources change, and which bytes are typed in one run only (does a rule lose typed coverage)?"
  The rules are gen_data_s.FEATURES: ptr_starts, array_end, mem_ptrs, loop_index, step_arrays,
  deep_records.  --only R turns on R alone, --drop R all but R, against the same "off" run, so each
  rule's own effect and line churn can be read separately.

HOW
  Runs tools/gen_data_s.py in separate processes with the environment variable GEN_DATA_S_OFF naming
  the rules turned off (gen_data_s.py reads it), writing each run's sources into <scratch>/<profile>_<run>/
  (never into the tree), and pickles the typed items' byte ranges.  The row and opaque counts are read
  from the written data_NN.s files, by the headers gen_data_s writes:
    reader rows   "\\t# N bytes read by ...", "\\t# N bytes the code takes the address of: ...",
                  "\\t# a string, N bytes with its pad, read by ..." (as callee_walk_stats.py)
    opaque        a "# census: opaque -- <kind>: ..." line, and the `.incbin_range "...", LO, HI` after it
  Line churn is `diff` of the two runs' data_NN.s, data_structs.inc and labels.sym (lines added + removed).

RUN (from the repository root; the scratch directory must be outside the repository; a run takes what
     gen_data_s.py takes, about a minute for a KN7000 build)
  python3 kn7000/notes/mn10300-typer-probes/typer_stats.py --profile 941 --scratch ~/compartilhado/tmp/x
  python3 kn7000/notes/mn10300-typer-probes/typer_stats.py --profile 941 --scratch DIR --only array_end
  python3 kn7000/notes/mn10300-typer-probes/typer_stats.py --profile 941 --scratch DIR --drop loop_index
"""
import argparse, collections, os, pickle, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.normpath(os.path.join(HERE, "..", "..", "tools"))
RULES = ("ptr_starts", "array_end", "mem_ptrs", "loop_index", "step_arrays", "deep_records")
ROWS = [("read", rb"\t# (\d+) bytes read by .*the read fields at their widths"),
        ("address", rb"\t# (\d+) bytes the code takes the address of: "),
        ("string", rb"\t# a string, (\d+) bytes with its pad, read by ")]
OPAQUE = re.compile(rb"^# census: opaque -- ([\w-]+)")
RANGE = re.compile(rb'^\.incbin_range\s+"[^"]+",\s*(0x[0-9A-Fa-f]+|\d+),\s*(0x[0-9A-Fa-f]+|\d+)')


def run_one(profile, off, out):
    os.environ["GEN_DATA_S_OFF"] = ",".join(off)
    sys.path.insert(0, TOOLS)
    import gen_data_s as G
    os.chdir(G.KN7_DIR)
    G.configure(profile)
    g = G.Gen()
    os.makedirs(out, exist_ok=True)
    g.run(out)
    with open(out + ".pkl", "wb") as f:
        pickle.dump({o: (it.size, it.kind, it.label) for o, it in g.items.items()}, f)


def text_stats(d):
    rows = {k: [0, 0] for k, _ in ROWS}
    opq = collections.Counter()
    opb = collections.Counter()
    for fn in sorted(os.listdir(d)):
        if not re.fullmatch(r"data_\d+\.s", fn):
            continue
        lines = open(os.path.join(d, fn), "rb").read().split(b"\n")
        for i, ln in enumerate(lines):
            for k, rx in ROWS:
                m = re.match(rx, ln)
                if m:
                    rows[k][0] += 1
                    rows[k][1] += int(m.group(1))
            m = OPAQUE.match(ln)
            if m:
                for nxt in lines[i + 1:i + 3]:
                    r = RANGE.match(nxt)
                    if r:
                        opq[m.group(1).decode()] += 1
                        opb[m.group(1).decode()] += int(r.group(2), 0) - int(r.group(1), 0)
                        break
    return rows, opq, opb


def churn(a, b):
    n = 0
    for fn in sorted(os.listdir(a)):
        if re.fullmatch(r"data_\d+\.s|data_structs\.inc|labels\.sym", fn) and os.path.exists(os.path.join(b, fn)):
            p = subprocess.run(["diff", os.path.join(a, fn), os.path.join(b, fn)], capture_output=True)
            n += sum(1 for ln in p.stdout.split(b"\n") if ln[:1] in (b"<", b">"))
    return n


def cover(items):
    m = {}
    for o, (n, k, lab) in items.items():
        for i in range(o, o + n):
            m[i] = (k, lab, o)
    return m


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
        run_one(a.profile, [x for x in a.one[0].split(",") if x], a.one[1])
        return 0
    on_off = [r for r in RULES if r != a.only] if a.only else [a.drop] if a.drop else []
    tag = f"only_{a.only}" if a.only else f"drop_{a.drop}" if a.drop else "on"
    runs = {"off": list(RULES), tag: on_off}
    procs = []
    for name, off in runs.items():
        out = os.path.join(scratch, f"{a.profile}_{name}")
        if os.path.exists(out + ".pkl") and name == "off":
            continue                      # the "off" run is the same for every comparison: reused
        procs.append(subprocess.Popen([sys.executable, os.path.abspath(__file__), "--profile", a.profile,
                                       "--scratch", scratch, "--one", ",".join(off), out],
                                      stdout=subprocess.DEVNULL))
    if any(p.wait() for p in procs):
        sys.exit("typer_stats: a generator run failed")
    res = {}
    for name in runs:
        out = os.path.join(scratch, f"{a.profile}_{name}")
        res[name] = (pickle.load(open(out + ".pkl", "rb")),) + text_stats(out)
    (io, ro, qo, bo), (in_, rn, qn, bn) = res["off"], res[tag]
    co, cn = cover(io), cover(in_)
    fmt = lambda c: f"{c[0]:,} / {c[1]:,}"   # noqa: E731
    print(f"{a.profile} ({tag} vs off): typed bytes {len(co):,} -> {len(cn):,} ({len(cn) - len(co):+,})")
    for k, _ in ROWS:
        print(f"  reader rows {k:8s} {fmt(ro[k])} -> {fmt(rn[k])}")
    tro = [sum(ro[k][0] for k in ro), sum(ro[k][1] for k in ro)]
    trn = [sum(rn[k][0] for k in rn), sum(rn[k][1] for k in rn)]
    print(f"  reader rows all      {fmt(tro)} -> {fmt(trn)}")
    print(f"  opaque               {fmt([sum(qo.values()), sum(bo.values())])} -> "
          f"{fmt([sum(qn.values()), sum(bn.values())])}")
    for k in sorted(set(qo) | set(qn)):
        print(f"    {k:12s} {fmt([qo[k], bo[k]])} -> {fmt([qn[k], bn[k]])}")
    print(f"  line churn (data_NN.s, data_structs.inc, labels.sym): "
          f"{churn(os.path.join(scratch, a.profile + '_off'), os.path.join(scratch, a.profile + '_' + tag)):,}")
    for name, x, y in (("typed in the off run only", co, cn), ("typed in the on run only", cn, co)):
        kinds, firsts = collections.Counter(), collections.defaultdict(set)
        for i, v in x.items():
            if i not in y:
                kinds[v[0]] += 1
                firsts[v[0]].add((v[2], v[1]))
        print(f"  {name}: " + (", ".join(f"{k} {n:,}" for k, n in kinds.most_common()) or "none"))
        for k in kinds:
            print(f"    {k}: " + ", ".join(lab or "?" for _o, lab in sorted(firsts[k])[:8])
                  + (f" (+{len(firsts[k]) - 8} more)" if len(firsts[k]) > 8 else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
