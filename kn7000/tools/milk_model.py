#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""milk_model.py -- the MILK UI object system of a KN7000 program image, read
from the image itself and from the registration code that publishes it.

QUESTION ANSWERED
-----------------
"Which bytes of the program's data region are the MILK class tables, object
(Viewable) tables, widget records, resource-name tables, procedure tables and
event / method name tables, and what does every field of every widget record
mean?"  It is the library behind tools/gen_data_s.py (the typed data region),
tools/gui_menu_map.py (the committed menu map) and tools/gui_readability.py.

THE REGISTRY (evidence: RegisterObjectTable, CPU 0x4842A717)
    RegisterObjectTable(d0 = slot, a0 = &{u32 class, u32 proc, u16 count,
    u16 pad, u32 table}) copies the 16-byte record to 0x5011FAAC + 16*slot
    (slot <= 0x2FF).  The program registers 400 tables at start-up, nearly
    all from the 36 InitializeBlockNN routines, 11 each, at slots 16*N + k:

        k  class            table holds
        0  Viewable         count pointers to widget RECORDS
        1  Function         count code addresses   (9: their name strings)
        2  ApFunction       count code addresses   (10: names)
        3  MainFunction     count code addresses   (11: names)
        4  Class            count 24-byte CLASS records
        5  Event            count pointers to event-name strings (EV_*)
        6  Method           count pointers to method-name strings (MT_*)
        8  ResName          count pointers to the NAME strings of the
                            Viewable objects, index-parallel

    An id is (slot << 16) | index: class ids 0x0004KKKK name entry KKKK of
    block 0's class table, event ids 0x0005KKKK, method ids 0x0006KKKK, and
    an object's id is (16*N << 16) | index in block N's Viewable table.
    This file finds the registrations by reading the converted code
    (src/program/*.s): the stores to the four stack words and the slot in d0
    before each `call RegisterObjectTable`.

THE CLASS RECORD (evidence: ClassProc, CPU 0x4842A802, 0x18-byte stride)
    +0 proc, +4 parent class id (0xFFFFFFFF = none), +8 u16 allsize,
    +10 u16 selfsize, +12 name, +16 propdata, +20 propname: the same 24-byte
    record and field names as the KN5000's (scripts/analysis/
    nakarest_objtab_map.py, THE CLASS SYSTEM); the root class "Class" names
    them itself.  propdata is one character per own field, its type;
    propname points at len(propdata)+1 pointers to the field names, the last
    an empty string.  SIG_SIZE (the byte size of each type character) is
    solved here so that sum == selfsize for every class.

A WIDGET RECORD is the fields of its class chain, root first: Viewable's
class (the record's own class id), super / sub / next / prev (indices of the
parent, first child, next and previous sibling in the same Viewable table,
0xFFFF = none), flag and rect, then each subclass's own fields.

RUN
    python3 tools/milk_model.py --classes          # every class and its fields
    python3 tools/milk_model.py --check            # assert the invariants
    python3 tools/milk_model.py --coverage         # bytes of the data region claimed
"""

import argparse
import glob
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.dirname(HERE)
BASE = 0x48400000
NONE16 = 0xFFFF
# The initialised work-RAM image: ResetEntry (CPU 0x4840FF7E, the loop at
# loc_48410068) copies 0x7F34 bytes from ROM 0x487B0B78 to RAM 0x50000010
# before anything runs, so a pointer into RAM 0x50000010..0x50007F44 (33 of the
# widget records, for instance) reads its initial value from those ROM bytes.
RAMINIT_ROM, RAMINIT_RAM, RAMINIT_LEN = 0x487B0B78, 0x50000010, 0x7F34

# byte size of each propdata type character (see Model._solve_sizes)
SIG_SIZE = {"I": 4, "B": 2, "X": 4, "A": 2, "j": 4, "m": 4, "n": 4, "r": 4, "f": 1, "e": 2,
            "c": 4, "t": 2, "k": 4, "u": 2, "^": 2, "i": 4, "b": 4, "g": 2, "h": 2, "_": 4,
            "a": 4, "G": 4, "d": 2, "`": 4, "N": 4, "s": 4, "v": 2, "w": 2, "F": 4, "C": 1,
            "l": 4, "J": 4, "M": 4, "L": 4, "K": 4, "[": 2, "]": 2, "P": 8, "\\": 2, "q": 4,
            "E": 4, "D": 2}


def read_syms(paths):
    """{addr: name} and {name: addr} from `0xADDR  name` symbol files."""
    by_addr, by_name = {}, {}
    for p in paths:
        if not os.path.exists(p):
            continue
        for line in open(p, encoding="latin-1"):
            if line.lstrip().startswith(";"):
                continue
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
            if m:
                a, n = int(m.group(1), 16), m.group(2)
                by_addr.setdefault(a, n)
                by_name.setdefault(n, a)
    return by_addr, by_name


REG_CALLS = ("RegisterObjectTable", "RegisterOTBlock", "RegisterTitle", "RegisterMode")


def parse_calls(src_glob, by_name):
    """Every call of a REG_CALLS function in the converted code, with the
    values a small register / stack tracker sees before it over the
    straight-line code of its function: `mov IMM, Rn`, `mov Rm, Rn`,
    `clr Dn`, `mov sp, An` / `add IMM, An`, `mov Rn, (off, sp)` and
    `movhu Rn, (off, sp)`.  A list of dicts {call, d0, d1, a0, a1, stack,
    func, file, line}; a0 may be ("sp", X), the caller's sp + X."""
    def val(t):
        t = t.strip()
        try:
            return int(t, 0)
        except ValueError:
            return by_name.get(t)
    calls = []
    callre = re.compile(r"\s+call\s+(" + "|".join(REG_CALLS) + r")(?:_entry)?\b")
    for f in sorted(glob.glob(src_glob)):
        regval, stack, func = {}, {}, None
        for i, l in enumerate(open(f, encoding="latin-1").read().split("\n")):
            m = re.match(r"^([A-Za-z_]\w*):", l)
            if m and not m.group(1).startswith("loc_") and not m.group(1).endswith("_entry"):
                func = m.group(1)
                regval, stack = {}, {}
            m = re.match(r"\s+mov\s+sp, (a\d)$", l)
            if m:
                regval[m.group(1)] = ("sp", 0)
                continue
            m = re.match(r"\s+add\s+(-?0x[0-9a-fA-F]+|-?\d+), (a\d)$", l)
            if m and isinstance(regval.get(m.group(2)), tuple):
                regval[m.group(2)] = ("sp", regval[m.group(2)][1] + int(m.group(1), 0))
                continue
            m = re.match(r"\s+mov\s+(\S+), (d\d|a\d)$", l)
            if m:
                s = m.group(1)
                regval[m.group(2)] = regval.get(s) if re.fullmatch(r"[da]\d", s) else val(s)
                continue
            m = re.match(r"\s+clr\s+(d\d)$", l)
            if m:
                regval[m.group(1)] = 0
                continue
            m = re.match(r"\s+(?:mov|movhu)\s+(d\d|a\d), \((0x[0-9a-fA-F]+|\d+), sp\)$", l)
            if m:
                stack[int(m.group(2), 0)] = regval.get(m.group(1))
                continue
            m = callre.match(l)
            if m:
                calls.append(dict(call=m.group(1), d0=regval.get("d0"), d1=regval.get("d1"),
                                  a0=regval.get("a0"), a1=regval.get("a1"), stack=dict(stack),
                                  func=func, file=os.path.relpath(f, KN7), line=i + 1))
    return calls


def parse_registrations(calls):
    """RegisterObjectTable(d0 = slot, a0 = &{class, proc, count, table}): one
    dict {cls, proc, count, table, slot, func, file, line} per call."""
    regs = []
    for c in calls:
        if c["call"] != "RegisterObjectTable" or not isinstance(c["a0"], tuple):
            continue
        b, st = c["a0"][1], c["stack"]
        regs.append(dict(cls=st.get(b), proc=st.get(b + 4), count=st.get(b + 8), table=st.get(b + 12),
                         slot=c["d0"], func=c["func"], file=c["file"], line=c["line"]))
    return regs


class Field:
    __slots__ = ("name", "sig", "off", "size", "cls")

    def __init__(self, name, sig, off, size, cls):
        self.name, self.sig, self.off, self.size, self.cls = name, sig, off, size, cls


class Klass:
    def __init__(self, cid, addr, rec, model):
        self.id, self.addr = cid, addr
        (self.proc, self.parent, self.allsize, self.selfsize,
         self.name_ptr, self.propdata_ptr, self.propname_ptr) = rec
        self.name = model.cstr(self.name_ptr)
        self.propdata = model.cstr(self.propdata_ptr) if self.propdata_ptr else ""
        n = len(self.propdata)
        self.propname_ptrs = ([model.u32(self.propname_ptr + 4 * i) for i in range(n + 1)]
                              if self.propname_ptr else [])
        self.propnames = [model.cstr(p) for p in self.propname_ptrs]


class Obj:
    """One widget record of a Viewable table."""

    def __init__(self, block, index, addr, klass, name):
        self.block, self.index, self.addr, self.klass, self.name = block, index, addr, klass, name
        self.values = {}     # field name -> value


class Model:
    def __init__(self, rom_path=None, src_glob=None, sym_paths=None):
        rom_path = rom_path or os.path.join(KN7, "baserom", "kn7000_program.rom")
        self.rom = open(rom_path, "rb").read()
        self.end = BASE + len(self.rom)
        sym_paths = sym_paths or [os.path.join(KN7, p) for p in
                                  ("kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym")]
        self.sym_by_addr, self.sym_by_name = read_syms(sym_paths)
        src_glob = src_glob or os.path.join(KN7, "src", "program", "*.s")
        self.calls = parse_calls(src_glob, self.sym_by_name)
        self.regs = parse_registrations(self.calls)
        self._named_ids()
        self.by_slot = {}
        for r in self.regs:
            if None in (r["cls"], r["count"], r["table"], r["slot"]):
                continue
            self.by_slot.setdefault(r["slot"], r)
        self._classes()
        self._solve_sizes()
        self._layouts()
        self._objects()

    # -- bytes ---------------------------------------------------------------
    @staticmethod
    def rom_addr(a):
        """The ROM address holding the initial value of CPU address `a` (`a`
        itself, or its source in the initialised-RAM image)."""
        if RAMINIT_RAM <= a < RAMINIT_RAM + RAMINIT_LEN:
            return a - RAMINIT_RAM + RAMINIT_ROM
        return a

    def inrom(self, a):
        return BASE <= self.rom_addr(a) < self.end

    def u32(self, a):
        return struct.unpack_from("<I", self.rom, self.rom_addr(a) - BASE)[0]

    def u16(self, a):
        return struct.unpack_from("<H", self.rom, self.rom_addr(a) - BASE)[0]

    def bytes_at(self, a, n):
        o = self.rom_addr(a) - BASE
        return self.rom[o:o + n]

    def cstr(self, a):
        if not self.inrom(a):
            return None
        o = self.rom_addr(a) - BASE
        e = self.rom.index(b"\0", o)
        return self.rom[o:e].decode("latin-1")

    # -- OT blocks, titles and modes ----------------------------------------
    def _named_ids(self):
        """The ids the start-up code names with a string (RegisterOTBlock
        CPU 0x484317D1: d0 = block, a0 = "OTB_..." name, a1 = its "i..." tag,
        into the OTBlock table at registry slot 0xC; RegisterTitle 0x48431836:
        d0 = index, a0 = "TT_..." name, into the Title table (slot 0xF, 0x1C
        bytes each); RegisterMode 0x484317EC: d0 = index, a0 = "MD_..." name,
        into the Mode table (slot 0xE, 0x10 bytes each)).  An id is again
        (slot << 16) | index: {id: (name, name string address, call)}."""
        self.otblocks, self.titles, self.modes = {}, {}, {}
        for c in self.calls:
            if not isinstance(c["d0"], int) or not isinstance(c["a0"], int):
                continue
            nm = self.cstr(c["a0"])
            if c["call"] == "RegisterOTBlock":
                self.otblocks[0xC0000 | c["d0"]] = (nm, c["a0"], c)
            elif c["call"] == "RegisterTitle":
                self.titles[0xF0000 | c["d0"]] = (nm, c["a0"], c)
            elif c["call"] == "RegisterMode":
                self.modes[0xE0000 | c["d0"]] = (nm, c["a0"], c)

    # -- classes -------------------------------------------------------------
    def _classes(self):
        self.classes = {}
        # the class tables: the registrations whose class is Class (an entry of
        # block 0's own class table, found as the registration at slot 4 whose
        # class id names entry 4 of itself)
        c = self.by_slot.get(4)
        if c is None:
            sys.exit("milk_model: no class table registered at slot 4")
        self.CLASS_ID = c["cls"]
        for slot, r in sorted(self.by_slot.items()):
            if r["cls"] != self.CLASS_ID:
                continue
            for k in range(r["count"]):
                a = r["table"] + 24 * k
                rec = struct.unpack_from("<IIHHIII", self.rom, a - BASE)
                cid = (slot << 16) | k
                self.classes[cid] = Klass(cid, a, rec, self)
        self.class_by_name = {}
        for k in self.classes.values():
            self.class_by_name.setdefault(k.name, k)
        self.reg_kind = {}
        for slot, r in self.by_slot.items():
            k = self.classes.get(r["cls"])
            r["kind"] = k.name if k else None

    def chain(self, cid):
        out = []
        while cid != 0xFFFFFFFF:
            k = self.classes[cid]
            out.append(k)
            cid = k.parent
        return out[::-1]

    def _solve_sizes(self):
        """The byte size of each propdata type character.  The records are C
        structs of the MN10300 compiler, naturally aligned: a class's own
        fields form a struct (each field at a multiple of its size, `P`, the
        rect of four s16, at a multiple of 2; the struct padded to its widest
        field) of size `selfsize`, placed in the record at the parent's
        `allsize` rounded up to its alignment, and `allsize` is that end
        rounded up to 4.  SIG_SIZE starts from the KN5000's table
        (nakarest_objtab_map.py), whose compiler packs; `f`, `l`, `G` and `_`
        differ here, and `E`, `D` (only in IvSDPlayTimer / IvSDFwdRewTimer)
        are new.  check() asserts selfsize and allsize for every class."""
        self.sig_size = dict(SIG_SIZE)

    def own_layout(self, pd):
        """[(char, offset in the own struct)], own size, own alignment."""
        off, mx, out = 0, 1, []
        for ch in pd:
            sz = self.sig_size[ch]
            al = 2 if sz == 8 else sz
            off = -(-off // al) * al
            out.append((ch, off))
            off += sz
            mx = max(mx, al)
        return out, -(-off // mx) * mx, mx

    def _layouts(self):
        """Per class: its record's fields, root first (offset, size)."""
        self.layout, self.base_of = {}, {}
        for cid in self.classes:
            fields, end = [], 0
            for k in self.chain(cid):
                if not all(ch in self.sig_size for ch in k.propdata):
                    fields = None
                    break
                lay, size, al = self.own_layout(k.propdata)
                # the own struct follows the parent's whole (padded) record
                base = -(-end // al) * al if k.name != "Object" else 0
                self.base_of[k.id] = base
                for (ch, o), nm in zip(lay, k.propnames):
                    fields.append(Field(nm, ch, base + o, self.sig_size[ch], k))
                end = k.allsize if k.name != "Object" else 0
            self.layout[cid] = fields

    # -- objects -------------------------------------------------------------
    def _objects(self):
        self.blocks = {}         # block slot base (16*N) -> dict
        for slot, r in sorted(self.by_slot.items()):
            if r["kind"] != "Viewable":
                continue
            names_r = self.by_slot.get(slot + 8)
            names = []
            if names_r and names_r["kind"] == "ResName":
                names = [self.cstr(self.u32(names_r["table"] + 4 * i)) for i in range(names_r["count"])]
            objs = []
            for i in range(r["count"]):
                p = self.u32(r["table"] + 4 * i)
                cid = self.u32(p) if self.inrom(p) else None
                k = self.classes.get(cid)
                o = Obj(slot, i, p, k, names[i] if i < len(names) else None)
                if k is not None and self.layout.get(cid):
                    for f in self.layout[cid]:
                        o.values[f.name] = int.from_bytes(self.bytes_at(p + f.off, f.size), "little")
                objs.append(o)
            self.blocks[slot] = dict(slot=slot, viewable=r, resname=names_r, objects=objs,
                                     init=r["func"])

    # -- checks --------------------------------------------------------------
    def check(self):
        bad = []
        for k in self.classes.values():
            if not all(ch in self.sig_size for ch in k.propdata):
                bad.append(f"class {k.name}: unsized type in {k.propdata!r}")
                continue
            _lay, size, al = self.own_layout(k.propdata)
            if size != k.selfsize:
                bad.append(f"class {k.name}: fields {k.propdata!r} make {size}, selfsize {k.selfsize}")
            if k.parent != 0xFFFFFFFF:
                p = self.classes.get(k.parent)
                if p is None:
                    bad.append(f"class {k.name}: parent {k.parent:#x} unknown")
                elif p.name != "Object" and -(-(-(-p.allsize // al) * al + size) // 4) * 4 != k.allsize:
                    bad.append(f"class {k.name}: allsize {k.allsize} != {p.name} {p.allsize} + {size}")
            if k.propnames and k.propnames[-1] != "":
                bad.append(f"class {k.name}: propname list not ended by an empty name")
        for b in self.blocks.values():
            objs = b["objects"]
            n = len(objs)
            for o in objs:
                if o.klass is None:
                    bad.append(f"block {b['slot']:#x} object {o.index}: no class ({o.addr:#x})")
                    continue
                v = o.values
                for f in ("super", "sub", "next", "prev"):
                    x = v.get(f)
                    if x is not None and x != NONE16 and x >= n:
                        bad.append(f"block {b['slot']:#x} object {o.index}: {f} {x} out of range")
                if v.get("next", NONE16) != NONE16 and v["next"] < n and objs[v["next"]].values.get("prev") != o.index:
                    bad.append(f"block {b['slot']:#x} object {o.index}: next.prev != self")
                if v.get("sub", NONE16) != NONE16 and v["sub"] < n and objs[v["sub"]].values.get("super") != o.index:
                    bad.append(f"block {b['slot']:#x} object {o.index}: sub.super != self")
        return bad


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--classes", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--regs", action="store_true")
    a = ap.parse_args()
    m = Model()
    if a.regs:
        for r in m.regs:
            print(f"{r['slot']:#06x} {r['kind'] or '?':14s} count {r['count']:5d} table {r['table']:#x}  {r['func']}")
    if a.classes:
        print("type sizes:", " ".join(f"{c}={s}" for c, s in sorted(m.sig_size.items())))
        for cid, k in sorted(m.classes.items()):
            par = m.classes.get(k.parent)
            print(f"{cid:#010x} {k.name:24s} < {par.name if par else '-':20s} all {k.allsize:3d} self {k.selfsize:3d} "
                  + " ".join(f"{n}:{c}" for c, n in zip(k.propdata, k.propnames)))
    if a.check:
        bad = m.check()
        for b in bad[:50]:
            print("FAIL", b)
        print(f"{len(m.classes)} classes, {sum(len(b['objects']) for b in m.blocks.values())} objects "
              f"in {len(m.blocks)} Viewable tables: {len(bad)} failures")
        sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
