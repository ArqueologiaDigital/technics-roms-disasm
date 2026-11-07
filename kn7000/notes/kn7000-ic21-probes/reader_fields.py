#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""reader_fields.py -- which program-941 routine read which field of a sound record, in a MAME run.

Question (N-b8f49b1e): the voice record's sub-record (VOICE_SUB) and element (VOICE_ELEM) bytes, the
TABLE tone head (CSOUND_HEAD) and the 'JK' archive's parameter records (jk_param) had no traced reader.
kit_readers.lua logs every CPU read of a region as `R <phase> <pc> <offset> <count>` (offset from the
region base).  This script gives each read its record and field, from the generated sources' macro
layout, and its routine, from the program build's label file, and prints one row per field with the
routines that read it.

Regions (the `REGION` lines kit_readers.lua prints, or --region NAME=BASE):
  kit      03custm3 slot 7's custom-sound block: CSOUND_HEAD (0x27 bytes), 128 VOICE_REF, 128 voice
           records of 0x8E bytes (VOICE_HEAD, two VOICE_SUB, two VOICE_ELEM), as src/customdata/ spells it
  tcmp     slot 7's "TCMP" container (header, style record, variation records with their PART_SETUPs;
           streams are not mapped and show as UNMAPPED)
  tpad     slot 7's "TPAD" container (header, bank record, pad records with their PART_SETUPs)
  archive  the table flash's 'JK' voice archive (src/table/voices/internal_archive.s): Voice_* records
           (VOICE_HEAD + VOICE_SUB...), JkElementTable (VOICE_ELEM), JkParamRecords (jk_param), laid out
           from the label addresses of the table build (--table-labels: kn7asm --labels output of
           src/table.s) and the macro sizes

Usage (from kn7000/):
  python3 -I notes/kn7000-ic21-probes/reader_fields.py RUN.txt [--labels build/kn7000_program.labels]
          [--table-labels TABLE.labels] [--phase PHASE ...]
