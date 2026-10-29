#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""gen_data_s.py -- the program image's data region as typed source.

QUESTION ANSWERED
-----------------
"What is every byte of the data region of program build 941 (file offsets
0x186000..0x3B8FD1, CPU 0x48586000..0x487B8FD1, the initialised-RAM image
included), written so that a reader can see it?"

Generates src/program/data/: data.s (included by src/program.s in place of
the old `.incbin_range` of the whole region), its parts data_NN.s,
gui_classes.inc (one assembler macro per MILK class, its parameters the
class chain's own field names) and gui_ids.inc (the title / mode / OT-block
ids the start-up code names).  The bytes are byte-identical (make verify);
what this changes is how they read:

  * the MILK class tables, as CLASS records with their names, field
    signatures (propdata) and field-name lists (propname);
  * every widget record (8,509 of them in 36 Viewable tables), as one macro
    invocation named by its class, its links (super / sub / next / prev) by
    object NAME, its rect as X / Y / W / H, its colours, borders, edit
    switches and flags by the firmware's own constant names (CL_ BD_ ES_ VF_,
    src/constants.inc), its strings by label with the text in a comment, its
    title / exit targets by TT_ name and the procedures by function id name,
    indented under its parent so the tree is the indentation;
  * the Viewable tables (OBJ entries that also define <name>_ix and
    <name>_id), the ResName tables, the Function / ApFunction / MainFunction
    tables (code pointers and names), the Event (EV_) and Method (MT_) name
    tables, which define the event / method ids;
  * strings as .asciz, pointer tables as .long LABEL, the display palette;
  * whatever is left as a labelled .incbin_range of the reference image,
    split at every address the code or a typed item refers to.

The model (classes, field layout, registrations, ids) is tools/milk_model.py,
whose docstring gives the firmware evidence for each structure.

RUN (needs baserom/kn7000_program.rom and build/kn7000_program.labels, i.e.
one `make verify` first)
    python3 tools/gen_data_s.py            # make data-src
"""

import argparse
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import milk_model as MM  # noqa: E402
from milk_model import BASE, NONE16  # noqa: E402

KN7 = os.path.dirname(HERE)
LINES_PER_FILE = 40000
# The program builds this generator knows: the image, its converted code, its
# symbol files, the previous build's labels, and the layout gen_program_s.py
# gives it (end of code region 1, the palette, the library image's start).
PROFILES = {
    "941": dict(rom="baserom/kn7000_program.rom", src="src/program", prog="src/program.s",
                syms=["kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym"],
                labels="build/kn7000_program.labels", r1=0x186000, pal=0x32573C, end=0x3B8FD1),
    "b935": dict(rom="baserom/kn7000_program_b935.rom", src="src/b935/program", prog="src/b935/program.s",
                 syms=["kn7000_b935.sym", "kn7000_b935_manual.sym", "kn7000_b935_exports.sym",
                       "kn7000_b935_bycode.sym"],
                 labels="build/kn7000_program_b935.labels", r1=0x18595C, pal=0x3256D8, end=0x3B8F6D),
    "b893": dict(rom="baserom/kn7000_program_b893.rom", src="src/b893/program", prog="src/b893/program.s",
                 syms=["kn7000_b893.sym", "kn7000_b893_manual.sym", "kn7000_b893_exports.sym",
                       "kn7000_b893_bycode.sym"],
                 labels="build/kn7000_program_b893.labels", r1=0x1846A0, pal=0x323E80, end=0x3B76B1),
    "sp7001": dict(rom="baserom/kn7000_program_sp7001.rom", src="src/sp7001/program", prog="src/sp7001/program.s",
                   syms=["kn7000_sp7001.sym", "kn7000_sp7001_manual.sym", "kn7000_sp7001_new.sym",
                         "kn7000_sp7001_exports.sym"],
                   labels="build/kn7000_program_sp7001.labels", r1=0x1864F4, pal=0x326760, end=0x3BA785),
}
# The SX-KN6000 (v7.1) and SX-KN6500 (v1.3) program flash images, the same MILK
# framework linked at 0x4C000000 (../kn6000, ../kn6500).  Their extra keys: `root`,
# the tree the paths are relative to (default kn7000/); `code`, the converted code
# (default <src>/*.s: there, gen_image_s.py's single src/program.s); `base`, the link
# base; `scheme`, the registry layout (milk_model.SCHEMES: "naka", 0x20 slots per
# kind); `sigmap`, its propdata type characters in the KN7000's alphabet
# (milk_model.SIGMAP_NAKA: with it selfsize and allsize agree for all 449 / 451
# classes, milk_model --check); `labels` may be .equ includes.  `pal` None: no palette.
for _m, _r1, _end in (("kn6000", 0x176037, 0x3F47EC), ("kn6500", 0x176839, 0x37E44C)):
    PROFILES[_m] = dict(root=f"../{_m}", rom=f"baserom/{_m}_program.rom", src="src/program", code="src/program.s",
                        prog="src/program.s", syms=[f"{_m}.sym", f"{_m}_manual.sym", f"{_m}_ported.sym"],
                        labels=["src/symbols.inc", "src/labels.inc"], r1=_r1, pal=None, end=_end,
                        base=0x4C000000, scheme="naka", sigmap=MM.SIGMAP_NAKA, model=_m.upper(),
                        functions_sym=True, bitmaps=True, code_ids=True, text_strict=True, tones=True)
# The SX-KN2400 / SX-KN2600 (program v1.1): the KN7000's registry layout (16 slots
# per block) and alphabet; data first in the image (file 0x0F, after the boot
# vectors, to the MILK kernel's code at 0x1E427C).
PROFILES["kn2400"] = dict(root="../kn2400", rom="baserom/kn2400_program.rom", src="src/program",
                          code="src/program.s", prog="src/program.s",
                          syms=["kn2400.sym", "kn2400_manual.sym", "kn2400_ported.sym"],
                          labels=["src/symbols.inc", "src/labels.inc"], r1=0x00000F, pal=None, end=0x1E427C,
                          model="KN2400", functions_sym=True, bitmaps=True, code_ids=True, text_strict=True,
                          string_arrays=True,
                          # func_486183E3 inflates demo song n's three streams (ptrs_50000C18 / C48 / C78)
                          # through func_486D4A2A, as the KN7000's func_48457350 through func_48533758
                          inflate="func_486D4A2A")
# The KN6000 / KN6500 expansion board's XAPR plug-in (sx6-113, the HD-SX6's; folder
# hdsx3): code first, then its data, then erased flash.  It runs on the SX-KN6000:
# its records use the KN6000's classes (`host`) and its own (registry slot 0x168), it
# calls the KN6000's routines through the host's Function table (milk_model
# HOST_CALLS), and its initialised RAM is copied from 0x978B3E84 to 0x97910000
# (0x26D8 bytes, func_97800082, the XAPR header's first code vector's loop).
PROFILES["hdsx3"] = dict(root="../hdsx3", rom="baserom/hdsx3_extapr.rom", src="src/program",
                         code="src/program.s", prog="src/program.s",
                         syms=["hdsx3.sym", "hdsx3_manual.sym", "hdsx3_ported.sym"],
                         labels=["src/symbols.inc", "src/labels.inc"], r1=0x03DED6, pal=None, end=0x0B655C,
                         base=0x97800000, scheme="naka", sigmap=MM.SIGMAP_NAKA, model="HDSX3",
                         functions_sym=True, host="kn6000", constants="../kn6000/src/constants.inc",
                         bitmaps=True, code_ids=True, text_strict=True, string_arrays=True,
                         raminit=(0x978B3E84, 0x97910000, 0x26D8))
PROFILE = "941"
KN7_DIR = KN7                 # this tree; KN7 is rebound to the profile's root by configure()


def configure(name):
    """Bind the module's layout constants to program build `name`."""
    global PROFILE, P, ROMQ, R1_END, PALETTE, DATA_END, OUTDIR, KN7, BASE
    global RAMINIT_ROM, RAMINIT_RAM, RAMINIT_LEN, RAMINIT_OFF, RAMINIT_END, RAM_MNBASE
    PROFILE, P = name, PROFILES[name]
    KN7 = os.path.normpath(os.path.join(KN7_DIR, P.get("root", ".")))
    # kn7000/'s shared includes as a source of the profile's tree names them
    # (kn7asm has one include base: the tree's own directory)
    global SHARED
    SHARED = "" if KN7 == KN7_DIR else os.path.relpath(KN7_DIR, KN7) + "/"
    BASE = P.get("base", 0x48400000)
    MM.configure(base=BASE, sig_size=P.get("sig"), scheme=P.get("scheme", "kn7000"), sigmap=P.get("sigmap", {}),
                 host_calls={})
    ROMQ = f'"{P["rom"]}"'
    R1_END = P["r1"]             # end of code region 1 (file offset)
    PALETTE = P["pal"]           # display palette, 512 x u32
    DATA_END = P["end"]          # the library image starts here (gen_program_s LIB_FILE_BASE)
    OUTDIR = P["src"] + "/data"
    RAMINIT_ROM, RAMINIT_RAM, RAMINIT_LEN = P.get("raminit") or MM.find_raminit(code_glob())
    MM.RAMINIT_ROM, MM.RAMINIT_RAM, MM.RAMINIT_LEN = RAMINIT_ROM, RAMINIT_RAM, RAMINIT_LEN
    RAMINIT_OFF = RAMINIT_ROM - BASE
    RAMINIT_END = RAMINIT_OFF + RAMINIT_LEN
    RAM_MNBASE = RAMINIT_RAM - RAMINIT_OFF   # .mnbase that makes the image's labels RAM addresses


def code_glob():
    """The converted code of the profile's build (a glob)."""
    return os.path.join(KN7, P.get("code", P["src"] + "/*.s"))


def sym_addr(name, default=None):
    """`0xADDR` of a routine of this build, by its name, for the comments."""
    a = MM.read_syms([os.path.join(KN7, f) for f in P["syms"]])[1].get(name)
    return f"0x{a:08X}" if a is not None else (default or "?")


def sanitize(text, maxlen=40):
    t = re.sub(r"[^A-Za-z0-9]+", "_", text).strip("_")
    return t[:maxlen].rstrip("_")


def c_escape(bs):
    out = []
    for c in bs:
        if c == 0x22:
            out.append('\\"')
        elif c == 0x5C:
            out.append("\\\\")
        elif 0x20 <= c < 0x7F:
            out.append(chr(c))
        elif c == 0x0A:
            out.append("\\n")
        else:
            out.append(f"\\x{c:02X}")
    return "".join(out)


def is_text(bs):
    """A NUL-terminated string worth spelling as text: mostly printable."""
    if not bs:
        return True
    pr = sum(1 for c in bs if 0x20 <= c < 0x7F)
    return pr >= max(1, int(len(bs) * 0.8)) and all(c >= 0x09 for c in bs)


class Item:
    __slots__ = ("start", "size", "label", "kind", "render", "block", "depth", "comment")

    def __init__(self, start, size, label, kind, render, block=None):
        self.start, self.size, self.label, self.kind, self.render = start, size, label, kind, render
        self.block = block
        self.depth = 0
        self.comment = None


def host_model(name):
    """(the Model of host profile `name`, {offset: routine name} of its Function
    table at registry slot 0x100, which a plug-in calls through); the module is
    bound to the current profile again afterwards."""
    cur = PROFILE
    configure(name)
    hm = MM.Model(rom_path=os.path.join(KN7, P["rom"]), src_glob=code_glob(),
                  sym_paths=[os.path.join(KN7, f) for f in P["syms"]],
                  label_paths=[os.path.join(KN7, OUTDIR, "labels.sym"),
                               os.path.join(KN7, OUTDIR, "gui_code_ids.inc")])
    r = hm.by_slot[0x100]
    calls = {}
    for i in range(r["count"]):
        a = hm.u32(r["table"] + 4 * i)
        calls[4 * i] = hm.sym_by_addr.get(a) or f"func_{a:08X}"
    # the host's title, mode and function ids, by name (read while it is configured)
    ids = {i: sanitize(nm or f"ID_{i:X}", 60) for d in (hm.titles, hm.modes) for i, (nm, _a, _c) in d.items()}
    for slot, r in hm.by_slot.items():
        nr = hm.by_slot.get(MM.names_slot(slot))
        if r.get("kind") not in ("Function", "ApFunction", "MainFunction") or not nr:
            continue
        for i in range(min(r["count"], nr["count"])):
            nm = hm.cstr(hm.u32(nr["table"] + 4 * i))
            if nm:
                ids.setdefault((slot << 16) | i, "FN_" + sanitize(nm, 60))
    hm.id_names = ids
    # its event and method names (a plug-in's procedures answer the host's methods)
    ev = {}
    for slot, r in hm.by_slot.items():
        if r.get("kind") in ("Event", "Method", "ResEvent", "ResMethod"):
            for i in range(r["count"]):
                nm = hm.cstr(hm.u32(r["table"] + 4 * i))
                if nm:
                    ev.setdefault((slot << 16) | i, sanitize(nm, 60))
    hm.ev_names = ev
    configure(cur)
    return hm, calls


