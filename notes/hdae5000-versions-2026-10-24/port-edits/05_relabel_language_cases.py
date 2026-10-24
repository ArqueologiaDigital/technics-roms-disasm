"""Name the cases of HDAE5000_AcLanguageText1Proc in v2.01i after their message numbers.

QUESTION ANSWERED
    The porting tool aligned this switch's 80 v2.06i cases with v2.01i's 77 by
    instruction shape; every case has the same shape, so it kept v2.06i's case 1,
    piled the labels of cases 2-4 on one address and shifted every later name by
    three (the bytes were right, the names were not: v2.01i lacks messages 65-67).
    The switch table says which address serves which message.  This renames, from
    the table and the ROM bytes alone:
      * the label at each case address        -> _Msg<NNN>
      * the target of that case's first `jr/jrl nz` (the German test) -> _Msg<NNN>_LangDE
      * the target of the German test's `jr/jrl nz` (the French test)  -> _Msg<NNN>_LangFR
    (when v2.06i's case for the same message has those labels), and deletes the
    other labels at those addresses that nothing references.

RUN (once, from the repo root; it rewrites hdae5000_v2_01i/ in place)
    python3 notes/hdae5000-versions-2026-10-24/port-edits/05_relabel_language_cases.py
"""
import collections
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_hdae5000_version as P  # noqa: E402

PFX = "HDAE5000_AcLanguageText1Proc_"
bld = P.do_build("v2_01i")
assert bld.ok
B = bld.img
assert B == P.ref_image("v2_01i")
by = collections.defaultdict(list)
for a, n in bld.syms:
    if not n.startswith("__PM_"):
        by[a].append(n)
w_names = set(open(os.path.join(ROOT, "symbols/hdae5000_symbols_reference.txt")).read().split())
base = bld.symaddr[PFX + "Msg001"]
tab = bld.symaddr["HDAE5000_LangText_CaseTable"]
noms = bld.symaddr[PFX + "NoMessage"]
dec = {a: (bs, t) for a, bs, t in P.unidasm(B[base - P.BASE:tab - P.BASE], base)}


def nz_target(a, limit=12):
    for _ in range(limit):
        if a not in dec:
            return None
        bs, t = dec[a]
        m = re.match(r'^jrl? NZ,0x([0-9a-f]+)$', t)
        if m:
            return int(m.group(1), 16)
        a += len(bs)
    return None


want = {}                                  # address -> wanted name
for i in range(77):
    off = struct.unpack_from("<h", B, tab - P.BASE + 2 * i)[0]
    msg = i + 1 if i <= 0x3f else i + 0x88
    c = base + off
    if c == noms:
        continue
    want[c] = PFX + "Msg%03d" % msg
    de = nz_target(c)
    if de is not None and PFX + "Msg%03d_LangDE" % msg in w_names:
        want[de] = PFX + "Msg%03d_LangDE" % msg
        fr = nz_target(de)
        if fr is not None and PFX + "Msg%03d_LangFR" % msg in w_names:
            want[fr] = PFX + "Msg%03d_LangFR" % msg

# references across the tree
tree = P.tree_of("v2_01i")
files = [f for f in os.listdir(tree) if f.endswith(".s")]
text = {f: open(os.path.join(tree, f), "rb").read() for f in files}
ident = re.compile(rb'(?<![\w.@])([A-Za-z_]\w*)')
refs = collections.Counter()
for s in text.values():
    for ln in s.split(b"\n"):
        code = ln.split(b";")[0]
        code = re.sub(rb'^[A-Za-z_]\w*:', b"", code)
        for t in ident.findall(code):
            refs[t.decode()] += 1

rename, delete = {}, set()
for a, new in want.items():
    have = [n for n in by[a] if n.startswith(PFX + "Msg")]
    if new in have:
        keep = new
    elif have:
        keep = have[0]
        rename[keep] = new
    else:
        sys.exit("no label at 0x%06x for %s" % (a, new))
    for n in have:
        if n != keep:
            if refs[n]:
                sys.exit("%s at 0x%06x is referenced; resolve by hand" % (n, a))
            delete.add(n)
# a name we want may still sit on another address (it was shifted there): that one
# must move away first; anything left with a Msg name that is not wanted and not
# referenced is deleted
wanted_names = set(want.values())
for a, ns in by.items():
    for n in ns:
        if n.startswith(PFX + "Msg") and a not in want and n not in rename:
            if n in wanted_names or not refs[n]:
                if refs[n]:
                    sys.exit("%s at 0x%06x is referenced but not a case; resolve by hand" % (n, a))
                delete.add(n)
print("rename %d, delete %d" % (len(rename), len(delete)))
tmp = {old: "__RELABEL_%d" % k for k, old in enumerate(rename)}
for f, s in text.items():
    ls = s.split(b"\n")
    out = []
    for ln in ls:
        m = re.match(rb'^([A-Za-z_]\w*):\s*$', ln)
        if m and m.group(1).decode() in delete:
            continue
        out.append(ln)
    s = b"\n".join(out)
    for old, t in tmp.items():
        s = re.sub(rb'(?<![\w.@])' + re.escape(old.encode()) + rb'(?![\w])', t.encode(), s)
    for old, t in tmp.items():
        s = re.sub(rb'(?<![\w.@])' + re.escape(t.encode()) + rb'(?![\w])', rename[old].encode(), s)
    if s != text[f]:
        open(os.path.join(tree, f), "wb").write(s)
        print("rewrote", f)
