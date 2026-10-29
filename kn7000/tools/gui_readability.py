#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""gui_readability.py -- how readable the GUI data of each KN7000 program tree is.

QUESTION ANSWERED
-----------------
"In the source of a program build, how many of the MILK widget records are
written as typed records, and how much of what they hold is still a number a
reader has to decode by hand?"  Counted per tree, from the committed source
only (comments excluded):

  records typed       class-macro invocations (one per widget record)
  records in blobs    widget records the source still holds inside an
                      .incbin_range (the firmware's own count, from
                      tools/milk_model.py, minus the typed ones)
  raw ids             record fields (class-macro arguments) given as a hex
                      number shaped like a MILK id, (slot 1..0x2FF << 16) |
                      index: class, object, function, title, mode, event ids
  numeric links       super= / sub= / next= / prev= given as a number
  numeric addresses   0x48xxxxxx / 0x4Cxxxxxx / 0x50xxxxxx literals in data
                      lines (an .incbin_range's file offsets are not counted)
  code -> data nums   immediates in the CODE that are data-region addresses
                      spelled as numbers (what a symbolizing pass would name)
  unnamed fields      class-macro parameters with no name from the class
                      tables (f, field_*, <name>_<digits>)

RUN
    python3 tools/gui_readability.py                    # this tree (all program builds)
    python3 tools/gui_readability.py --root /path/to/an/other/checkout
"""

import argparse
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TREES = {
    "kn7000-program": "src/program.s",
    "kn7000-sp7001": "src/sp7001/program.s",
    "kn7000-b935": "src/b935/program.s",
    "kn7000-b893": "src/b893/program.s",
}
# The MN10300 siblings, typed by tools/gen_data_s.py --profile <model>: their tree
# (relative to kn7000/), top file and profile (whose data region and RAM image count).
SIBLINGS = {
    "kn6000": ("../kn6000", "src/program.s", "kn6000"),
    "kn6500": ("../kn6500", "src/program.s", "kn6500"),
}
ID_RE = re.compile(r"=\s*(0x[0-9A-Fa-f]+)\b")      # a record field given as hex ...
ADDR_RE = re.compile(r"\b0x(?:48|4[Cc]|50)[0-9A-Fa-f]{6}\b")
LINK_RE = re.compile(r"\b(super|sub|next|prev)=(0x[0-9A-Fa-f]+|\d+)\b")


def strip(line):
    out, q = [], False
    for ch in line:
        if ch == '"':
            q = not q
        if ch == "#" and not q:
            break
        out.append(ch)
    return "".join(out)


def files_of(kn7, top):
    """The top file and every file it includes, recursively."""
    seen, todo = [], [top]
    while todo:
        f = todo.pop(0)
        p = os.path.join(kn7, f)
        if f in seen or not os.path.exists(p):
            continue
        seen.append(f)
        for line in open(p, encoding="latin-1"):
            m = re.match(r'\s*\.include\s+"([^"]+)"', line)
            if m:
                todo.append(m.group(1))
    return seen


def census(kn7, top, objects_total, data_lo, data_hi, ram=(0x50000010, 0x50007F44)):
    macros, params = set(), []
    fs = files_of(kn7, top)
    for f in fs:
        if f.endswith("gui_classes.inc"):
            for line in open(os.path.join(kn7, f), encoding="latin-1"):
                m = re.match(r"\.macro\s+(\w+)\s*(.*)", line)
                if m and m.group(1) not in ("CLASS", "OBJ", "IDNAME"):
                    macros.add(m.group(1))
                    params += [p.split("=")[0].strip() for p in m.group(2).split(",") if p.strip()]
    r = dict(typed=0, raw_ids=0, numeric_links=0, numeric_addr=0, code_data_nums=0)
    r["unnamed_fields"] = sum(1 for p in params if re.fullmatch(r"f|field_\w+|\w+_\d+", p))
    for f in fs:
        is_data = "/data/" in f
        for line in open(os.path.join(kn7, f), encoding="latin-1"):
            s = strip(line)
            if not s.strip() or ".incbin_range" in s:
                continue
            tok = s.split()
            if not tok:
                continue
            op = tok[0].rstrip(":") if not tok[0].endswith(":") else (tok[1] if len(tok) > 1 else "")
            if is_data:
                if op in macros:
                    r["typed"] += 1
                if op in macros:
                    # ... whose value has the shape of a MILK id: slot 1..0x2FF, any index
                    r["raw_ids"] += sum(1 for v in ID_RE.findall(s) if 0x10000 <= int(v, 16) < 0x3000000)
                r["numeric_links"] += len(LINK_RE.findall(s))
                r["numeric_addr"] += len(ADDR_RE.findall(s))
            elif not op.startswith("."):
                for m in ADDR_RE.finditer(s):
                    v = int(m.group(0), 16)
                    if data_lo <= v < data_hi or ram[0] <= v < ram[1]:
                        r["code_data_nums"] += 1
    r["in_blobs"] = objects_total - r["typed"] if objects_total is not None else None
    return r


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", help="another checkout's repository root (default: this one)")
    a = ap.parse_args()
    kn7 = os.path.join(a.root, "kn7000") if a.root else os.path.dirname(HERE)
    total = None
    try:
        sys.path.insert(0, HERE)
        import milk_model
        total = sum(len(b["objects"]) for b in milk_model.Model(
            rom_path=os.path.join(os.path.dirname(HERE), "baserom", "kn7000_program.rom")).blocks.values())
    except Exception as e:   # noqa: BLE001 -- the reference image may be absent
        print(f"(no object total: {e})", file=sys.stderr)
    cols = ["tree", "records typed", "records in blobs", "raw ids", "numeric links", "numeric addresses",
            "code -> data nums", "unnamed fields"]
    rows = []
    for t, top in TREES.items():
        if not os.path.exists(os.path.join(kn7, top)):
            continue
        # build 941's data region; the other builds' regions are the same size within a few KB
        r = census(kn7, top, total if t == "kn7000-program" else None, 0x48586000, 0x487B8FD1)
        rows.append([t, str(r["typed"]), "-" if r["in_blobs"] is None else str(r["in_blobs"]),
                     str(r["raw_ids"]), str(r["numeric_links"]), str(r["numeric_addr"]),
                     str(r["code_data_nums"]), str(r["unnamed_fields"])])
    for t, (root, top, prof) in SIBLINGS.items():
        tree = os.path.normpath(os.path.join(kn7, root))
        if not os.path.exists(os.path.join(tree, top)):
            continue
        tot, lo, hi, ram = None, 0, 0, (0, 0)
        try:
            import gen_data_s as G
            import milk_model
            G.configure(prof)
            lo, hi = G.BASE + G.R1_END, G.BASE + G.DATA_END
            ram = (G.RAMINIT_RAM, G.RAMINIT_RAM + G.RAMINIT_LEN)
            tot = sum(len(b["objects"]) for b in milk_model.Model(
                rom_path=os.path.join(tree, G.P["rom"]), src_glob=G.code_glob(),
                sym_paths=[os.path.join(tree, f) for f in G.P["syms"]],
                label_paths=[os.path.join(tree, G.OUTDIR, "labels.sym"),
                             os.path.join(tree, G.OUTDIR, "gui_code_ids.inc")]).blocks.values())
        except (Exception, SystemExit) as e:   # noqa: BLE001 -- the reference image may be absent
            print(f"(no object total for {t}: {e})", file=sys.stderr)
        r = census(tree, top, tot, lo, hi, ram)
        rows.append([t, str(r["typed"]), "-" if r["in_blobs"] is None else str(r["in_blobs"]),
                     str(r["raw_ids"]), str(r["numeric_links"]), str(r["numeric_addr"]),
                     str(r["code_data_nums"]), str(r["unnamed_fields"])])
    w = [max(len(x) for x in c) for c in zip(cols, *rows)]
    print("| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(cols)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in rows:
        print("| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |")


if __name__ == "__main__":
    main()