class Gen:
    def __init__(self):
        self.host, self.host_calls = (host_model(P["host"]) if P.get("host") else (None, {}))
        MM.HOST_CALLS = dict(self.host_calls)
        self.m = MM.Model(rom_path=os.path.join(KN7, P["rom"]), src_glob=code_glob(),
                          sym_paths=[os.path.join(KN7, f) for f in P["syms"]],
                          label_paths=[os.path.join(KN7, OUTDIR, "labels.sym"),
                                       os.path.join(KN7, OUTDIR, "gui_code_ids.inc")], host=self.host)
        m = self.m
        self.rom = m.rom
        self.items = {}               # file offset -> Item
        self.claimed = bytearray(len(self.rom))   # 1 = a byte some item already holds
        self.ranges = []              # (off, end, item start)
        self.label_at = {}            # CPU address -> label (data items)
        self.names = set()
        self.extern = {}              # CPU address -> name defined outside the data region
        self._load_names()
        self.refs = set()             # CPU addresses referred to (need a label)
        self.code_targets = set()     # code addresses the typed data names loc_<ADDR>
        self.host_ids, self.host_used = self.host_id_names(), set()

    def host_id_names(self):
        """(a plug-in) {id: name} of the host firmware's titles, modes and Function /
        ApFunction / MainFunction entries (its records name host titles in `exit`
        and host functions in `func` / `main_func`); gui_ids.inc equates those used."""
        if self.host is None:
            return {}
        return {i: (n if n not in self.names else n + "_HOST") for i, n in self.host.id_names.items()}

    # -- names ---------------------------------------------------------------
    def _load_names(self):
        m = self.m
        labs = P["labels"] if isinstance(P["labels"], list) else [P["labels"]]
        pairs = []
        for lf in labs:
            lab = os.path.join(KN7, lf)
            if not os.path.exists(lab):
                sys.exit(f"gen_data_s: {lf} missing: build this program first")
            for line in open(lab):
                mo = re.match(r"\.equ\s+(\w+),\s*(0x[0-9A-Fa-f]+)", line)
                if mo:
                    pairs.append((mo.group(1), mo.group(2)))
                elif not lf.endswith(".inc") and line.strip():
                    pairs.append(tuple(line.split()))
        self.prev_data_label = {}       # name -> address of the previous build's data labels
        for n, v in pairs:
            a = int(v, 16)
            if self.in_data(a):
                self.prev_data_label[n] = a
                continue          # this generator's own labels: made again below
            self.extern.setdefault(a, n)
            self.names.add(n)
        for a, n in m.sym_by_addr.items():
            self.names.add(n)
            if not self.in_data(a):
                self.extern.setdefault(a, n)
        # names src/symbols.inc / src/program.s give addresses inside the data
        # region: kept as this region's labels (kn7asm checks they agree)
        self.fixed = {}
        for a, n in m.sym_by_addr.items():
            if self.in_data(a):
                self.fixed[a] = n
        prev = os.path.join(KN7, P["src"], "data", "labels.sym")
        if os.path.exists(prev):
            for line in open(prev):
                if not line.startswith(";"):
                    a, n, _sz = line.split()
                    self.prev_data_label[n] = int(a, 16)
        # a name the converted code already uses for a data address keeps it (the
        # code is generated from labels.sym: renaming would change the code)
        import glob
        nx = re.compile(r"\b([A-Za-z_]\w*)\b")
        self.code_names = set()
        for f in glob.glob(code_glob()):
            for line in open(f, encoding="latin-1"):
                self.code_names.update(nx.findall(line.split("#", 1)[0]))
        for n, a in self.prev_data_label.items():
            if n in self.code_names and not n.startswith(("data_", "ram_")):
                self.fixed.setdefault(a, n)
                self.names.add(n)
        for line in open(os.path.join(KN7, P["prog"])):
            mo = re.match(r"\.equ\s+(\w+),\s*0x([0-9A-Fa-f]+)", line)
            if mo and self.in_data(int(mo.group(2), 16)):
                self.fixed.setdefault(int(mo.group(2), 16), mo.group(1))
                self.names.add(mo.group(1))
        for line in open(os.path.join(KN7, P.get("constants", "src/constants.inc"))):
            mo = re.match(r"\.equ\s+(\w+),\s*(0x[0-9A-Fa-f]+)", line)
            if mo:
                self.names.add(mo.group(1))
        self.const = collections.defaultdict(dict)    # prefix -> value -> name
        for line in open(os.path.join(KN7, P.get("constants", "src/constants.inc"))):
            mo = re.match(r"\.equ\s+(([A-Z]+)_\w+),\s*(0x[0-9A-Fa-f]+)", line)
            if mo:
                self.const[mo.group(2)].setdefault(int(mo.group(3), 16), mo.group(1))

    @staticmethod
    def in_data(a):
        """A data-region address as the code uses it.  The initialised-RAM
        image is addressed by its RAM addresses; its ROM addresses (only the
        copy loop and an odd pointer use them) are not, so they are never
        spelled with the image's RAM labels."""
        if RAMINIT_RAM <= a < RAMINIT_RAM + RAMINIT_LEN:
            return True
        o = a - BASE
        return R1_END <= o < DATA_END and not RAMINIT_OFF <= o < RAMINIT_END

    def uniq(self, base):
        base = base if re.match(r"[A-Za-z_]", base) else "_" + base
        n, k = base, 2
        while n in self.names:
            n = f"{base}_{k}"
            k += 1
        self.names.add(n)
        return n

    def name_at(self, a, base):
        """The label of CPU address `a` (creating it as `base` if new)."""
        if a in self.label_at:
            return self.label_at[a]
        n = self.fixed.get(a)
        if n and "root" in P and n.startswith(("Str_", "ptrs_")) and not base.startswith(n.split("_")[0] + "_") \
                and n in self.prev_data_label:
            n = None     # (a sibling) a generated name of what the bytes were taken for before
        n = n or self.uniq(base)
        self.label_at[a] = n
        return n

    # -- claims --------------------------------------------------------------
    @staticmethod
    def off(a):
        return MM.Model.rom_addr(a) - BASE

    def free(self, a, size):
        o = self.off(a)
        return R1_END <= o and o + size <= DATA_END and not any(self.claimed[o:o + size])

    def add(self, a, size, label, kind, render, block=None):
        o = self.off(a)
        if not (R1_END <= o and o + size <= DATA_END):
            raise ValueError(f"item {label} at {a:#x} outside the data region")
        if o in self.items:
            it = self.items[o]
            if it.size == size:
                return it
            raise ValueError(f"item {label} at {a:#x} (+{size}) overlaps {it.label} (+{it.size})")
        if any(self.claimed[o:o + size]):
            raise ValueError(f"item {label} at {a:#x} (+{size}) overlaps an item already placed")
        self.claimed[o:o + size] = b"\1" * size
        it = Item(a, size, label, kind, render, block)
        self.items[o] = it
        self.ranges.append((o, o + size, o))
        if label:
            self.label_at.setdefault(a, label)
        return it

    def build_index(self):
        """Sort the claims and check they never overlap."""
        self.ranges.sort()
        for (s1, e1, _a), (s2, e2, _b) in zip(self.ranges, self.ranges[1:]):
            if s2 < e1:
                a, b = self.items[s1], self.items[s2]
                raise ValueError(f"overlap: {a.label} {BASE + s1:#x}+{a.size} and {b.label} {BASE + s2:#x}+{b.size}")
        self.starts = [r[0] for r in self.ranges]

    def item_containing(self, a):
        import bisect
        o = self.off(a)
        i = bisect.bisect_right(self.starts, o) - 1
        if i >= 0 and self.ranges[i][0] <= o < self.ranges[i][1]:
            return self.items[self.ranges[i][0]]
        return None

    # -- references ----------------------------------------------------------
    @staticmethod
    def in_code(v):
        """An address in code region 1 (a jump-table target, a callback)."""
        return BASE + 0x80 <= v < BASE + R1_END

    def ref(self, v, note=True):
        """A 32-bit value written symbolically when it is an address."""
        if v == 0:
            return "0"
        if v in self.label_at:
            return self.label_at[v]
        if v in self.extern:
            if self.in_code(v) and self.extern[v] == f"loc_{v:08X}":
                self.code_targets.add(v)      # a label only because the data names it: keep it so
            return self.extern[v]
        if self.in_code(v):
            # gen_program_s.py labels it loc_<ADDR> (code_refs.txt)
            self.code_targets.add(v)
            return f"loc_{v:08X}"
        if self.in_data(v):
            it = self.item_containing(v)
            if it is not None and it.label:
                return f"{it.label}+{v - it.start}"
        return f"0x{v:08X}"

    # ======================================================================
    # GUI
    # ======================================================================
    def gui(self):
        m = self.m
        self.blockname = {}
        for bid, (nm, _a, _c) in m.otblocks.items():
            self.blockname[(bid & 0xFFFF) * 16] = nm[4:] if nm and nm.startswith("OTB_") else f"BLK{bid & 0xFFFF:02d}"
        if MM.SCHEME == "naka":
            self.naka_block_names()
        for slot in m.by_slot:
            self.blockname.setdefault(MM.block_key(slot), f"BLK{slot >> 4:02d}")
        self.class_names()
        self.gui_ids()
        self.gui_class_tables()
        self.gui_name_tables()
        self.gui_function_tables()
        self.gui_objects()

    def bname(self, slot):
        return self.blockname[MM.block_key(slot)]

    def naka_block_names(self):
        """NAKA scheme: a module's tables (0x1000 | N) are named after the routine
        that registers them (InitializeUser07 -> User07); a Viewable table V after
        its first root object's ResName (V_<name>), else V<V>."""
        m = self.m
        for slot, r in sorted(m.by_slot.items()):
            k = MM.block_key(slot)
            if k & 0x1000 and k not in self.blockname:
                fn = re.sub(r"_entry.*$", "", r["func"] or "")
                self.blockname[k] = fn[len("Initialize"):] if fn.startswith("Initialize") else f"Module{k & 0x1F:02d}"
        taken = set()
        for slot, r in sorted(m.by_slot.items()):
            if r["kind"] != "Viewable" or slot in self.blockname:
                continue
            nr = m.by_slot.get(MM.names_slot(slot))
            nm = None
            if nr and nr["count"]:
                nm = m.cstr(m.u32(nr["table"]))
            n = f"V_{sanitize(nm, 40)}" if nm and sanitize(nm) else f"V{slot:02X}"
            if n in taken:
                n = f"{n}_{slot:02X}"
            taken.add(n)
            self.blockname[slot] = n

    @staticmethod
    def cid_value(cid):
        return cid

    def class_names(self):
        m = self.m
        self.cls_label, self.cls_id = {}, {}
        for cid, k in sorted(m.classes.items()):
            self.cls_label[cid] = self.uniq("Class_" + sanitize(k.name))
            self.cls_id[cid] = self.uniq("CLASS_" + sanitize(k.name))

    def gui_ids(self):
        """TT_ / MD_ / OTB_ id constants from the registration calls."""
        m = self.m
        self.id_name = {}
        for d in (m.titles, m.modes, m.otblocks):
            for i, (nm, _a, _c) in d.items():
                n = sanitize(nm or f"ID_{i:X}", 60)
                self.id_name[i] = self.uniq(n if n not in self.names else n + "_ID")

    def str_item(self, a, base, kind="string", block=None):
        """A NUL-terminated string at `a` as an .asciz item; returns its label."""
        if a == 0 or not self.m.inrom(a):
            return None
        o = self.off(a)
        if o in self.items:
            return self.items[o].label
        e = self.rom.index(b"\0", o)
        bs = self.rom[o:e]
        if not self.free(a, e - o + 1):
            self.refs.add(a)        # the tail of another string: labelled inside it
            return None
        lab = self.name_at(a, base)
        self.add(a, e - o + 1, lab, kind,
                 lambda g, it, bs=bs: [f'{it.label}:\t.asciz "{c_escape(bs)}"'], block)
        return lab

    def gui_class_tables(self):
        m = self.m
        for slot, r in sorted(m.by_slot.items()):
            if r["kind"] != "Class" or not r["count"]:
                continue
            bn = self.bname(slot)
            tab = f"{bn}_Classes"
            ks = [m.classes[(slot << 16) | i] for i in range(r["count"])]
            for k in ks:
                cn = sanitize(k.name)
                self.str_item(k.name_ptr, f"ClassName_{cn}", "class name")
                if k.propdata_ptr:
                    self.str_item(k.propdata_ptr, f"ClassSig_{cn}", "class sig")
                if k.propname_ptr:
                    fl = [self.str_item(p, f"Field_{cn}_{sanitize(n) or 'end'}", "field name")
                          for p, n in zip(k.propname_ptrs, k.propnames)]
                    self.add(k.propname_ptr, 4 * len(fl), self.name_at(k.propname_ptr, f"ClassFields_{cn}"),
                             "class fields",
                             lambda g, it, k=k: [f"{it.label}:"] + [f"\t.long\t{g.ref(p)}" for p in k.propname_ptrs])
            tlabel = self.name_at(r["table"], tab)

            def render(g, it, ks=ks, slot=slot, tlabel=tlabel):
                out = [f"# {len(ks)} classes; a class id is ({slot:#x} << 16) | its index here (ClassProc"
                       f" {sym_addr('ClassProc', '0x4842A802')} reads entry id & 0xFFFF, 0x18 bytes each)",
                       f".equ {tlabel}_SLOT, {slot:#x}"]
                out.append(f"{it.label}:")
                for k in ks:
                    par = g.cls_id.get(k.parent, "NOCLASS") if k.parent != 0xFFFFFFFF else "NOCLASS"
                    out.append(f"\tCLASS\t{g.cls_label[k.id]}, {g.cls_id[k.id]}, {tlabel}, proc={g.ref(k.proc)}, "
                               f"parent={par}, allsize={k.allsize}, selfsize={k.selfsize}, "
                               f"cname={g.ref(k.name_ptr)}, sig={g.ref(k.propdata_ptr)}, fields={g.ref(k.propname_ptr)}"
                               + (f"\t# {''.join(f'{n}:{c} ' for c, n in zip(k.propdata_raw, k.propnames)).strip()}"
                                  if k.propdata else ""))
                return out
            self.add(r["table"], 24 * r["count"], tlabel, "class table", render, slot)
            for k in ks:
                self.label_at.setdefault(k.addr, self.cls_label[k.id])

    def gui_name_tables(self):
        """Event / Method name tables (they define EV_ / MT_ ids) and the
        ResName tables (handled with the objects)."""
        m = self.m
        self.ev_name = {}
        for slot, r in sorted(m.by_slot.items()):
            if r["kind"] not in ("Event", "Method", "ResEvent", "ResMethod"):
                continue
            bn = self.bname(slot)
            tab = self.name_at(r["table"], f"{bn}_{r['kind']}s")
            ents = []
            for i in range(r["count"]):
                p = m.u32(r["table"] + 4 * i)
                s = m.cstr(p) or f"{r['kind']}_{i}"
                cname = sanitize(s, 60)
                cname = self.uniq(cname if cname not in self.names else f"{cname}_{bn}")
                self.ev_name[(slot << 16) | i] = cname
                self.str_item(p, "Str_" + sanitize(s, 60), r["kind"].lower() + " name")
                ents.append((cname, p))

            def render(g, it, ents=ents, slot=slot, kind=r["kind"]):
                out = [f"# {len(ents)} {kind} names; an {kind.lower()} id is ({slot:#x} << 16) | its index",
                       f"{it.label}:"]
                for cname, p in ents:
                    out.append(f"\tIDNAME\t{cname}, {g.ref(p)}, {it.label}, {slot:#x}")
                return out
            if r["count"]:
                self.add(r["table"], 4 * r["count"], tab, f"{r['kind'].lower()} table", render, slot)

    def gui_function_tables(self):
        m = self.m
        self.fn_name = {}
        self.fn_code = {}             # code address -> the name its Function table gives it
        for slot, r in sorted(m.by_slot.items()):
            if r["kind"] not in ("Function", "ApFunction", "MainFunction") or not MM.is_fn_table(slot):
                continue
            nr = m.by_slot.get(MM.names_slot(slot))
            bn = self.bname(slot)
            tab = self.name_at(r["table"], f"{bn}_{r['kind']}s")
            ents = []
            for i in range(r["count"]):
                code = m.u32(r["table"] + 4 * i)
                np_ = m.u32(nr["table"] + 4 * i) if nr else 0
                s = m.cstr(np_) if np_ else None
                idn = self.uniq("FN_" + sanitize(s or f"{bn}_{r['kind']}_{i}", 60))
                self.fn_name[(slot << 16) | i] = idn
                if s and code:
                    self.fn_code.setdefault(code, s)
                if np_:
                    self.str_item(np_, "FnName_" + sanitize(s or "", 60), "function name")
                ents.append((idn, code, np_, s))

            def render(g, it, ents=ents, slot=slot, kind=r["kind"]):
                out = [f"# {len(ents)} {kind} procedures; a function id is ({slot:#x} << 16) | its index"
                       f" (the names are the parallel table at slot {MM.names_slot(slot):#x})", f"{it.label}:"]
                for idn, code, _np, s in ents:
                    out.append(f"\tIDNAME\t{idn}, {g.ref(code)}, {it.label}, {slot:#x}")
                return out

            def render_names(g, it, ents=ents):
                return [f"{it.label}:"] + [f"\t.long\t{g.ref(np_)}" for _i, _c, np_, _s in ents]
            if r["count"]:
                self.add(r["table"], 4 * r["count"], tab, "function table", render, slot)
                if nr:
                    self.add(nr["table"], 4 * nr["count"], self.name_at(nr["table"], f"{bn}_{r['kind']}Names"),
                             "function names", render_names, slot)

    # -- objects ---------------------------------------------------------------
    def obj_names(self, b):
        """A unique label per object: its ResName when it has one, else its
        parent's name + its class (+ its label text when it shows one)."""
        m = self.m
        objs = b["objects"]
        bn = self.bname(b["slot"])
        names = [None] * len(objs)
        order = self.preorder(objs)
        counters = collections.Counter()
        named = {}                 # index -> its nearest ancestor with a ResName (or itself)
        for i in order:
            o = objs[i]
            par = o.values.get("super", NONE16)
            if o.name:
                named[i] = i
            else:
                named[i] = named.get(par) if par != NONE16 else None
        for i in order:
            o = objs[i]
            if o.name:
                base = sanitize(o.name, 60)
            else:
                par = o.values.get("super", NONE16)
                anc = named.get(par) if par != NONE16 else None
                pn = names[anc] if anc is not None and names[anc] else bn
                cls = sanitize(o.klass.name)
                for cut in ("Vw", "Ac", "Ps", "Iv"):
                    if cls.startswith(cut) and len(cls) > len(cut) + 1:
                        cls = cls[len(cut):]
                        break
                txt = ""
                for f in ("str", "caption", "title", "stron", "text"):
                    v = o.values.get(f)
                    if isinstance(v, int) and v and m.inrom(v) and f in self.field_sig(o) and self.field_sig(o)[f] == "X":
                        s = m.cstr(v)
                        if s and is_text(s.encode("latin-1")):
                            txt = sanitize(s, 20)
                            break
                key = (pn, cls, txt)
                counters[key] += 1
                base = f"{pn}_{cls}" + (f"_{txt}" if txt else "") + (f"{counters[key]}" if not txt or counters[key] > 1 else "")
            n = base if base not in self.names else f"{bn}_{base}"
            names[i] = self.uniq(n)
        return names

    def field_sig(self, o):
        return {f.name: f.sig for f in self.m.layout[o.klass.id]}

    @staticmethod
    def preorder(objs):
        """Object indices root first, children in sibling order; then any not reached."""
        n = len(objs)
        seen, out = set(), []

        def walk(i):
            while i != NONE16 and i < n and i not in seen:
                seen.add(i)
                out.append(i)
                c = objs[i].values.get("sub", NONE16)
                if c != NONE16:
                    walk(c)
                i = objs[i].values.get("next", NONE16)
        for i, o in enumerate(objs):
            if o.values.get("super", NONE16) == NONE16 and o.values.get("prev", NONE16) == NONE16:
                walk(i)
        for i in range(n):
            if i not in seen:
                walk(i)
        return out

    def gui_objects(self):
        m = self.m
        self.obj_label = {}           # (slot, ix) -> name
        self.obj_by_id = {}           # object id -> name
        self.obj_depth = {}
        self.obj_rec_slot = {}
        for slot, b in sorted(m.blocks.items()):
            names = self.obj_names(b)
            objs = b["objects"]
            for i, o in enumerate(objs):
                self.obj_label[(slot, i)] = names[i]
                self.obj_by_id[(slot << 16) | i] = names[i]
            # depth for indentation
            for i, o in enumerate(objs):
                d, j = 0, o.values.get("super", NONE16)
                while j != NONE16 and j < len(objs) and d < 64:
                    d += 1
                    j = objs[j].values.get("super", NONE16)
                self.obj_depth[(slot, i)] = d
        for slot, b in sorted(m.blocks.items()):
            objs = b["objects"]
            if not objs:            # an empty table (KN6000: `clr d0` count): the code's label only
                continue
            bn = self.bname(slot)
            vt, rn = b["viewable"], b["resname"]
            tlabel = self.name_at(vt["table"], f"{bn}_Viewables")
            for i, o in enumerate(objs):
                lab = self.obj_label[(slot, i)]
                self.label_at[o.addr] = lab
                self.add(o.addr, o.klass.allsize, lab, "widget",
                         lambda g, it, slot=slot, i=i: g.render_object(slot, i), slot)
                self.items[self.off(o.addr)].depth = self.obj_depth[(slot, i)]
            ents = [(self.obj_label[(slot, i)]) for i in range(len(objs))]

            def render_tab(g, it, ents=ents, slot=slot, bn=bn):
                return [f"# {len(ents)} objects of block {bn}; object <name> is index <name>_ix,"
                        f" id <name>_id = ({slot:#x} << 16) | <name>_ix",
                        f"{it.label}:"] + [f"\tOBJ\t{e}, {it.label}, {slot:#x}" for e in ents]
            self.add(vt["table"], 4 * len(objs), tlabel, "object table", render_tab, slot)
            if rn:
                rlabel = self.name_at(rn["table"], f"{bn}_ResNames")
                ptrs = [m.u32(rn["table"] + 4 * i) for i in range(rn["count"])]
                for i, p in enumerate(ptrs):
                    s = m.cstr(p)
                    self.str_item(p, "RN_" + (sanitize(s, 60) if s else "empty"), "resource name", slot)

                def render_rn(g, it, ptrs=ptrs, slot=slot):
                    return [f"{it.label}:"] + [f"\t.long\t{g.ref(p)}\t# {g.obj_label[(slot, i)]}"
                                               for i, p in enumerate(ptrs)]
                self.add(rn["table"], 4 * len(ptrs), rlabel, "resname table", render_rn, slot)
        # strings and RAM variables the records point at
        for slot, b in sorted(m.blocks.items()):
            for i, o in enumerate(b["objects"]):
                for f in m.layout[o.klass.id]:
                    v = o.fvalues[f.off]
                    if f.sig == "X" and v and m.inrom(v):
                        s = m.cstr(v)
                        self.str_item(v, "Str_" + (sanitize(s, 40) or "empty"), "widget text", slot)
                    elif f.sig in "lmqr" and v and self.in_data(v):
                        # the object's state variable (in the initialised RAM)
                        self.name_at(v, f"{self.obj_label[(slot, i)]}_{sanitize(f.name)}")
                        self.refs.add(v)

    # rendering of one record --------------------------------------------------
    def render_object(self, slot, i):
        m = self.m
        o = m.blocks[slot]["objects"][i]
        k = o.klass
        args = [self.obj_label[(slot, i)]]
        comments = []
        objs = m.blocks[slot]["objects"]
        for f in self.macro_fields(k.id):
            v = o.fvalues[f.off]
            p = self.param[k.id][f.off]
            if f.name in ("super", "sub", "next", "prev") and f.sig == "[":
                if v != NONE16:
                    args.append(f"{p}={self.obj_label[(slot, v)]}")
                continue
            if f.name == "class" and f.sig == "M":
                continue
            if f.sig == "P":
                b = m.bytes_at(o.addr + f.off, 8)
                x1, y1, x2, y2 = (int.from_bytes(b[j:j + 2], "little", signed=True) for j in (0, 2, 4, 6))
                q = self.rect_prefix[k.id][f.off]
                args.append(f"{q}X={x1}, {q}Y={y1}, {q}W={x2 - x1 + 1}, {q}H={y2 - y1 + 1}")
                continue
            if v == 0 and f.sig not in ("]", "e"):
                continue
            args.append(f"{p}={self.fmt(f, v, comments)}")
        line = "\t" * (1 + self.obj_depth[(slot, i)]) + f"{self.macro[k.id]}\t" + ", ".join(args)
        out = []
        if comments:
            line += "\t# " + "; ".join(comments)
        out.append(line)
        return out

    def fmt(self, f, v, comments):
        m = self.m
        s = f.sig
        if s == "]":
            return self.const["CL"].get(v, str(v))
        if s == "^":
            return self.const["BD"].get(v, str(v))
        if s == "e":
            return self.const["ES"].get(v, str(v))
        if s == "\\":
            return self.flags(v)
        if s == "X":
            r = self.ref(v)
            st = m.cstr(v) if m.inrom(v) else None
            if st is not None:
                comments.append(f'{f.name} "{c_escape(st.encode("latin-1"))[:40]}"')
            return r
        if s in "lmqr":
            return self.ref(v)
        if s in "aN`s" or (s in "jk"):
            if v in self.id_name:
                return self.id_name[v]
            if v in self.obj_by_id:
                return self.obj_by_id[v] + "_id"
            if v in self.fn_name:
                return self.fn_name[v]
            if v in self.host_ids:
                self.host_used.add(v)
                return self.host_ids[v]
            return f"0x{v:X}"
        if f.size == 4 and v >= 0x80000000:
            return f"0x{v:X}"
        if f.size == 2 and v == 0xFFFF:
            return "0xFFFF"
        return str(v)

    def flags(self, v):
        if v == 0:
            return "0"
        names, rest = [], v
        for val, n in sorted(self.const["VF"].items()):
            if val and v & val == val:
                names.append(n)
                rest &= ~val
        if rest:
            names.append(f"0x{rest:X}")
        return "|".join(names)

    # -- class macros ------------------------------------------------------------
    RESERVED = {"this", "X", "Y", "W", "H"}

    def macro_fields(self, cid):
        return self.m.layout[cid]

    def class_macros(self):
        """One macro per class used by a record: its parameters are the class
        chain's field names, its body the record's bytes in field order."""
        m = self.m
        self.macro, self.param, self.rect_prefix = {}, {}, {}
        used = set()
        for b in m.blocks.values():
            for o in b["objects"]:
                used.add(o.klass.id)
        lines = []
        for cid in sorted(used):
            k = m.classes[cid]
            mname = sanitize(k.name)
            if mname in self.names or mname.lower() in ("obj", "class", "idname"):
                mname = "W_" + mname
            self.macro[cid] = mname
            fields = m.layout[cid]
            # parameters per field (by offset: a subclass may declare a field name
            # again); the first rect is X / Y / W / H, a further one <field>_X ...
            pnames, params, seen, rp = {}, [], set(), {}
            for f in fields:
                pn = sanitize(f.name) or "f"
                if pn in self.RESERVED or pn in seen:
                    pn = f"{pn}_{f.cls.name}" if f"{pn}_{f.cls.name}" not in seen else f"{pn}_{f.off}"
                    pn = sanitize(pn)
                seen.add(pn)
                pnames[f.off] = pn
                if f.sig == "P":
                    rp[f.off] = "" if not rp else f"{pn}_"
            self.param[cid], self.rect_prefix[cid] = pnames, rp
            plist = ["this"]
            body = ["\\this\\():"]
            off = 0
            for f in fields:
                pn = pnames[f.off]
                if f.off > off:
                    body.append(f"\t.space\t{f.off - off}")
                off = f.off + f.size
                if f.name == "class" and f.sig == "M":
                    body.append(f"\t.long\t{self.cls_id[cid]}")
                elif f.sig == "[" and f.name in ("super", "sub", "next", "prev"):
                    plist.append(f"{pn}=NONE")
                    body.append(f"\t.word\t\\{pn}\\()_ix")
                elif f.sig == "P":
                    q = rp[f.off]
                    plist += [f"{q}X=0", f"{q}Y=0", f"{q}W=0", f"{q}H=0"]
                    body.append(f"\t.word\t\\{q}X, \\{q}Y, \\{q}X + \\{q}W - 1, \\{q}Y + \\{q}H - 1")
                else:
                    plist.append(f"{pn}=0")
                    d = {1: ".byte", 2: ".word", 4: ".long"}[f.size]
                    body.append(f"\t{d}\t\\{pn}")
            if k.allsize > off:
                body.append(f"\t.space\t{k.allsize - off}")
            chain = " < ".join(c.name for c in reversed(m.chain(cid)) if c.name != "Object")
            lines += [f"# {k.name}: {chain}; {k.allsize} bytes"
                      + (f"; own fields {''.join(f'{n}:{c} ' for c, n in zip(k.propdata_raw, k.propnames)).strip()}"
                         if k.propdata else ""),
                      f".macro {mname} " + ", ".join(plist)] + body + [".endm", ""]
        self.macro_lines = lines

    def check_pads(self):
        """Every byte a class macro writes as .space (struct padding) is zero."""
        m = self.m
        bad = 0
        for b in m.blocks.values():
            for o in b["objects"]:
                fields = m.layout[o.klass.id]
                off = 0
                spans = []
                for f in fields:
                    if f.off > off:
                        spans.append((off, f.off))
                    off = f.off + f.size
                if o.klass.allsize > off:
                    spans.append((off, o.klass.allsize))
                for s, e in spans:
                    if any(m.bytes_at(o.addr + s, e - s)):
                        bad += 1
                        print(f"gen_data_s: nonzero pad in {o.klass.name} at {o.addr + s:#x}")
        return bad

    # ======================================================================
    # the rest
    # ======================================================================
    def palette(self):
        a = BASE + PALETTE
        vals = [int.from_bytes(self.rom[PALETTE + 4 * i:PALETTE + 4 * i + 4], "little") for i in range(512)]

        def render(g, it, vals=vals):
            out = ["# ---- display palette (256-entry 0x00BBGGRR CLUT + a themed sub-range); the boot's",
                   "#      CLUT seeder (loop at 0x4842D9D7, writer 0x4842DB1E) copies it to the LCD controller",
                   f"{it.label}:"]
            for i in range(0, 512, 8):
                out.append("\t.long\t" + ", ".join(f"0x{v:08X}" for v in vals[i:i + 8]) + f"\t# idx {i:3d}")
            return out
        self.add(a, 0x800, self.name_at(a, "display_palette"), "palette", render)

    def code_refs(self):
        """Every data-region address the converted code names as an immediate."""
        import glob
        rx = re.compile(r"\b0x([0-9a-fA-F]{8})\b")      # in_data() decides
        # the code names a data address it refers to by the label the previous
        # generation gave it (gen_program_s.py reads labels.sym), or as a number
        nx = re.compile(r"\b([A-Za-z_]\w*)(?:\+(\d+))?")
        self.readers = collections.defaultdict(list)   # address -> [(function, cpu, load, signed)]
        for f in sorted(glob.glob(code_glob())):
            self.scan_readers(open(f, encoding="latin-1").read().split("\n"))
            for line in open(f, encoding="latin-1"):
                code = line.split("#", 1)[0]
                for mo in rx.finditer(code):
                    a = int(mo.group(1), 16)
                    if self.in_data(a):
                        self.refs.add(a)
                for mo in nx.finditer(code):
                    a = self.prev_data_label.get(mo.group(1))
                    if a is not None:
                        a += int(mo.group(2) or 0)
                        if self.in_data(a):
                            self.refs.add(a)
        for a in self.fixed:
            self.refs.add(a)

    LOAD = re.compile(r"\s+(movbu|movhu|mov)\s+\((?:[^,()]*,\s*)?(a\d)\),\s*([da]\d)$")

    def scan_readers(self, lines):
        """For `mov ADDR, aN` (ADDR a data address, as a number or a data label):
        the first load through aN within the next 8 lines -- `movbu` (u8), `movhu`
        (u16) or `mov` (u32) -- and whether an `extb` / `exth` of the loaded
        register follows (signed).  The function is the last non-loc label."""
        func, cpu = None, None
        for i, ln in enumerate(lines):
            m = re.match(r"^([A-Za-z_]\w*):", ln)
            if m and not m.group(1).startswith("loc_"):
                func = m.group(1)
            m = re.match(r"# \S+\s+\((?:lib )?CPU (0x[0-9a-fA-F]+)", ln)
            if m:
                cpu = int(m.group(1), 16)
            m = re.match(r"\s+mov\s+([A-Za-z_]\w*|0x[0-9a-fA-F]{8}),\s*(a\d)$", ln)
            if not m:
                continue
            tok, reg = m.group(1), m.group(2)
            a = int(tok, 16) if tok.startswith("0x") else self.prev_data_label.get(tok)
            if a is None or not self.in_data(a):
                continue
            for j in range(i + 1, min(i + 9, len(lines))):
                lj = lines[j].split("#", 1)[0]
                mm = self.LOAD.match(lj)
                if mm and mm.group(2) == reg:
                    w = {"movbu": 1, "movhu": 2, "mov": 4}[mm.group(1)]
                    nxt = " ".join(lines[j + 1:j + 3])
                    signed = bool(re.search(r"\bext%s\s+%s\b" % ("b" if w == 1 else "h", mm.group(3)), nxt)) \
                        if w < 4 else False
                    self.readers[a].append((func, cpu, lj.strip(), w, signed))
                    break
                if re.search(r"\b%s\b" % reg, lj) and not mm:
                    if re.match(r"\s+(mov|add|sub)\s+[^,]+,\s*%s$" % reg, lj):
                        break               # the register is set to something else

    def reader_tables(self):
        """A labelled gap that the code reads with a load of one width becomes a
        table of that width (u8 / s8 / u16 / s16 / u32), up to the next label or
        item; one mostly holding the all-ones value is a sparse map keyed by
        index (ids no entry is set for read as 0xFF / 0xFFFF)."""
        starts = sorted(a for a in self.refs if self.in_data(a) and self.free(a, 1))
        self.build_index()
        # a table ends at the next address anything refers to (the code, a table, a name) or the next item
        bounds = sorted(set(self.off(a) for a in self.label_at if self.item_containing(a) is None)
                        | {self.off(a) for a in self.refs if self.in_data(a)} | {o for o in self.items})
        import bisect
        for a in starts:
            rd = self.readers.get(a)
            if not rd or not self.free(a, 1):
                continue
            widths = collections.Counter(r[3] for r in rd)
            w = widths.most_common(1)[0][0]
            signed = any(r[4] for r in rd if r[3] == w)
            o = self.off(a)
            k = bisect.bisect_right(bounds, o)
            end = bounds[k] if k < len(bounds) else DATA_END
            e = o
            while e < end and not self.claimed[e]:
                e += 1
            n = (e - o) // w
            if n < 1 or o % w:
                continue
            vals = [int.from_bytes(self.rom[o + w * i:o + w * i + w], "little", signed=signed) for i in range(n)]
            kind = ("s" if signed else "u") + str(8 * w)
            # (ties broken by function and instruction: a set's order changes from run to run)
            readers = sorted({(r[0], r[1], r[2]) for r in rd if r[3] == w}, key=lambda r: (r[1] or 0, r[0] or "", r[2]))
            fn = next((r[0] for r in sorted(rd, key=lambda r: r[1] or 0) if r[0]), None)
            base = (re.sub(r"_entry$", "", fn) + "_Table") if fn else f"tab_{a:08X}"
            self.add(a, w * n, self.name_at(a, base), "reader table",
                     lambda g, it, vals=vals, kind=kind, readers=readers, w=w: g.render_table(it, vals, kind, readers, w))

    def render_table(self, it, vals, kind, readers, w):
        ones = (1 << (8 * w)) - 1
        unset = sum(1 for v in vals if v & ones == ones)
        rd = "; ".join(f"{f or '?'} {('0x%08X' % c) if c else ''}: `{ins}`".replace("  ", " ")
                       for f, c, ins in readers[:2]) + (" ..." if len(readers) > 2 else "")
        lo, hi = min(vals), max(vals)
        if w < 4 and len(vals) >= 16 and 2 * unset >= len(vals) and unset < len(vals):
            out = [f"{it.label}:\t# {len(vals)} x {kind}, a sparse map by index: {len(vals) - unset} entries set, "
                   f"the rest 0x{ones:X} (none); read by {rd}"]
            i = 0
            while i < len(vals):
                if vals[i] & ones == ones:
                    j = i
                    while j < len(vals) and vals[j] & ones == ones:
                        j += 1
                    out.append(f"\tmap_none{8 * w}\t{j - i}\t# [{i}..{j - 1}]")
                    i = j
                else:
                    out.append(f"\tmap{8 * w}\t{i}, {vals[i]}")
                    i += 1
            return out
        out = [f"{it.label}:\t# {len(vals)} x {kind}, {lo}..{hi}; read by {rd}"]
        per = {1: 16, 2: 12, 4: 8}[w]
        for i in range(0, len(vals), per):
            out.append(f"\ttab_{kind}\t" + ", ".join(str(v) for v in vals[i:i + per])
                       + (f"\t# [{i}]" if len(vals) > per else ""))
        return out

    def typed_refs(self):
        """Strings and pointer tables at referenced addresses not claimed yet,
        and what those pointer tables point at, until nothing new appears."""
        m = self.m
        todo = sorted(self.refs)
        seen = set()
        while todo:
            a = todo.pop()
            if a in seen or not self.in_data(a):
                continue
            seen.add(a)
            o = self.off(a)
            if not self.free(a, 1):
                continue
            # a pointer table: aligned words, every one an address (or 0) in the
            # program, its library or the initialised RAM
            if a % 4 == 0:
                n = 0
                while True:
                    if not self.free(a + 4 * n, 4) or (n and (a + 4 * n) in self.refs):
                        break
                    w = m.u32(a + 4 * n)
                    if not (w and (self.in_data(w) or w in self.extern or self.in_code(w))):
                        break
                    n += 1
                if n >= 2:
                    # a NULL word right after the table ends it (a terminated list)
                    term = self.free(a + 4 * n, 4) and m.u32(a + 4 * n) == 0 and (a + 4 * n) not in self.refs
                    ws = [m.u32(a + 4 * i) for i in range(n)] + ([0] if term else [])
                    n += 1 if term else 0
                    for w in ws:
                        if self.in_data(w):
                            self.refs.add(w)
                            todo.append(w)
                    lab = self.name_at(a, f"ptrs_{a:08X}")
                    self.add(a, 4 * n, lab, "pointer table",
                             lambda g, it, ws=ws: [f"{it.label}:"] + [f"\t.long\t{g.ref(w)}" for w in ws])
                    continue
            # a string
            e = self.rom.find(b"\0", o)
            if 0 <= e - o < 512 and e > o and is_text(self.rom[o:e]) and not self.pointerish(o, e) \
                    and self.free(a, e - o + 1):
                s = self.rom[o:e].decode("latin-1")
                self.str_item(a, "Str_" + (sanitize(s, 40) or "empty"), "string")

    # -- media and compressed streams -----------------------------------------
    def media(self):
        """JPEG and BMP files and zlib streams the region holds whole.  A JPEG
        runs from SOI through its marker segments, the entropy-coded scan (where
        0xFF is always stuffed or an RSTn) and EOI; a BMP is `BM` + its own file
        size; a zlib stream ends where inflate says (decompressobj().eof)."""
        import struct
        import zlib
        rom = self.rom
        self.media_files = {}
        for mo in re.finditer(rb"\xff\xd8\xff", rom[R1_END:DATA_END]):
            o = R1_END + mo.start()
            n = self.jpeg_len(o)
            if n and self.free(BASE + o, n):
                self.add_media(o, n, "jpg")
        for mo in re.finditer(rb"BM", rom[R1_END:DATA_END]):
            o = R1_END + mo.start()
            size, res, bits = struct.unpack_from("<IIi", rom, o + 2)
            hdr = struct.unpack_from("<I", rom, o + 14)[0]
            if res == 0 and hdr in (12, 40, 108, 124) and 14 + hdr <= bits < size < 0x100000 \
                    and o + size <= DATA_END and self.free(BASE + o, size):
                self.add_media(o, size, "bmp")
        self.zlib_items = []
        for mo in re.finditer(rb"\x78[\x01\x5e\x9c\xda]", rom[R1_END:DATA_END]):
            o = R1_END + mo.start()
            if not self.free(BASE + o, 2):
                continue
            d = zlib.decompressobj()
            try:
                out = d.decompress(rom[o:DATA_END])
            except zlib.error:
                continue
            if not d.eof or len(out) < 64:
                continue
            n = DATA_END - o - len(d.unused_data)
            levels = [lv for lv in range(1, 10) if zlib.compress(out, lv) == rom[o:o + n]]
            a = self.addr_of(o)
            lab = self.name_at(a, f"zlib_{a:08X}")
            head = out[:16]
            what = ('"' + c_escape(head.split(b"\0")[0][:24]) + '..."') if is_text(head[:12]) else head[:8].hex(" ")
            note = (f"census: opaque -- compressed: a zlib stream, {n} bytes, inflating to {len(out)} bytes "
                    f"that begin {what}; " + (f"Python's zlib at level {levels[0]} re-compresses it byte-exactly, "
                                              "so the inflated data, once its format is typed, can be the source"
                                              if levels else "no zlib level reproduces it")
                    + "; the inflated bytes are not committed (bulk dump bytes)")
            it = self.add(a, n, lab, "zlib",
                          lambda g, it, o=o, n=n, note=note, out=out, level=(levels or [None])[0]:
                          g.render_zlib(it, o, n, note, out, level))
            self.zlib_items.append((a, out))

    # -- the program's own "Technics Rhythms" style resource ------------------------
    def rhythm(self):
        """TechnicsRhythmsResource (a manual-symbol name in every build): IC18's
        format with one style, typed by tools/program_rhythm.py with IC18's macros."""
        import program_rhythm
        a = self.m.sym_by_name.get("TechnicsRhythmsResource")
        if a is None or not self.in_data(a):
            return
        try:
            lines, n = program_rhythm.emit(self.rom, a - BASE, "TechnicsRhythmsResource")
        except ValueError as e:
            print(f"gen_data_s: TechnicsRhythmsResource not typed: {e}")
            return
        if not self.free(a, n):
            print("gen_data_s: TechnicsRhythmsResource overlaps a typed item; not typed")
            return
        self.rhythm_macros = program_rhythm.macro_block()
        self.label_at[a] = "TechnicsRhythmsResource"
        self.add(a, n, "TechnicsRhythmsResource", "rhythm resource", lambda g, it, lines=lines: lines)

    # -- the built-in demo songs: zlib streams typed as songs -------------------------
    def zlib_kinds(self):
        """What each zlib stream inflates to, from its content and from the
        parallel pointer tables that list them (func_48457350, program 941
        0x48457350: song n's three streams, from three 12-entry tables in the
        initialised RAM, go through func_48533758 (inflate) to the song record
        Rec8E0TablePtr(0) (0x8E0 bytes), the event memory 0x5003D36C (0x9800
        bytes) and a panel-memory bank (func_4C021A4E / func_4C021ADE):
          record  "ZZZZ" first, n * 0x8E0 bytes: kn_sqt.typer1
          events  256-byte cells, paired with the record at the same index of
                  the record table: kn_sqt.typer2
          panel   a 16-character bank name and 8 PANEL MEMORY records (the
                  .PMT bank shape, floppy/tools/kd/kn_panel.py)."""
        z = dict(self.zlib_items)
        self.zkind, self.zpair, self.zname = {}, {}, {}
        tables = []
        for it in self.items.values():
            if it.kind != "pointer table":
                continue
            ws = [self.m.u32(it.start + 4 * i) for i in range(it.size // 4)]
            if sum(1 for w in ws if w in z) >= 2:
                tables.append(ws)
        rec_tab = next((t for t in tables if any(z.get(w, b"")[:4] == b"ZZZZ" for w in t)), None)
        for a, out in z.items():
            # (the SX-KN6000 / KN6500's song record is 0x870 bytes: floppy/tools/kd/kn_sqt.py)
            if out[:4] == b"ZZZZ" and (len(out) % 0x8E0 == 0 or (P.get("scheme") == "naka" and len(out) % 0x870 == 0)):
                self.zkind[a] = "record"
            elif out[16:18] == b"@\x12" and is_text(out[:16]):
                self.zkind[a] = "panel"
            elif len(out) % 256 == 0 and rec_tab:
                for t in tables:
                    if a in t and t is not rec_tab and len(t) == len(rec_tab):
                        partner = rec_tab[t.index(a)]
                        if partner in z:
                            self.zkind[a] = "events"
                            self.zpair[a] = z[partner]
        for t in tables:
            for k, w in enumerate(t):
                if w in self.zkind:
                    self.zname[w] = f"DemoSong{k + 1:02d}"

    @staticmethod
    def kn7(lines, payload):
        """kn_sqt / kn_panel's llvm-mc lines in kn7asm syntax: `;` comments become
        `#`, octal string escapes \\ooo become \\xHH, `.fill n, 1, v` becomes
        `.space n, v`, the .include lines go (data.s includes the macros once),
        and `.incbin "REF", off, n` of the inflated payload -- free cells holding
        what an earlier song left -- become .byte rows of those bytes."""
        out = []
        for ln in lines:
            if ln.strip().startswith(".include"):
                continue
            if re.fullmatch(r"\w+:", ln.strip()):
                # no labels inside a .zlib block (theirs would be payload offsets)
                out.append(f"# {ln.strip()[:-1]}")
                continue
            mo = re.match(r'\s*\.incbin\s+"REF",\s*(0x[0-9a-fA-F]+|\d+),\s*(\d+)(.*)$', ln)
            if mo:
                o, n = int(mo.group(1), 0), int(mo.group(2))
                b = payload[o:o + n]
                out += ["\t.byte\t" + ", ".join(str(x) for x in b[k:k + 16]) for k in range(0, n, 16)]
                continue
            if ln.lstrip().startswith("; census:"):
                out.append(ln.replace("; census: opaque -- unknown-dump:", "# not events:"))
                continue
            ln = re.sub(r"\\([0-7]{3})", lambda m: "\\x%02X" % int(m.group(1), 8), ln)
            ln = re.sub(r"^(\s*)\.fill\s+(\d+),\s*1,\s*(\S+)", r"\1.space\t\2, \3", ln)
            if ln.startswith(";"):
                ln = "#" + ln[1:]
            else:
                q, cut = False, None
                for i, ch in enumerate(ln):
                    if ch == '"':
                        q = not q
                    elif ch == ";" and not q:
                        cut = i
                        break
                if cut is not None:
                    ln = ln[:cut].rstrip() + "\t# " + ln[cut + 1:].strip()
            out.append(ln)
        return out

    def typed_zlib(self, a, out):
        """The source lines of a demo-song stream's inflated content, or None."""
        sys.path.insert(0, os.path.join(KN7, "..", "floppy", "tools", "kd"))
        sys.path.insert(0, os.path.join(KN7, "..", "floppy", "tools"))
        import kn_sqt
        import kn_panel
        kind, nm = self.zkind.get(a), self.zname.get(a, f"Z{a:08X}")

        class Ctx:
            path = "demo"
        if kind == "record":
            L = kn_sqt.typer1(Ctx, 1, out, "REF", f"{nm}_Record")
        elif kind == "events":
            kn_sqt._P1["demo"] = self.zpair[a]
            L = kn_sqt.typer2(Ctx, 2, out, "REF", f"{nm}_Events", self.zpair[a])
        elif kind == "panel":
            L = [f"# the bank's name, then its 8 PANEL MEMORY records (tag / length lists ended by FF FF)",
                 f"{nm}_Panel:", '\t.ascii\t' + kn_panel.s_esc(out[:16])]
            o, k = 16, 1
            while o < len(out):
                recs, e = kn_panel.block(out, o)
                if recs is None:
                    # the last memory: the stream holds 0x3A80 bytes, 16 fewer than 16 + 8 * 0x750
                    q, part = o, []
                    while q + 2 <= len(out) and q + 2 + out[q + 1] <= len(out):
                        part.append((q, out[q], out[q + 1]))
                        q += 2 + out[q + 1]
                    L += kn_panel.block_lines(out, part, f"memory {k}, cut short: its last {len(out) - q} "
                                              f"stream bytes start a record the stream ends inside")[:-1]
                    L += ["\t.byte\t" + ", ".join(str(x) for x in out[q:])]
                    break
                L += kn_panel.block_lines(out, recs, f"memory {k}")
                o, k = e, k + 1
        else:
            return None
        if L is None:
            return None
        return self.kn7(L, out)

    def render_zlib(self, it, o, n, note, out, level):
        lines = self.typed_zlib(it.start, out) if level else None
        if lines is None:
            return [f"{it.label}:\t# {note}", f".incbin_range {ROMQ}, 0x{o:06X}, 0x{o + n:06X}"]
        kind = self.zkind[it.start]
        what = {"record": "song record", "events": "event memory", "panel": "panel-memory bank"}[kind]
        return [f"{it.label}:\t# {self.zname.get(it.start, '')}: its {what}, {len(out)} bytes, stored as a zlib "
                f"stream of {n} bytes (inflated by {P.get('inflate', 'func_48533758' if P.get('scheme', 'kn7000') == 'kn7000' else 'the program')}); kn7asm compresses it at level {level} "
                "(Python's zlib reproduces the firmware's stream byte-exactly)",
                f"\t.zlib\t{level}"] + lines + ["\t.endzlib"]

    def addr_of(self, o):
        """The CPU address code uses for file offset o (RAM for the RAM image)."""
        return o - RAMINIT_OFF + RAMINIT_RAM if RAMINIT_OFF <= o < RAMINIT_END else BASE + o

    def jpeg_len(self, o):
        rom, i = self.rom, o + 2
        while i + 4 <= DATA_END:
            if rom[i] != 0xFF:
                return None
            mk = rom[i + 1]
            if mk == 0xD9:
                return i + 2 - o
            if mk == 0x01 or 0xD0 <= mk <= 0xD7:
                i += 2
                continue
            seg = int.from_bytes(rom[i + 2:i + 4], "big")
            i += 2 + seg
            if mk == 0xDA:          # scan: entropy-coded data up to the next marker
                while i + 1 < DATA_END:
                    if rom[i] == 0xFF and rom[i + 1] != 0 and not 0xD0 <= rom[i + 1] <= 0xD7:
                        break
                    i += 1
        return None

    def add_media(self, o, n, ext):
        a = self.addr_of(o)
        lab = self.name_at(a, f"{'Jpeg' if ext == 'jpg' else 'Bmp'}_{a:08X}")
        fn = f"{lab}.{ext}"
        self.media_files[fn] = self.rom[o:o + n]
        desc = ""
        if ext == "bmp":
            import struct
            w, h, _pl, bpp = struct.unpack_from("<iiHH", self.rom, o + 18)
            desc = f"{w} x {abs(h)}, {bpp} bpp"
        else:
            j = o + 2
            while j < o + n - 9:
                if self.rom[j] == 0xFF and self.rom[j + 1] in (0xC0, 0xC1, 0xC2):
                    h = int.from_bytes(self.rom[j + 5:j + 7], "big")
                    w = int.from_bytes(self.rom[j + 7:j + 9], "big")
                    desc = f"{w} x {h}"
                    break
                j += 1
        self.add(a, n, lab, "media",
                 lambda g, it, fn=fn, n=n, ext=ext, desc=desc: [
                     f"{it.label}:\t# a {ext.upper()} file, {n} bytes" + (f", {desc}" if desc else ""),
                     f'\t.incbin\t"{OUTDIR}/media/{fn}"'])

    # -- the built-in tone / voice records (SX-KN6000 / KN6500) -----------------------
    def tones(self):
        """(`tones` profiles) ToneRecordDirectory (a manual-symbol name): the program's own
        table of tone and voice records, one u32 pointer per record index.  The KN6000's
        func_4C07C26A turns a record index into a record address: from the loaded archive
        in RAM (0x50033BF8 / 0x50033BC8) when func_4C07CF02 answers 1, else from this
        directory (`mov ToneRecordDirectory, a0 / asl2 d0 / mov (d0, a0), a0`).  The
        records it lists lie back to back, so each one's size is the distance to the
        next; three shapes occur (src/include/voice_record.inc):
          tone        0x54-byte head (16-character name, SOUND_HEAD) + n x 0x7A units
                      (SOUND_MOD), n = 1..4
          TABLE tone  class 0x40 at +0x10: the 16-character name, a 0x17-byte head and
                      128 three-byte note entries (TgNoteOnTableTone reads +0x27 + note x 3)
          voice       a 13-character name and three bytes (VOICE_HEAD_TAIL), then one or
                      two 0x1C-byte sub-records (VOICE_SUB)
        A record of any other size stays as it is (none in the KN6000 v7.1)."""
        a0 = self.m.sym_by_name.get("ToneRecordDirectory")
        if a0 is None or not self.in_data(a0):
            return
        m = self.m
        ptrs = []
        while self.in_data(m.u32(a0 + 4 * len(ptrs))) and self.free(a0 + 4 * len(ptrs), 4):
            ptrs.append(m.u32(a0 + 4 * len(ptrs)))
        targets = sorted(set(ptrs))
        recs = {}
        for i, a in enumerate(targets):
            nxt = targets[i + 1] if i + 1 < len(targets) else None
            if nxt is None or nxt - a > 0x400:     # the end of a run: the directory follows, or nothing
                nxt = a0 if a < a0 <= a + 0x400 else None
            if nxt is None:
                continue
            n = nxt - a
            raw = self.rom[self.off(a):self.off(a) + n]
            name16 = raw[:16]
            shape = None
            if n >= 0x54 + 0x7A and (n - 0x54) % 0x7A == 0 and all(0x20 <= c < 0x7F for c in name16):
                shape = ("tone", (n - 0x54) // 0x7A)
            elif n == 0x27 + 3 * 128 and raw[0x10] & 0xC0 == 0x40 and all(0x20 <= c < 0x7F for c in name16):
                shape = ("table", 128)
            elif n in (16 + 0x1C, 16 + 2 * 0x1C) and all(0x20 <= c < 0x7F for c in raw[:13]):
                shape = ("voice", (n - 16) // 0x1C)
            if shape and self.free(a, n):
                recs[a] = (n, shape, raw)
        used = set()
        names = {}
        for a, (n, shape, raw) in sorted(recs.items()):
            nm = raw[:13 if shape[0] == "voice" else 16].decode("latin-1")
            lab = self.name_at(a, ("Voice_" if shape[0] == "voice" else "Tone_") + (sanitize(nm, 30) or "unnamed"))
            names[a] = lab

            def render(g, it, raw=raw, shape=shape, nm=nm):
                kind, k = shape
                hx = lambda bs: ", ".join(f"0x{x:02x}" for x in bs)
                if kind == "tone":
                    out = [f"{it.label}:\t# tone record, {k} unit(s)", f'\t.ascii\t"{c_escape(raw[:16])}"',
                           f"\tSOUND_HEAD\t{hx(raw[0x10:0x54])}"]
                    out += [f"\tSOUND_MOD\t{hx(raw[0x54 + 0x7A * j:0x54 + 0x7A * (j + 1)])}" for j in range(k)]
                elif kind == "table":
                    out = [f"{it.label}:\t# TABLE tone record: one entry per note (TgNoteOnTableTone)",
                           f'\t.ascii\t"{c_escape(raw[:16])}"', f"\ttone_head_table\t{hx(raw[0x10:0x27])}"]
                    out += [f"\ttone_note\t{hx(raw[0x27 + 3 * j:0x2A + 3 * j])}\t# note {j}" for j in range(128)]
                else:
                    out = [f"{it.label}:\t# voice record, {k} sub-record(s)", f'\t.ascii\t"{c_escape(raw[:13])}"',
                           f"\tVOICE_HEAD_TAIL\t{hx(raw[13:16])}"]
                    out += [f"\tVOICE_SUB\t{hx(raw[16 + 0x1C * j:16 + 0x1C * (j + 1)])}" for j in range(k)]
                return out
            self.add(a, n, lab, "tone record", render)
        self.label_at[a0] = self.fixed.get(a0, "ToneRecordDirectory")
        self.add(a0, 4 * len(ptrs), self.label_at[a0], "tone directory",
                 lambda g, it, ptrs=ptrs: [f"{it.label}:\t# {len(ptrs)} record pointers by record index (func_4C07C26A)"]
                 + [f"\t.long\t{g.ref(p)}\t# {i}" for i, p in enumerate(ptrs)])
        self.tone_macros = True
        print(f"gen_data_s: tone directory {len(ptrs)} entries, {len(recs)} records typed")

    # -- the factory panel memories (SX-KN6000) -------------------------------------
    def panel_banks(self):
        """FactoryPanelMemory (a manual-symbol name): the factory PANEL MEMORY banks, the
        .PMT bank layout (floppy/tools/kd/kn_panel.py): per bank its 16-character name and
        8 memories, each a tag / length list ended by FF FF.  The KN6000's func_4C03D431
        copies the 16-byte .PMT header and then 0x2D8D0 bytes from here to the backup RAM
        (0x840007C2 / 0x840007D2, memcpy): the factory reset of the panel memories.  The
        banks are typed with the floppy describer's PMR_ lines, as the demo songs' banks."""
        a = self.m.sym_by_name.get("FactoryPanelMemory")
        if a is None or not self.in_data(a):
            return
        sys.path.insert(0, os.path.join(KN7_DIR, "..", "floppy", "tools", "kd"))
        sys.path.insert(0, os.path.join(KN7_DIR, "..", "floppy", "tools"))
        import kn_panel
        rom, o0 = self.rom, self.off(a)
        o, L, banks = o0, [], 0
        while all(0x20 <= c < 0x7F for c in rom[o:o + 16]) and rom[o + 16:o + 18] == b"@\x12":
            name, q, mem = rom[o:o + 16], o + 16, []
            for k in range(8):
                recs, e = kn_panel.block(rom, q)
                if recs is None or not recs or recs[0][1] != 0x40:
                    break
                mem.append((recs, q, e))
                q = e
            if len(mem) != 8:
                break
            L += [f"# bank {banks + 1}: {name.decode('latin-1').strip()!r}", "\t.ascii\t" + kn_panel.s_esc(name)]
            for k, (recs, _q, _e) in enumerate(mem):
                L += kn_panel.block_lines(rom, recs, f"memory {k + 1}")
            banks += 1
            o = q
        if not banks or not self.free(a, o - o0):
            return
        lines = self.kn7(L, b"")
        self.label_at[a] = "FactoryPanelMemory"
        self.add(a, o - o0, "FactoryPanelMemory", "panel banks",
                 lambda g, it, lines=lines, banks=banks: [
                     f"{it.label}:\t# {banks} banks x 8 PANEL MEMORY records, the .PMT bank layout (func_4C03D431"
                     " copies them to the backup RAM)"] + lines)
        print(f"gen_data_s: factory panel memory, {banks} banks")

    # -- bitmap resources (SX-KN6000 / KN6500) ------------------------------------
    BITMAP_METHODS = {"MT_GetBitmapData": "data", "MT_GetBitmapWidth": "w", "MT_GetBitmapHeight": "h",
                      "MT_GetBitmapPalette": "pal", "MT_GetBitCount": "bits"}

    def bitmaps(self):
        """(`bitmaps` profiles) The bitmap resources: procedures that answer the
        ResMethod ids MT_GetBitmapData / Width / Height / Palette / GetBitCount
        (`cmp <id>, d1 / beq L` ... `L: mov <value>, d0`; BitmapKn6000, BitmapNx,
        UserBitmapCheck ... in the KN6000 v7.1) give each bitmap's pixels, size,
        depth and palette.  The pixels, rows padded to an even byte count (that
        is the room every one of them has before the next referenced address),
        become an indexed PNG in <data dir>/media/ (tools/table_png.py format
        `pk D W H`), which the build turns back into the bytes; a palette is 16
        (4-bit) or 256 entries of 0x00BBGGRR, typed."""
        import table_png as TP
        ids = {v: k for k, v in self.ev_name.items()}
        if self.host is not None:
            for k, v in self.host.ev_names.items():
                ids.setdefault(v, k)
        meth = {ids[n]: f for n, f in self.BITMAP_METHODS.items() if n in ids}
        if len(meth) < 4:
            return
        by_name = {n: a for a, n in self.extern.items()}
        by_name.update(self.prev_data_label)
        by_name.update({n: a for a, n in self.fixed.items()})
        by_name.update({n: i for i, n in self.ev_name.items()})
        if self.host is not None:
            # (a plug-in) the code names the host's method ids (gui_code_ids.inc)
            for i, n in self.host.ev_names.items():
                by_name.setdefault(n, i)

        def val(t):
            t = t.strip()
            try:
                return int(t, 0)
            except ValueError:
                b, _, k = t.partition("+")
                return by_name[b] + int(k or 0) if b in by_name else None
        import glob
        found = []
        for f in sorted(glob.glob(code_glob())):
            func, body = None, []
            for line in open(f, encoding="latin-1").read().split("\n") + ["END:"]:
                mo = re.match(r"^([A-Za-z_]\w*):", line)
                if mo and not re.search(r"_L[0-9a-f]+_*$|_entry$", mo.group(1)):
                    if func and len(body) < 400:
                        txt = "\n".join(body)
                        r = {}
                        # `cmp ID, d1 / beq L` (the KN6000), or `cmp ID, d0 / bne N / bra L`
                        # (the XAPR plug-in's compiler)
                        pairs = re.findall(r"cmp\s+(\S+), d1\n\s+beq\s+(\w+)", txt) + re.findall(
                            r"cmp\s+(\S+), d[01]\n\s+bne\s+\w+\n\s+bra\s+(\w+)", txt)
                        for c, lab in pairs:
                            k = meth.get(val(c))
                            m2 = re.search(rf"^{lab}:\n\s+(?:mov\s+(\S+), d0|clr\s+d0)\n", txt, re.M)
                            if k and m2:
                                r[k] = val(m2.group(1)) if m2.group(1) else 0
                        if r.get("data") and r.get("w") and r.get("h") and r.get("bits") in (1, 2, 4, 8):
                            found.append((func, r))
                    func, body = mo.group(1), []
                body.append(line)
        pal_of = {}
        for func, r in found:
            a, w, h, depth = r["data"], r["w"], r["h"], r["bits"]
            n = TP.pk_stride(depth, w) * h
            if not self.in_data(a) or not self.free(a, n):
                print(f"gen_data_s: bitmap of {func} at {a:#x} ({n} bytes) not free; not typed")
                continue
            base = func if func.startswith("Bitmap") else "Bitmap_" + re.sub(r"^func_", "", func)
            lab = self.name_at(a, f"{base}_Pixels")
            pal = None
            p = r.get("pal")
            if p and self.in_data(p) and depth <= 8:
                np_ = 1 << depth
                if p in pal_of or self.free(p, 4 * np_):
                    vals = [self.m.u32(p + 4 * i) for i in range(np_)]
                    pal = [(v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF) for v in vals]
                    if p not in pal_of:
                        pal_of[p] = vals
                        self.add(p, 4 * np_, self.name_at(p, f"{base}_Palette"), "palette",
                                 lambda g, it, vals=vals, func=func: [
                                     f"{it.label}:\t# {len(vals)} colours, 0x00BBGGRR ({func}: MT_GetBitmapPalette)"]
                                 + [f"\t.long\t" + ", ".join(f"0x{v:08X}" for v in vals[i:i + 8]) for i in range(0, len(vals), 8)])
            fmt = f"pk {depth} {w} {h}"
            fn = f"{lab}.png"
            raw = self.rom[self.off(a):self.off(a) + n]
            png = TP.to_png(fmt, raw, pal)
            self.media_files[fn] = png
            self.add(a, n, lab, "bitmap",
                     lambda g, it, fn=fn, fmt=fmt, func=func, w=w, h=h, depth=depth: [
                         f"{it.label}:\t# {w} x {h}, {depth} bit(s) a pixel, rows padded to even bytes: the bitmap"
                         f" {func} answers MT_GetBitmapData with ({OUTDIR}/media/{fn})",
                         f'\t.incbin\t"build/bitmaps/{os.path.splitext(fn)[0]}.bin"\t# census: generated -- '
                         f"../kn7000/tools/table_png.py ({fmt}) from {OUTDIR}/media/{fn}"])

    # -- text, doubles and name / value tables in what is left -------------------
    def name_value_tables(self):
        """{name pointer, u32 value} runs (>= 4 pairs) whose names are
        identifiers: the MILK framework's own constant tables that
        tools/gen_constants.py reads (CL_ BD_ ES_ VF_ ...), and others."""
        m = self.m
        o = R1_END - R1_END % 4
        while o + 32 <= DATA_END:
            a = self.addr_of(o)
            n = 0
            while o + 8 * (n + 1) <= DATA_END and self.free(self.addr_of(o + 8 * n), 8):
                p = m.u32(self.addr_of(o + 8 * n))
                s = m.cstr(p) if p and self.in_data(p) else None
                if not s or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]{1,40}", s):
                    break
                n += 1
            if n >= 4:
                ents = []
                for k in range(n):
                    p = m.u32(self.addr_of(o + 8 * k))
                    v = m.u32(self.addr_of(o + 8 * k) + 4)
                    s = m.cstr(p)
                    self.str_item(p, "Str_" + sanitize(s, 40), "string")
                    ents.append((p, v, s))
                self.add(a, 8 * n, self.name_at(a, f"names_{a:08X}"), "name table",
                         lambda g, it, ents=ents: [f"{it.label}:"] + [
                             f"\t.long\t{g.ref(p)}, " + (s if s in g.names and g.const_value(s) == v else
                                                          g.ref(v) if g.in_data(v) or v in g.extern else
                                                          (f"0x{v:X}" if v > 0xFFFF else str(v)))
                             for p, v, s in ents])
                o += 8 * n
            else:
                o += 4

    def const_value(self, name):
        for d in self.const.values():
            for v, n in d.items():
                if n == name:
                    return v
        return None

    def panel_memories(self):
        """Built-in PANEL MEMORY records: a tag / length list (the KN5000 PanelTlv
        shape, floppy/tools/kd/kn_panel.py) that starts with the name record
        (0x40, 18), holds 43 records and fills exactly 0x750 bytes -- the
        KN7000's panel-memory record (lib func_4C021F33 copies one to
        0x84000020).  A bank's 16-character name right before its first memory is
        typed with it.  PMR_* macros of src/include/panel_memory.inc."""
        sys.path.insert(0, os.path.join(KN7, "..", "floppy", "tools", "kd"))
        sys.path.insert(0, os.path.join(KN7, "..", "floppy", "tools"))
        import kn_panel
        rom, o, k = self.rom, R1_END, 0
        while o < DATA_END - 0x750:
            if rom[o] == 0x40 and rom[o + 1] == 18 and not self.claimed[o]:
                recs, e = kn_panel.block(rom, o)
                if recs and e - o == 0x750 and len(recs) == 43 and self.free(self.addr_of(o), 0x750):
                    k += 1
                    nm = rom[o + 2:o + 18].decode("latin-1").strip()
                    a = self.addr_of(o)
                    bank = rom[o - 16:o]
                    if all(0x20 <= c < 0x7F for c in bank) and self.free(self.addr_of(o - 16), 16):
                        ba = self.addr_of(o - 16)
                        self.add(ba, 16, self.name_at(ba, "PanelBank_" + (sanitize(bank.decode()) or "noname")),
                                 "panel bank name", lambda g, it, bank=bank: [
                                     f"{it.label}:\t.ascii\t\"{c_escape(bank)}\"\t# a panel-memory bank's name"])
                    lines = self.kn7(kn_panel.block_lines(rom[o:e], [(q - o, t, n) for q, t, n in recs],
                                                          f'panel memory "{nm}"'), b"")
                    self.add(a, 0x750, self.name_at(a, "PanelMemory_" + (sanitize(nm) or f"{a:08X}")), "panel memory",
                             lambda g, it, lines=lines: [f"{it.label}:"] + lines)
                    o = e
                    continue
            o += 1

    def short_strings(self):
        """Gaps of a few bytes that are a short NUL-terminated text (1..3
        printable characters, then 0x00, then padding up to the next item):
        `.asciz`, like the longer ones text_runs takes."""
        self.build_index()
        o = R1_END
        while o < DATA_END:
            if self.claimed[o]:
                o += 1
                continue
            e = o
            while e < DATA_END and not self.claimed[e] and e - o < 16:
                e += 1
            if e < DATA_END and self.claimed[e]:
                bs = self.rom[o:e]
                z = bs.find(b"\0")
                if 1 <= z <= 3 and all(0x20 <= c < 0x7F for c in bs[:z]) and (o == R1_END or self.claimed[o - 1]) \
                        and set(bs[z + 1:]) <= {0, 0xFF}:
                    a = self.addr_of(o)
                    self.str_item(a, "Str_" + (sanitize(bs[:z].decode()) or "text"), "text")
            o = e

    def pointerish(self, o, e):
        """True when at least half the aligned words of file bytes o..e are
        program addresses: pointers into 0x485B.... read as text ("t[H u[H"),
        so such bytes are not taken for a string (a long text may still hold
        one such word by chance: "...eH" ends a word)."""
        words = range(o + (-o % 4), e - 3, 4)
        hits = sum(1 for k in words if BASE <= int.from_bytes(self.rom[k:k + 4], "little") < BASE + len(self.rom))
        return hits > 0 and 2 * hits >= len(words)

    def string_arrays(self):
        """(`string_arrays` profiles) Fixed-width text tables: >= 8 back-to-back
        NUL-terminated strings of printable ASCII, all of one length, in bytes no
        item holds (value names such as "  1.0 s ", " 16k Hz": the code indexes
        them with a stride, so a row is not a label of its own).  Each table is
        one item, a row per string."""
        rom = self.rom
        rx = re.compile(rb"(?:[\x20-\x7e]{1,40}\x00){8,}")
        for mo in rx.finditer(rom, R1_END, DATA_END):
            o = mo.start()
            parts = mo.group(0).split(b"\0")[:-1]
            i = 0
            while i < len(parts):
                j = i
                while j < len(parts) and len(parts[j]) == len(parts[i]):
                    j += 1
                L = len(parts[i]) + 1
                if j - i >= 8 and L >= 3:
                    a = self.addr_of(o)
                    rows = parts[i:j]
                    if self.free(a, L * len(rows)) and sum(1 for c in b"".join(rows) if c > 0x20) >= len(rows):
                        lab = self.name_at(a, "Text_" + (sanitize(rows[0].decode("latin-1"), 24) or "table"))
                        self.add(a, L * len(rows), lab, "text table",
                                 lambda g, it, rows=rows, L=L: [
                                     f"{it.label}:\t# {len(rows)} strings of {L - 1} characters, NUL-terminated"]
                                 + [f'\t.asciz\t"{c_escape(r)}"' for r in rows])
                o += L * (j - i)
                i = j

    def text_runs(self):
        """NUL-terminated printable strings (>= 4 characters) in the bytes no
        item holds: message text, help pages, file names the code reaches with
        computed offsets.  A run is typed only where the string starts right
        after a NUL / 0xFF / an item, so a string's tail is never split off."""
        rom = self.rom
        rx = re.compile(rb"[\x20-\x7e\x09\x0a\x0d\x80-\xfe]{4,}\x00")
        for mo in rx.finditer(rom, R1_END, DATA_END):
            o, e = mo.start(), mo.end()
            bs = rom[o:e - 1]
            if not is_text(bs) or sum(1 for c in bs if 0x41 <= c <= 0x7A) < 3:
                continue
            if P.get("text_strict") and self.fake_text(bs):
                continue
            if o > R1_END and rom[o - 1] not in (0x00, 0xFF) and not self.claimed[o - 1]:
                continue
            a = self.addr_of(o)
            if self.free(a, e - o) and not self.pointerish(o, e - 1):
                self.str_item(a, "Str_" + (sanitize(bs.decode("latin-1"), 40) or "text"), "text")

    @staticmethod
    def fake_text(bs):
        """(`text_strict` profiles) A short printable run that is most likely pixels or
        packed numbers, not text: under 8 characters with no vowel ("HPPd", "N QZ"), or
        a letter three times in a row in a run under 12 ("PPP@", "wwww1").  Such runs in
        the SX-KN6000's bitmaps and tables would otherwise become Str_ labels."""
        if len(bs) < 8 and not re.search(rb"[AEIOUaeiou]", bs):
            return True
        return len(bs) < 12 and re.search(rb"([A-Za-z])\1\1", bs) is not None

    def doubles(self):
        """Runs (>= 4) of 8-aligned IEEE-754 doubles of plausible magnitude
        (1e-12 .. 1e12, or zero) in the bytes no item holds."""
        import struct
        rom = self.rom
        o = R1_END + (-R1_END % 8)
        while o + 32 <= DATA_END:
            n = 0
            while o + 8 * (n + 1) <= DATA_END and self.free(self.addr_of(o + 8 * n), 8) \
                    and not RAMINIT_OFF <= o + 8 * n < RAMINIT_END:     # RAM variables are not tables
                v = struct.unpack_from("<d", rom, o + 8 * n)[0]
                if not (v == 0.0 and rom[o + 8 * n:o + 8 * n + 8] == bytes(8) or 1e-12 < abs(v) < 1e12):
                    break
                if v != v:
                    break
                n += 1
            nz = sum(1 for k in range(n) if rom[o + 8 * k:o + 8 * k + 8] != bytes(8))
            if n >= 4 and nz >= n // 2 + 1:
                vals = [struct.unpack_from("<IId", rom, o + 8 * k) for k in range(n)]
                a = self.addr_of(o)
                self.add(a, 8 * n, self.name_at(a, f"doubles_{a:08X}"), "double table",
                         lambda g, it, vals=vals: [f"{it.label}:\t# IEEE-754 doubles (lo word, hi word)"] + [
                             f"\t.long\t0x{lo:08X}, 0x{hi:08X}\t# {d:.9g}" for lo, hi, d in vals])
                o += 8 * n
            else:
                o += 8

    def gaps(self):
        """Label every referenced address not inside a typed item; the bytes
        between typed items stay .incbin_range, split at those labels.  A name
        given to an address that a typed item turned out to hold (not at its
        start) is dropped: ref() spells it Item+N."""
        for a in list(self.label_at):
            it = self.item_containing(a)
            if it is not None and it.start != a:
                del self.label_at[a]
        for a in sorted(self.refs):
            if self.in_data(a) and self.item_containing(a) is None:
                self.label_at.setdefault(a, self.fixed.get(a) or self.uniq(
                    (f"ram_{a:08X}" if a < BASE else f"data_{a:08X}")))

    # ======================================================================
    # output
    # ======================================================================
    def emit(self, outdir):
        self.build_index()
        self.class_macros()
        if self.check_pads():
            sys.exit("gen_data_s: padding bytes are not zero; the class macros would not be byte-exact")
        # cut points: item starts and labelled gap addresses, in file order
        gap_labels = collections.defaultdict(list)
        for a, n in self.label_at.items():
            if self.item_containing(a) is None:
                gap_labels[self.off(a)].append(n)
        body = []
        cur = R1_END

        def mnbase_for(o):
            return RAM_MNBASE if RAMINIT_OFF <= o < RAMINIT_END else BASE

        cur_base = BASE
        prev_group = None
        events = sorted(set(self.items) | set(gap_labels) | {RAMINIT_OFF, RAMINIT_END})
        for o in events + [DATA_END]:
            if o > DATA_END:
                continue
            if cur < o:
                body += self.gap_lines(cur, o)
                cur = o
            if o == DATA_END:
                break
            want = mnbase_for(o)
            if want != cur_base:
                body += ["", f".mnbase 0x{want:08X}" + ("   # the initialised-RAM image: labels are the RAM"
                                                        " addresses ResetEntry copies it to"
                                                        if want != BASE else "   # flash addresses again"), ""]
                cur_base = want
            for n in sorted(gap_labels.get(o, [])):
                body.append(f"{n}:")
            it = self.items.get(o)
            if it is not None:
                group = "string" if it.kind in self.STRING_KINDS else it.kind
                if group != prev_group or (it.kind == "widget" and it.depth == 0):
                    body.append("")
                prev_group = group
                body += it.render(self, it)
                cur = o + it.size
        if cur_base != BASE:
            body.append(f".mnbase 0x{BASE:08X}")
        # split into parts
        os.makedirs(os.path.join(KN7, outdir), exist_ok=True)
        parts, chunk = [], []
        for ln in body:
            chunk.append(ln)
            if len(chunk) >= LINES_PER_FILE and ln == "":
                parts.append(chunk)
                chunk = []
        if chunk:
            parts.append(chunk)
        hdr = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
               "# Licensed under the terms of the GNU General Public License v3 or later",
               "#"]
        top = hdr + [
            f"# The data region of program build {PROFILE} (file 0x{R1_END:06X}..0x{DATA_END:06X}), GENERATED by",
            f"# tools/gen_data_s.py --profile {PROFILE} -- do not edit by hand.  Included by {P['prog']}",
            "# after code region 1; the library image follows.  See tools/gen_data_s.py and",
            "# tools/milk_model.py for what each structure is and the firmware code that reads it.",
            "",
            f'.include "{P.get("constants", "src/constants.inc")}"',
            f'.include "{SHARED}src/include/kn_song.inc"',
            f'.include "{SHARED}src/include/panel_memory.inc"',
            *([f'.include "{SHARED}src/include/voice_record.inc"', f'.include "{OUTDIR}/tone_macros.inc"']
              if self.tone_macros else []),
            f'.include "{SHARED}src/include/kn_panel_extra.inc"',
            f'.include "{SHARED}src/include/data_tables.inc"',
            f'.include "{outdir}/rhythm_macros.inc"',
            f'.include "{outdir}/gui_ids.inc"',
            f'.include "{outdir}/gui_classes.inc"',
            "",
            f".org 0x{R1_END:06X}"]
        for n in range(len(parts)):
            top.append(f'.include "{outdir}/data_{n:02d}.s"')
        top.append(f".org 0x{DATA_END:06X}")
        self.write(os.path.join(outdir, "data.s"), top)
        for n, p in enumerate(parts):
            self.write(os.path.join(outdir, f"data_{n:02d}.s"),
                       hdr + [f"# data.s part {n:02d}: GENERATED by tools/gen_data_s.py -- do not edit by hand.", ""] + p)
        self.write(os.path.join(outdir, "gui_classes.inc"), hdr + self.classes_inc())
        # every label the data region defines, for tools/gen_program_s.py: the
        # converted code names a data address by it (`Label` or `Label+N`)
        sym = ["; Data-region labels of program build " + PROFILE + ", GENERATED by tools/gen_data_s.py:",
               "; cpu_addr  name  size (bytes of the typed item it starts; 0 = a label in raw bytes)"]
        sizes = {it.start: it.size for it in self.items.values()}
        for a, n in sorted(self.label_at.items()):
            sym.append(f"0x{a:08X}  {n}  {sizes.get(a, 0)}")
        self.write(os.path.join(outdir, "labels.sym"), sym)
        if P.get("functions_sym"):
            self.write_functions_sym(os.path.join(outdir, "functions.sym"))
        md = os.path.join(KN7, outdir, "media")
        os.makedirs(md, exist_ok=True)
        for fn, bs in sorted(self.media_files.items()):
            with open(os.path.join(md, fn), "wb") as f:
                f.write(bs)
        for fn in os.listdir(md):
            if fn not in self.media_files:
                os.remove(os.path.join(md, fn))
        self.write(os.path.join(outdir, "gui_ids.inc"), hdr + self.ids_inc())
        if self.tone_macros:
            self.write(os.path.join(outdir, "tone_macros.inc"), hdr + [
                "# A TABLE tone's head after its name and its per-note entries: the same macros as",
                "# kn7000/src/table/style_macros.inc (that file also holds style macros whose names the",
                "# rhythm resource's macros take), GENERATED by tools/gen_data_s.py.",
                "# TgNoteOnTableTone (KN7000 lib 0x4C03600D) reads the entry at +0x27 + note x 3: it",
                "# enables up to two synth layers.",
                ".macro tone_head_table class, b11, b12, b13, b14, b15, b16, b17, b18, b19, b1a, b1b, b1c, b1d, b1e, b1f, b20, b21, b22, b23, b24, b25, b26",
                "\t.byte\t\\class, \\b11, \\b12, \\b13, \\b14, \\b15, \\b16, \\b17, \\b18, \\b19, \\b1a, \\b1b, \\b1c, \\b1d, \\b1e, \\b1f",
                "\t.byte\t\\b20, \\b21, \\b22, \\b23, \\b24, \\b25, \\b26",
                ".endm",
                ".macro tone_note a, b, c",
                "\t.byte\t\\a, \\b, \\c",
                ".endm"])
        self.write(os.path.join(outdir, "rhythm_macros.inc"), hdr + [
            "# The style-record and event macros of src/ic18/rhythm.s (tools/gen_ic18_rhythm_s.py), copied",
            "# verbatim by tools/gen_data_s.py for the program's own Technics Rhythms resource; do not edit.",
            ""] + self.rhythm_macros)
        self.write(os.path.join(outdir, "code_refs.txt"), [
            "# Code addresses the typed data points at (jump and pointer tables), GENERATED by",
            "# tools/gen_data_s.py: tools/gen_program_s.py labels each loc_<ADDR> (or .equ's it when it is",
            "# not an instruction start)."] + [f"0x{a:08X}" for a in sorted(self.code_targets)])
        ev = ["# The MILK event (EV_) and method (MT_) ids of block 0's Event and Method name tables,",
              "# GENERATED by tools/gen_data_s.py: id = (registry slot << 16) | index, slot 5 events, 6",
              "# methods (the IDNAME tables in data_NN.s compute the same values from their entries'",
              "# positions).  Included by the program source before the code, which names them in",
              "# `mov` / `cmp` immediates (tools/gen_program_s.py).", ""]
        for i, n in sorted(self.ev_name.items()):
            if (i >> 16) in (5, 6):
                ev.append(f".equ {n}, 0x{i:08X}")
        self.write(os.path.join(outdir, "gui_event_ids.inc"), hdr + ev)
        ids = ["# The other MILK ids the code passes, GENERATED by tools/gen_data_s.py: title (TT_), mode (MD_)",
               "# and OT-block ids (gui_ids.inc), class ids (CLASS_*, the class tables), function ids (FN_*,",
               "# the Function / ApFunction / MainFunction tables) and object ids (<object>_id, the Viewable",
               "# tables; block 0's are left out, being 0..8; so is every index-0 id), numerically, for the",
               "# code before the data:",
               "# tools/gen_program_s.py names them in `mov IMM, dN` / `cmp IMM, dN`.  The tables compute",
               "# the same values from their entries' positions, and the code's bytes check them.", ""]
        seen = set()
        # (siblings, NAKA layout: their event and method ids are in the ResEvent / ResMethod
        # tables of every module, slots 0x180.., not in gui_event_ids.inc's slots 5 / 6)
        evs = ((("events and methods", self.ev_name),) if P.get("scheme") == "naka" or "root" in P else ())
        if self.host is not None:
            # (a plug-in) the host's ids its code passes and compares: its events, methods,
            # functions, titles and modes (the host's registry, not tables of this image)
            evs = ((f"the {P['host'].upper()}'s events and methods",
                    {i: n for i, n in self.host.ev_names.items() if n not in self.names}),
                   (f"the {P['host'].upper()}'s functions, titles and modes",
                    {i: n for i, n in self.host.id_names.items() if n not in self.names})) + evs
        for title, d in evs + (("titles, modes, OT blocks", self.id_name),
                         ("classes", {self.cid_value(c): n for c, n in self.cls_id.items()}),
                         ("functions", self.fn_name),
                         ("objects", {i: n + "_id" for i, n in self.obj_by_id.items() if i >> 16})):
            ids.append(f"# {title}")
            for i, n in sorted(d.items()):
                # index 0 is left out: (slot << 16) is a round number the code also uses as a
                # plain constant (0x100000, 0x20000)
                if i >= 0x10000 and i & 0xFFFF and i not in seen:
                    seen.add(i)
                    ids.append(f".equ {n}, 0x{i:08X}")
        self.write(os.path.join(outdir, "gui_code_ids.inc"), hdr + ids)
        # stale parts
        for fn in os.listdir(os.path.join(KN7, outdir)):
            mo = re.fullmatch(r"data_(\d\d)\.s", fn)
            if mo and int(mo.group(1)) >= len(parts):
                os.remove(os.path.join(KN7, outdir, fn))
        return len(parts)

    def write_functions_sym(self, rel):
        """(`functions_sym` profiles) The procedures the MILK Function / ApFunction /
        MainFunction tables name, as a symbol file for the code generator
        (gen_image_s.py --sym): the firmware's own name for each code address, from
        the parallel name table (slot + 0x200), where the build's symbol files give
        that address none.  A name another address already has is not used."""
        m = self.m
        used = set(m.sym_by_name)
        out = ["; Procedures named by the MILK Function / ApFunction / MainFunction tables of " + PROFILE + ",",
               "; GENERATED by tools/gen_data_s.py from the tables the InitializeUserNN routines register",
               "; (code pointer table + its parallel name table); only addresses no other symbol file names."]
        rows = []
        for a, nm in sorted(self.fn_code.items()):
            if a in m.sym_by_addr or self.in_data(a) or not BASE <= a < BASE + len(self.rom):
                continue
            if not re.fullmatch(r"[A-Za-z_]\w*", nm) or nm in used:
                continue
            used.add(nm)
            rows.append(f"0x{a:08X}  {nm}")
        self.write(rel, out + rows)

    STRING_KINDS = {"string", "text", "class name", "class sig", "field name", "event name", "method name",
                    "function name", "resource name", "widget text"}

    def gap_lines(self, a, b):
        """The bytes a..b (file offsets) no typed item holds: a uniform run is
        .space (or .align, when it is the padding up to a 4-byte boundary after
        a string or record); the rest stays .incbin_range of the reference."""
        d = self.rom[a:b]
        if len(set(d)) == 1:
            fill = d[0]
            if b - a < 4 and b % 4 == 0:
                prev = self.item_containing(self.addr_of(a - 1)) if a > R1_END else None
                return [f"\t.align\t4, 0x{fill:02X}" + (f"\t# pad after {prev.label}" if prev and prev.label else "")]
            return [f"\t.space\t{b - a}, 0x{fill:02X}" + ("\t# erased flash" if fill == 0xFF and b - a >= 256 else "")]
        # runs of >= 64 equal bytes inside the gap are fill too
        out, cur = [], a
        for mo in re.finditer(rb"(.)\1{63,}", d, re.S):
            s, e = a + mo.start(), a + mo.end()
            if cur < s:
                out.append(f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{s:06X}")
            out.append(f"\t.space\t{e - s}, 0x{d[mo.start()]:02X}")
            cur = e
        if cur < b:
            out.append(f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{b:06X}")
        return out

    def classes_inc(self):
        return [
            "# The MILK widget classes, one assembler macro each, GENERATED by tools/gen_data_s.py.",
            "# A record's bytes are its class chain's fields, root first (milk_model.py: the C struct",
            "# layout of the MN10300 compiler; field names are the class tables' own propname lists).",
            "# Common parameters: `this` (the object's label), super / sub / next / prev (the parent,",
            "# first child, next and previous sibling, by object name: NONE when absent; written as",
            "# <name>_ix, the object's index in its Viewable table), and X / Y / W / H, the rect,",
            "# stored as {left, top, right, bottom} with right = X + W - 1 (the full-screen Screen",
            "# objects hold 0, 0, 639, 239: the 640 x 240 LCD).",
            "",
            ".equ NONE_ix, 0xFFFF",
            ".equ NOCLASS, 0xFFFFFFFF",
            "",
            f"# class table record (ClassProc {sym_addr('ClassProc', '0x4842A802')}: proc +0, parent +4, allsize +8, selfsize +10,",
            "# name +12, propdata +16, propname +20); `id` is the class id the records hold",
            ".macro CLASS this, id, table, proc=0, parent=NOCLASS, allsize=0, selfsize=0, cname=0, sig=0, fields=0",
            "\\this\\():",
            "\t.equ\t\\id, (\\table\\()_SLOT << 16) | ((\\this - \\table) / 24)",
            "\t.long\t\\proc, \\parent",
            "\t.word\t\\allsize, \\selfsize",
            "\t.long\t\\cname, \\sig, \\fields",
            ".endm",
            "",
            "# one entry of a Viewable table: defines the object's index and id",
            ".macro OBJ this, table, slot",
            "\\this\\()_at:",
            "\t.equ\t\\this\\()_ix, (\\this\\()_at - \\table) / 4",
            "\t.equ\t\\this\\()_id, (\\slot << 16) | \\this\\()_ix",
            "\t.long\t\\this",
            ".endm",
            "",
            "# one entry of an Event / Method / Function table: `id` = (slot << 16) | index",
            ".macro IDNAME id, value, table, slot",
            "\\id\\()_at:",
            "\t.equ\t\\id, (\\slot << 16) | ((\\id\\()_at - \\table) / 4)",
            "\t.long\t\\value",
            ".endm",
            ""] + self.host_class_ids() + self.macro_lines

    def host_class_ids(self):
        """(a plug-in) `.equ` lines for the host firmware's classes this image's
        classes derive from and its records are instances of: their ids are the
        host's registry (`P["host"]`), not tables of this image."""
        m = self.m
        if m.host is None:
            return []
        own = set()
        for slot, r in m.by_slot.items():
            if r["kind"] == "Class":
                own |= {(slot << 16) | k for k in range(r["count"])}
        used = set()
        for cid in list(own) + [o.klass.id for b in m.blocks.values() for o in b["objects"] if o.klass]:
            used |= {k.id for k in m.chain(cid)}
        rows = [f".equ {self.cls_id[c]}, 0x{c:08X}\t# {m.classes[c].name}" for c in sorted(used - own)]
        return [f"# The {P['host'].upper()}'s classes this image's classes derive from and its records use:",
                f"# their ids are the host's (its class tables, ../{P['host']}/src/program/data/)."] + rows + [""]

    def ids_inc(self):
        m = self.m
        out = ["# The OT-block, title and mode ids, GENERATED by tools/gen_data_s.py from the start-up code's",
               f"# RegisterOTBlock ({sym_addr('RegisterOTBlock', '-')}), RegisterTitle ({sym_addr('RegisterTitle')})"
               f" and RegisterMode ({sym_addr('RegisterMode')}) calls:",
               f"# id = (registry slot << 16) | index, slot 0x{MM.SCHEMES[MM.SCHEME]['otb_slot'] or 0:X} OT blocks,"
               f" 0x{MM.SCHEMES[MM.SCHEME]['title_slot']:X} titles, 0x{MM.SCHEMES[MM.SCHEME]['mode_slot']:X} modes; each name is",
               "# the string the call registers.", ""]
        for title, d in (("OT blocks", m.otblocks), ("titles", m.titles), ("modes", m.modes)):
            out.append(f"# {len(d)} {title}")
            for i, (nm, _a, c) in sorted(d.items()):
                extra = ""
                if d is m.titles:
                    scr = c["stack"].get(0x10)
                    extra = f"\t# screen {self.obj_by_id.get(scr, hex(scr) if isinstance(scr, int) else '?')}"
                out.append(f".equ {self.id_name[i]}, 0x{i:08X}{extra}")
            out.append("")
        if self.host_used:
            out += [f"# the {P['host'].upper()}'s titles and functions this image's records name (the host's ids)"]
            out += [f".equ {self.host_ids[i]}, 0x{i:08X}" for i in sorted(self.host_used)] + [""]
        return out

    @staticmethod
    def write(rel, lines):
        with open(os.path.join(KN7, rel), "w") as f:
            f.write("\n".join(lines).rstrip("\n") + "\n")

    def run(self, outdir):
        self.rhythm_macros = []
        self.gui()
        if PALETTE is not None:
            self.palette()
        self.rhythm()
        self.tone_macros = False
        if P.get("tones"):
            self.tones()
            self.panel_banks()
        self.media()
        if P.get("bitmaps"):
            self.bitmaps()
        self.code_refs()
        self.typed_refs()
        self.name_value_tables()
        self.doubles()
        self.panel_memories()
        if P.get("string_arrays"):
            self.string_arrays()
        self.text_runs()
        self.reader_tables()
        self.short_strings()
        self.zlib_kinds()
        self.build_index()
        self.gaps()
        n = self.emit(outdir)
        kinds = collections.Counter()
        for it in self.items.values():
            kinds[it.kind] += it.size
        typed = sum(kinds.values())
        print(f"gen_data_s: {len(self.items)} typed items, {typed} of {DATA_END - R1_END} bytes "
              f"({100 * typed / (DATA_END - R1_END):.1f}%) in {n} parts")
        for k, v in kinds.most_common():
            print(f"  {k:16s} {v:9d}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--profile", default="941", choices=sorted(PROFILES))
    ap.add_argument("--out", help="output directory (default: <the build's source>/data)")
    a = ap.parse_args()
    os.chdir(KN7)
    configure(a.profile)
    Gen().run(a.out or OUTDIR)


if __name__ == "__main__":
    main()
