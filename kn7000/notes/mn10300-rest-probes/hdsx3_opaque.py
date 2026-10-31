#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""hdsx3_opaque.py -- the HD-SX3 (HD-SX6) plug-in's opaque data pieces, grouped, with their readers.

QUESTION IT ANSWERS
  "Who reads the `# census: opaque -- unknown-dump` pieces of hdsx3/src/program/data/data_00.s, and
   what are they?"  Each piece is put in the first group whose test it passes:
     POW10     inside the 309 IEEE-754 doubles 10^0..10^308 that start at
               PfDoubleToDecimal_entry_L290_Records (every double checked against 10.0**k); the reader
               is PfDoubleToDecimal, which indexes the table by the decimal exponent (lines printed).
     SENTINEL  the word just past a names table the plug-in registers (ResName, Function, ApFunction,
               MainFunction names: registration count from gen_data_s' model), or the "" string such a
               word points at: an extra {..., ""} entry past the registered count.
     WIDGET    a variable of the initialised-RAM image that a widget record's pointer field names
               (`field=Label`); the record's class chain (gui_classes.inc) gives the field offset, and
               every class procedure of the chain (the plug-in's <Class>Proc, the KN6000's for host
               classes) is scanned for `mov (OFF, aN), aM` followed within 3 instructions by an
               access through aM: those are the readers / writers, with their width.
     POINTED   some 32-bit word of the image holds the piece's address (or its label's, when the
               label starts a byte or two earlier): a pointer whose target the typer did not label.
     CODEARG   code takes the address of the piece's label (`mov Label, aN`): printed with the call.
     PAD       only 0x00 / 0xFF bytes and no reference at all.
     UNREAD    none of the above.
  For each piece: CPU address, size, the label before it, a short look at the bytes, and the
  evidence.  The group counts and bytes come last.

RUN (from the repository root; ../kn6000 and ../hdsx3 reference images built):
  python3 kn7000/notes/mn10300-rest-probes/hdsx3_opaque.py
"""
import collections
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
sys.path.insert(0, HERE)
import gen_data_s as G  # noqa: E402
from hdsx3_entry_vectors import line_addrs  # noqa: E402

G.configure("hdsx3")
BASE = 0x97800000
RAMIMG, RAM, RAMLEN = 0x0B3E84, 0x97910000, 0x26D8      # gen_data_s PROFILES["hdsx3"]["raminit"]
HX = os.path.join(ROOT, "hdsx3")
ROM = open(os.path.join(HX, "baserom", "hdsx3_extapr.rom"), "rb").read()
DATA = open(os.path.join(HX, "src", "program", "data", "data_00.s"), encoding="latin-1").read().split("\n")
GUI = open(os.path.join(HX, "src", "program", "data", "gui_classes.inc"), encoding="latin-1").read().split("\n")


def cpu_of_file(off):
    """flash file offset -> the CPU address its labels use (RAM for the initialised-RAM image)"""
    return RAM + off - RAMIMG if RAMIMG <= off < RAMIMG + RAMLEN else BASE + off


def file_of_cpu(a):
    return a - RAM + RAMIMG if RAM <= a < RAM + RAMLEN else a - BASE


def u32(off):
    return struct.unpack_from("<I", ROM, off)[0]


def labels_sym():
    """({label: CPU address}, {label: size}) from the data generator's labels.sym"""
    out, size = {}, {}
    for ln in open(os.path.join(HX, "src", "program", "data", "labels.sym"), encoding="latin-1"):
        m = re.match(r"(0x[0-9A-Fa-f]{8})\s+(\S+)\s+(\d+)", ln)
        if m:
            out[m.group(2)] = int(m.group(1), 16)
            size[m.group(2)] = int(m.group(3))
    return out, size


def pieces():
    out = []
    for i, ln in enumerate(DATA):
        if "census: opaque" not in ln:
            continue
        m = re.search(r'incbin_range "[^"]+", (0x[0-9A-Fa-f]+), (0x[0-9A-Fa-f]+)', DATA[i + 1])
        s, e = int(m.group(1), 16), int(m.group(2), 16)
        j = i - 1
        while not re.match(r"^\w+:", DATA[j]):
            j -= 1
        out.append(dict(start=s, end=e, label=DATA[j].split(":")[0], line=i + 1))
    return out


