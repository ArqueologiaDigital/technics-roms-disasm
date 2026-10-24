#!/usr/bin/env python3
r"""Where does v7 keep the RAM variables that v10 keeps at a given address?

QUESTION ANSWERED
    Porting a v10 comment to v7 means rewriting every RAM address it quotes.  This measures
    the v10 -> v7 RAM relocation from the code itself: for every label defined in both trees
    whose bodies (scripts/tools/propagate_v10_headers.py's Tree.body) have the same number of
    lines, each line pair that tokenizes alike and differs only in numbers gives (v10 number,
    v7 number) pairs for the numbers right after a `(` -- memory operands such as
    `(0x3728:16)`, not immediates -- and a same-named `.equ` in the pair gives its two values.  Only pairs below
    0x40000 and less than 0x400 apart are kept (RAM operands, as in propagate_v10_headers'
    RAM-remap tier).  An address also seen UNCHANGED in such a paired line counts as delta 0.

    It prints the pairs as runs of consecutive v10 addresses (sorted) that share one delta,
    with the number of observations behind each run, and flags addresses observed with two
    different deltas.  A gap between two runs is unmeasured: the map says nothing about it.

RUN
    make all          # the ELFs supply the .equ values
    python3 scripts/analysis/v7_ram_shift_map.py [--min-obs N] [--out FILE]
"""
import argparse
import collections
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
import propagate_v10_headers as P  # noqa: E402


def observations(src, dst):
    obs = collections.defaultdict(collections.Counter)   # v10 addr -> Counter(delta)
    for name in src.labels:
        if name not in dst.labels or name in src.dups or name in dst.dups:
            continue
        sb, _, _ = src.body(name)
        db, _, _ = dst.body(name)
        if len(sb) != len(db):
            continue
        for (_, s, _, _), (_, d, _, _) in zip(sb, db):
            ts, td = P.TOKEN.findall(s), P.TOKEN.findall(d)
            if len(ts) != len(td):
                continue
            skel_s = [t if not t.isdigit() else "#" for t in ts]
            skel_d = [t if not t.isdigit() else "#" for t in td]
            if skel_s != skel_d:
                continue
            for k, (x, y) in enumerate(zip(ts, td)):
                if x.isdigit() and (k == 0 or ts[k - 1] != "("):
                    continue                  # an immediate, not a memory operand
                if x.isdigit():
                    x, y = int(x), int(y)
                elif x in src.value and x in dst.value and x not in src.addr:
                    x, y = src.value[x], dst.value[x]
                else:
                    continue
                if 0x100 <= x < P.RAM_TOP and 0 <= y < P.RAM_TOP and abs(x - y) < P.RAM_SHIFT:
                    obs[x][y - x] += 1
    return obs


def runs(obs, min_obs):
    out, cur = [], None
    for x in sorted(obs):
        c = obs[x]
        delta, n = c.most_common(1)[0]
        if n < min_obs:
            continue
        if cur and cur["delta"] == delta:
            cur["hi"], cur["n"], cur["addrs"] = x, cur["n"] + n, cur["addrs"] + 1
        else:
            cur = {"lo": x, "hi": x, "delta": delta, "n": n, "addrs": 1}
            out.append(cur)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--min-obs", type=int, default=1)
    ap.add_argument("--out")
    a = ap.parse_args()
    src, dst = P.Tree("v10"), P.Tree("v7")
    src.load_elf()
    dst.load_elf()
    obs = observations(src, dst)
    lines = ["# v10 -> v7 RAM relocation measured from paired code lines "
             "(scripts/analysis/v7_ram_shift_map.py)",
             "# v10_lo   v10_hi   delta  addresses  observations"]
    for r in runs(obs, a.min_obs):
        lines.append("0x%05x  0x%05x  %+5d  %9d  %12d" % (r["lo"], r["hi"], r["delta"],
                                                         r["addrs"], r["n"]))
    conflicts = {x: c for x, c in obs.items() if len(c) > 1}
    lines.append("# addresses seen with more than one delta: %d" % len(conflicts))
    for x in sorted(conflicts):
        lines.append("#   0x%05x  %s" % (x, ", ".join("%+d x%d" % kv for kv in
                                                     conflicts[x].most_common())))
    text = "\n".join(lines) + "\n"
    if a.out:
        open(a.out, "w").write(text)
    sys.stdout.write(text)


if __name__ == "__main__":
    main()
