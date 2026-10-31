#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""hdsx3_indirect_calls.py -- every indirect `calls (aN)` of the XAPR plug-in, classified and resolved.

QUESTION IT ANSWERS
  "How is the register of each of the HD-SX3 (HD-SX6) plug-in's `calls (aN)` built, and to which
   routine does it go?"  For each `calls (aN)` of hdsx3/src/program.s the probe walks back over the
   straight-line code before it to the instruction that last wrote aN (a `call` / `calls` between
   them clobbers only a0 / a1 / d0 / d1: a2, a3, d2, d3 are callee-saved in this ABI) and follows
   `mov (OFF, aX), aN` chains back to their root.  Categories:
     HOST  `mov (0x979126B4), aX / mov (0x1SSC, aX), aX / mov (OFF, aX), aN`: 0x979126B4 holds the
           host's registry base (XaprEntryInit stores the a0 the host passes, 0x5024BE58); +0x1SSC is
           the table pointer of registry slot 0x1SS (16-byte records, +0xC the table), so the target is
           entry OFF / 4 of the Function table the host registered at that slot.  Resolved statically
           from the host's registrations (gen_data_s.host_model): KN6000 and KN6500 names side by side.
     TAG   func_97834719's two handler calls: (8, record) of the record func_978340C8 finds in the
           tag hash table, and (0x9C8 + 12 i, ctx), the copy of that record on the open-tag stack;
           both are the `proc` field (+8) of a row of func_97834719_Table (12-byte rows
           {name, kind, proc}, ended by the name ">"), so the possible targets are its rows' procs.
     OTHER anything else (printed one by one; expected none).
  It prints the counts per category and per registry slot, every (slot, OFF) with its call count
  and the routine on each host (flagging offsets where the two hosts' tables disagree), and the
  TAG rows.  Also: the plug-in calls whose slot is not 0x100 but whose OFF milk_model's slot-blind
  HOST_CALLS lookup would name after a block-0 routine.

RUN (from the repository root; ../kn6000, ../kn6500 and ../hdsx3 reference images built):
  python3 kn7000/notes/mn10300-rest-probes/hdsx3_indirect_calls.py
"""
import collections
import os
import re
import struct
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
import gen_data_s as G  # noqa: E402

G.configure("hdsx3")

HOST_REGISTRY_VAR = "func_978003E3_entry_L595_Var"     # = 0x979126B4 (hdsx3/src/labels.inc)
SRC = os.path.join(ROOT, "hdsx3", "src", "program.s")
L = open(SRC, encoding="latin-1").read().split("\n")
MOVLD = re.compile(r"mov \((0x[0-9a-f]+|\d+), (a\d)\), a\d$")


def routine_of(i):
    for j in range(i, -1, -1):
        m = re.match(r"^(\w+):", L[j])
        if m and not re.search(r"_L[0-9a-f]+$", m.group(1)):
            return m.group(1)
    return "?"


def defof(i, reg):
    """(line, 'mnemonic operands') of the last write of reg before line i, in straight-line code."""
    for j in range(i - 1, max(0, i - 80), -1):
        s = L[j]
        if not s.startswith("\t"):
            m = re.match(r"^(\w+):", s)
            if m and not re.search(r"_L[0-9a-f]+$", m.group(1)):
                return None                       # routine start
            continue
        p = s.split("\t")
        if len(p) < 2:
            continue
        if p[1] in ("call", "calls"):
            if reg in ("a0", "a1"):
                return None                       # clobbered by the call
            continue
        if len(p) >= 3 and re.search(r"(^|,\s*)%s$" % reg, p[2]) and p[1] not in ("cmp", "btst"):
            return j, p[1] + " " + p[2]
    return None


def host_tables(name):
    hm, _calls = G.host_model(name)
    base = G.PROFILES[name]["base"]       # host_model() leaves milk_model bound to the plug-in's base

    def u32(a):
        return struct.unpack_from("<I", hm.rom, a - base)[0]
    out = {}
    for slot, r in hm.by_slot.items():
        if r.get("kind") != "Function":
            continue
        out[slot] = [hm.sym_by_addr.get(u32(r["table"] + 4 * k)) or f"func_{u32(r['table'] + 4 * k):08X}"
                     for k in range(r["count"])]
    return out


def main():
    cats = collections.Counter()
    per_slot = collections.Counter()
    per_off = collections.Counter()
    sites = collections.defaultdict(list)
    tag, other = [], []
    for i, line in enumerate(L):
        m = re.match(r"\tcalls\t\((a\d)\)$", line)
        if not m:
            continue
        d1 = defof(i, m.group(1))
        mo = MOVLD.match(d1[1]) if d1 else None
        d2 = defof(d1[0], mo.group(2)) if mo else None
        mo2 = MOVLD.match(d2[1]) if d2 else None
        d3 = defof(d2[0], mo2.group(2)) if mo2 else None
        if mo2 and d3 and d3[1] == f"mov ({HOST_REGISTRY_VAR}), {mo2.group(2)}":
            slot_off = int(mo2.group(1), 0)
            assert (slot_off & 0xF) == 0xC, (i + 1, d2)
            slot, off = (slot_off - 0xC) // 16, int(mo.group(1), 0)
            cats["HOST"] += 1
            per_slot[slot] += 1
            per_off[(slot, off)] += 1
            sites[(slot, off)].append(i + 1)
        elif routine_of(i).startswith("func_97834719"):
            cats["TAG"] += 1
            tag.append((i + 1, d1[1] if d1 else "?", d2[1] if d2 else "?"))
        else:
            cats["OTHER"] += 1
            other.append((i + 1, routine_of(i), d1, d2))
    total = sum(cats.values())
    print(f"{total} `calls (aN)` in hdsx3/src/program.s")
    for k in ("HOST", "TAG", "OTHER"):
        print(f"  {k:5s} {cats[k]:5d}")
    print("HOST calls per registry slot:", ", ".join(f"0x{s:X}: {n}" for s, n in sorted(per_slot.items())))
    t6000, t6500 = host_tables("kn6000"), host_tables("kn6500")
    for slot in sorted(per_slot):
        print(f"registry slot 0x{slot:X}: KN6000 {len(t6000.get(slot, []))} entries, "
              f"KN6500 {len(t6500.get(slot, []))} entries")
    print(f"{'slot':>5} {'OFF':>6} {'idx':>4} {'calls':>5}  {'KN6000':34s} {'KN6500':34s} first site (program.s line)")
    differ = 0
    for (slot, off), n in sorted(per_off.items()):
        a = t6000.get(slot, [])
        b = t6500.get(slot, [])
        na = a[off // 4] if off // 4 < len(a) else "<past the table>"
        nb = b[off // 4] if off // 4 < len(b) else "<past the table>"
        flag = "" if na == nb else "  <-- differ"
        differ += na != nb
        print(f"0x{slot:03X} {off:#6x} {off // 4:4d} {n:5d}  {na:34s} {nb:34s} {sites[(slot, off)][0]}{flag}")
    print(f"{len(per_off)} (slot, OFF) pairs; {differ} where the KN6000's and KN6500's routine names differ")
    blk0 = set(off for (s, off) in per_off if s == 0x100)
    clash = [(s, off) for (s, off) in per_off if s != 0x100 and off // 4 < len(t6000.get(0x100, []))]
    print(f"slot-blind risk: {sum(per_off[k] for k in clash)} calls in {len(clash)} non-0x100 (slot, OFF) pairs "
          f"that a lookup ignoring the slot would name from block 0 "
          f"({sum(1 for k in clash if k[1] in blk0)} of the OFFs are also used with slot 0x100)")
    print("TAG calls (func_97834719, the tag parser):")
    for ln, d1, d2 in tag:
        print(f"  line {ln}: {d1}  <-  {d2}")
    rom = open(os.path.join(ROOT, "hdsx3", "baserom", "hdsx3_extapr.rom"), "rb").read()
    names = {}
    for f in ("hdsx3.sym", "hdsx3_manual.sym", "hdsx3_ported.sym", os.path.join("src", "program", "data", "labels.sym")):
        for ln in open(os.path.join(ROOT, "hdsx3", f), encoding="latin-1"):
            m = re.match(r"(0x[0-9A-Fa-f]{8})\s+(\S+)", ln)
            if m:
                names.setdefault(int(m.group(1), 16), m.group(2))
    # func_97834719_Table is in the initialised-RAM image (copied from 0x978B3E84 to 0x97910000)
    tab = 0x979117D0 - 0x97910000 + 0x0B3E84
    print("  func_97834719_Table rows (RAM 0x979117D0, flash copy file %#x): {name, kind, proc}" % tab)
    for k in range(16):
        nm, kind, proc = struct.unpack_from("<III", rom, tab + 12 * k)
        s = rom[nm - 0x97800000: rom.index(b"\0", nm - 0x97800000)].decode("latin-1") if 0x97800000 <= nm < 0x978C0000 else "?"
        print(f"    [{k:2d}] name {nm:#010x} {s!r:8s} kind {kind}  proc {proc:#010x} {names.get(proc, '')}")
        if s == ">":
            break
    for o in other:
        print("OTHER", o)


if __name__ == "__main__":
    main()
