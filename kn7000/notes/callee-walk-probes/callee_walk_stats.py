#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""callee_walk_stats.py -- what the interprocedural reader walk (lane callee-walk) made of the reader rows.

QUESTION IT ANSWERS
  "In each typed data region (KN7000 941 / 942 / 935 / 893, KN6000, KN6500, KN2400, HD-SX3), how many pieces
   and bytes does tools/gen_data_s.py still write as reader rows (reader_rows(): read at a known width, address
   only taken, string), before and after the callee walk; how many blocks are now records of what a routine
   reads through the argument it is passed (and how many bytes); how many pointed records there are in all;
   and, for every piece that stays rows because the code only takes its address, why?"

WHAT IT READS
  The generated sources <tree>/src/.../data/data_*.s, as bytes (they hold non-UTF-8 `.ascii`), at two git
  revisions: --base (default 2a7b45be5: main with lanes media-files and code-island merged, which this
  lane is measured against) and --head (default: the working tree).  The signals:
    reader rows       "\t# N bytes read by ...; the read fields at their widths"           -> read
                      "\t# N bytes the code takes the address of: ..."                       -> address
                      "\t# a string, N bytes with its pad, read by ..."                      -> string
    callee records    "Label:\t# REC_X (N bytes): the layout F 0xADDR reads through its argument S ..."
                      (+ "\t# then K x uW up to the next label" for a tail: K * W bytes more)
    inferred records  "Label:\t# REC_X (N bytes) [INFERENCE: between two records of the kind ..."
    pointed records   any "Label:\t# REC_X (N bytes)" line (ptr_records(): records a pointer, a T value, a
                      return value or now an argument leads to)
  and, after the callee walk, the reason an address-only piece gives after its row kinds ("the callee walk:
  F (slot): ..." or "the address is not seen reaching a call ...").

RUN (from the repository root)
  python3 kn7000/notes/callee-walk-probes/callee_walk_stats.py [--base REV] [--head REV] [--reasons]
"""
import argparse, collections, os, re, subprocess, sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TREES = [("kn7000-941", "kn7000/src/program/data"), ("kn7000-942", "kn7000/src/sp7001/program/data"),
         ("kn7000-935", "kn7000/src/b935/program/data"), ("kn7000-893", "kn7000/src/b893/program/data"),
         ("kn6000", "kn6000/src/program/data"), ("kn6500", "kn6500/src/program/data"),
         ("kn2400", "kn2400/src/program/data"), ("hdsx3", "hdsx3/src/program/data")]
ROWS = [("read", rb"\t# (\d+) bytes read by .*the read fields at their widths"),
        ("address", rb"\t# (\d+) bytes the code takes the address of: "),
        ("string", rb"\t# a string, (\d+) bytes with its pad, read by ")]
REC = re.compile(rb"^[A-Za-z_]\w*:\t# REC_\w+ \((\d+) bytes\)(.*)$")
TAIL = re.compile(rb"^\t# then (\d+) x [us](\d+) up to the next label")
KINDS = r"\((?:[us]\d+|pointers)(?:, (?:[us]\d+|pointers))*\); "


def files(rev, d):
    """{name: bytes} of the data_NN.s files of directory d at git revision rev (None: the working tree)."""
    if rev is None:
        p = os.path.join(ROOT, d)
        return {f: open(os.path.join(p, f), "rb").read() for f in sorted(os.listdir(p))
                if re.fullmatch(r"data_\d+\.s", f)} if os.path.isdir(p) else {}
    ls = subprocess.run(["git", "-C", ROOT, "ls-tree", "--name-only", f"{rev}:{d}"], capture_output=True)
    out = {}
    for f in ls.stdout.decode().split():
        if re.fullmatch(r"data_\d+\.s", f):
            out[f] = subprocess.run(["git", "-C", ROOT, "show", f"{rev}:{d}/{f}"], capture_output=True).stdout
    return out


def reason(text):
    """The reason class of an address-only piece's header (text after the row kinds)."""
    if "not seen reaching a call" in text:
        return "the address reaches no call the walk sees (kept in memory, or a path it does not follow)"
    if "library routine" in text:
        return "handed to a library routine (string / block copy)"
    if "byte by byte in a loop" in text:
        return "the routine reads it byte by byte in a loop (a string or a block)"
    if "one field at +0 only" in text:
        return "the routine reads one field at +0 only"
    if "reads only its first byte" in text:
        return "the routine reads only its first byte"
    if "reads nothing through it at a fixed offset (it hands it on" in text:
        return "the routine hands it on (or stores it) and reads no field"
    if "reads nothing through it at a fixed offset" in text:
        return "the routine stores it (a timer, a registry, a queue) and reads no field"
    if "reads nothing through it the walk sees" in text:
        return "the routine's reads are not seen (an argument the walk loses inside it)"
    if "an indirect call" in text:
        return "an indirect call: the routine is not known"
    if "would run into bytes another item holds" in text:
        return "the record would overlap an item another pass typed"
    if "INFERENCE: what the callee reads" in text:
        return "(before the callee walk: not traced)"
    return "other"


def stats(rev, d):
    c = {k: [0, 0] for k, _ in ROWS}
    rec = {"callee": [0, 0], "inferred": [0, 0], "pointed": [0, 0]}
    why = collections.Counter()
    whyb = collections.Counter()
    for _f, data in files(rev, d).items():
        lines = data.split(b"\n")
        for i, ln in enumerate(lines):
            for k, rx in ROWS:
                m = re.match(rx, ln)
                if m:
                    c[k][0] += 1
                    c[k][1] += int(m.group(1))
                    if k == "address":
                        t = ln.decode("latin-1")
                        m2 = re.search(KINDS + r"(.*)$", t)
                        r = reason(m2.group(1) if m2 else t)
                        why[r] += 1
                        whyb[r] += int(m.group(1))
            m = REC.match(ln)
            if m:
                n = int(m.group(1))
                if i + 2 < len(lines):
                    mt = TAIL.match(lines[i + 2])
                    if mt:
                        n += int(mt.group(1)) * int(mt.group(2)) // 8
                rec["pointed"][0] += 1
                rec["pointed"][1] += n
                if b"reads through its argument" in m.group(2):
                    rec["callee"][0] += 1
                    rec["callee"][1] += n
                elif b"[INFERENCE: between two records of the kind" in m.group(2):
                    rec["inferred"][0] += 1
                    rec["inferred"][1] += n
    return c, rec, why, whyb


def table(head, body):
    w = [max(len(r[i]) for r in [head] + body) for i in range(len(head))]
    print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in body:
        print("| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(r)) + " |")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--base", default="2a7b45be5")
    ap.add_argument("--head", default=None, help="a git revision (default: the working tree)")
    ap.add_argument("--reasons", action="store_true", help="also list why address-only pieces stay rows")
    a = ap.parse_args()
    body, reasons = [], []
    for tree, d in TREES:
        b, rb_, _w, _wb = stats(a.base, d)
        h, rh, wh, whb = stats(a.head, d)
        fmt = lambda c: f"{c[0]} / {c[1]:,}"   # noqa: E731
        tb = [sum(b[k][0] for k in b), sum(b[k][1] for k in b)]
        th = [sum(h[k][0] for k in h), sum(h[k][1] for k in h)]
        body.append([tree, fmt(b["read"]), fmt(h["read"]), fmt(b["address"]), fmt(h["address"]),
                     fmt(b["string"]), fmt(h["string"]), fmt(tb), fmt(th), fmt(rh["callee"]), fmt(rh["inferred"]),
                     fmt(rb_["pointed"]), fmt(rh["pointed"])])
        for r, n in wh.most_common():
            reasons.append([tree, r, str(n), f"{whb[r]:,}"])
    print(f"reader rows and records, n / bytes ({a.base} -> {a.head or 'working tree'}):\n")
    table(["tree", "read before", "read after", "address before", "address after", "string before",
           "string after", "rows before", "rows after", "callee records", "inferred records",
           "pointed before", "pointed after"], body)
    if a.reasons:
        print("\nwhy the address-only pieces after stay rows:\n")
        table(["tree", "reason", "pieces", "bytes"], reasons)


if __name__ == "__main__":
    sys.exit(main())