Output rows: `<region> <record kind> <field> <routines (pc count)>`, then `UNMAPPED` reads.
Placeholder routine names are matched exactly: loc_<8 hex> and func_<8 hex>[_entry] (a loc_ label is
skipped when finding a read's routine; a func_ one is a routine without a name yet).
"""
import argparse
import bisect
import re
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
KN7 = HERE.parent.parent
LOC = re.compile(r"^loc_[0-9A-Fa-f]{8}$")


def macro_params(path, name):
    for line in path.read_bytes().decode("latin-1").splitlines():
        m = re.match(r"\s*\.macro\s+(\w+)\s+(.*)", line)
        if m and m.group(1) == name:
            return [p.strip() for p in m.group(2).split(",")]
    raise SystemExit(f"no macro {name} in {path}")


VR = KN7 / "src/include/voice_record.inc"
CD = KN7 / "src/customdata/customdata.inc"
SUB = macro_params(VR, "VOICE_SUB")
ELEM = macro_params(VR, "VOICE_ELEM")
HEAD = ["name"] * 13 + macro_params(VR, "VOICE_HEAD")[1:]
CHEAD = ["name"] * 16 + macro_params(CD, "CSOUND_HEAD")[1:]
JKPARAM = ["ms"] * 4 + ["zones"] * 4 + ["flags", "key_lo", "key_hi", "b11", "center", "center", "b14", "b15"]


def kit_layout():
    """offset -> (kind, field) for the custom-sound block"""
    m = {}
    for i in range(0x27):
        m[i] = ("CSOUND_HEAD", CHEAD[i])
    for n in range(128):
        for k, f in enumerate(("prog", "bank_lsb", "bank_msb")):
            m[0x27 + n * 3 + k] = ("VOICE_REF", f)
    for v in range(128):
        b = 0x1A7 + v * 0x8E
        for i in range(16):
            m[b + i] = ("VOICE_HEAD", HEAD[i])
        for s in range(2):
            for i in range(0x1C):
                m[b + 0x10 + s * 0x1C + i] = (f"VOICE_SUB", SUB[i])
        for e in range(2):
            for i in range(0x23):
                m[b + 0x48 + e * 0x23 + i] = ("VOICE_ELEM", ELEM[i])
    return m


PSETUP = macro_params(CD, "PART_SETUP")
TPADP = macro_params(CD, "TPAD_PAD")


def tcmp_layout():
    """offset in the "TCMP" container -> (kind, field): header, style record, 20 variation records"""
    m = {i: ("TCMP_HEADER", f"h{i:02x}") for i in range(0x70)}
    st = ["name"] * 16 + ["vname"] * 64 + ["index"] * 20 + ["pad"] * 12 + ["units4"] * 2 + ["units5"] * 2 + ["pad"] * 12
    for i, f in enumerate(st):
        m[0x70 + i] = ("TCMP_STYLE", f)
    var = (["src_lo", "src_hi", "src_ext", "flags"] + [f"p{k}" for k in range(8)] + ["v0c", "v0d", "v0e", "v0f"]
           + ["bars", "meter", "v12", "v13", "v14"] + ["stream"] * 3 + ["eff4", "eff5"] + [f"v{k:02x}" for k in range(0x1A, 0x20)])
    for v in range(20):
        b = 0xF0 + v * 0xE0
        for i, f in enumerate(var):
            m[b + i] = ("TCMP_VAR", f)
        for k in range(8):
            for i in range(0x18):
                m[b + 0x20 + k * 0x18 + i] = ("PART_SETUP", PSETUP[i])
    return m


def tpad_layout():
    """offset in the "TPAD" container -> (kind, field): header, bank record, six pad records"""
    m = {i: ("TPAD_HEADER", f"h{i:02x}") for i in range(0x70)}
    for i in range(0x30):
        m[0x70 + i] = ("TPAD_BANK", "name" if i < 16 else f"b{i:02x}")
    pad = ["name"] * 16 + TPADP[1:14] + ["stream"] * 3 + [f"z{k:02x}" for k in range(0x20, 0x28)]
    for p in range(6):
        b = 0xA0 + p * 0x60
        for i, f in enumerate(pad):
            m[b + i] = ("TPAD_PAD", f)
        for k in range(2):
            for i in range(0x18):
                m[b + 0x28 + k * 0x18 + i] = ("PART_SETUP", PSETUP[i])
    return m


def archive_layout(table_labels):
    """absolute address -> (kind, field) for the archive's voice records, elements and parameter records"""
    lab = {}
    for line in Path(table_labels).read_text().splitlines():
        p = line.split()
        if len(p) == 2:
            lab[p[0]] = int(p[1], 16)
    m = {}
    src = (KN7 / "src/table/voices/internal_archive.s").read_bytes().decode("latin-1").splitlines()
    sizes = {"VOICE_HEAD": (16, HEAD), "VOICE_SUB": (0x1C, SUB), "VOICE_ELEM": (0x23, ELEM),
             "jk_param": (16, JKPARAM)}
    addr = None
    for line in src:
        lm = re.match(r"^(\w+):", line)
        if lm:
            name = lm.group(1)
            addr = lab.get(name) if (name.startswith("Voice_") or name in ("JkElementTable", "JkParamRecords")) else None
            line = line[lm.end():]
        if addr is None:
            continue
        mm = re.match(r"\s+(\w+)\b", line)
        if not mm:
            continue
        if mm.group(1) not in sizes:
            addr = None
            continue
        n, fields = sizes[mm.group(1)]
        for i in range(n):
            m[addr + i] = (mm.group(1), fields[i])
        addr += n
    return m


def routine_finder(labels):
    rows = []
    for line in Path(labels).read_text().splitlines():
        p = line.split()
        if len(p) == 2 and not LOC.match(p[0]) and not p[0].startswith("."):
            rows.append((int(p[1], 16), p[0]))
    rows.sort()
    keys = [r[0] for r in rows]

    def find(pc):
        i = bisect.bisect_right(keys, pc) - 1
        if i < 0:
            return f"{pc:08X}"
        name = rows[i][1]
        # prefer the routine label over its _entry twin
        if name.endswith("_entry"):
            name = name[:-6]
        return name
    return find


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("run")
    ap.add_argument("--labels", default=str(KN7 / "build/kn7000_program.labels"))
    ap.add_argument("--table-labels")
    ap.add_argument("--phase", action="append")
    a = ap.parse_args()
    find = routine_finder(a.labels)
    regions = {"kit": 0x968E0100}
    reads = []
    for line in Path(a.run).read_text(errors="replace").splitlines():
        p = line.split()
        if p[:1] == ["REGION"]:
            regions[p[1]] = int(p[2], 16)
        elif p[:1] == ["R"] and len(p) == 6:
            reads.append((p[1], p[2], int(p[3], 16), int(p[4], 16), int(p[5])))
        elif p[:1] == ["R"] and len(p) == 5:   # older runs: one region, no name
            reads.append(("kit", p[1], int(p[2], 16), int(p[3], 16), int(p[4])))
    lay = {"kit": kit_layout(), "tcmp": tcmp_layout(), "tpad": tpad_layout()}
    if a.table_labels:
        lay["archive"] = archive_layout(a.table_labels)
    out = defaultdict(lambda: defaultdict(int))
    unm = defaultdict(int)
    for reg, phase, pc, off, n in reads:
        if a.phase and phase not in a.phase:
            continue
        if reg == "archive":
            key = lay["archive"].get(regions["archive"] + off) if "archive" in lay else None
        else:
            key = lay.get(reg, {}).get(off)
        if key is None:
            unm[(reg, find(pc))] += n
            continue
        out[(reg,) + key][find(pc)] += n
    for k in sorted(out):
        rs = ", ".join(f"{r} ({c})" for r, c in sorted(out[k].items(), key=lambda x: -x[1]))
        print(f"{k[0]:8} {k[1]:12} {k[2]:16} {rs}")
    for (reg, r), n in sorted(unm.items()):
        print(f"UNMAPPED {reg} {r} {n}")


if __name__ == "__main__":
    sys.exit(main())
