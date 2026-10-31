#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_groups.py -- what kinds of bytes are left `census: opaque -- unknown-dump` in a data region?

QUESTION IT ANSWERS
  "In a tree's generated data sources (<data dir>/data_NN.s), which pieces does the generator declare
   `# census: opaque -- unknown-dump: ...` (followed by `.incbin_range`), and how do they cluster by
   WHERE they are: inside the initialised-RAM image, as a widget's RAM variable, as Japanese text, as
   alignment pad, as the rows past a typed table's bound, behind a string label the typer put on
   binary, as a high-entropy block, as a labelled block a pointer holds ...?  How many pieces and
   bytes per group?"  It is the map lane mn10300-rest item 9 started from; the readers found for the
   groups are checked by opaque_readers_941.py beside this file.

  The rules are generic (no address of any one build is in them) and are tried in this order; the
  first that matches names the piece's group:

    ram-widget-var   the piece is in the initialised-RAM image (its census line says so) and its own
                     label is the value of a `field=LABEL` argument of a widget record (a class macro
                     of <data dir>/gui_classes.inc invoked in the data sources): a widget's RAM
                     variable, read through the record's pointer field by the class's procedure
    ram-other        anything else in the initialised-RAM image
    euc-text         NUL-terminated strings that decode as EUC-JP with at least one double-byte
                     character (only NULs or 0xFF after the last one): Japanese text
    align-pad        at most 3 bytes, all 0x00 / 0xFF, ending on a 4-byte boundary
    record-rest      at most 3 bytes right after a record macro line (REC_* or another macro the
                     data sources define): a record slot's bytes past its typed fields
    high-entropy     at least 256 bytes with a byte entropy of 6.5 bits or more
    false-string     right after a one-line `Label: .asciz "..."` whose text holds a \\x escape or
                     has at most 2 characters: the typer took the head of binary data for a string
    table-tail       no label of its own, right after a typed row (tab_*, REC_*, .space, .byte,
                     .short/.word, .long, .ascii, a class macro): rows past the bound the typer gave
                     the table above (sub-grouped by that table's label with --by-table)
    after-string     right after a real string line
    labelled-held    its own label, and a typed pointer or a code immediate holds the address
    labelled         its own label, nothing holds it
    other            none of the above

  "Own label": the nearest non-blank line above the census comment is a bare `Label:` line (a
  trailing comment allowed).  The CPU address is the `.incbin_range` file offset plus the last
  `.mnbase` above it (the flash link base before the first one: the value of the `.mnbase` line that
  is not the initialised-RAM image's).

RUN (from the repository root; reads only the data sources and the reference image)
  python3 kn7000/notes/mn10300-rest-probes/opaque_groups.py --tree 941
  python3 kn7000/notes/mn10300-rest-probes/opaque_groups.py --tree all           # one line per tree
  python3 kn7000/notes/mn10300-rest-probes/opaque_groups.py --tree 941 --by-table --top 15
  python3 kn7000/notes/mn10300-rest-probes/opaque_groups.py --tree 941 --list euc-text
  trees: 941 942 935 893 (KN7000 program builds), kn6000 kn6500 kn2400 hdsx3
"""
import argparse
import collections
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))

# tree -> (root the .incbin_range paths are relative to, data directory)
TREES = {
    "941": ("kn7000", "kn7000/src/program/data"),
    "942": ("kn7000", "kn7000/src/sp7001/program/data"),
    "935": ("kn7000", "kn7000/src/b935/program/data"),
    "893": ("kn7000", "kn7000/src/b893/program/data"),
    "kn6000": ("kn6000", "kn6000/src/program/data"),
    "kn6500": ("kn6500", "kn6500/src/program/data"),
    "kn2400": ("kn2400", "kn2400/src/program/data"),
    "hdsx3": ("hdsx3", "hdsx3/src/program/data"),
}
GROUPS = ["ram-widget-var", "ram-other", "euc-text", "align-pad", "record-rest", "high-entropy",
          "false-string", "table-tail", "after-string", "labelled-held", "labelled", "other"]

Piece = collections.namedtuple("Piece", "file line cpu size ram held kind own prev_label prev_line data group table")

LABEL_ONLY = re.compile(r"([A-Za-z_.$][\w.$]*):\s*(#.*)?$")
LABEL_ANY = re.compile(r"([A-Za-z_.$][\w.$]*):")
INCBIN = re.compile(r'\.incbin_range "([^"]+)", (0x[0-9A-Fa-f]+), (0x[0-9A-Fa-f]+)')
ASCIZ_LINE = re.compile(r'[A-Za-z_.$][\w.$]*:\s+\.asciz\s+"(.*)"')
ROW = re.compile(r"\s+(tab_\w+|REC_\w+|\.space|\.byte|\.short|\.word|\.long|\.ascii|\.be16|\.be24|\.be32)\b")


def data_files(ddir, root):
    """The data_NN.s parts in the order data.s includes them."""
    inc = open(os.path.join(ddir, "data.s"), encoding="latin-1").read()
    out = [os.path.join(REPO, root, m.group(1)) for m in re.finditer(r'\.include "([^"]*/data_\d+\.s)"', inc)]
    return out or sorted(os.path.join(ddir, f) for f in os.listdir(ddir) if re.match(r"data_\d+\.s$", f))


def class_macros(ddir):
    """{class macro name: set of its parameter names} from gui_classes.inc."""
    out = {}
    p = os.path.join(ddir, "gui_classes.inc")
    if os.path.exists(p):
        for ln in open(p, encoding="latin-1"):
            m = re.match(r"\.macro (\w+) this,(.*)", ln)
            if m:
                out[m.group(1)] = {a.split("=")[0].strip() for a in m.group(2).split(",")}
    return out


def entropy(b):
    if not b:
        return 0.0
    c = collections.Counter(b)
    return -sum(v / len(b) * math.log2(v / len(b)) for v in c.values())


def is_euc(b):
    t = b.rstrip(b"\xff")
    if not t.endswith(b"\x00"):
        return False
    hi = 0
    for p in t[:-1].split(b"\x00"):
        if not p:
            continue
        try:
            s = p.decode("euc-jp")
        except UnicodeDecodeError:
            return False
        if any(ord(ch) < 0x20 for ch in s):
            return False
        hi += sum(1 for ch in s if ord(ch) > 0x7F)
    return hi > 0


def pieces(tree):
    root, dd = TREES[tree]
    ddir = os.path.join(REPO, dd)
    files = data_files(ddir, root)
    texts = [open(f, encoding="latin-1").read().split("\n") for f in files]
    base = None
    for L in texts:
        for ln in L:
            m = re.match(r"\.mnbase (0x[0-9A-Fa-f]+)", ln)
            if m and "initialised-RAM" not in ln:
                base = int(m.group(1), 16)
    classes = class_macros(ddir)
    widget_vals = set()
    if classes:
        for L in texts:
            for ln in L:
                m = re.match(r"\s+(\w+)\t\w+, (.*)", ln)
                if m and m.group(1) in classes:
                    for kv in re.finditer(r"(\w+)=(\w+)", m.group(2).split("\t#")[0]):
                        if kv.group(1) in classes[m.group(1)]:
                            widget_vals.add(kv.group(2))
    roms, out = {}, []
    mb = base
    for f, L in zip(files, texts):
        last_label = None
        for i, ln in enumerate(L):
            m = re.match(r"\.mnbase (0x[0-9A-Fa-f]+)", ln)
            if m:
                mb = int(m.group(1), 16)
                continue
            m = LABEL_ANY.match(ln)
            if m:
                last_label = m.group(1)
            if not ln.startswith("# census: opaque -- unknown-dump"):
                continue
            m = INCBIN.match(L[i + 1]) if i + 1 < len(L) else None
            if not m:
                continue
            s, e = int(m.group(2), 16), int(m.group(3), 16)
            rp = os.path.join(REPO, root, m.group(1))
            if rp not in roms:
                roms[rp] = open(rp, "rb").read()
            j = i - 1
            while j >= 0 and not L[j].strip():
                j -= 1
            prev = L[j] if j >= 0 else ""
            mo = LABEL_ONLY.match(prev)
            own = mo.group(1) if mo else ""
            k = re.search(r"bytes of (.*?) in the", ln)
            out.append(Piece(os.path.relpath(f, REPO), i + 2, mb + s, e - s, "initialised-RAM" in ln,
                             "a typed pointer or a code immediate holds" in ln, k.group(1) if k else "",
                             own, last_label or "", prev, roms[rp][s:e], None, None))
    return [classify(p, widget_vals, set(classes)) for p in out]


def classify(p, widget_vals, classes):
    b, prev = p.data, p.prev_line
    table = None
    if p.ram:
        g = "ram-widget-var" if p.own and p.own in widget_vals else "ram-other"
    elif is_euc(b):
        g = "euc-text"
    elif p.size <= 3 and (p.cpu + p.size) % 4 == 0 and set(b) <= {0, 0xFF}:
        g = "align-pad"
    elif p.size <= 3 and re.match(r"\s+(REC_\w+|[A-Z]\w*)\s", prev) and not prev.lstrip().startswith("."):
        g = "record-rest"
    elif p.size >= 256 and entropy(b) >= 6.5:
        g = "high-entropy"
    else:
        ma = ASCIZ_LINE.match(prev)
        mrow = ROW.match(prev)
        mcls = re.match(r"\s+(\w+)\s", prev)
        if ma and ("\\x" in ma.group(1) or len(ma.group(1).encode("latin-1").decode("unicode_escape")) <= 2):
            g = "false-string"
        elif not p.own and (mrow or (mcls and mcls.group(1) in classes)):
            g, table = "table-tail", p.prev_label
        elif ma or re.match(r"\s+\.asciz\s", prev):
            g = "after-string"
        elif p.own:
            g = "labelled-held" if p.held else "labelled"
        else:
            g = "other"
    return p._replace(group=g, table=table)


def summary(ps):
    by = collections.OrderedDict((g, [0, 0]) for g in GROUPS)
    for p in ps:
        by[p.group][0] += 1
        by[p.group][1] += p.size
    return by


def table(rows, head):
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    fmt = lambda r: "| " + " | ".join(str(c).ljust(w[i]) for i, c in enumerate(r)) + " |"
    return "\n".join([fmt(head), "|" + "|".join("-" * (x + 2) for x in w) + "|"] + [fmt(r) for r in rows])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", default="941", choices=sorted(TREES) + ["all"])
    ap.add_argument("--by-table", action="store_true", help="table-tail sub-groups by the table above")
    ap.add_argument("--top", type=int, default=20)
    ap.add_argument("--list", metavar="GROUP", help="list every piece of one group")
    a = ap.parse_args()
    if a.tree == "all":
        rows = []
        for t in TREES:
            by = summary(pieces(t))
            rows.append([t, sum(v[0] for v in by.values()), sum(v[1] for v in by.values())]
                        + [f"{v[0]}/{v[1]}" for v in by.values()])
        print(table(rows, ["tree", "pieces", "bytes"] + GROUPS))
        print("(each group cell: pieces/bytes)")
        return
    ps = pieces(a.tree)
    by = summary(ps)
    rows = [[g, v[0], v[1]] for g, v in by.items()]
    rows.append(["total", sum(v[0] for v in by.values()), sum(v[1] for v in by.values())])
    print(f"tree {a.tree}: opaque pieces by group")
    print(table(rows, ["group", "pieces", "bytes"]))
    if a.by_table:
        tt = collections.Counter()
        tn = collections.Counter()
        for p in ps:
            if p.group == "table-tail":
                tt[p.table] += p.size
                tn[p.table] += 1
        print(f"\ntable-tail by the table above (top {a.top})")
        print(table([[k, tn[k], v] for k, v in tt.most_common(a.top)], ["table", "pieces", "bytes"]))
    if a.list:
        print(f"\n{a.list}: every piece (CPU address, bytes, own label / table above, first 16 bytes)")
        for p in ps:
            if p.group == a.list:
                print(f"0x{p.cpu:08X}  {p.size:5d}  {p.own or p.table or p.prev_label:40s}  {p.data[:16].hex()}")


if __name__ == "__main__":
    main()