def class_chain(cls):
    for ln in GUI:
        m = re.match(r"# %s: (.*?); " % re.escape(cls), ln)
        if m:
            return [c.strip() for c in m.group(1).split("<")]
    return [cls]


def field_offsets(cls):
    i = [k for k, ln in enumerate(GUI) if re.match(r"\.macro %s\b" % re.escape(cls), ln)][0]
    off, res = 0, {}
    for ln in GUI[i + 1:]:
        ln = ln.strip()
        if ln == ".endm":
            break
        m = re.match(r"\.(long|word|byte|space)\s+(.*)", ln)
        if not m:
            continue
        kind, arg = m.groups()
        if kind == "space":
            off += int(arg.split(",")[0], 0)
            continue
        for item in arg.split(","):
            for f in re.findall(r"\\(\w+)", item):
                res.setdefault(f, off)
            off += {"long": 4, "word": 2, "byte": 1}[kind]
    return res


class Code:
    def __init__(self, model, src, rom, base):
        self.L, self.addr, self.labels = line_addrs(src, rom, base)
        self.model = model

    def body(self, name):
        if name not in self.labels:
            return None
        i = self.L.index(name + ":")
        j = i + 1
        # a switch's case targets are `loc_<ADDR>` labels inside the routine
        while j < len(self.L) and not (re.match(r"^\w+:", self.L[j]) and not self.L[j].startswith("loc_") and
                                       not re.search(r"(_L[0-9a-f]+|_entry):$", self.L[j])):
            j += 1
        return range(i, j)

    def field_uses(self, proc, off):
        """[(address, 'insn', 'access insn')] for `mov (off, aN), aM` + an access through aM"""
        rng = self.body(proc)
        if rng is None:
            return None
        hits = []
        pat = re.compile(r"\tmov\t\((?:%#x|%d), a\d\), (a\d)$" % (off, off))
        for i in rng:
            m = pat.match(self.L[i])
            if not m:
                continue
            for j in range(i + 1, min(i + 5, rng.stop)):
                t = self.L[j].strip()
                if re.search(r"\(%s\)" % m.group(1), t):
                    hits.append((self.addr.get(i), self.L[i].strip(), t))
                    break
        return hits


