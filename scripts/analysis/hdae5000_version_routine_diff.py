#!/usr/bin/env python3
"""Which HD-AE5000 routines differ between v2.06i and a ported version tree?

QUESTION ANSWERED
    For notes/hdae5000-versions-2026-10-24/README.md: what changed in the code
    between v2.06i (hdae5000/) and a version tree (hdae5000_<ver>/), routine by
    routine, after the moves are factored out.  A routine is a code label that is
    not a local one (.L*, *_Skip/_Join/_Loop/_Next/_Done/_Default/_Ev*/_Case*/
    _On*/_Msg* style suffixes are folded into the routine above them) and whose first
    source line is an instruction (the pointer tables between routines are left out);
    its body runs to the next routine label.  Both bodies are decoded (MAME unidasm) and compared
    as instruction shapes with numbers masked and call / jump targets replaced by
    the routine names they reach, so moved code compares equal.

    Prints, per routine: `same`, `changed` (instruction counts and the size of the
    shape difference), `only in v2.06i`, `only in <ver>`; then totals.

INPUTS
    The two source trees, assembled by scripts/tools/port_hdae5000_version.py's
    marker build (no `make` needed).

RUN
    python3 scripts/analysis/hdae5000_version_routine_diff.py v2_01i [--all]
    (--all also lists the routines that are the same)
"""
import difflib
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_hdae5000_version as P  # noqa: E402

LOCAL = re.compile(r'^\.L|_(Skip|Join|Loop|Next|Done|Default|Epilogue|Exit|Return|Fail|Ok)\d*$|'
                   r'_(Ev[0-9A-F]{8}|Case\w*|On[A-Z]\w*|Msg\d+\w*|Lang[A-Z]{2}|SwitchBase\d*)$|__')
NUM = re.compile(r'0x[0-9a-f]+|(?<![\w])\d+(?![\w])')
CALLS = re.compile(r'^(call|calr|jp|jr|jrl|djnz)\b')


def is_data(bld, a):
    """True when the first source line emitting at a is a data directive."""
    k = P.bisect.bisect_left(bld.starts, a)
    if k >= len(bld.starts) or bld.starts[k] != a:
        return False
    f, n, s, e = bld.lines[bld.byaddr[k][1]]
    code = re.sub(rb'^\s*(\.L)?[A-Za-z_]\w*:', b"", bld.text(f, n).split(b";")[0]).strip()
    return code.startswith(b".")


def routines(bld, end):
    tops = sorted((a, n) for a, n in bld.syms if not n.startswith("__PM_") and not LOCAL.search(n)
                  and a < end)
    out = {}
    for k, (a, n) in enumerate(tops):
        e = tops[k + 1][0] if k + 1 < len(tops) else end
        if e > a and not is_data(bld, a):
            out.setdefault(n, (a, e))
    return out


def body(bld, a, e, names):
    res = []
    for addr, bs, t in P.unidasm(bld.img[a - P.BASE:e - P.BASE], a):
        t = t.lower()
        if CALLS.match(t):
            t = re.sub(r'0x([0-9a-f]{6})\b', lambda m: names.get(int(m.group(1), 16), "N"), t)
        res.append(NUM.sub("N", t))
    return res


def main():
    ver = sys.argv[1] if len(sys.argv) > 1 else "v2_01i"
    sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
    import port_hdae5000_version as P0
    base = P0.base_of(sys.argv)
    btree, bmain = P0.base_tree(base)
    ba = P.Build(btree, bmain, P.incs_of(base),
                 os.path.join(P.SCRATCH, "port_hdae5000_routinediff_a"))
    bb = P.Build(P.tree_of(ver), P.main_of(ver), P.incs_of(ver),
                 os.path.join(P.SCRATCH, "port_hdae5000_routinediff_b"))
    assert ba.ok and bb.ok
    ea, eb = ba.symaddr["HDAE5000_Str_End_ObjNames"], bb.symaddr["HDAE5000_Str_End_ObjNames"]
    ra, rb = routines(ba, ea), routines(bb, eb)
    na = {a: n for n, (a, e) in ra.items()}
    nb = {a: n for n, (a, e) in rb.items()}
    same = changed = 0
    rows = []
    for n in sorted(set(ra) | set(rb), key=lambda n: ra.get(n, rb.get(n))[0]):
        if n not in rb:
            rows.append("  only in %-7s %-56s %5d B" % (base, n, ra[n][1] - ra[n][0]))
            continue
        if n not in ra:
            rows.append("  only in %-7s %-56s %5d B" % (ver, n, rb[n][1] - rb[n][0]))
            continue
        x, y = body(ba, *ra[n], na), body(bb, *rb[n], nb)
        if x == y:
            same += 1
            if "--all" in sys.argv:
                rows.append("  same            %s" % n)
            continue
        changed += 1
        sm = difflib.SequenceMatcher(None, x, y, autojunk=False)
        d = sum(max(i2 - i1, j2 - j1) for op, i1, i2, j1, j2 in sm.get_opcodes() if op != "equal")
        rows.append("  changed         %-56s %5d -> %5d B, %4d -> %4d insns, %4d differ"
                    % (n, ra[n][1] - ra[n][0], rb[n][1] - rb[n][0], len(x), len(y), d))
    print("%s -> %s: %d routines in %s, %d in %s; %d same, %d changed, %d only in %s, "
          "%d only in %s" % (base, ver, len(ra), base, len(rb), ver, same, changed, len(set(ra) - set(rb)),
                             base, len(set(rb) - set(ra)), ver))
    print("\n".join(rows))


if __name__ == "__main__":
    main()