def main():
    lab, lab_size = labels_sym()
    g = G.Gen()
    regs = g.m.regs
    plug = Code("hdsx3", os.path.join(HX, "src", "program.s"), ROM, BASE)
    host = Code("kn6000", os.path.join(ROOT, "kn6000", "src", "program.s"),
                open(os.path.join(ROOT, "kn6000", "baserom", "kn6000_program.rom"), "rb").read(), 0x4C000000)
    # POW10: the doubles from PfDoubleToDecimal_entry_L290_Records
    p10 = lab["PfDoubleToDecimal_entry_L290_Records"]
    n10 = 0
    while n10 < 309 and abs(struct.unpack_from("<d", ROM, p10 - BASE + 8 * n10)[0] / 10.0 ** n10 - 1) < 1e-15:
        n10 += 1
    pow10 = (p10 - BASE, p10 - BASE + 8 * n10)
    # SENTINEL: the word after each registered names table
    sentinel = {}
    for r in regs:
        if r.get("kind") in ("ResName",) or (r.get("kind") in ("Function", "ApFunction", "MainFunction")
                                             and r["slot"] >= 0x300):
            w = file_of_cpu(r["table"] + 4 * r["count"])
            sentinel[w] = (r["slot"], r.get("kind"), r["count"], r["table"], u32(w))
    sent_targets = {file_of_cpu(v[4]): k for k, v in sentinel.items()}
    print(f"POW10 table: {n10} doubles 10^0..10^{n10 - 1} at {p10:#010x}..{p10 + 8 * n10:#010x}")
    for k, v in sorted(sentinel.items()):
        print(f"names table slot {v[0]:#05x} {v[1]:12s} count {v[2]:4d} at {v[3]:#010x}: word [{v[2]}] "
              f"at {cpu_of_file(k):#010x} = {v[4]:#010x}")
    # where PfDoubleToDecimal reads the table
    for i in plug.body("PfDoubleToDecimal") or []:
        t = plug.L[i].strip()
        if "PfDoubleToDecimal_entry_L290_Records" in t or re.match(r"mov\t\((8|0xc|-8|-4), a0\), d[01]$", t):
            print(f"  PfDoubleToDecimal reads: {plug.addr.get(i, 0):#010x} `{t}`")
    words = collections.defaultdict(list)
    for k in range(0, len(ROM) - 3):
        v = u32(k)
        if BASE <= v < BASE + len(ROM) or RAM <= v < RAM + RAMLEN:
            words[v].append(k)
    groups = collections.Counter()
    nbytes = collections.Counter()
    for p in pieces():
        s, e = p["start"], p["end"]
        a = cpu_of_file(s)
        b = ROM[s:e]
        look = b[:12].hex(" ") + (" ..." if len(b) > 12 else "")
        ev = []
        if pow10[0] <= s and e <= pow10[1]:
            grp = "POW10"
            ev.append(f"doubles 10^{(s - pow10[0]) // 8}..10^{(e - pow10[0] - 1) // 8} of the table")
        elif s in sentinel or s in sent_targets:
            grp = "SENTINEL"
            k = s if s in sentinel else sent_targets[s]
            v = sentinel[k]
            ev.append(f"slot {v[0]:#05x} {v[1]} names: entry [{v[2]}] at {cpu_of_file(k):#010x} -> {v[4]:#010x}, "
                      f"past the registered count {v[2]}")
        else:
            grp = None
        if grp is None:
            fields = [(m.group(1), m.group(2)) for ln in DATA
                      for m in [re.match(r"\s+(\w+)\s+\w+,.*\b(\w+)=%s\b" % re.escape(p["label"]), ln)] if m]
            if fields and RAMIMG <= s:
                grp = "WIDGET"
                cls, fld = fields[0]
                off = field_offsets(cls)[fld]
                ev.append(f"{len(fields)} record(s); first: {cls}.{fld} (+{off:#x})")
                for c in class_chain(cls):
                    for code in (plug, host):
                        hits = code.field_uses(c + "Proc", off)
                        if hits:
                            widths = collections.Counter(re.match(r"(\w+)", h[2]).group(1) for h in hits)
                            ev.append(f"  {code.model} {c}Proc: {len(hits)} uses of +{off:#x}, accesses "
                                      f"{dict(widths)}; first {hits[0][0]:#010x} `{hits[0][1]}` / `{hits[0][2]}`")
        if grp is None:
            # a pointer into the piece, or to the short label (<= 8 bytes: a string or record start
            # the typer cut short) the piece continues; words inside the piece itself do not count
            lab_a = lab.get(p["label"], a)
            lab_n = lab_size.get(p["label"], 0)
            targets = list(range(a, a + e - s)) + ([lab_a] if lab_a < a and lab_n <= 8 else [])
            ptr = [(t, k) for t in targets for k in words.get(t, []) if not s <= k < e]
            if ptr:
                grp = "POINTED"
                ev.append("held by: " + ", ".join(
                    f"{cpu_of_file(k):#010x} ({'code' if k < 0x3DED6 else 'data'}) -> {t:#010x}"
                    + ("" if t == a else f" = {p['label']}") for t, k in ptr[:6]))
        if grp is None and lab_size.get(p["label"], 0) <= 8:
            refs = [i for i in plug.addr if re.search(r"\b%s\b" % re.escape(p["label"]), plug.L[i])]
            if refs:
                grp = "CODEARG"
                ev.append("code: " + "; ".join(f"{plug.addr[i]:#010x} `{plug.L[i].strip()}`" for i in refs[:3]))
        if grp is None:
            grp = "PAD" if set(b) <= {0x00, 0xFF} else "UNREAD"
        groups[grp] += 1
        nbytes[grp] += e - s
        print(f"{a:#010x} {e - s:5d} B  {grp:8s} after {p['label']}  [{look}]")
        for x in ev:
            print(f"      {x}")
    print("groups:", ", ".join(f"{k} {groups[k]} pieces / {nbytes[k]} B" for k in sorted(groups)),
          f"; total {sum(groups.values())} / {sum(nbytes.values())} B")


if __name__ == "__main__":
    main()
