#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""gen_data_s.py -- the program image's data region as typed source.

QUESTION ANSWERED
-----------------
"What is every byte of the data region of program build 941 (file offsets
0x186000..0x3B8B78, CPU 0x48586000..0x487B8B78, the initialised-RAM image
included), written so that a reader can see it?"  (The region ends where the
code gen_program_s.py finds at its end starts, <data dir>/tail_code.txt: the
MILK kernel's flash tail, up to the library image at 0x3B8FD1.)

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
import struct
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
                labels="build/kn7000_program.labels", r1=0x186000, pal=0x32573C, end=0x3B8FD1, structs=True,
                bitmaps=True, bitmap_bits=4, bitmap_dir="build/bitmaps/941", string_arrays=True, string_arrays_min=4, text_strict=True, readers_ext=True),
    "b935": dict(rom="baserom/kn7000_program_b935.rom", src="src/b935/program", prog="src/b935/program.s",
                 syms=["kn7000_b935.sym", "kn7000_b935_manual.sym", "kn7000_b935_exports.sym",
                       "kn7000_b935_bycode.sym", "kn7000_b935_own.sym"],
                 labels="build/kn7000_program_b935.labels", r1=0x18595C, pal=0x3256D8, end=0x3B8F6D, structs=True,
                bitmaps=True, bitmap_bits=4, bitmap_dir="build/bitmaps/b935", string_arrays=True, string_arrays_min=4, text_strict=True, readers_ext=True),
    "b893": dict(rom="baserom/kn7000_program_b893.rom", src="src/b893/program", prog="src/b893/program.s",
                 syms=["kn7000_b893.sym", "kn7000_b893_manual.sym", "kn7000_b893_exports.sym",
                       "kn7000_b893_bycode.sym", "kn7000_b893_own.sym"],
                 labels="build/kn7000_program_b893.labels", r1=0x1846A0, pal=0x323E80, end=0x3B76B1, structs=True,
                bitmaps=True, bitmap_bits=4, bitmap_dir="build/bitmaps/b893", string_arrays=True, string_arrays_min=4, text_strict=True, readers_ext=True),
    "sp7001": dict(rom="baserom/kn7000_program_sp7001.rom", src="src/sp7001/program", prog="src/sp7001/program.s",
                   syms=["kn7000_sp7001.sym", "kn7000_sp7001_manual.sym", "kn7000_sp7001_new.sym",
                         "kn7000_sp7001_exports.sym"],
                   labels="build/kn7000_program_sp7001.labels", r1=0x1864F4, pal=0x326760, end=0x3BA785, structs=True,
                bitmaps=True, bitmap_bits=4, bitmap_dir="build/bitmaps/sp7001", string_arrays=True, string_arrays_min=4, text_strict=True, readers_ext=True),
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
                        functions_sym=True, bitmaps=True, code_ids=True, text_strict=True, tones=True,
                        # lane siblings-final: the reader-typed passes of the KN7000 profiles
                        structs=True, string_arrays=True, string_arrays_min=4,
                        style_panels=("StyleRecordTable", 0, 0x90))
# (KN6000 v7.1) the built-in sound tables' three hash tables, read when no voice archive is loaded
# (func_4C07B982 answers neither 1 nor 2): kn6000/notes/siblings-data-final/README.md
# (KN6500 v1.3) its program flash holds the factory panel memories too (FactoryPanelMemory, kn6500_manual.sym);
# it has no ToneRecordDirectory, so tones() finds nothing
PROFILES["kn6500"]["tones"] = True
PROFILES["kn6000"]["hash_tables"] = [
    ("ToneKeyHash", 0x4C3E8680, 4, 12, "ToneKeyLookup", 8,
     "Key: bank MSB << 16 | LSB << 8 | program (ToneKeyFind builds it from the part's sound triple); payload: "
     "the tone index, the icon and the panel switch numbers (TONE_KEY_PAYLOAD, src/include/data_tables.inc)."),
    ("ShortKeyHash", 0x4C3E9850, 2, 6, "ShortKeyLookup", 6,
     "Key: a panel switch, group << 8 | number (SoundSwNoBankGet builds it); payload: the bank MSB, LSB and program "
     "it selects (SHORT_KEY_PAYLOAD)."),
    ("BankKeyHash", 0x4C3EC6A0, 4, 4, "BankKeyLookup", 8,
     "Key: MSB << 16 | LSB << 8 | program (SoundBankIndexGet); payload: the u16 SoundBankIndexGet answers (`movhu (a0), d0`; "
     "BANK_KEY_PAYLOAD)."),
]
# The SX-KN2400 / SX-KN2600 (program v1.1): the KN7000's registry layout (16 slots
# per block) and alphabet; data first in the image (file 0x0F, after the boot
# vectors, to the MILK kernel's code at 0x1E427C).
PROFILES["kn2400"] = dict(root="../kn2400", rom="baserom/kn2400_program.rom", src="src/program",
                          code="src/program.s", prog="src/program.s",
                          syms=["kn2400.sym", "kn2400_manual.sym", "kn2400_ported.sym"],
                          labels=["src/symbols.inc", "src/labels.inc"], r1=0x00000F, pal=None, end=0x1E427C,
                          model="KN2400", functions_sym=True, bitmaps=True, code_ids=True, text_strict=True,
                          string_arrays=True, structs=True,
                          # crt0_start copies .data 0x485DD334 -> 0x50000010, 0x6E78 bytes (kn2400_manual.sym);
                          # stated, since the typed code spells the copy's source as a data label
                          raminit=(0x485DD334, 0x50000010, 0x6E78),
                          # lane mn10300-data2: TitleNameTable (0x140 name pointers, title i's "_TT_<NAME>")
                          title_names=(0x48414BD8, 0x140),
                          # func_486183E3 inflates demo song n's three streams (ptrs_50000C18 / C48 / C78)
                          # through func_486D4A2A, as the KN7000's func_48457350 through func_48533758
                          inflate="func_486D4A2A",
                          # lane siblings-final: the built-in Music Stylist setups' one-touch settings (KN7000 layout)
                          style_panels=("StyleRecordTable", 0, 0xA0),
                          # lane mn10300-formats: the DSP effects' descriptors (FxDescTable, kn2400_manual.sym)
                          fx_descriptors=260,
                          # lane mn10300-rest: the effect DSP's programs, scripts and maps for the 208 DSP types
                          # (FxTypeProgramTable, kn2400_manual.sym; FxDspProgramLoad checks `cmp 0xcf, d0`)
                          fx_streams=208,
                          # lane mn10300-data: the DSP effect presets FxPresetGet / FxPresetVarGet return
                          fx_presets=("FxPresetTable", 8192, "FxPresetVarTable", 64),
                          # the application's code is after the data (Makefile CODE: file 0x1E427C..0x3285BE),
                          # and the part linked for RAM 0x50120000 (file 0x3285BE..0x3965B8)
                          code_cpu=[(0x485E427C, 0x487285BE), (0x50120000, 0x5018DFFA)])
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
                         bitmaps=True, code_ids=True, text_strict=True, string_arrays=True, structs=True,
                         raminit=(0x978B3E84, 0x97910000, 0x26D8))
# The SP7001's XAPR plug-in in table flash 83 (Key Soft Service, table 0x3E8000..0x3FB5A0, linked at
# 0x48000000): code 0x3E803C..0x3EF6C5 (gen_table_s.py --plugin-code), then its data to the footer
# 'XAPR' at 0x3FB59C.  It runs on program 942 (`host`): its records use 942's block-0 classes and its
# own (registry block 0x2F0, func_483E8071's registrations), it calls 942's routines through 942's
# Function table (registry slot 1: `mov (0x50299298), aN / mov (0x1c, aN), aN / mov (OFF, aN), aM /
# calls (aM)`), and its initialised RAM is copied from 0x483FA104 to 0x50298000 (0x1498 bytes,
# func_483E803E's second loop).  Its code is src/sp7001/table.s (gen_table_s.py), whose plug-in pass
# includes the data this profile writes to src/sp7001/plugin/data/.
PROFILES["sp7001plugin"] = dict(rom="baserom/kn7000_table_sp7001.rom", src="src/sp7001/plugin",
                                code="src/sp7001/table.s", prog="src/sp7001/table.s",
                                syms=["kn7000_sp7001_table.sym", "kn7000_sp7001_table_manual.sym"],
                                labels="build/kn7000_table_sp7001.labels", r1=0x3EF6C5, pal=None,
                                end=0x3FB59C, base=0x48000000, model="SP7001 plug-in", host="sp7001",
                                text_strict=True, string_arrays=True, string_arrays_min=4, header_funcs=True, residue=True,
                                raminit=(0x483FA104, 0x50298000, 0x1498),
                                # func_483E803E's first loop clears 0xA48 bytes from 0x50299498
                                bss=(0x50299498, 0xA48, "KssWorkRam"), raminit_label="KssRamImage",
                                # lane mn10300-formats: KssBgScreen's own fields (kn7000/notes/mn10300-formats/README.md)
                                field_notes={
                                    ("KssBgScreen", "icon"): "icon {v}: the host's ResIconTable[{v}] (table flash, "
                                    "src/table/gui/icon_{v:03d}.png), drawn by 942's DrawTitleBar -> DrawIcons for MT_GetIcon",
                                    ("KssBgScreen", "image_id"): "image_id 0x{v:X}: no routine of the plug-in reads it "
                                    "(942's Screen ends at +0x28); not a resource-trie id"})
# lane generic-zero: the bytes an instruction reads that no pass typed are rows of the reads' widths
# (reader_rows), not a generic .incbin_range, in the program builds and the siblings
for _m in ("941", "b935", "b893", "sp7001", "kn6000", "kn6500", "kn2400", "hdsx3"):
    PROFILES[_m]["reader_rows"] = True
# lane mn10300-data: the single rules of the KN7000's `readers_ext` walk the siblings take (data_readers
# Reader(sib_rules=)), each measured alone on the KN6000 and the KN2400 (kn7000/notes/mn10300-data/README.md,
# section 3): `fieldret` changes nothing in either; `reloadbound` types a little more in both; `loopslots`
# changes nothing in the KN6000 and turns 4.5 KB of the KN2400's reader rows into records; `setlb` loses
# 5,877 typed bytes of the KN6000 (func_4C03C193's results, func_4C037CBF's copies) and names two more
# KN2400 fields.  So each profile takes the rules that lose nothing there.
for _m in ("kn6000", "kn6500", "hdsx3"):
    PROFILES[_m]["sib_rules"] = ("reloadbound",)
PROFILES["kn2400"]["sib_rules"] = ("loopslots", "reloadbound", "setlb")
# lane callee-walk: a block whose address is passed to a routine is a record of what the routine reads
# through that argument (data_readers.Reader(callee=): register and stack arguments, arg_layout)
for _m in ("941", "b935", "b893", "sp7001", "kn6000", "kn6500", "kn2400", "hdsx3"):
    PROFILES[_m]["readers_callee"] = True
PROFILE = "941"
# (lane mn10300-typer, 2026-10-31) the typer and walk rules it added, each switchable so that
# kn7000/notes/mn10300-typer-probes/ can measure what each one changes; all on by default:
#   ptr_starts   a word is a pointer into code only when it lands on an instruction start
#   array_end    a stepped pointer compared with an address (`cmp End, aN`, a loop back) ends its array
#   mem_ptrs     (walk) a data address stored to a RAM global or a record field and loaded back
#   loop_index   (walk) an index register a loop steps is an induction variable, not its first value
#   step_arrays  a loop stepping a parameter pointer by N >= 2 over a bounded block: N-byte records
#   deep_records records a typed pointer field leads to are followed again, depth-guarded
# (lane mn10300-rest, 2026-10-31; kn7000/notes/mn10300-rest/README.md)
#   top_tested   (walk) a pointer loop that compares at its head (`L: cmp End, aN` / exit / ... / `bra L`)
#                ends its array too, as array_end's bottom-tested loops do
#   fld_slots    (walk, with mem_ptrs) a pointer loaded from a typed field and stored to a memory slot,
#                the only thing ever stored there, is that field's pointer again where the slot is loaded
#   builtin_pads the KN7000 builds' own "Technics Pads" copy (TechnicsPadsResourceBuiltin), as the siblings'
#   sibling_trie the resource-id trie (ResourceIdTrie, a manual-symbol name) typed in the siblings too
#   euc_text     a pointed-at NUL-terminated EUC-JP string is a string (the language tables' Japanese entries)
#   pow10_table  the C library's powers of ten (309 doubles), found by their contents in every tree
#   fx_streams   the KN2400's effect-DSP programs, parameter scripts and address maps (profile `fx_streams`)
# (lane mn10300-data, 2026-11-02; kn7000/notes/mn10300-data/README.md)
#   widget_vars  a widget's RAM state variable (its l / m / q / r field's target) typed at the width the
#                class chain's procedure reads it through the field
#   sentinel_lists  the lists a loop walks until a record's field holds an end marker (-1, 0xff, 0xffff, 0)
#   chord_voicings  the chord voicing blocks (12 x 8) and inversion lists the memcpy-8 routine reads
#   index_bounds a table indexed right after an `and 2^k-1` / `cmp N` + branch of its index has that many
#                records: struct_arrays and reader_tables type up to it (the bytes free)
#   fx_presets   the KN2400's DSP effect presets (profile `fx_presets`): name, descriptor, parameters, key
#   table_terminators  the all-ones end word after a typed table whose reader compares with -1
#   msg_readers  a {key, code} dispatch table is named after the routine that reads its keys
#   count_notes  a struct array's macro header says where its count comes from when no loop or index check gives it
#   doubles_text a run of "doubles" mostly of printable words is text: printable_runs() types such runs (>= 32
#                bytes no instruction reads) as .ascii
#   table_ptrs   a reader table whose every entry is 0 or a data address is a pointer table (its strings typed)
#   maps128      the 128 x 64 maps of two-byte entries (`cmp 0x7f` row, `and 0x3f` column, `asl 7`)
# (lane mn10300-data3, 2026-11-06; kn7000/notes/mn10300-data3/README.md)
#   sentinel_indexed  sentinel_lists also reads the indexed form of the walk: `mov (dI, aT), dX` with dI a
#                counter stepped by one and scaled to the entry width (`asl2 dI`), `lne` / `b<cc>` back
#   frozen_obj_names  the GUI objects with an empty ResName keep the names <src>/data/gui_object_names.tsv
#                gives them (written back by every run), instead of names invented afresh each time
#   host_widget_vars  (a plug-in) widget_vars() also reads the host firmware's class procedures (the HD-SX3's
#                widgets are instances of the KN6000's classes)
#   field_*      (tools/data_field_uses.py, read there) the field-use walk's new rules: field_pos,
#                field_slots, field_bra, field_keyloop, field_merge, field_screen
FEATURES = {k: True for k in ("ptr_starts", "array_end", "mem_ptrs", "loop_index", "step_arrays", "deep_records",
                              "top_tested", "fld_slots", "fx_streams", "pow10_table", "euc_text",
                              "sibling_trie", "builtin_pads", "widget_vars", "maps128", "sentinel_lists", "chord_voicings", "index_bounds", "fx_presets", "table_terminators", "msg_readers", "count_notes", "doubles_text", "table_ptrs",
                              # lane mn10300-data2 (wave 10)
                              "support_values", "sibling_support", "boot_sectors", "panel_700", "style_lists", "reclaim_strings", "curated_counts", "nv_not_ptrs",
                              # lane mn10300-data3 (wave 11)
                              "sentinel_indexed", "frozen_obj_names", "host_widget_vars")}
for _k in os.environ.get("GEN_DATA_S_OFF", "").split(","):
    if _k.strip():
        FEATURES[_k.strip()] = False
KN7_DIR = KN7                 # this tree; KN7 is rebound to the profile's root by configure()
TAIL = None                   # (CPU lo, hi) of gen_program_s.py's tail code, see configure()
from data_readers import LIBC as DR_LIBC  # noqa: E402


# An older build's kn7000_<b>_own.sym (names written for THAT build: routines and data 941 has no 1:1
# counterpart for, and corrections of ported names) replaces the ported rows, as gen_program_s.py's
# load_manual_syms does: a row of the other files at one of its addresses, or named like one of its
# names (X and X_entry count as one), is dropped.  milk_model.read_syms keeps the first row of an
# address or a name, so the override is applied here, for every Model this generator builds.
_MM_READ_SYMS = MM.read_syms


def _sym_rows(path):
    rows = []
    if os.path.exists(path):
        for line in open(path, encoding="latin-1"):
            if not line.lstrip().startswith(";"):
                m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
                if m:
                    rows.append((int(m.group(1), 16), m.group(2)))
    return rows


def read_syms_own(paths):
    """milk_model.read_syms, with the rows of an `*_own.sym` among `paths` replacing the others'."""
    own = [p for p in paths if p.endswith("_own.sym")]
    if not own:
        return _MM_READ_SYMS(paths)
    stem = lambda nm: nm[:-6] if nm.endswith("_entry") else nm
    orows = [r for p in own for r in _sym_rows(p)]
    own_at, own_nm = {a for a, _ in orows}, {stem(n) for _, n in orows}
    by_addr, by_name = {}, {}
    for a, n in orows + [(a, n) for p in paths if p not in own for a, n in _sym_rows(p)
                         if a not in own_at and stem(n) not in own_nm]:
        by_addr.setdefault(a, n)
        by_name.setdefault(n, a)
    return by_addr, by_name


MM.read_syms = read_syms_own


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
    import data_struct_names as _DN
    import data_structs as _DS
    _DN.MODEL = name
    _DS.PREFER_DIRECT = "root" in P
    MM.configure(base=BASE, sig_size=P.get("sig"), scheme=P.get("scheme", "kn7000"), sigmap=P.get("sigmap", {}),
                 host_calls={})
    ROMQ = f'"{P["rom"]}"'
    R1_END = P["r1"]             # end of code region 1 (file offset)
    PALETTE = P["pal"]           # display palette, 512 x u32
    DATA_END = P["end"]          # the library image starts here (gen_program_s LIB_FILE_BASE)
    OUTDIR = P["src"] + "/data"
    # the code gen_program_s.py found at the end of the data region (its TAIL_CODE, written to
    # <data dir>/tail_code.txt): the data region ends where that code starts, and the
    # addresses in it are code (in_code), so a table that points at it names its labels
    global TAIL
    TAIL = None
    tail = os.path.join(KN7, OUTDIR, "tail_code.txt")
    if os.path.exists(tail):
        lo, hi = (int(x, 16) for x in next(ln for ln in open(tail) if not ln.startswith(";")).split())
        if hi != DATA_END:
            sys.exit(f"gen_data_s: {tail}: the tail code ends at {hi:#x}, not at the data region's end {DATA_END:#x}")
        DATA_END, TAIL = lo, (BASE + lo, BASE + hi)
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


def is_euc(bs):
    """(FEATURES["euc_text"], lane mn10300-rest) A NUL-terminated string in EUC-JP: printable ASCII and at least
    two double-byte characters (0xA1..0xFE twice, or 0x8E and a half-width kana 0xA1..0xDF), nothing else.  The
    Japanese entries of the language pointer tables (language 6: AcLanguageTextProc 0x484208BA `cmp 6, d0` /
    `mov (d0, a3), a0` and u2d_entry; KN6000 0x4C0135B7) are such strings; typed_refs() takes one only where a
    pointer holds its address."""
    i, dbl = 0, 0
    while i < len(bs):
        c = bs[i]
        if 0x20 <= c < 0x7F or c in (0x09, 0x0A, 0x0D):
            i += 1
        elif 0xA1 <= c <= 0xFE and i + 1 < len(bs) and 0xA1 <= bs[i + 1] <= 0xFE:
            i, dbl = i + 2, dbl + 1
        elif c == 0x8E and i + 1 < len(bs) and 0xA1 <= bs[i + 1] <= 0xDF:
            i, dbl = i + 2, dbl + 1
        else:
            return False
    return dbl >= 2


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
    # the host's Function table: block 0's slot 1 (KN7000 scheme), the NAKA scheme's 0x100
    r = hm.by_slot[1 if MM.SCHEME == "kn7000" else 0x100]
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
    c_escape = staticmethod(c_escape)

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
        self.readers_ext = bool(P.get("readers_ext"))   # tools/data_readers.py Reader(ext=)
        self.readers_callee = bool(P.get("readers_callee"))   # Reader(callee=), lane callee-walk
        self.array_end = FEATURES["array_end"]                # Reader(array_end=), lane mn10300-typer
        self.top_tested = FEATURES["top_tested"]              # Reader(top_tested=), lane mn10300-rest
        self.fld_slots = FEATURES["fld_slots"]                # Reader(fld_slots=), lane mn10300-rest
        self.mem_ptrs = FEATURES["mem_ptrs"]                  # Reader(mem_ptrs=)
        self.loop_index = FEATURES["loop_index"]              # Reader(loop_index=)
        self.deep_records = FEATURES["deep_records"]          # Reader(chains=), field_targets' closure
        self.step_arrays = FEATURES["step_arrays"]            # arg_kinds' arrays of stepped records
        # (lane mn10300-data) the single ext rules the siblings' walk takes (data_readers Reader(sib_rules=)):
        # FEATURES sib_fieldret, sib_loopslots, sib_reloadbound, sib_setlb; a profile's `sib_rules` lists
        # which of them it uses (measured one by one, kn7000/notes/mn10300-data/README.md)
        self.sib_rules = tuple(r for r in P.get("sib_rules", ()) if FEATURES.get("sib_" + r, True))

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
        self.label_pairs = [(n, int(v, 16)) for n, v in pairs]   # (the instruction-start oracle's anchors)
        for n, v in pairs:
            a = int(v, 16)
            if self.in_data(a):
                self.prev_data_label[n] = a
                continue          # this generator's own labels: made again below
            if TAIL and TAIL[0] <= a < TAIL[1] and self.GUESSED.match(n):
                continue          # a data name the tail code had before it was code (its labels are loc_)
            self.extern.setdefault(a, n)
            self.names.add(n)
        for a, n in m.sym_by_addr.items():
            self.names.add(n)
            if not self.in_data(a):
                self.extern.setdefault(a, n)
        # the converted code's own function names (`# Name  (CPU 0x...)` headers) replace a made-up
        # func_ / loc_ name the previous build's labels give the same address: the code was
        # regenerated since (with new symbol-file names) and no longer defines the old one
        # (a name the previous build put at another address -- the header gives the entry, the
        # label sits on the prologue -- is not taken)
        import glob as _glob
        built = {nm_: int(v_, 16) for nm_, v_ in pairs}
        self.code_labels = dict(built)  # every name the label files give (tools/data_structs.readers)
        self.distinct_readers = "root" in P   # (siblings) data_readers.resolve_params_distinct
        hx = re.compile(r"^# (\w+)\s+\((?:lib )?CPU 0x([0-9a-fA-F]+)\)", re.M)
        for f in _glob.glob(code_glob()):
            for mo in hx.finditer(open(f, encoding="latin-1").read()):
                a, n = int(mo.group(2), 16), mo.group(1)
                if built.get(n, a) != a:
                    continue
                if re.fullmatch(r"(func|loc)_[0-9A-F]{8}", self.extern.get(a, "")) and n != self.extern[a]:
                    self.extern[a] = n
                    self.names.add(n)
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
        strq = re.compile(r'"(?:[^"\\]|\\.)*"')
        for f in glob.glob(code_glob()):
            for line in open(f, encoding="latin-1"):
                c = line.split("#", 1)[0]
                if P.get("header_funcs"):
                    # (the plug-in: its code shares table.s with the help texts) not the words of a string
                    c = strq.sub('""', c)
                self.code_names.update(nx.findall(c))
        self.fixed_by_code = set()
        for n, a in self.prev_data_label.items():
            if n in self.code_names and not n.startswith(("data_", "ram_")):
                if a not in self.fixed:
                    self.fixed_by_code.add(a)
                self.fixed.setdefault(a, n)
                self.names.add(n)
        for line in open(os.path.join(KN7, P["prog"])):
            mo = re.match(r"\.equ\s+(\w+),\s*0x([0-9A-Fa-f]+)", line)
            if mo and self.in_data(int(mo.group(2), 16)):
                self.fixed.setdefault(int(mo.group(2), 16), mo.group(1))
                self.names.add(mo.group(1))
        # the data names of annotations/*.ann (`equ NAME ADDR`, ported by gen_program_s):
        # program.s defines them as .equ only while no data label has their address, so
        # the previous labels.sym carries them the other times; either way they are fixed
        # names (and array boundaries), or each generation would undo the last
        import glob as _glob
        ann = set()
        for f in _glob.glob(os.path.join(KN7, "annotations", "*.ann")):
            for line in open(f, encoding="latin-1"):
                mo = re.match(r"equ\s+(\w+)\s", line)
                if mo:
                    ann.add(mo.group(1))
        for n, a in self.prev_data_label.items():
            if n in ann and self.in_data(a):
                self.fixed.setdefault(a, n)
                self.fixed_by_code.discard(a)
                self.names.add(n)
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

    def rename_at(self, a, base):
        """Give CPU address `a` a new label `base` (unique), replacing a guessed one."""
        self.label_at[a] = self.uniq(base)
        return self.label_at[a]

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
        """An address in code region 1 (a jump-table target, a callback); a profile whose code
        is not before its data (the KN2400) states its code's CPU ranges (`code_cpu`)."""
        if "code_cpu" in P:
            return any(lo <= v < hi for lo, hi in P["code_cpu"])
        if TAIL and TAIL[0] <= v < TAIL[1]:
            return True
        return BASE + 0x80 <= v < BASE + R1_END

    def ref(self, v, note=True):
        """A 32-bit value written symbolically when it is an address."""
        if v == 0:
            return "0"
        if v in self.label_at:
            return self.label_at[v]
        if v in self.extern:
            if self.in_code(v) and self.extern[v] in (f"loc_{v:08X}", f"func_{v:08X}"):
                # a label only because the data names it (gen_program_s.py names a prologue the data points
                # at func_<ADDR>, any other target loc_<ADDR>): keep it so
                self.code_targets.add(v)
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
    OBJ_NAMES_TSV = "gui_object_names.tsv"

    def frozen_object_names(self):
        """(N-fb88572c, lane mn10300-data3) The names of the GUI objects with an empty ResName, read from the
        build's committed map (<src>/data/gui_object_names.tsv: object id, class, name), so that a
        regeneration never renames them: obj_names() invents a name (parent + class + text, below) only for an
        object the map does not have, or whose class differs there.  Each name is reserved before any other
        name of this run is made; a name another source already holds (a symbol file, an extern) is not
        taken and the object is named afresh (reported).  emit() writes the map back with every unnamed
        object's final label, so a new object's invented name is frozen from then on."""
        self.frozen_names, self.frozen_report = {}, collections.Counter()
        path = os.path.join(KN7, P["src"], "data", self.OBJ_NAMES_TSV)
        rows = {}
        if FEATURES.get("frozen_obj_names", True) and os.path.exists(path):
            for line in open(path, encoding="latin-1"):
                if line.startswith("#") or not line.strip():
                    continue
                oid, cls, nm = line.rstrip("\n").split("\t")
                rows[int(oid, 16)] = (cls, nm)
        taken = set()
        for slot, b in sorted(self.m.blocks.items()):
            for i, o in enumerate(b["objects"]):
                if o.name:
                    continue
                r = rows.get((slot << 16) | i)
                if r is None:
                    self.frozen_report["new"] += 1
                elif r[0] != o.klass.name:
                    self.frozen_report["class changed"] += 1
                elif r[1] in taken or (r[1] in self.names and self.fixed.get(o.addr) != r[1]):
                    self.frozen_report["name taken"] += 1
                else:
                    self.frozen_names[(slot, i)] = r[1]
                    self.frozen_report["frozen"] += 1
                    taken.add(r[1])
                    self.names.add(r[1])
        self.frozen_report["map rows"] = len(rows)

    def object_names_tsv(self):
        """The map frozen_object_names() reads, as this run named the objects (one row per object with an
        empty ResName: id = (slot << 16) | index, class, label)."""
        out = ["# The invented names of the GUI objects that have no ResName, GENERATED by tools/gen_data_s.py and",
               "# read back by it (frozen_object_names, N-fb88572c): a regeneration keeps each name while the",
               "# object's id and class are the same.  Columns: object id = (block slot << 16) | index, class, label.",
               "# Rename an object by editing its row (the name must be unique) and regenerating."]
        for slot, b in sorted(self.m.blocks.items()):
            for i, o in enumerate(b["objects"]):
                if not o.name:
                    out.append(f"0x{(slot << 16) | i:08X}\t{o.klass.name}\t{self.label_at.get(o.addr, self.obj_label[(slot, i)])}")
        return out

    def gui(self):
        m = self.m
        self.frozen_object_names()
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
        # (lane mn10300-data2, L-mn10300-names-kn2400-titles) the titles no screen registers but the firmware's own
        # title-name table names (profile `title_names`: its CPU address and entry count; the KN2400's
        # TitleNameTable, title i's name string "_TT_<NAME>" at entry i): TT_<NAME> = (title slot << 16) | i.
        # The firmware's placeholders ("_TT_13e") stay unnamed.
        self.table_titles = {}
        tn = P.get("title_names")
        if tn:
            ta, cnt = tn
            slot = MM.SCHEMES[MM.SCHEME]["title_slot"]
            have = set(self.id_name.values())
            for i in range(cnt):
                tid = (slot << 16) | i
                if tid in m.titles:
                    continue
                s = m.cstr(m.u32(ta + 4 * i)) or ""
                if not s.startswith("_TT_") or re.fullmatch(r"_TT_[0-9a-f]+", s):
                    continue
                n = sanitize(s[1:], 60)
                if n in have or n in self.names:
                    continue
                self.id_name[tid] = self.uniq(n)
                self.table_titles[tid] = s

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

    def resource_trie(self):
        """(KN7000 program builds) the resource-id trie under ResourceIdTrie: func_4C01BB1A (lib
        0x4C01BB1A) takes nibble n of a 24-bit id from the top (shift 20, 16, ... 0) and indexes a
        table of 8-byte entries {u32 target, u8 inner, u8 count, u16 0}: target 0 = no such id;
        inner 0 = target is the leaf record, whose +0 u32 must equal the id; else target is the
        next table, of `count` entries, and a nibble >= count is no such id.  The root has 16
        entries.  Every table is typed (RES_TRIE_ENTRY, src/include/data_tables.inc); every leaf's
        +0 is a location of the field func_4C01BB1A returns (`mov (a1), a0`), so ptr_records types
        all 469 leaves as one kind with the reads its callers make through that return value."""
        root = next((a for a, n in self.fixed.items() if n == "ResourceIdTrie"), None)
        if root is None:
            return
        m = self.m
        tables, leaves, seen = [], {}, set()

        def walk(t, n):
            if t in seen or not self.in_data(t) or not self.free(t, 8 * n) or n > 16:
                return
            seen.add(t)
            tables.append((t, n))
            for i in range(n):
                p = m.u32(t + 8 * i)
                inner, cnt = m.rom[self.off(t + 8 * i) + 4], m.rom[self.off(t + 8 * i) + 5]
                if p and inner:
                    walk(p, cnt)
                elif p:
                    leaves[t + 8 * i] = p
        walk(root, 16)
        self.extra_locs = getattr(self, "extra_locs", collections.defaultdict(set))
        self.extra_locs[(("rec", root, 8), 0)] |= set(leaves)
        # tables may share entries (a table that is the tail of another): one item per run of entries
        starts = collections.defaultdict(list)
        ents = set()
        for t, n in tables:
            starts[t].append(n)
            ents.update(t + 8 * i for i in range(n))
        runs, cur = [], None
        for e in sorted(ents):
            if cur and e == cur[1]:
                cur[1] = e + 8
            else:
                cur = [e, e + 8]
                runs.append(cur)
        for a, b in runs:
            rows = []
            for e in range(a, b, 8):
                p = m.u32(e)
                if p:
                    self.refs.add(p)
                rows.append((e, p, m.rom[self.off(e) + 4], m.rom[self.off(e) + 5]))

            def render(g, it, rows=rows, a=a):
                out = [f"{it.label}:\t# entries of the resource-id trie, one per id nibble (func_4C01BB1A)"]
                k = 0
                for e, p, inner, c in rows:
                    if e != a and e in starts:
                        out.append(f"\t# +{e - a}: a table of {max(starts[e])} entries (ResourceIdTrieNode_{e:08X})")
                        k = 0
                    elif e == a and len(starts.get(e, [])) and a != root:
                        k = 0
                    out.append(f"\tRES_TRIE_ENTRY\t{g.ref(p)}, {inner}, {c}\t# [{k:X}]")
                    k += 1
                return out
            lab = self.name_at(a, "ResourceIdTrie" if a == root else f"ResourceIdTrieNode_{a:08X}")
            self.add(a, b - a, lab, "trie table", render)
        if not P.get("readers_ext"):
            self.trie_leaves(sorted(set(leaves.values())))
        print(f"gen_data_s: resource-id trie: {len(tables)} tables in {len(runs)} runs, {len(leaves)} leaves")

    def trie_leaves(self, leaves):
        """(the siblings, lane mn10300-rest) The parameter-id trie's leaves, which the KN7000 builds type
        through the reads of ResourceIdFind's return value (readers_ext): here each leaf from its address
        up to the next leaf (at most 32 bytes), {u32 id; u16 type; u16 kind; the rest by type}: GetM3Em
        reads +4 (`movhu (4, a0), d1`), the kind-0 handler +8 / +0xA (min, max) and +0xC..+0xF (block,
        offset, mask, shift), type 1 +0xC a RAM pointer (probes kn6000_opaque.py / kn2400_opaque.py)."""
        m = self.m
        for i, a in enumerate(leaves):
            e = min(leaves[i + 1] if i + 1 < len(leaves) else a + 32, a + 32)
            n = e - a
            while n > 8 and not self.free(a, n):
                n -= 4
            if n < 8 or not self.free(a, n) or not self.in_data(a):
                continue
            o = self.off(a)
            if int.from_bytes(m.rom[o:o + 4], "little") >> 24:
                continue                        # (not an id: 24 bits)

            def render(g, it, o=o, n=n):
                r = g.rom
                lid, typ, knd = int.from_bytes(r[o:o + 4], "little"), int.from_bytes(r[o + 4:o + 6], "little"), \
                    int.from_bytes(r[o + 6:o + 8], "little")
                out = [f"{it.label}:\t# a parameter-id trie leaf (ResourceIdFind): id 0x{lid:06X}, type {typ}, kind {knd}",
                       f"\t.long\t0x{lid:06X}", f"\t.word\t{typ}, {knd}"]
                for k in range(8, n, 16):
                    out.append("\t.byte\t" + ", ".join(f"0x{x:02x}" for x in r[o + k:o + min(n, k + 16)]) + f"\t# +{k}")
                return out
            self.add(a, n, self.name_at(a, f"ResourceIdLeaf_{a:08X}"), "trie leaf", render)

    def support_classes(self):
        """The SupportClass table (InitSptClassTable: class SupportClass, proc SupportClassProc, its
        count and table; registry slot 0xD in the KN7000 / KN2400 layout, 0x1C0 in the NAKA one):
        12-byte entries {proc, u16 name count, u16 property size, pointer}, then an all-zero entry;
        spelled with SUPPORT_CLASS (src/include/data_tables.inc, whose header gives the readers).
        Each entry's pointer is its value-name list (support_value_names)."""
        m = self.m
        slot, r = next(((s, r) for s, r in sorted(m.by_slot.items()) if r.get("kind") == "SupportClass"),
                       (None, None))
        if not r or not self.in_data(r["table"] or 0):
            return
        n = r["count"] + 1 if not any(m.rom[self.off(r["table"]) + 12 * r["count"]:
                                             self.off(r["table"]) + 12 * r["count"] + 12]) else r["count"]
        if not self.free(r["table"], 12 * n):
            return
        ents = []
        for i in range(n):
            a = r["table"] + 12 * i
            ents.append((m.u32(a), int.from_bytes(m.rom[self.off(a) + 4:self.off(a) + 6], "little"),
                         int.from_bytes(m.rom[self.off(a) + 6:self.off(a) + 8], "little"), m.u32(a + 8)))
            v = m.u32(a + 8)
            if v and self.in_data(v):
                self.refs.add(v)

        def render(g, it, ents=ents, cnt=r["count"], slot=slot):
            out = [f"# {cnt} SupportClass entries (registry slot {slot:#x}; a support-class id is ({slot:#x} << 16) | its"
                   f" index), then an empty one", f"{it.label}:"]
            for i, (p, x4, ps, d) in enumerate(ents):
                out.append(f"\tSUPPORT_CLASS\t{g.ref(p)}, {x4}, {ps}, {g.ref(d)}\t# [{i}]")
            return out
        self.add(r["table"], 12 * n, self.name_at(r["table"], "SupportClassTable"), "support class table", render)
        if FEATURES.get("support_values", True):
            for i, (p, nn, _ps, d) in enumerate(ents):
                if p:
                    self.support_value_names(i, p, nn, d)

    def style_genre_lists(self):
        """(FEATURES["style_lists"], lane mn10300-data2) What a StyleGenre record's +4 points at: its styles,
        GenreStyle {char *name, u16 *setups} pairs (data_struct_names.py), ended by a pair whose +4 is 0, and
        each style's setups, four u16 MusicStylistSetup numbers (StyleRecordTable records; 1,080 = 270
        styles x 4) and the end marker 0xFFFF.  941 StyleListBoxGetItem 0x4847C216: `asl 3` /
        `add StyleGenreTable, a0` / `mov (4, a0), d0` (the pairs), pair i's `mov (4, a0), d0` (its
        styles), `movhu (d0, a1), d3` four times (`cmp 4, d2` / `blt`), then the next pair's `mov (0xc,
        a0), d0` / `cmp 0, d0` (the end); func_4847BA42 `mov (d0, a3), a1` / memcpy(.., 0x10) (the pair's
        name).  Typed before the record passes, which read the lists' u16 rows at odd offsets or took a
        style number's low byte for a one-character string (opaque group false-string)."""
        if not FEATURES.get("style_lists", True):
            return
        m = self.m
        g0 = m.sym_by_name.get("StyleGenreTable")
        if g0 is None:
            g0 = next((a for a, n in self.fixed.items() if n == "StyleGenreTable"), None)
        if g0 is None or not self.in_data(g0):
            return
        isptr = lambda v: v and self.in_data(v) and m.inrom(v)
        npairs = nlists = 0
        k = 0
        while isptr(m.u32(g0 + 8 * k)) and isptr(m.u32(g0 + 8 * k + 4)) and k < 64:
            gname = m.cstr(m.u32(g0 + 8 * k)) or ""
            pa = m.u32(g0 + 8 * k + 4)
            k += 1
            pairs = []
            while len(pairs) < 256 and self.free(pa + 8 * len(pairs), 8):
                na, sa = m.u32(pa + 8 * len(pairs)), m.u32(pa + 8 * len(pairs) + 4)
                if sa == 0:
                    pairs.append((na, 0))
                    break
                if not (isptr(na) and isptr(sa) and sa % 2 == 0):
                    pairs = []
                    break
                pairs.append((na, sa))
            if not pairs or pairs[-1][1] != 0 or pa % 4:
                continue
            lists = {}
            for na, sa in pairs[:-1]:
                if sa in lists:
                    continue
                vals = []
                while len(vals) < 64 and self.free(sa + 2 * len(vals), 2):
                    v = int.from_bytes(m.rom[self.off(sa) + 2 * len(vals):self.off(sa) + 2 * len(vals) + 2], "little")
                    vals.append(v)
                    if v == 0xFFFF:
                        break
                if vals and vals[-1] == 0xFFFF:
                    lists[sa] = (vals, m.cstr(na) or "")
            if len(lists) != len({sa for _n, sa in pairs[:-1]}):
                continue
            tag = sanitize(gname, 30) or f"{k - 1}"
            for sa, (vals, nm) in sorted(lists.items()):
                cur = self.fixed.get(sa)
                lab = cur if cur and not self.GUESSED.match(cur) else self.rename_at(
                    sa, f"StyleSetups_{tag}_{sanitize(nm, 30) or 'unnamed'}")
                self.add(sa, 2 * len(vals), lab, "style list",
                         lambda g, it, vals=vals, nm=nm: [
                             f"{it.label}:\t# the setups of style \"{nm.strip()}\" (u16 MusicStylistSetup numbers: StyleRecordTable"
                             f" records), then 0xFFFF; StyleListBoxGetItem reads four"]
                         + ["\t.word\t" + ", ".join(f"{v}" if v != 0xFFFF else "0xffff" for v in vals)])
                nlists += 1

            def render(g, it, pairs=pairs, gname=gname):
                out = [f"{it.label}:\t# StyleGenre \"{gname.strip()}\"'s {len(pairs) - 1} styles, GenreStyle {{char *name, u16"
                       f" *setups}}, then the one whose setups is 0 (StyleListBoxGetItem: `mov (0xc, a0), d0` / `cmp 0, d0`)"]
                out += [f"\t.long\t{g.ref(na)}, {g.ref(sa)}" for na, sa in pairs]
                return out
            cur = self.fixed.get(pa)
            lab = cur if cur and not self.GUESSED.match(cur) else self.rename_at(pa, f"StyleGenre_{tag}_Styles")
            self.add(pa, 8 * len(pairs), lab, "style genre pairs", render)
            npairs += 1
        print(f"gen_data_s: style genres: {npairs} style lists, {nlists} setup lists")
        # the eras' and the letters' setup lists: StyleEra {name, setups, era} (12 bytes; func_4847D644 walks
        # the eras, func_4847D639 reads the first one's +4) and StyleLetter {letter, setups} (8 bytes;
        # func_4847C977 counts +4's list up to 0xFFFF, func_4847D083 `movhu (a2), d0` / `cmp 0xffff, d0` / `add
        # 2, a2` walks it): u16 MusicStylistSetup numbers ended by 0xFFFF, of any length
        nset = 0
        for tname, stride, kind in (("StyleEraTable", 12, "era"), ("StyleAlphabetTable", 8, "letter"),
                                    ("StyleEraTableKN2400", 12, "era"), ("StyleAlphabetTableKN2400", 8, "letter")):
            t0 = m.sym_by_name.get(tname)
            if t0 is None:
                t0 = next((a for a, n in self.fixed.items() if n == tname), None)
            if t0 is None or not self.in_data(t0):
                continue
            k = 0
            while k < 64 and isptr(m.u32(t0 + stride * k)) and isptr(m.u32(t0 + stride * k + 4)):
                sa = m.u32(t0 + stride * k + 4)
                nm = (m.cstr(m.u32(t0 + stride * k)) or "").strip()
                k += 1
                if sa % 2 or not self.free(sa, 2):
                    continue
                vals = []
                while len(vals) < 2048 and self.free(sa + 2 * len(vals), 2):
                    v = int.from_bytes(m.rom[self.off(sa) + 2 * len(vals):self.off(sa) + 2 * len(vals) + 2], "little")
                    vals.append(v)
                    if v == 0xFFFF:
                        break
                if not vals or vals[-1] != 0xFFFF:
                    continue
                cur = self.fixed.get(sa)
                lab = cur if cur and not self.GUESSED.match(cur) and not cur.startswith("func_") else self.rename_at(
                    sa, f"StyleSetups_{kind.capitalize()}_{sanitize(nm, 30) or k - 1}")
                self.add(sa, 2 * len(vals), lab, "style list",
                         lambda g, it, vals=vals, nm=nm, kind=kind, tname=tname: [
                             f"{it.label}:\t# the setups (u16 MusicStylistSetup numbers) under {kind} \"{nm}\" of {tname},"
                             f" then 0xFFFF (func_4847D083: `movhu (a2), d0` / `cmp 0xffff, d0` / `add 2, a2`)"]
                         + ["\t.word\t" + ", ".join(f"{v}" if v != 0xFFFF else "0xffff" for v in vals[i:i + 16])
                            for i in range(0, len(vals), 16)])
                nset += 1
        print(f"gen_data_s: style eras / letters: {nset} setup lists")

    def boot_sectors(self):
        """(FEATURES["boot_sectors"], lane mn10300-data2, N-044cdbc6) The first 32 bytes of a FAT
        boot sector that a routine hands memcpy (`mov Head, a1` / `mov 0x20, d0` or `mov 0x200, d0` /
        `call memcpy`): the disk formatters copy one into a zeroed 512-byte sector before writing it
        (941 func_484707AC 720 KB, func_48470A76 1.44 MB), and func_4846FED0 copies one in place of a
        boot sector it cannot read.  The layout is the FAT boot sector's (the DOS 3 BPB: Microsoft,
        "FAT: General Overview of On-Disk Format", offsets 0x00..0x1D), written with FAT_BOOT_HEAD
        (src/include/data_tables.inc); typed only when the bytes are a plausible BPB (512..4096 bytes
        a sector, a power-of-two cluster, one or two FATs, a media byte 0xF0 / 0xF8..0xFF)."""
        if not FEATURES.get("boot_sectors", True):
            return
        found = collections.OrderedDict()
        for fn, cpu, L in self.code_funcs():
            for i, ins in enumerate(L):
                if not re.match(r"call memcpy(_entry)?\b", ins):
                    continue
                src = n = None
                for x in L[max(0, i - 4):i]:
                    mo = re.fullmatch(r"mov ([A-Za-z_]\w*), a1", x)
                    if mo:
                        src = self.data_label_addr(mo.group(1))
                    mo = re.fullmatch(r"mov (0x[0-9a-f]+|\d+), d0", x)
                    if mo:
                        n = int(mo.group(1), 0)
                if src is not None and n in (0x20, 0x200):
                    found.setdefault(src, []).append((re.sub(r"_entry$", "", fn), cpu, n))
        u16 = lambda o: int.from_bytes(self.rom[o:o + 2], "little")
        for a, uses in found.items():
            if not self.free(a, 32):
                continue
            o = self.off(a)
            bps, spc, nfat, media = u16(o + 0x0B), self.rom[o + 0x0D], self.rom[o + 0x10], self.rom[o + 0x15]
            if bps not in (512, 1024, 2048, 4096) or spc not in (1, 2, 4, 8, 16, 32, 64, 128) \
                    or nfat not in (1, 2) or not (media == 0xF0 or media >= 0xF8) or not u16(o + 0x13):
                continue
            raw = self.rom[o:o + 32]
            f = dict(bps=bps, spc=spc, res=u16(o + 0x0E), nfat=nfat, root=u16(o + 0x11), tot=u16(o + 0x13),
                     media=media, spf=u16(o + 0x16), spt=u16(o + 0x18), heads=u16(o + 0x1A), hidden=u16(o + 0x1C))
            kb = f["tot"] * bps // 1024
            cite = "; ".join(f"{fn} 0x{cpu or 0:08X}: memcpy(.., {n:#x})" for fn, cpu, n in uses[:3])

            def render(g, it, raw=raw, f=f, kb=kb, cite=cite, uses=uses):
                tail = raw[0x1E:0x20]
                jmp = raw[0:3]
                out = [f"{it.label}:\t# a FAT boot sector's first 32 bytes, a {kb} KB disk's ({f['tot']} sectors of"
                       f" {f['bps']} bytes): {cite}"
                       + ("; the 0x200-byte copy runs on into the items after these 32 bytes" if
                          any(n == 0x200 for _f, _c, n in uses) else ""),
                       f'\tFAT_BOOT_HEAD\t{", ".join(f"0x{x:02x}" for x in jmp)}, "{c_escape(raw[3:11])}", '
                       f"{f['bps']}, {f['spc']}, {f['res']}, {f['nfat']}, {f['root']}, {f['tot']}, 0x{f['media']:02x},"
                       f" {f['spf']}, {f['spt']}, {f['heads']}, {f['hidden']}",
                       f"\t.byte\t0x{tail[0]:02x}, 0x{tail[1]:02x}\t# +0x1E: "
                       + ("the boot code the jump at +0 lands on (EB 1C: +2 + 0x1C), x86 `jmp $`: a loop"
                          if jmp[0] == 0xEB and jmp[1] == 0x1C and tail == b"\xeb\xfe" else
                          "past the BPB; no reader")]
                return out
            cur = self.fixed.get(a)
            lab = cur if cur and not self.GUESSED.match(cur) else self.rename_at(
                a, f"FatBootSector_{kb}K_Default" if any(n == 0x200 for _f, _c, n in uses) else f"FatBootHead_{kb}K")
            self.add(a, 32, lab, "boot sector head", render)

    def support_value_names(self, i, proc, nn, d):
        """(N-027de254) A support class's value-name list, the pointer at +8 of its SupportClass
        entry: {char *name, u32 value} pairs ended by a pair whose name is "" -- for a class with no
        names (+4 = 0: the integers, IDs, pointers, rects) only that end pair, its "" the four bytes
        before it.  The reader is the support classes' common handler (941 func_48431434, which each
        xxxProc calls for the messages it does not answer itself; a3 = the entry, MT_GetInstance's
        answer): `movhu (4, a3), d0` / `cmp 0, d0` / `beq` (no names: done), `mov (8, a3), a0` the
        list, then (value -> name, MT_DumpPropertyEx's text) `asl 3` / `mov (4, a0), d0` / `cmp d3,
        d0` until `movbu (a0), d0` / `cmp 0, d0` finds the empty name, `strcpy`; (name -> value) the
        same walk with `strcmp` and `mov (4, a0), d0` / `mov d0, (a2)`, -1 when no name matches; and
        (the n-th name) `mov (8, a0), d0` / `asl 3, d0` / `mov (d0, a1), a1` / `strcpy`."""
        m = self.m
        if not self.in_data(d) or not m.inrom(d):
            return
        pairs = []
        for k in range(nn + 1):
            na, v = m.u32(d + 8 * k), m.u32(d + 8 * k + 4)
            if not (self.in_data(na) and m.inrom(na)):
                return
            s = m.cstr(na)
            if s is None:
                return
            pairs.append((na, v, s))
            if s == "":
                break
        if pairs[-1][2] != "" or len(pairs) != nn + 1 or not self.free(d, 8 * len(pairs)):
            return
        pn = m.sym_by_addr.get(proc) or self.extern.get(proc) or ""
        stem = re.sub(r"Proc$", "", pn) if pn and not re.fullmatch(r"(func|loc)_[0-9A-F]{8}", pn) else f"Class{i}"
        stem = "Spt" + stem[:1].upper() + stem[1:]
        for na, v, s in pairs[:-1]:
            self.str_item(na, "Str_" + sanitize(s, 40), "string")
        na = pairs[-1][0]
        if self.free(na, 1):
            o = self.off(na)
            pad = 0
            while (na + 1 + pad) % 4 and self.free(na + 1 + pad, 1) and self.rom[o + 1 + pad] == 0xFF:
                pad += 1
            if (na + 1 + pad) % 4:
                pad = 0
            self.add(na, 1 + pad, self.name_at(na, f"{stem}_EndName"), "string",
                     lambda g, it, pad=pad: [f'{it.label}:\t.asciz ""\t# the end pair\'s name'
                                             + (f", then {pad} bytes of 0xFF to a word" if pad else "")]
                     + (["\t.align\t4, 0xFF"] if pad else []))
        what = (f"{nn} name(s), then the end pair" if nn else
                "no names, its entry's +4 being 0: only the end pair")

        def render(g, it, pairs=pairs, what=what):
            out = [f"{it.label}:\t# the value names of support class {stem} ({what}): {{char *name, u32 value}}"
                   f" pairs the SupportClass handler (func_48431434 in 941) walks until a name's first byte is 0"]
            for na, v, s in pairs:
                vs = (s if s and s in g.names and g.const_value(s) == v else
                      g.ref(v) if g.in_data(v) or v in g.extern else (f"0x{v:X}" if v > 0xFFFF else str(v)))
                out.append(f"\tSPT_VALUE_NAME\t{g.ref(na)}, {vs}" + ("\t# end" if not s else ""))
            return out
        self.add(d, 8 * len(pairs), self.name_at(d, f"{stem}_ValueNames"), "support value names", render)

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
                if (b["slot"], i) in self.frozen_names:
                    names[i] = self.frozen_names[(b["slot"], i)]      # (reserved by frozen_object_names)
                    continue
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
            # (profile `field_notes`, lane mn10300-formats) what a field's value names, where the
            # generator cannot spell it as a symbol: {(class, field): comment format of v}
            note = P.get("field_notes", {}).get((k.name, f.name))
            if note:
                comments.append(note.format(v=v))
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
            if m and not m.group(1).startswith("loc_") and not re.search(r"_L[0-9a-f]+_*$", m.group(1)):
                func = m.group(1)
            m = re.match(r"# (\S+)\s+\((?:lib )?CPU (0x[0-9a-fA-F]+)", ln)
            if m:
                cpu = int(m.group(2), 16)
                if P.get("header_funcs"):
                    func = m.group(1)       # code without labels (gen_table_s.py's plug-in pass)
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

    def ptr_strings(self, vals, strict=False):
        """(table_ptrs, lane mn10300-data) The targets of a typed pointer table's entries: each a label, and a
        short NUL-terminated text (at most 63 printable characters) there typed as that string, as
        typed_refs() types a pointer table's strings.  strict: only when every target is such a text of at
        most 15 characters and there are at least 4 (a table of names, not of records that begin with text)."""
        def text_at(v):
            if not (v and self.in_data(v) and self.m.inrom(v) and self.free(v, 1)):
                return None
            q = self.off(v)
            z = self.rom.find(b"\0", q, q + 64)
            return z - q if z >= q and all(0x20 <= c < 0x7F for c in self.rom[q:z]) and self.free(v, z - q + 1) else None
        tv = [v for v in vals if v and self.in_data(v)]
        fr = {v for v in tv if self.m.inrom(v) and self.free(v, 1)}       # (the others are typed already)
        lens = [text_at(v) for v in fr]
        if strict and (len(set(tv)) < 4 or any(x is None or x > 15 for x in lens) or sum(1 for x in lens if x == 0) > 1):
            ok = False      # (strict: a name table, its one empty name at most the end marker)
        else:
            ok = FEATURES.get("table_ptrs", True)
        for v in tv:
            if ok and text_at(v) is not None:
                q = self.off(v)
                self.str_item(v, "Str_" + (sanitize(self.rom[q:q + text_at(v)].decode("latin-1")) or "text"), "string")
            self.refs.add(v)

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
            ixb = self.index_bounds().get(a)
            note = ""
            if ixb and ixb[1] == w and ixb[0] > n and self.free(a, ixb[0] * w) and \
                    not any(self.fixed.get(self.addr_of(q)) for q in range(o + 1, o + ixb[0] * w)):
                # (index_bounds) past a generated label: the routine bounds the index
                n, note = ixb[0], f"; {ixb[0]} entries: the index is bounded by {ixb[2]}"
            if n < 1 or o % w:
                continue
            if self.in_arg_span(a, w * n):
                # (callee) a field of a block a routine is handed: ptr_records(only_arg=True)
                self._arg_deferred.append((o, o + w * n, w, signed))
                continue
            vals = [int.from_bytes(self.rom[o + w * i:o + w * i + w], "little", signed=signed) for i in range(n)]
            kind = ("s" if signed else "u") + str(8 * w)
            # (ties broken by function and instruction: a set's order changes from run to run)
            readers = sorted({(r[0], r[1], r[2]) for r in rd if r[3] == w}, key=lambda r: (r[1] or 0, r[0] or "", r[2]))
            fn = next((r[0] for r in sorted(rd, key=lambda r: r[1] or 0) if r[0]), None)
            base = (re.sub(r"_entry$", "", fn) + "_Table") if fn else f"tab_{a:08X}"
            uv = [v & 0xFFFFFFFF for v in vals]
            if w == 4 and FEATURES.get("table_ptrs", True) and any(uv) and \
                    all(v == 0 or (self.in_data(v) and self.m.inrom(v)) for v in uv):
                # (lane mn10300-data) every entry is 0 or a data address: a pointer table, its targets named, and
                # a short NUL-terminated text at a target typed as that string (the KN2400's naming window's
                # character table, AcNamingWindowProc: "!", "#", ...)
                self.ptr_strings(uv, strict=True)
                rd_s = "; ".join(f"{f or '?'} {('0x%08X' % c) if c else ''}: `{ins}`".replace("  ", " ")
                                 for f, c, ins in readers[:2])
                self.add(a, w * n, self.name_at(a, base), "pointer table",
                         lambda g, it, uv=uv, rd_s=rd_s, note=note: [f"{it.label}:\t# {len(uv)} pointers; read by {rd_s}{note}"]
                         + [f"\t.long\t{g.ref(v)}" for v in uv])
                continue
            self.add(a, w * n, self.name_at(a, base), "reader table",
                     lambda g, it, vals=vals, kind=kind, readers=readers, w=w, note=note:
                     g.render_table(it, vals, kind, readers, w, note))

    def render_table(self, it, vals, kind, readers, w, note=""):
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
        out = [f"{it.label}:\t# {len(vals)} x {kind}, {lo}..{hi}; read by {rd}{note}"]
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
                    if not self.is_addr(w):
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
                    and self.free(a, e - o + 1) and not self.record_start(a, e - o + 1):
                s = self.rom[o:e].decode("latin-1")
                self.str_item(a, "Str_" + (sanitize(s, 40) or "empty"), "string")
            elif FEATURES.get("euc_text", True) and 0 <= e - o < 1024 and e > o and is_euc(self.rom[o:e]) \
                    and self.free(a, e - o + 1) and not self.record_start(a, e - o + 1) \
                    and not self.code_read(a, e - o + 1):
                bs = self.rom[o:e]
                self.add(a, e - o + 1, self.name_at(a, f"StrJa_{a:08X}"), "string",
                         lambda g, it, bs=bs: [f'{it.label}:\t.asciz "{c_escape(bs)}"\t# EUC-JP'])

    def host_calls_tsv(self, outdir):
        """(a plug-in, lane mn10300-rest) host_calls.tsv beside the data: the host's Function tables, one row
        {registry slot, entry offset, routine name} each, which gen_image_s.py --host-calls writes beside the
        plug-in's `calls (aN)` (registry slot 0x100: block 0, 0x107: block 7)."""
        hm = self.host
        hb = PROFILES[P["host"]].get("base", 0x48400000)   # (hm.u32 reads with the plug-in's base once it is bound again)
        u32 = lambda a: int.from_bytes(hm.rom[a - hb:a - hb + 4], "little")  # noqa: E731
        rows = ["# GENERATED by kn7000/tools/gen_data_s.py from the host's registrations: slot, OFF, routine"]
        for slot, r in sorted(hm.by_slot.items()):
            if r.get("kind") != "Function":
                continue
            for k in range(r["count"]):
                v = u32(r["table"] + 4 * k)
                rows.append(f"0x{slot:x}\t0x{4 * k:x}\t{hm.sym_by_addr.get(v) or f'func_{v:08X}'}")
        self.write(os.path.join(outdir, "host_calls.tsv"), rows)

    def code_read(self, a, n):
        """(lane mn10300-rest) True when an instruction of the converted code reads or indexes the n bytes at
        `a` directly (an absolute load, or a base it indexes from): a table of the code's own, not a string
        another table points at (u2d's conversion table, PanelLedRegMap)."""
        dr = getattr(self, "dr", None)
        if dr is None:
            return False
        if not hasattr(self, "_code_read"):
            self._code_read = sorted({x.key[1] for x in dr.accesses if x.key[0] in ("abs", "base")} |
                                     {x.key[1] for x in dr.accesses if x.key[0] == "rec"})
        import bisect
        i = bisect.bisect_left(self._code_read, a)
        return i < len(self._code_read) and self._code_read[i] < a + n

    def record_start(self, a, n):
        """(`reader_rows` profiles, lane generic-zero) True when the reader walk reads the n bytes
        at `a` as the start of a record whose read fields reach past them: `a` is one of the
        records a T value selects (a switch, a stack slot, a return value) or a target of a pointer
        field the code reads through, with a read at +n or later.  Such an address is not taken for
        a short string (the 260-way switch's descriptors whose first word is 0x0000B024, "$\\xB0";
        the resource-id trie's leaves), so ptr_records() types it as the record it is."""
        if not P.get("reader_rows"):
            return False
        if not hasattr(self, "_rec_need"):
            self.build_index()
            self._lmemo, self._tmemo = {}, {}
            need = collections.defaultdict(int)
            for x in self.dr.accesses:
                k = x.key
                if k[0] != "ptr" or k[1][0] not in ("fld", "tgt") or not x.width or x.off < 0:
                    continue
                for t in self.field_targets(k[1]):
                    need[t] = max(need[t], x.off + x.width)
            self._rec_need = need
            self._lmemo, self._tmemo = {}, {}
        return self._rec_need.get(a, 0) > n

    # -- struct arrays, from their readers (tools/data_structs.py) ----------------
    def is_addr(self, v):
        """A 32-bit value that is an address a pointer field may hold: a data address, a named one
        outside the data region, or code -- where a pointer into code can land, on the first byte of
        an instruction (code_ptr_ok; lane mn10300-typer: text such as "><SH" = 0x48533C3E reads as a
        code address but lands inside an instruction)."""
        return bool(v) and (self.in_data(v) or ((v in self.extern or self.in_code(v)) and self.code_ptr_ok(v)))

    def init_word(self, a):
        """The initial 32-bit value of data address a (data_readers' mem_ptrs: a word that starts as 0)."""
        try:
            return self.m.u32(a)
        except Exception:
            return None

    def code_ptr_ok(self, v):
        """False when v is code that tools/mn10300_insn_len.py decodes and v is inside an instruction
        (no pointer lands there); True otherwise (an instruction start, or no code the oracle knows:
        RAM, the host, another chip).  FEATURES["ptr_starts"] off: always True (the test before)."""
        if not FEATURES["ptr_starts"] or self.in_data(v):
            return True
        st = getattr(self, "_starts", None)
        if st is None:
            import glob as _glob
            import mn10300_insn_len as IL
            st = self._starts = IL.oracle(self.rom, BASE, sorted(_glob.glob(code_glob())), self.label_pairs)
        return st.is_start(v) is not False

    # A name an earlier generation made up from a guess about the bytes, which a
    # reader-typed item replaces (the code is regenerated with the new name)
    GUESSED = re.compile(r"(Str|ptrs|doubles|names|data|tab|recs)_")

    def struct_arrays(self):
        """Arrays of fixed-size records that the code indexes base + i * stride
        + field (tools/data_readers.py), typed one macro per record kind with
        a field per offset its readers use (tools/data_structs.py).  An array
        whose record is a single number is a table (tab_uN, as reader_tables)."""
        import data_structs as DS
        import data_struct_names as DN
        self.dr = DS.readers(self, self.code_labels, code_glob())
        gs = DS.groups(self.dr)
        hard = set(self.fixed) - self.fixed_by_code | {g.base for g in gs}
        # an address the code loads as a base (`mov Addr, rN`) on a record boundary of an array is
        # another table that follows it (NoteConvRules+1024), not one of its records [INFERENCE]
        bases = {x.key[1] for x in self.dr.accesses if x.key[0] == "base"}
        self.struct_groups = []
        for g in sorted(gs, key=lambda g: g.base):
            a, s = g.base, g.stride
            if not self.in_data(a) or not self.free(a, s):
                continue
            o = self.off(a)
            probe = DS.layout(g, self, o, 1)
            ptrf = [f for f in probe if f.kind == "ptr" and f.accs]
            n = 0
            while n < 65536:
                ra, ro = a + n * s, o + n * s
                if not self.free(ra, s) or (n and (any(x in hard for x in range(ra, ra + s)) or ra in bases)):
                    break
                if any(not (v == 0 or self.is_addr(v)) for v in
                       (int.from_bytes(self.rom[ro + f.off:ro + f.off + 4], "little") for f in ptrf)):
                    break
                rest = self.rom[ro:ro + s]
                if n and len(set(rest)) == 1 and rest[0] == 0xFF:
                    break
                n += 1
            bounds = [x.bound for _o, x in g.accs if getattr(x, "bound", None) and x.inner != -1]
            capped = False
            if bounds and n > max(bounds):
                n = max(bounds)        # [INFERENCE] the index is checked (or is a byte) below this
                capped = True
            ixb = self.index_bounds().get(a)
            ix_note = ""
            if ixb and ixb[1] == s and ixb[0] > n:
                # (index_bounds) the routine bounds the record number: the records up to it, while free
                m_ = n
                while m_ < ixb[0] and self.free(a + m_ * s, s) and not any(x in hard for x in range(a + m_ * s, a + m_ * s + s)):
                    m_ += 1
                if m_ == ixb[0]:
                    n, ix_note = m_, f"; {m_} records: the index is bounded by {ixb[2]}"
            cnt = DN.options(self.label_at.get(a) or self.fixed.get(a) or "").get("count") \
                if FEATURES.get("curated_counts", True) else None
            if cnt and cnt[0] > n:
                # (lane mn10300-data2) a count data_struct_names.OPTIONS states, with its evidence (a bound in a callee)
                m_ = n
                while m_ < cnt[0] and self.free(a + m_ * s, s) and not any(x in hard for x in range(a + m_ * s, a + m_ * s + s)):
                    m_ += 1
                if m_ == cnt[0]:
                    n, ix_note = m_, f"; {m_} records: {cnt[1]}"
            end_note = ""
            lb = self.loop_end(a, s, n)
            if lb is not None:
                n, x = lb
                end_note = (f"; ends at +{n * s}, where {re.sub(r'_entry$', '', x.func or '?')} 0x{x.cpu or 0:08X}'s "
                            f"loop stops (`{' '.join(x.insn.split())}`)")
                g.evidence = [end_note[2:]]
            if n < 1:
                continue
            if ix_note and not end_note:
                end_note = ix_note
                g.evidence = [ix_note[2:]]
            if not getattr(g, "evidence", None) and FEATURES.get("count_notes", True):
                # (lane mn10300-data, N-92b0bf4c) say where the count comes from when no loop or index check gives it
                g.evidence = (["the count is capped by an index bound a reader checks (a `cmp` before the index, or a"
                               " byte index) [INFERENCE: the table may end before it]"] if capped else
                              ["[INFERENCE] the count: the records up to where they stop being free, a pointer field stops"
                               " holding an address or another named address begins; no reader checks it"])
                g.count_inferred = not capped
            g.count = n
            g.fields = DS.layout(g, self, o, n)
            nm = self.label_at.get(a) or self.fixed.get(a)
            if nm and a in self.fixed_by_code and self.GUESSED.match(nm):
                nm = None
            fn = next((x.func for _o, x in sorted(g.accs, key=lambda t: (t[1].cpu or 0, t[1].insn)) if x.func), None)
            fn = re.sub(r"_entry$", "", fn) if fn else None
            single = len(g.fields) == 1 and g.fields[0].kind in ("num", "ptr") and g.fields[0].width == s
            base = nm or (f"{fn}_{'Table' if single else 'Records'}" if fn else f"recs_{a:08X}")
            g.label = self.rename_at(a, base) if nm is None else self.name_at(a, nm)
            for k in range(n):
                for f in g.fields:
                    if f.kind == "ptr":
                        v = self.m.u32(a + k * s + f.off)
                        if v and self.in_data(v):
                            self.refs.add(v)
            if single:
                f = g.fields[0]
                kind = ("s" if f.signed else "u") + str(8 * s)
                vals = [int.from_bytes(self.rom[o + s * i:o + s * i + s], "little", signed=f.signed) for i in range(n)]
                rd = sorted({(x.func, x.cpu, x.insn) for _o, x in g.accs if x.width},
                            key=lambda r: (r[1] or 0, r[0] or "", r[2]))
                if f.kind == "ptr":
                    self.add(a, n * s, g.label, "pointer table",
                             lambda gen, it, vals=vals: [f"{it.label}:"] + [f"\t.long\t{gen.ref(v)}" for v in vals])
                    if FEATURES.get("table_ptrs", True):
                        self.ptr_strings([v & 0xFFFFFFFF for v in vals], strict=True)
                else:
                    self.add(a, n * s, g.label, "reader table",
                             lambda gen, it, vals=vals, kind=kind, rd=rd, s=s, nt=end_note:
                             gen.render_table(it, vals, kind, rd, s, nt))
                continue
            kind, names, new_label = DN.lookup3(g.label, s)
            if new_label and g.label != new_label:
                g.label = self.rename_at(a, new_label)
            g.macro = self.uniq(kind or ("REC_" + g.label))
            DS.name_fields(g, names)
            self.struct_groups.append(g)
            self.add(a, n * s, g.label, "struct array",
                     lambda gen, it, g=g: gen.render_structs(it, g))

    def loop_end(self, a, s, n):
        """(FEATURES["array_end"], lane mn10300-typer) The record count of the s-byte array at `a` that
        a proven pointer loop gives (data_readers.Reader.loop_bound: `cmp End, aN` and a branch back,
        aN stepped by s from a record boundary B of the array): (count up to End, the bound access),
        when that is fewer than n records; else None."""
        if not self.array_end:
            return None
        lb = getattr(self, "_loop_bounds", None)
        if lb is None:
            lb = self._loop_bounds = collections.defaultdict(list)
            for x in self.dr.accesses:
                if x.key[0] == "bound":
                    lb[x.key[1]].append(x)
        best = None
        for k in range(n):
            for x in lb.get(a + k * s, ()):
                if x.width == s:
                    m = k + x.off // s
                    if m < n and (best is None or m < best[0]):
                        best = (m, x)
        return best

    # the bytes masks of a one-touch part record (src/include/panel_memory.inc PM_PART), as
    # tools/gen_customdata_s.py checks them
    PM_PART_MASKS = [None, None, None, 0xFF, 0xDF, 0x03, 0xFF, 0xFF, 0xFF, 0x7F, 0xFF, 0x7F, 0x7F, 0x7F,
                     0x7F, 0x7F, 0x7F, 0xFF, 0x0F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F]

    def style_panels(self):
        """(profile `style_panels` = (table label, field offset, record size)) The one-touch
        settings the built-in Music Stylist setups point at (StyleRecordTable.panel): the record
        the CUSTOM one-touch settings also are (src/include/panel_memory.inc, kn6000 customdata
        Slot*.inc), here with the built-in rhythm's own 24-bit id in place of the CUSTOM slot
        (PM_RHYTHM).  KN6000: func_4C04C476 hands the pointer to func_4C04C58C, which merges the
        record into the panel parameters through the triple tables at func_4C04B9F8_entry_L4f_Table
        (the same tables the CUSTOM writer func_4C04B9F8 uses); func_4C04C552 answers 0x90 (KN6500:
        func_4C04C6C2)."""
        cfg = P.get("style_panels")
        if not cfg:
            return
        tlab, foff, size = cfg
        g = next((g for g in getattr(self, "struct_groups", []) if g.label == tlab), None)
        if g is None:
            print(f"gen_data_s: style_panels: no array {tlab}")
            return
        done = 0
        for k in range(g.count):
            ra = g.base + k * g.stride
            t = self.m.u32(ra + foff)
            if not (self.in_data(t) and self.free(t, size)):
                continue
            r = self.rom[self.off(t):self.off(t) + size]
            st = r[0x70:0x77]
            if st[2] or st[3] & ~0x40 or st[4] & 0xCF or st[6] & ~0x01:
                continue
            if size == 0x90 and r[0x8E:0x90] != b"\xff\xff":
                continue
            # (the KN7000 layout, 160 bytes) +0x8E, PM_PART_TAIL x 4 (tremulant masked 0x07), 5 x 0xFF
            if size == 0xA0 and (r[0x9B:0xA0] != b"\xff" * 5 or any(r[0x8F + 3 * j] & ~0x07 for j in range(4))):
                continue
            nm_a = self.m.u32(ra + 4)
            name = ""
            if self.in_data(nm_a):
                o = self.off(nm_a)
                name = self.rom[o:o + 16].split(b"\0")[0].decode("latin-1").strip()
            setup = self.m.u16(ra + 12)
            lab0 = self.label_at.get(t) or self.fixed.get(t)
            if lab0 is None or (t in self.fixed_by_code and self.GUESSED.match(lab0)) or lab0 in self.prev_data_label:
                lab = self.rename_at(t, f"StylePanel_{sanitize(name, 32) or k}_{setup + 1}")
            else:
                lab = self.name_at(t, lab0)
            self.add(t, size, lab, "style panel",
                     lambda gen, it, r=r, k=k, name=name, setup=setup, tlab=tlab: gen.render_style_panel(it, r, k, name, setup, tlab))
            done += 1
        print(f"gen_data_s: style panels, {done} of {g.count} typed")

    # (lane mn10300-formats) SoundAlphaListGet (941 0x485831BA) answers SoundAlphaListTable[2 * kind +
    # variant] (kind 0..2, variant 0..1, each clamped to 0 when out of range); its callers choose the
    # kind from the sound group 0x5006B7EC: 0x19 / 0x1A (the drum kits) kind 2, 0x13..0x1E but 0x1F
    # kind 1, the rest kind 0 (941 0x48498681..0x484986BB)
    SOUND_ALPHA_LISTS = ("SoundAlphaList_Groups00_12", "SoundAlphaList_Groups00_12_Var1",
                         "SoundAlphaList_Groups13_1E", None, "SoundAlphaList_DrumKits", None)

    def sound_alpha_lists(self):
        """SoundAlphaListTable (a manual-symbol name; the KN7000 program builds): 6 pointers to the
        alphabetical sound lists, each a run of 4-byte entries {char initial; u8 msb, lsb, program}
        ended by an entry whose initial is 0 (SoundAlphaIndexBuild 0x485831DC reads +0 of every
        entry, `asl2` / `movbu (d1, a0), d2`, while it is above 0; SoundAlphaInitialGet 0x485834C0
        compares +1 / +2 / +3 with a sound's bank MSB, LSB and program and answers +0).  Written one
        SOUND_ALPHA line an entry (src/include/data_tables.inc)."""
        for tname, sfx in (("SoundAlphaListTable", ""), ("SoundAlphaListTableKN2400", "KN2400")):
            self.sound_alpha_table(tname, sfx)

    def sound_alpha_table(self, tname, sfx):
        """One SoundAlphaListTable (sound_alpha_lists); `sfx` is added to its lists' names (the KN2400's own
        set, which SoundAlphaListGet 0x487019FB picks when KnprModelGet answers 1; lane mn10300-rest)."""
        a = self.m.sym_by_name.get(tname)
        if a is None or not self.in_data(a) or not self.free(a, 24):
            return
        ptrs = [self.m.u32(a + 4 * i) for i in range(6)]
        if not all(self.in_data(p) for p in ptrs):
            print("gen_data_s: SoundAlphaListTable does not point into the data region; not typed")
            return
        names = {}
        for i, p in enumerate(ptrs):
            if p not in names and self.SOUND_ALPHA_LISTS[i]:
                names[p] = self.SOUND_ALPHA_LISTS[i] + sfx
        lists = []
        for p, nm in names.items():
            o, n = self.off(p), 0
            while 0 < self.rom[o + 4 * n] < 0x80:
                n += 1
            if self.rom[o + 4 * n:o + 4 * n + 4] != b"\0\0\0\0" or not self.free(p, 4 * n + 4):
                print(f"gen_data_s: sound list {nm} at {p:#x} does not end as expected or overlaps; not typed")
                return
            lists.append((p, nm, n))
        for p, nm, n in lists:
            lab = self.rename_at(p, nm)

            def render(g, it, n=n):
                o = g.off(it.start)
                out = [f"{it.label}:\t# {n} sounds by initial {{initial, bank MSB, bank LSB, program}} and the end entry"
                       " (SoundAlphaIndexBuild, SoundAlphaInitialGet)"]
                for k in range(n + 1):
                    c, msb, lsb, pg = g.rom[o + 4 * k:o + 4 * k + 4]
                    ini = '"' + g.c_escape(bytes([c])) + '"'          # (the end entry's 0 as "\x00")
                    out.append(f"\tSOUND_ALPHA\t{ini}, {msb}, {lsb}, {pg}" + ("\t# end" if k == n else ""))
                return out
            self.add(p, 4 * n + 4, lab, "sound list", render)
        tl = self.name_at(a, tname)      # (the symbol files' name)
        self.add(a, 24, tl, "sound list",
                 lambda g, it, ptrs=ptrs: [f"{it.label}:\t# SoundAlphaListGet: [2 * kind + variant]"] +
                 [f"\t.long\t{g.ref(v)}\t# kind {i // 2}, variant {i % 2}" for i, v in enumerate(ptrs)])
        print(f"gen_data_s: sound lists: {', '.join(f'{nm} {n}' for _p, nm, n in lists)} entries")

    def fx_descriptors(self):
        """(profile `fx_descriptors` = its entry count, the KN2400) FxDescTable (a manual-symbol name): FxDescGet
        0x4863CDEF answers FxDescTable[FxDescIndexGet(code)], a 16-byte descriptor (FX_DESC) whose
        `count` 36-byte parameter records (FX_PARAM) lie right before it; FxParamGet 0x4863D4F1 and
        the Fx*Get routines read their fields (src/include/data_tables.inc has each reader).  The
        descriptors and their records tile 0x48439000..0x48440898 (probe kn2400_fx_desc.py)."""
        if not P.get("fx_descriptors"):
            return
        ta = self.m.sym_by_name.get("FxDescTable")
        if ta is None or not self.in_data(ta):
            return
        import struct
        n = P["fx_descriptors"]          # FxDescTable's entries (FxDescIndexGet's range)
        ents = [self.m.u32(ta + 4 * i) for i in range(n)]
        if not all(self.in_data(a) for a in ents):
            print("gen_data_s: FxDescTable does not point into the data region; not typed")
            return
        descs, first = [], {}
        for i, a in enumerate(ents):
            first.setdefault(a, i)
        for a in sorted(first):
            cnt, p = self.rom[self.off(a)], self.m.u32(a + 4)
            # (FxDesc_000 has count 0 but points at the one record right before it: typed too, its
            # FxDescGet answers never read it)
            nrec = cnt or (1 if p + 36 == a else 0)
            span = (p, a + 16) if nrec else (a, a + 16)
            if self.rom[self.off(a) + 2:self.off(a) + 4] != b"\0\0" or not self.in_data(p) or \
                    (cnt and p + 36 * cnt != a) or self.rom[self.off(a) + 13:self.off(a) + 16] != b"\0\0\0":
                print(f"gen_data_s: fx descriptor at {a:#x} does not check; FxDescTable not typed")
                return
            descs.append((a, cnt, p, span, nrec))
        for a, cnt, p, (lo, hi), nrec in descs:
            for k in range(nrec):
                r = self.off(p) + 36 * k
                nm = self.rom[r:r + 20]
                z = nm.find(b"\0")
                if z <= 0 or nm[z:] != bytes(20 - z) or self.rom[r + 30:r + 32] != b"\0\0":
                    print(f"gen_data_s: fx parameter at {p + 36 * k:#x} does not check; FxDescTable not typed")
                    return
            if not self.free(lo, hi - lo):
                print(f"gen_data_s: fx descriptor at {a:#x} overlaps a typed item; FxDescTable not typed")
                return
        if not self.free(ta, 4 * n):
            return
        lab = {}
        for a, cnt, p, _sp, nrec in descs:
            k = first[a]
            lab[a] = self.rename_at(a, f"FxDesc_{k:03d}")
            if nrec:
                self.rename_at(p, f"FxDesc_{k:03d}_Params")
        for a, cnt, p, _sp, nrec in descs:
            if nrec:
                def rparams(g, it, cnt=nrec, k=first[a], zero=not cnt):
                    out = [f"{it.label}:\t# the {cnt} parameter records of FxDesc_{k:03d} (FX_PARAM; FxParamGet)" +
                           (" -- its count is 0: no routine reads this one" if zero else "")]
                    for j in range(cnt):
                        r = g.off(it.start) + 36 * j
                        nm = g.rom[r:r + 20]
                        z = nm.find(b"\0")
                        num, mn, mx = struct.unpack_from("<Hhh", g.rom, r + 20)
                        band, sub, var, x29 = g.rom[r + 26:r + 30]
                        vals = int.from_bytes(g.rom[r + 32:r + 36], "little")
                        args = [f'"{g.c_escape(nm[:z])}"', str(20 - z)]
                        for fn, v, dflt in (("number", num, 0), ("min", mn, 0), ("max", mx, 0), ("band", band, 0xFF),
                                            ("sub", sub, 0), ("variant", var, 0xFF), ("depth_link", x29, 0xFF)):
                            if v != dflt:
                                args.append(f"{fn}={v if fn in ('number', 'min', 'max', 'band', 'sub') else f'0x{v:02X}'}")
                        if vals:
                            args.append(f"values={g.ref(vals)}")
                        out.append("\tFX_PARAM\t" + ", ".join(args))
                    return out
                self.add(p, 36 * nrec, self.name_at(p, f"FxDesc_{first[a]:03d}_Params"), "fx descriptor", rparams)

            def rdesc(g, it, cnt=cnt, p=p, idx=sorted(i for i, e in enumerate(ents) if e == a)):
                o = g.off(it.start)
                s8 = [x - 256 if x >= 0x80 else x for x in g.rom[o + 8:o + 13]]
                args = [g.ref(p) if cnt else g.ref(p), f"count={cnt}", f"nparams={g.rom[o + 1]}"]
                for fn, v, dflt in zip(("connection", "speed_param", "tempo_param", "drive_param", "send_param"), s8,
                                       (0, -1, -1, -1, -1)):
                    if v != dflt:
                        args.append(f"{fn}={v}")
                return [f"{it.label}:\t# FxDescTable[{', '.join(map(str, idx[:8]))}{', ...' if len(idx) > 8 else ''}]",
                        "\tFX_DESC\t" + ", ".join(args)]
            self.add(a, 16, lab[a], "fx descriptor", rdesc)
        self.add(ta, 4 * n, self.name_at(ta, "FxDescTable"), "fx descriptor",
                 lambda g, it, ents=ents: [f"{it.label}:\t# FxDescGet: [FxDescIndexGet(effect code)]"] +
                 [f"\t.long\t{g.ref(v)}\t# [{i}]" for i, v in enumerate(ents)])
        print(f"gen_data_s: fx descriptors: {len(descs)} descriptors, {sum(c for _a, c, _p, _s, _n in descs)} parameter"
              f" records, FxDescTable {n} entries")

    # (lane mn10300-rest) the KN2400's effect-DSP streams: kind byte -> operand bytes of a parameter-script
    # entry after its index byte, from each converter's pointer advance (FxParamEntryExec 0x5018A7B8; probe
    # notes/mn10300-rest-probes/kn2400_fx_streams.py); 0x70 / 0x76 have a first operand byte whose low nibble
    # adds bytes (func_501884FA, func_5018909C)
    FX_OPS = {0x21: 6, 0x23: 1, 0x24: 1, 0x25: 0, 0x40: 0, 0x61: 1, 0x62: 1, 0x63: 1, 0x64: 6, 0x65: 1, 0x66: 6,
              0x67: 3, 0x68: 3, 0x69: 0, 0x6A: 1, 0x6B: 6, 0x6C: 6, 0x6D: 0, 0x6E: 1, 0x6F: 0, 0x71: 0, 0x72: 1,
              0x73: 6, 0x74: 1, 0x75: 4, 0x78: 4, 0x79: 0}
    FX_KIND_NOTE = {0x64: "lo + (hi - lo) x v / 99", 0x66: "lo + (hi - lo) x v / 99",
                    0x21: "lo + (hi - lo) x v / 99, doubled", 0x67: "offset + v x 44100 / 1000 (ms to samples)",
                    0x68: "x v / 180", 0x69: "0x800000 - x and x to the address and the next",
                    0x40: "v x 44100 / 1000", 0x79: "bypass the unit, run FxDspClearStream, enable it",
                    0x70: "an EQ band (func_501884FA)", 0x76: "a filter (func_5018909C)"}

    def fx_streams(self):
        """(profile `fx_streams`, the KN2400; FEATURES["fx_streams"]) The effect DSP's download streams
        (lane mn10300-rest; data_tables.inc FXP_* / FXS_* / FXM_*): per DSP type a program stream
        (FxTypeProgramTable -> FxDspProgramLoad -> FxDspStreamExec 0x5018A345: records 0xFB raw bytes,
        0xFC program words to step base[unit] + i, 0xFD / 0xF7 u24 coefficients from an address, 0xFE
        {register, value} pairs, 0xFF the end), a parameter script (FxTypeScriptTable -> FxDspParamApply
        -> FxParamScriptRun: one group per parameter number, {u16 BE length, entries {kind, index,
        operands}, 0x7A}, 0xFF the end) and an address map (FxTypeMapTable: groups {u16 BE length, kind,
        u16 BE addresses}, 0xFF the end); the units' idle programs, the boot and clear streams and the
        coefficient waves FxDspQueueFlush downloads.  The pointer tables are the only readers: nothing
        loads from these bytes directly, which is why the reader search called them opaque.  A block
        nothing points at between two that are pointed at is parsed as whatever of the three kinds it
        parses as (an orphan: an older type's copy)."""
        if not P.get("fx_streams") or not FEATURES.get("fx_streams", True):
            return
        sym = self.m.sym_by_name
        need = ("FxTypeProgramTable", "FxTypeScriptTable", "FxTypeMapTable", "FxUnitIdleProgramTable")
        if any(sym.get(n) is None for n in need):
            return
        ntypes = P["fx_streams"]
        rom, u32 = self.rom, self.m.u32
        by = lambda a: rom[self.off(a)]  # noqa: E731
        names = {v: k for k, v in sym.items()}

        def prog(a, lim):
            recs, q = [], a
            while q < lim and by(q) != 0xFF:
                op = by(q)
                if op in (0xFB, 0xFC, 0xFD, 0xF7):
                    if by(q + 1) & 0xF0:
                        return None, None
                    ln = (by(q + 1) & 15) << 8 | by(q + 2)
                    if (op == 0xFC and (ln - 3) % 4) or (op in (0xFD, 0xF7) and ln != 3 and (ln < 5 or (ln - 5) % 3)) \
                            or ln < 3:
                        return None, None
                    recs.append((op, q, ln))
                    q += ln
                elif op == 0xFE:
                    r = q + 1
                    while r < lim and by(r) < 0xFB:
                        r += 5
                    recs.append((op, q, r - q))
                    q = r
                else:
                    return None, None
            return (recs, q + 1) if q < lim else (None, None)

        def groups(a, lim):
            g, q = [], a
            while q < lim and by(q) != 0xFF:
                ln = by(q) << 8 | by(q + 1)
                if ln < 3 or ln > 0x800:
                    return None, None
                g.append((q, ln))
                q += ln
            return (g, q + 1) if q < lim else (None, None)

        def entries(body):
            out, i = [], 0
            while i < len(body):
                k = body[i]
                if k == 0x7A:
                    out.append(("next", i, 1))
                    i += 1
                    continue
                if i + 1 >= len(body) or (k in (0x70, 0x76) and i + 2 >= len(body)):
                    return None
                if k == 0x70:
                    n = 1 + {1: 1, 3: 2}.get(body[i + 2] & 15, 0)
                elif k == 0x76:
                    n = 1 + (body[i + 2] & 15 == 2)
                elif k in self.FX_OPS:
                    n = self.FX_OPS[k]
                else:
                    return None
                out.append(("op", i, 2 + n))
                i += 2 + n
            return out if i == len(body) and body and body[-1] == 0x7A else None

        blocks = collections.defaultdict(set)    # (address, kind) -> {who points at it}
        for name, kind in (("FxTypeProgramTable", "program"), ("FxTypeScriptTable", "script"),
                           ("FxTypeMapTable", "map")):
            for i in range(ntypes):
                v = u32(sym[name] + 4 * i)
                if v:
                    blocks[(v, kind)].add(i)
        for u in range(6):
            blocks[(u32(sym["FxUnitIdleProgramTable"] + 4 * u), "program")].add(f"unit {u}")
        for n, why in (("FxDspBootStream", "FxDspBootStreamRun"), ("FxDspBootStream2", "FxDspBootStreamRun2"),
                       ("FxDspClearStream", "FxDspClearRun"), ("FxLfoWave0", "coefficient 0x68 = 0"),
                       ("FxLfoWave1", "coefficient 0x68 = 1"), ("FxLfoWave2", "coefficient 0x68 = 2"),
                       ("FxCurveKeep", "coefficient 0x8D = 3")):
            if sym.get(n) is not None:
                blocks[(sym[n], "program")].add(why)
        for k, why in ((4, "coefficient 0x8D = 4"), (8, "coefficient 0x8D = 5")):
            if sym.get("FxCurveKeep") is not None:
                blocks[(sym["FxCurveKeep"] + k, "program")].add(why)
        if any(not self.in_data(a) for a, _k in blocks):
            print("gen_data_s: fx streams: a pointer leaves the data region; not typed")
            return
        starts = sorted({a for a, _k in blocks})
        lo = starts[0]
        hard_end = min((v for v in (sym.get("FxUnitStepRows"),) if v is not None), default=None)
        parsed = {}
        for (a, kind), who in sorted(blocks.items()):
            nxt = min([x for x in starts if x > a] + ([hard_end] if hard_end and hard_end > a else []), default=None)
            lim = nxt if nxt is not None else a + 0x2000
            recs, end = prog(a, lim + 1) if kind == "program" else groups(a, lim + 1)
            if recs is None and nxt is None:
                print(f"gen_data_s: fx streams: the {kind} at {a:#x} does not parse; not typed")
                return
            if kind == "script" and recs is not None and any(entries(rom[self.off(g) + 2:self.off(g) + n]) is None
                                                               for g, n in recs):
                kind = "script!"         # a group the converters' operand counts do not tile: written as bytes
            parsed[a] = [a, end if recs is not None else nxt, kind, recs, who]
        # the gaps between the pointed blocks, up to the last one's end: orphans
        hi = max(p[1] for p in parsed.values())
        pos, extra = lo, []
        for a in sorted(parsed):
            if a > pos:
                extra.append((pos, a))
            pos = max(pos, parsed[a][1])
        for g0, g1 in extra:
            if hard_end is not None and g0 <= hard_end < g1:
                g1 = hard_end            # (FxUnitStepRows, the units' step rows, sits inside the family)
            q = g0
            while q < g1:
                recs, end = prog(q, g1)
                kind = "program"
                if not (recs and end and end <= g1):
                    recs, end = groups(q, g1)
                    kind = "script" if recs and all(entries(rom[self.off(g) + 2:self.off(g) + n]) is not None
                                                    for g, n in recs) else "map"
                if not (recs and end and end <= g1):
                    parsed[q] = [q, g1, "bytes", None, set()]
                    break
                parsed[q] = [q, end, kind, recs, set()]
                q = end
        spans = sorted(parsed.values())
        for (a, e, *_r), (b, *_s) in zip(spans, spans[1:]):
            if e > b:
                print(f"gen_data_s: fx streams: blocks at {a:#x} and {b:#x} overlap; not typed")
                return
        bad = [(a, e) for a, e, *_r in spans if not self.free(a, e - a)]
        if bad:
            its = sorted({f"{it.label} 0x{it.start:08X}+{it.size}" for it in self.items.values()
                          for a, e in bad if it.start < e and a < it.start + it.size})
            print(f"gen_data_s: fx streams: {len(bad)} blocks overlap typed items ({', '.join(its[:6])}); not typed")
            return
        # effect names per DSP type, for the comments: the presets FxPresetTable points at (+0x12 the type)
        tnames = collections.defaultdict(list)
        pt = sym.get("FxPresetTable")
        if pt is not None:
            for i in range(8192):
                r = u32(pt + 4 * i)
                if r and self.in_data(r):
                    t = int.from_bytes(rom[self.off(r) + 0x12:self.off(r) + 0x14], "little")
                    nm = rom[self.off(r):self.off(r) + 16].split(b"\0")[0].decode("latin-1").strip()
                    if nm and nm not in tnames[t] and len(tnames[t]) < 3:
                        tnames[t].append(nm)
        kname = {"program": "FxProgram", "script": "FxScript", "script!": "FxScript", "map": "FxMap",
                 "bytes": "FxStreamBytes"}
        def fxname(a, base):
            # (the name a previous generation gave this block stays: a fixpoint with the code)
            return self.name_at(a, base) if self.fixed.get(a) == base else self.rename_at(a, base)
        for a, e, kind, recs, who in spans:
            types = sorted(w for w in who if isinstance(w, int))
            if a in names:
                lab = self.name_at(a, names[a])
            elif types:
                lab = fxname(a, f"{kname[kind]}_{types[0]:03d}")
            elif who:
                w = sorted(who)[0]
                lab = fxname(a, f"FxUnitIdleProgram{w.split()[1]}" if w.startswith("unit") else
                                     f"{kname[kind]}_{a:08X}")
            else:
                lab = fxname(a, f"{kname[kind]}Orphan_{a:08X}")
            what = ", ".join(f"type {t}" + (f" ({' / '.join(tnames[t])})" if tnames.get(t) else "") for t in types[:6])
            if len(types) > 6:
                what += f" and {len(types) - 6} more types"
            other = ", ".join(sorted(str(w) for w in who if not isinstance(w, int)))
            src = {"program": "the program stream (FxDspStreamExec 0x5018A345)",
                   "script": "the parameter script (FxParamScriptRun 0x5018A724)",
                   "script!": "the parameter script (FxParamScriptRun 0x5018A724)",
                   "map": "the address map (FxMapAddrFind 0x5018AE27)",
                   "bytes": "bytes that parse as no stream kind"}[kind]
            head = f"{lab}:\t# {src} of {what or other or 'no type: nothing points at it [INFERENCE: an older copy]'}"
            if what and other:
                head += f"; also {other}"
            self.add(a, e - a, lab, "fx stream",
                     lambda g, it, kind=kind, recs=recs, head=head, e=e, ents=entries: g.render_fx(it, kind, recs, head, e, ents))
        print(f"gen_data_s: fx streams: {len(spans)} blocks, {sum(e - a for a, e, *_r in spans)} bytes "
              f"(0x{lo:08X}..0x{hi:08X})")

    def pow10_table(self):
        """(FEATURES["pow10_table"], lane mn10300-rest) The C library's table of the powers of ten, 309 IEEE-754
        doubles 1e0 .. 1e308, found by its contents in every MN10300 image (the "1,525 high-entropy bytes"
        the reader search left opaque are its tail).  PfDoubleToDecimal (KN7000 0x4C002A49 ...; HD-SX3
        0x9780905A `mov PfDoubleToDecimal_entry_L290_Records, a2`) puts its base in a2 and reads
        a2 +- 8 x the decimal exponent (`asl 3`; `mov (-8, a0), d0` / `mov (8, a0), d0`), which the walk does
        not bound (probes notes/mn10300-rest-probes/opaque_readers_941.py, kn6000_opaque.py, kn2400_opaque.py,
        hdsx3_opaque.py)."""
        if not FEATURES.get("pow10_table", True):
            return
        import struct
        pat = struct.pack("<dd", 1.0, 10.0)
        o = self.rom.find(pat, R1_END, DATA_END)
        while o >= 0:
            # (the firmware's values above 1e22 are one or two ulps off the nearest double: built by
            # repeated multiplication, not exact; every one within a relative 1e-14)
            if all(abs(struct.unpack_from("<d", self.rom, o + 8 * k)[0] / float(f"1e{k}") - 1) < 1e-14
                   for k in range(309)):
                break
            o = self.rom.find(pat, o + 1, DATA_END)
        if o < 0:
            return
        a = self.addr_of(o)
        if not self.free(a, 8 * 309):
            print(f"gen_data_s: the powers of ten at {a:#x} overlap a typed item; not typed")
            return

        def render(g, it):
            out = [f"{it.label}:\t# the powers of ten 1e0 .. 1e308 (309 IEEE-754 doubles, lo word, hi word; each "
                   "within 1e-14 of 10^k): PfDoubleToDecimal reads base +- 8 x the decimal exponent (found by its "
                   "contents)"]
            for k in range(309):
                lo, hi = struct.unpack_from("<II", g.rom, g.off(it.start) + 8 * k)
                out.append(f"\t.long\t0x{lo:08X}, 0x{hi:08X}\t# 1e{k}")
            return out
        lab = self.name_at(a, "Pow10Table") if self.fixed.get(a) == "Pow10Table" else self.rename_at(a, "Pow10Table")
        self.add(a, 8 * 309, lab, "double table", render)

    def render_fx(self, it, kind, recs, head, end, entries):
        rom = self.rom
        o0 = self.off(it.start)
        b = lambda a: rom[self.off(a)]  # noqa: E731
        u24 = lambda q: rom[q] << 16 | rom[q + 1] << 8 | rom[q + 2]  # noqa: E731
        hx = lambda bs: ", ".join(f"0x{x:02x}" for x in bs)  # noqa: E731
        out = [head]
        if recs is None:
            # (a pointed block whose groups do not parse up to the next block: the map of type 127, whose
            # kind-0x66 group says 7 bytes and holds 5 [INFERENCE: never reached, its script asks for 0x63 only])
            out[0] += "; its groups do not parse (written as bytes)"
            return out + [f"\t.byte\t{hx(rom[o0 + k:o0 + min(it.size, k + 16)])}" for k in range(0, it.size, 16)]

        def u24rows(q, n):
            vals = [u24(q + 3 * k) for k in range(n)]
            for k in range(0, n - n % 4, 4):
                out.append("\tFXP_U24x4\t" + ", ".join(f"0x{v:06x}" for v in vals[k:k + 4]) + f"\t# [{k}]")
            for k in range(n - n % 4, n):
                out.append(f"\tFXP_U24\t0x{vals[k]:06x}" + (f"\t# [{k}]" if k % 4 == 0 else ""))

        if kind == "program":
            for op, a, ln in recs:
                q = self.off(a)
                if op == 0xFB:
                    out.append(f"\tFXP_RAW\t{ln - 3}\t# sent raw after a 12-byte command (func_5018A2C1)")
                    for k in range(3, ln, 16):
                        out.append(f"\t.byte\t{hx(rom[q + k:q + min(ln, k + 16)])}")
                elif op == 0xFC:
                    n = (ln - 3) // 4
                    out.append(f"\tFXP_STEPS\t{n}\t# program words to steps base[unit] + 0 .. {n - 1} (FxDspStepWrite)")
                    for k in range(0, n, 4):
                        w = rom[q + 3 + 4 * k:q + 3 + 4 * min(n, k + 4)]
                        out.append(f"\t.byte\t{hx(w)}\t# steps +{k}")
                elif op in (0xFD, 0xF7) and ln == 3:
                    out.append(f"\t.byte\t0x{op:02x}, 0x00, 0x03\t# a coefficient record with no address and no value")
                elif op in (0xFD, 0xF7):
                    n, start = (ln - 5) // 3, rom[q + 3] << 8 | rom[q + 4]
                    if op == 0xFD:
                        out.append(f"\tFXP_COEF\t0x{start:x}, {n}\t# u24 coefficients burst-written from 0x{start:x}")
                    else:
                        out.append(f"\tFXP_COEF_EACH\t0x{start:x}, {n}\t# u24 coefficients from 0x{start:x}, "
                                   "each after register 0xFF = its address")
                    u24rows(q + 5, n)
                else:
                    out.append("\tFXP_REGS\t\t# {register, value} writes (FxDspIndirectWrite)")
                    for k in range(1, ln, 5):
                        out.append(f"\tFXP_REG\t0x{rom[q + k] << 8 | rom[q + k + 1]:x}, 0x{u24(q + k + 2):06x}")
            out.append("\tFXP_END")
            return out
        if kind in ("script", "map", "script!"):
            for g, ln in recs:
                q = self.off(g)
                body = rom[q + 2:q + ln]
                if kind == "map":
                    n = (ln - 3) // 2
                    if (ln - 3) % 2:
                        out.append(f"\t.byte\t{hx(rom[q:q + ln])}\t# a map group whose length does not hold "
                                   "whole addresses [INFERENCE: never reached]")
                        continue
                    out.append(f"\tFXM_GROUP\t{ln}, 0x{body[0]:02x}\t# kind 0x{body[0]:02x}: {n} address"
                               + ("es" if n != 1 else ""))
                    ads = [body[1 + 2 * j] << 8 | body[2 + 2 * j] for j in range(n)]
                    for k in range(0, n - n % 4, 4):
                        out.append("\tFXM_ADDR4\t" + ", ".join(f"0x{x:x}" for x in ads[k:k + 4]))
                    for k in range(n - n % 4, n):
                        out.append(f"\tFXM_ADDR\t0x{ads[k]:x}")
                    continue
                ents = entries(body) if kind == "script" else None
                if ents is None:
                    out.append(f"\t.byte\t{hx(rom[q:q + ln])}\t# a script group the converters' operand counts do "
                               "not tile [INFERENCE: never reached]")
                    continue
                out.append(f"\tFXS_GROUP\t{ln}")
                for typ, i, n in ents:
                    if typ == "next":
                        out.append("\tFXS_NEXT")
                        continue
                    k, ix, ops = body[i], body[i + 1], body[i + 2:i + n]
                    note = self.FX_KIND_NOTE.get(k)
                    c = f"\t# {note}" if note else ""
                    if len(ops) == 6 and k in (0x21, 0x64, 0x66, 0x6B, 0x6C, 0x73):
                        out.append(f"\tFXS_OP6\t0x{k:02x}, {ix}, 0x{ops[0] << 16 | ops[1] << 8 | ops[2]:06x}, "
                                   f"0x{ops[3] << 16 | ops[4] << 8 | ops[5]:06x}{c}")
                    elif len(ops) == 3:
                        out.append(f"\tFXS_OP3\t0x{k:02x}, {ix}, 0x{ops[0] << 16 | ops[1] << 8 | ops[2]:06x}{c}")
                    elif not ops:
                        out.append(f"\tFXS_OP\t0x{k:02x}, {ix}{c}")
                    else:
                        out.append(f"\tFXS_OP\t0x{k:02x}, {ix}\n\t.byte\t{hx(ops)}{c}")
            out.append("\tFXM_END" if kind == "map" else "\tFXS_END")
            return out
        return out + [f"\t.byte\t{hx(rom[o0 + k:o0 + min(it.size, k + 16)])}" for k in range(0, it.size, 16)]

    # (lane mn10300-formats) zlib 1.0.4's static tables, named in the symbol files where their contents
    # are found (notes/mn10300-formats-probes/zlib_tables.py): name -> (element, count, source)
    ZLIB_TABLES = {
        "configuration_table": ("config", 10, "deflate.c: per level {good_length, max_lazy, nice_length, max_chain; func}"),
        "extra_lbits": (4, 29, "trees.c: the extra bits of each length code"),
        "extra_dbits": (4, 30, "trees.c: the extra bits of each distance code"),
        "extra_blbits": (4, 19, "trees.c: the extra bits of each bit-length code"),
        "bl_order": (1, 19, "trees.c: the order the bit-length code lengths are sent in"),
        "static_l_desc": ("desc", 1, "trees.c: {static_tree, extra_bits, extra_base, elems, max_length}"),
        "static_d_desc": ("desc", 1, "trees.c: {static_tree, extra_bits, extra_base, elems, max_length}"),
        "static_bl_desc": ("desc", 1, "trees.c: {static_tree, extra_bits, extra_base, elems, max_length}"),
        "border": (4, 19, "infblock.c: the order of the bit-length code lengths"),
        "cplens": (4, 31, "inftrees.c: the copy lengths of literal codes 257..285"),
        "cplext": (4, 31, "inftrees.c: the extra bits of literal codes 257..285 (192: invalid)"),
        "cpdist": (4, 30, "inftrees.c: the copy offsets of distance codes 0..29"),
        "cpdext": (4, 30, "inftrees.c: the extra bits of distance codes 0..29"),
        "inflate_mask": (4, 17, "infutil.c: the masks of the low n bits, n = 0..16"),
    }

    def zlib_tables(self):
        """zlib 1.0.4's static tables (ZLIB_TABLES, the names the symbol files give them): each one that
        no earlier pass typed, as rows of its element type (the configuration table and the tree
        descriptors as their records), with the zlib source it comes from."""
        for name, (el, n, what) in self.ZLIB_TABLES.items():
            a = self.m.sym_by_name.get(name)
            if a is None or not self.in_data(a):
                continue
            size = {"config": 12, "desc": 20}.get(el, el) * n
            if not self.free(a, size):
                continue

            def render(g, it, el=el, n=n, what=what, name=name):
                o = g.off(it.start)
                out = [f"{it.label}:\t# zlib 1.0.4 {what} ({n} x {el if isinstance(el, str) else 8 * el}"
                       f"{'' if isinstance(el, str) else '-bit'}; found by its contents, zlib_tables.py)"]
                if el == "config":
                    for k in range(n):
                        w = struct.unpack_from("<4H", g.rom, o + 12 * k)
                        out.append(f"\t.word\t{w[0]}, {w[1]}, {w[2]}, {w[3]}\t# level {k}")
                        out.append(f"\t.long\t{g.ref(int.from_bytes(g.rom[o + 12 * k + 8:o + 12 * k + 12], 'little'))}")
                elif el == "desc":
                    t, eb, base_, elems, ml = struct.unpack_from("<5I", g.rom, o)
                    out += [f"\t.long\t{g.ref(t) if t else 0}, {g.ref(eb)}", f"\t.long\t{base_}, {elems}, {ml}"]
                else:
                    vals = [int.from_bytes(g.rom[o + el * k:o + el * k + el], "little") for k in range(n)]
                    fmt = (lambda v: f"0x{v:x}") if name == "inflate_mask" else str
                    for k in range(0, n, 16):
                        out.append(f"\ttab_u{8 * el}\t" + ", ".join(fmt(v) for v in vals[k:k + 16]) + f"\t# [{k}]")
                return out
            self.add(a, size, self.name_at(a, name), "zlib table", render)

    # (lane mn10300-formats) the payload layouts of the KN6000's hash tables, from their readers
    # (src/include/data_tables.inc has the macros and each field's reader): table name -> (macro,
    # [(payload offset, width, field)], bytes at the end no routine reads)
    HASH_PAYLOADS = {
        "ToneKeyHash": ("TONE_KEY_PAYLOAD", [(0, 2, "tone"), (2, 1, "icon"), (3, 1, "panel_group"),
                                             (4, 1, "explorer_group"), (5, 1, "panel_no_dsp"), (6, 1, "panel_no"),
                                             (7, 1, "explorer_no_dsp"), (8, 1, "explorer_no")], 3),
        "ShortKeyHash": ("SHORT_KEY_PAYLOAD", [(0, 1, "msb"), (1, 1, "lsb"), (2, 1, "program")], 3),
        "BankKeyHash": ("BANK_KEY_PAYLOAD", [(0, 2, "index")], 2),
    }

    def hash_tables(self):
        """(profile `hash_tables`: [(name, descriptor address, key bytes, payload bytes, reader,
        payload offset, what)]) Multiplicative hash tables: a descriptor {u16 mult, u16 nbuckets}
        right before nbuckets bucket pointers, each the head of a chain {u32 next, key, payload}.
        The reader (KN6000: ToneKeyLookup / ShortKeyLookup / BankKeyLookup) takes key * mult mod
        nbuckets (func_4C09B1EC: `mulu`, `divu`, mdr), walks the chain comparing +4 with the key
        and answers entry + 8 (u32 key) or + 6 (u16 key).  The entries lie back to back, one
        size per table; each is typed with its key, and the payload as rows."""
        for name, da, kb, pb, reader, poff, what in P.get("hash_tables", ()):
            m = self.m
            mult, nb = m.u16(da), m.u16(da + 2)
            ba = da + 4
            ents, ok = [], True
            for i in range(nb):
                p = m.u32(ba + 4 * i)
                while p:
                    if not self.in_data(p) or len(ents) > 100000:
                        ok = False
                        break
                    k = m.u32(p + 4) if kb == 4 else m.u16(p + 4)
                    if (k * mult) % nb != i:
                        ok = False
                    ents.append(p)
                    p = m.u32(p)
            size = 4 + kb + pb
            ents.sort()
            if not ok or not ents or any(b - a != size for a, b in zip(ents, ents[1:])) \
                    or not self.free(da, 4 + 4 * nb) or not self.free(ents[0], size * len(ents)):
                print(f"gen_data_s: hash table {name} at {da:#x} does not check; not typed")
                continue
            lab = {p: f"{name}_Ent{k:04d}" for k, p in enumerate(ents)}
            for p, l in lab.items():
                self.rename_at(p, l)
            # (the code names the descriptor and the buckets once a generation has: keep that name)
            dl = self.name_at(da, f"{name}Desc") if self.fixed.get(da) == f"{name}Desc" else self.rename_at(da, f"{name}Desc")
            bl = self.name_at(ba, f"{name}Buckets") if self.fixed.get(ba) == f"{name}Buckets" else \
                self.rename_at(ba, f"{name}Buckets")
            self.add(da, 4, dl, "hash table",
                     lambda g, it, mult=mult, nb=nb, reader=reader, name=name: [
                         f"{it.label}:\t# {name}: bucket = key * mult % nbuckets ({reader}"
                         f" {sym_addr(reader, hex(g.code_labels.get(reader, 0)).upper().replace('0X', '0x'))})",
                         f"\thash_desc\t{mult}, {nb}"])
            self.add(ba, 4 * nb, bl, "hash table",
                     lambda g, it, ba=ba, nb=nb: [f"{it.label}:"] + [
                         f"\t.long\t{g.ref(g.m.u32(ba + 4 * i)) if g.m.u32(ba + 4 * i) else 0}\t# [{i}]"
                         for i in range(nb)])

            # (lane mn10300-formats) the payload's fields, from the routines that read it (HASH_PAYLOADS):
            # used when every entry's unread bytes are 0, as the macro writes them
            spec = self.HASH_PAYLOADS.get(name)
            if spec:
                mac, flds, pad = spec
                if any(self.rom[self.off(p) + 4 + kb + pb - pad:self.off(p) + 4 + kb + pb] != bytes(pad) for p in ents):
                    print(f"gen_data_s: hash table {name}: unread payload bytes not all 0; payload as rows")
                    spec = None

            def render(g, it, kb=kb, pb=pb, head=None, spec=spec):
                p = it.start
                nx, k = g.m.u32(p), (g.m.u32(p + 4) if kb == 4 else g.m.u16(p + 4))
                o = g.off(p) + 4 + kb
                kc = (f"MSB 0x{k >> 16:02x}, LSB 0x{(k >> 8) & 0xFF:02x}, program {k & 0xFF}" if kb == 4
                      else f"0x{k >> 8:02x}, {k & 0xFF}")
                if spec:
                    args = []
                    for fo, fw, fn in spec[1]:
                        v = int.from_bytes(g.rom[o + fo:o + fo + fw], "little")
                        if v:
                            args.append(f"{fn}={v}")
                    pl = f"\t{spec[0]}\t" + ", ".join(args)
                else:
                    pl = "\t.byte\t" + ", ".join(f"0x{x:02x}" for x in g.rom[o:o + pb])
                return ([head] if head else []) + [
                    f"{it.label}:\thash_ent{8 * kb}\t{g.ref(nx) if nx else 0}, 0x{k:0{2 * kb}x}\t# key: {kc}",
                    pl.rstrip()]
            head = (f"# {name}: {len(ents)} chain entries {{next, {8 * kb}-bit key, {pb}-byte payload}};"
                    f" {reader} answers the payload (entry + {poff}).  {what}")
            for n_, p in enumerate(ents):
                self.add(p, size, lab[p], "hash table",
                         lambda g, it, kb=kb, pb=pb, h=(head if n_ == 0 else None), r=render: r(g, it, kb, pb, h))
            print(f"gen_data_s: hash table {name}: {nb} buckets, {len(ents)} entries")

    def render_style_panel(self, it, r, k, name, setup, tlab):
        def hx(bs):
            return ", ".join(f"{x:#04x}" for x in bs)
        st = r[0x70:0x77]
        rhythm = st[0] | st[1] << 8 | st[2] << 16
        return [f"{it.label}:\t# one-touch setting {setup + 1} of the Music Stylist setup \"{name}\""
                f" ({tlab}[{k}].panel; src/include/panel_memory.inc)",
                f"\tPM_PART\t{hx(r[0:0x1A])}\t# part 0 (RIGHT1)",
                f"\tPM_PART\t{hx(r[0x1A:0x34])}\t# part 1 (RIGHT2)",
                f"\tPM_PART\t{hx(r[0x34:0x4E])}\t# part 2 (LEFT)",
                f"\tPM_ENTRIES\t{hx(r[0x4E:0x56])}",
                f"\tPM_PART\t{hx(r[0x56:0x70])}\t# part 3 (PART 4)",
                f"\tPM_RHYTHM\t{rhythm:#08x}, {st[3]:#04x}, {st[4] >> 4}, {st[5] | st[6] << 8}"
                f"\t# rhythm id, TECHNI-CHORD on, VARIATION {(st[4] >> 4) + 1}, tempo",
                f"\tPM_SET77\t{hx(r[0x77:0x7A])}",
                f"\tPM_FX\t{hx(r[0x7A:0x88])}",
                # (N-4b34dd8b, lane mn10300-data3) the levels and numbers in decimal, the masks and the 0xFF
                # "none" in hex: tremolo mask, TECHNI-CHORD orchestrator part, type 0..13, sequencer volume;
                # pad volume, pad bank (src/include/panel_memory.inc)
                f"\tPM_SET88\t{r[0x88]:#04x}, {r[0x89]:#04x}, {r[0x8A]}, {r[0x8B]}",
                f"\tPM_SET8C\t{r[0x8C]}, {r[0x8D]}"] + (
                ["\t.space\t2, 0xff"] if len(r) == 0x90 else
                [f"\t.byte\t{r[0x8E]:#04x}\t# +0x8E (no field of the KN7000 writer func_4C02A0C4)"]
                + [f"\tPM_PART_TAIL\t{hx(r[0x8F + 3 * j:0x92 + 3 * j])}\t# part {j}" for j in range(4)]
                + ["\t.space\t5, 0xff"])

    # (callee) a routine whose reads through an argument are those of a string or a block, not the
    # fields of a record: the C library's, by name
    LIB_ROUTINE = re.compile(r"(str|mem|sprintf|vsprintf|printf|Lib[A-Z])")

    def arg_kinds(self):
        """(`readers_callee` profiles, lane callee-walk) {("arg", F, slot): (targets, accesses, calls)}:
        the fixed data addresses callers pass routine F in argument `slot` (a0 / a1 / d0 / d1, or
        spN, the word at (N, sp) of the caller's frame), and what F reads through that argument
        (tools/data_readers.py arg_layout: F's own loads and stores relative to it, and those of the
        routines F hands it on to).  ptr_records() types each target as a record of that layout.
        A slot whose layout says nothing about a record is left out, its reason in arg_skip."""
        if hasattr(self, "_arg_kinds"):
            return self._arg_kinds
        self._arg_kinds, self.arg_skip = {}, {}
        self._arg_arrays = {}
        dr = getattr(self, "dr", None)
        if not self.readers_callee or dr is None or not hasattr(dr, "arg_calls"):
            return self._arg_kinds
        for (F, r), cs in sorted(dr.arg_calls.items()):
            ts = {c.key[1] for c in cs if c.key[0] == "abs" and self.in_data(c.key[1])}
            if not ts:
                continue
            lay = [a for a in dr.arg_layout.get((F, r), ()) if a.off >= 0]
            fixed = [a for a in lay if a.width and a.key == ("ptr", ("arg", F, r)) and a.inner != -1]
            steps = dr.param_steps.get((F, r), set())
            why = None
            arr = self.arg_array(F, r, lay, steps) if self.step_arrays and not self.LIB_ROUTINE.match(F) else None
            if arr is not None:
                self._arg_arrays[("arg", F, r)] = arr
                self._arg_kinds[("arg", F, r)] = (ts, lay, cs)
                continue
            if self.LIB_ROUTINE.match(F):
                why = "a library routine: what it reads is a string or a block, not fields"
            elif not fixed:
                why = (f"{F} reads nothing through it at a fixed offset"
                       + (" (it hands it on, or stores it)" if lay else " (it stores it, or keeps it for later)"))
            elif 1 in steps and all(a.width == 1 for a in fixed):
                why = f"{F} reads it byte by byte in a loop (a string or a block)"
            elif max(a.off + a.width for a in fixed) <= 1:
                why = f"{F} reads only its first byte"
            elif len({a.off for a in fixed}) == 1 and fixed[0].off == 0:
                why = (f"{F} reads one field at +0 only (a scalar, or the first entry of an array it indexes"
                       f" with a loop counter the walk takes as a constant)")
            if why:
                for t in ts:
                    self.arg_skip.setdefault(t, []).append((F, r, why))
                continue
            self._arg_kinds[("arg", F, r)] = (ts, lay, cs)
        return self._arg_kinds

    def arg_array(self, F, r, lay, steps):
        """(FEATURES["step_arrays"], lane mn10300-typer) F walks the block it is handed in argument r as
        an array of s-byte records: it steps the pointer by one s >= 2 in a loop (param_steps), or reads
        it through an index the walk knows the scale s of (a loop counter times s: dyn accesses whose
        bound is s).  Returns (s, {s: count} the loops prove: data_readers param_count, a counter compared
        with a constant or the end the loop compares the pointer with; how) or None.  The records'
        fields are the accesses at their offsets modulo s."""
        fld = ("ptr", ("arg", F, r))
        how = None
        if len(steps) == 1 and min(steps) >= 2:
            s_, how = min(steps), f"{F} steps it by {min(steps)} in a loop"
        else:
            ks = {a.bound for a in lay if a.key == fld and a.inner == -1 and a.width and type(a.bound) is int}
            if len(ks) != 1 or min(ks) < 2:
                return None
            s_, how = min(ks), f"{F} reads it at an index times {min(ks)} (a loop counter)"
        if not any(a.width and a.key == fld and a.off >= 0 for a in lay):
            return None
        if max(a.width for a in lay if a.width and a.key == fld) > s_:
            return None
        counts = {n for (st_, n) in self.dr.param_count.get((F, r), ()) if st_ == s_}
        return s_, (min(counts) if counts else None), how

    def arg_evidence(self, fld):
        """The block header's evidence for an ("arg", F, slot) kind: the routine, its address, the
        slot and the calls that pass a target in it."""
        _f, F, r = fld
        a = self.dr.labels.get(F)
        cs = self._arg_kinds[fld][2]
        c0 = sorted(cs, key=lambda c: (c.cpu or 0, c.insn))[0]
        more = len({(c.func, c.cpu, c.insn) for c in cs}) - 1
        return (f"the layout {F}{f' 0x{a:08X}' if a is not None else ''} reads through its argument {r}"
                f" (passed by {re.sub(r'_entry$', '', c0.func or '?')} 0x{c0.cpu or 0:08X}"
                f" `{' '.join(c0.insn.split())}`" + (f", +{more} more calls" if more > 0 else "") + ")")

    def arg_reserve(self):
        """(callee) Before reader_tables() and variables(): the spans [target, target + the last field
        the routine reads) of the blocks arg_kinds() will type.  A table or variable those passes would
        make wholly inside one is a field of the record (the routine's read, carried into the caller by
        data_readers.resolve_params), so they leave it to ptr_records(only_arg=True), and so is one that
        starts in it and runs on past its end by no more than the span is long (a last field, and the
        bytes after it up to the next label); a longer one is kept, and the record is then not made."""
        import bisect
        spans = []
        for fld, (ts, lay, _cs) in self.arg_kinds().items():
            need = max([a.off + a.width for a in lay if a.width and a.key == ("ptr", fld) and a.inner != -1] + [0])
            if fld in self._arg_arrays:
                s_, n_, _h = self._arg_arrays[fld]
                need = s_ * (n_ or 1)
            for t in ts:
                if need and self.free(t, need):
                    spans.append((self.off(t), self.off(t) + need))
        spans.sort()
        self._arg_spans = spans
        self._arg_deferred = []        # (start, end, width, signed) of the tables / variables left to a record
        self._arg_span_starts = [s_ for s_, _e in spans]
        self._arg_bisect = bisect

    def in_arg_span(self, a, size):
        """(callee) True when the size bytes at CPU address a start inside one arg_reserve() span and
        end inside it, or past it by no more than its length (arg_reserve)."""
        spans = getattr(self, "_arg_spans", None)
        if not spans:
            return False
        o = self.off(a)
        i = self._arg_bisect.bisect_right(self._arg_span_starts, o) - 1
        while i >= 0 and spans[i][0] <= o:
            s_, e_ = spans[i]
            if o < e_ and o + size - e_ <= e_ - s_:
                return True
            i -= 1
        return False

    def indexed_tails(self):
        """(callee) After the passes that type by readers: a pointed record whose kind the code also
        reads a word of at a computed offset (`mov (d0, a0), a0`) and that the free words right after
        it continue as addresses of this region (or 0): those words are the array the code indexes,
        written `.long Label`.  (The callee walk finds fixed reads of such records' first words, so
        their kind is no longer the "fields, then rows the code indexes" of ptr_records' tail: the
        HD-SX3's names_978A31BC_p0, 13 string pointers of which the reads cover 7.)"""
        import data_structs as DS
        n = 0
        for t, size, lab, g in getattr(self, "_indexed_records", ()):
            o = self.off(t) + size
            e = o
            while o % 4 == 0 and e + 4 <= DATA_END and self.free(self.addr_of(e), 4):
                v = int.from_bytes(self.rom[e:e + 4], "little")
                if v and not self.in_data(v):
                    break
                e += 4
            vals = [int.from_bytes(self.rom[k:k + 4], "little") for k in range(o, e, 4)]
            while vals and vals[-1] == 0:
                vals.pop()
            if not any(vals):
                continue
            for v in vals:
                if v:
                    self.refs.add(v)
            rd = DS.cite([a for _o, a in g.accs if a.inner == -1], 2)
            a = self.addr_of(o)
            self.add(a, 4 * len(vals), self.name_at(a, f"{lab}_Tail"), "pointer run",
                     lambda gen, it, vals=vals, lab=lab, rd=rd: [
                         f"{it.label}:\t# {len(vals)} pointers after {lab}: the array its kind's computed-offset"
                         f" read indexes ({rd}) runs on past the fields the code reads at fixed offsets"
                         f" [INFERENCE: every word 0 or an address of this region]"]
                     + [f"\t.long\t{gen.ref(v)}" for v in vals])
            n += 1
        print(f"gen_data_s: {n} indexed record tails")

    def ptr_records(self, only_arg=False):
        """Records a pointer leads to: for every pointer the code loads from a
        typed field or table entry and then reads through (data_readers' ("ptr",
        ("fld", K, off)) keys), the targets of that field are records whose fields
        are the offsets those reads use.  Targets reached through the same fields
        are one kind; a kind whose targets lie a constant distance apart takes it
        as the record size, otherwise a record ends after its last read field.
        Nested pointers (a field of such a record) are followed the same way.
        only_arg (lane callee-walk, run after the reader-typed passes): the kinds are
        arg_kinds()'s, the blocks a caller hands a routine, with what the routine reads
        through that argument (and the records its pointer fields lead to)."""
        import bisect
        import data_structs as DS
        import data_struct_names as DN
        by_fld = collections.defaultdict(list)
        for acc in (() if only_arg else self.dr.accesses):
            k = acc.key
            if k[0] == "ptr" and k[1][0] in ("fld", "tgt") and acc.off >= 0:
                by_fld[k[1]].append(acc)
        # (lane callee-walk) the blocks callers hand a routine, as records of what it reads through the
        # argument; the records a pointer field of them leads to as well
        for fld, (_ts, lay, _cs) in (self.arg_kinds().items() if only_arg else ()):
            for acc in lay:
                if acc.key[0] == "ptr" and acc.key[1][0] in ("fld", "arg"):
                    by_fld[acc.key[1]].append(acc)
        # (data_struct_names.MODEL_POINTED) pointer fields the walk loses: a read of the target at
        # an offset the code computes, from the instruction the entry cites
        import data_readers as DR
        for (lab, foff), (fn, cpu, insn, roff, rw, sg) in (() if only_arg else DN.pointed().items()):
            for g in getattr(self, "struct_groups", []):
                if g.label == lab:
                    fld = ("fld", ("rec", g.base, g.stride), foff)
                    by_fld[fld].append(DR.Access(("ptr", fld), roff, rw, sg, "ld", fn, cpu, insn,
                                                 None, -1, None))
        # (data_readers ext) a T key: the records one of several addresses a path, a stack slot or a
        # function's return value selects; named after the first function that reads them
        self._tgt_names = {}
        for f, accs in by_fld.items():
            if f[0] == "tgt":
                fn = next((x.func for x in sorted(accs, key=lambda x: (x.cpu or 0, x.insn)) if x.func), None)
                org = self.dr.tgt_origin.get(f[1])
                mo = getattr(self.dr, "mem_origin", {}).get(f[1])
                if not org and mo:
                    # (mem_ptrs) the records a memory slot holds, named after the first function storing them
                    self._tgt_names[f] = re.sub(r"_entry.*$", "", mo) + "_Stored"
                    continue
                self._tgt_names[f] = (org + "_Result" if org else
                                      re.sub(r"_entry$", "", fn) + "_Selected" if fn else None)
        self.build_index()
        self._lmemo, self._tmemo = {}, {}
        self._arg_fill = getattr(self, "_arg_fill", set())
        self._indexed_records = getattr(self, "_indexed_records", [])
        targets = self.field_targets
        # kinds: fields whose targets overlap are one kind
        flds = [f for f in by_fld if targets(f)]
        parent = {f: f for f in flds}

        def find(f):
            while parent[f] != f:
                parent[f] = parent[parent[f]]
                f = parent[f]
            return f
        owner = {}
        for f in flds:
            for t in targets(f):
                if t in owner:
                    parent[find(f)] = find(owner[t])
                else:
                    owner[t] = f
        kinds = collections.defaultdict(list)
        for f in flds:
            kinds[find(f)].append(f)
        all_targets = sorted(owner)
        hard = sorted(set(all_targets) | set(self.fixed) - self.fixed_by_code)
        for root, fs in sorted(kinds.items(), key=lambda kv: min(min(targets(f)) for f in kv[1])):
            accs = [a for f in fs for a in by_fld[f]]
            arr = next((self._arg_arrays[f] for f in fs if f in getattr(self, "_arg_arrays", {})), None)
            if arr is not None:
                # (step_arrays) the records of an array the routine walks: its reads at their offsets
                # modulo the record size, the indexed ones too
                afs = {("ptr", f) for f in fs if f in self._arg_arrays}
                accs = [a._replace(off=a.off % arr[0], inner=None if a.inner == -1 else a.inner)
                        if a.key in afs and a.off >= 0 else a for a in accs]
            ts = sorted({t for f in fs for t in targets(f)} - set())
            ts = [t for t in ts if self.free(t, 1)]
            if not ts or not any(a.width for a in accs):
                continue
            dyn = [a for a in accs if a.inner == -1 and a.width]
            fixed_accs = [a for a in accs if a.inner != -1]
            opt = DN.options(self.kind_name(root))
            need = max([a.off + (a.width or 1) for a in fixed_accs] + [a.off for a in dyn] + [1])
            if opt.get("tail"):
                need = opt["tail"][2]
            # what the kind's 32-bit fields point at (a record's own name string) ends a record too
            stops = {self.m.u32(t + a.off) for t in ts for a in fixed_accs if a.width == 4 and self.in_data(t + a.off + 3)}
            if opt.get("tail"):
                stops |= {self.m.u32(t + k) for t in ts for k in range(0, need, 4)}
            hard_k = sorted(set(hard) | {v for v in stops if self.in_data(v)})
            room = {}
            for t in ts:
                o = self.off(t)
                e = o
                k = bisect.bisect_right(hard_k, t)
                lim = self.off(hard_k[k]) if k < len(hard_k) else DATA_END
                while e < DATA_END and e < lim and not self.claimed[e] and e - o < 0x2000:
                    e += 1
                room[t] = e - o
            gaps_ = [b - a for a, b in zip(ts, ts[1:]) if b - a == room[a]]
            stride = collections.Counter(gaps_).most_common(1)[0][0] if gaps_ else 0
            tail = None
            if opt.get("tail") and all(room[t] > need for t in ts):
                stride, tail = need, opt["tail"]
            elif dyn and (len({room[t] for t in ts}) > 1 or (self.loop_index and len(ts) == 1)) \
                    and all(room[t] > need for t in ts) and (
                    # (loop_index, lane mn10300-typer: also one record, whose rows the code indexes)
                    not gaps_ or (self.readers_ext and any(room[t] < collections.Counter(gaps_).most_common(1)[0][0]
                                                           for t in ts))):
                # (readers_ext: also when a common distance would leave the shorter records out: the
                # alphabetical sound lists SoundAlphaListGet's table points at, 4,948 / 4,864 / ... bytes,
                # before sound_alpha_lists() typed them)
                # records of varying size: the fields, then the rest of each record's room as rows of
                # the width its computed-offset reads use (the code indexes into it)
                stride = need
                w = collections.Counter(a.width for a in dyn).most_common(1)[0][0]
                tail = (w, any(a.signed for a in dyn if a.width == w), min(a.off for a in dyn))
            elif stride < need:
                stride = need + (-need % 4 if all(room[t] >= need + (-need % 4) for t in ts) else 0)
            if root[0] == "tgt" and not tail and any(need <= room[t] < stride for t in ts):
                # (data_readers ext) the records one function selects, of several sizes (the bytes
                # their pointer fields point at sit between them): the fields every one of them holds
                stride = min(room[t] for t in ts if room[t] >= need)
            # (readers_ext) records too short for the kind's size (a union whose variants hold fewer
            # fields: the resource-id trie's leaves) are a variant each, with the fields that fit
            if only_arg and not tail and stride:
                # (callee) two records of the kind a whole number of records apart with free bytes between:
                # the records between are of the kind too [INFERENCE: an array the routine is handed
                # elements of, some of them by no call the walk sees]
                fill = []
                for p_, q_ in zip(ts, ts[1:]):
                    k_ = (q_ - p_) // stride
                    if (q_ - p_) % stride == 0 and 2 <= k_ <= 8 and self.free(p_ + stride, q_ - p_ - stride):
                        fill += [p_ + j * stride for j in range(1, k_)]
                for t in fill:
                    room[t] = stride
                    self._arg_fill.add(t)
                ts = sorted(set(ts) | set(fill))
            variants = [(stride, [t for t in ts if room[t] >= stride], "")]
            if self.readers_ext and not tail:
                short = collections.defaultdict(list)
                for t in ts:
                    if 4 <= room[t] < stride:
                        short[room[t]].append(t)
                variants += [(r, short[r], f"_s{r}") for r in sorted(short, reverse=True)
                             if any(a.width and a.off + a.width <= r for a in fixed_accs)]
            args_ = [f for f in fs if f[0] == "arg"]
            for stride, ts, vsuf in variants:
                self._ptr_group(root, accs, stride, ts, tail, room, vsuf, args_)

    def _ptr_group(self, root, accs, stride, ts, tail, room, vsuf="", args_=()):
        """One record kind of ptr_records: its macro, and an item per target."""
        import data_structs as DS
        import data_struct_names as DN
        if True:
            if not ts or stride > 0x2000:
                return
            g = DS.Group(ts[0], stride)
            g.tail = tail
            # (callee) the routines whose reads through an argument give the layout
            g.evidence = [self.arg_evidence(f) for f in args_[:2]] + (
                [f"+{len(args_) - 2} more routines"] if len(args_) > 2 else [])
            for f in args_:
                if f in getattr(self, "_arg_arrays", {}):
                    s_, n_, how = self._arg_arrays[f]
                    g.evidence.append(f"an array of {s_}-byte records: {how}; "
                                      + (f"{n_} of them (the loop's count)" if n_ else
                                         "as many as are free up to the next label [INFERENCE: the block's extent]"))
                    break
            g.arg_of = {t: [f for f in args_ if t in self._arg_kinds[f][0]] for t in ts} if args_ else {}
            g.arg_tail = {}
            g.accs = [(a.off, a) for a in accs if a.off < stride and (not vsuf or a.off + (a.width or 1) <= stride)]
            g.count = len(ts)
            g.fields = DS.layout(g, self, None, 0, offs=[self.off(t) for t in ts])
            cont = self.kind_name(root) + vsuf
            g.label = cont
            kind, names = DN.lookup(cont, stride)
            g.macro = self.uniq(kind or ("REC_" + cont))
            DS.name_fields(g, names)
            self.struct_groups.append(g)
            for i, t in enumerate(ts):
                lab = self.label_at.get(t)
                if lab is None:
                    lab = self.fixed.get(t)
                if lab is None or (t in self.fixed_by_code and self.GUESSED.match(lab)):
                    lab = self.rename_at(t, f"{cont}_{i}")
                else:
                    lab = self.name_at(t, lab)
                for f in g.fields:
                    if f.kind == "ptr":
                        v = self.m.u32(t + f.off)
                        if v and self.in_data(v):
                            self.refs.add(v)
                size = stride
                if tail:
                    size = room[t] - (room[t] - stride) % tail[0]
                elif args_:
                    # (callee) a table or variable arg_reserve() left to this record that runs on past it
                    # (to the next label): its bytes after the record are the record's tail, so they
                    # stay typed
                    o_ = self.off(t)
                    run = [d for d in getattr(self, "_arg_deferred", ()) if o_ <= d[0] < o_ + stride < d[1]]
                    if run:
                        e_ = max(d[1] for d in run)
                        if self.free(t + stride, e_ - o_ - stride) and not any(
                                o_ + stride <= self.off(u) < e_ for u in ts if u != t):
                            w_, sg_ = max(run, key=lambda d: d[1])[2:]
                            if (e_ - o_ - stride) % w_ or (o_ + stride) % w_:
                                w_, sg_ = 1, False
                            size = e_ - o_
                            g.arg_tail[t] = (w_, sg_)
                self.add(t, size, lab, "pointed record", lambda gen, it, g=g: gen.render_pointed(it, g))
                if not tail and any(a.inner == -1 and a.width == 4 for a in accs):
                    self._indexed_records.append((t, size, lab, g))

    def _item_of(self, a):
        import bisect
        o = self.off(a)
        i = bisect.bisect_right(self.starts, o) - 1
        if i >= 0 and self.ranges[i][0] <= o < self.ranges[i][1]:
            return self.items[self.ranges[i][0]]
        return None

    def field_locs(self, fld, depth=0):
        """The addresses the pointer field `fld` (data_readers ("fld", key, off)) is
        read from: one fixed word, every record of a typed array or every entry of
        a pointer table, or the fields of the records another field points at."""
        if fld in self._lmemo:
            return self._lmemo[fld]
        self._lmemo[fld] = set()
        K, o = fld[1], fld[2]
        out = set(getattr(self, "extra_locs", {}).get((K, o), ()))
        if K[0] == "abs":
            out |= {K[1] + o}
        elif K[0] == "rec":
            b, st = K[1], K[2]
            it = self._item_of(b) if self.in_data(b) else None
            if it is not None and st:
                k = -((b + o - it.start) // st)
                while b + o + k * st + 4 <= it.start + it.size:
                    if b + o + k * st >= it.start:
                        out.add(b + o + k * st)
                    k += 1
            elif it is not None and it.kind == "pointer table":
                out = {it.start + 4 * i + o for i in range(it.size // 4)}
            else:
                out = {b + o}
        elif K[0] == "ptr" and K[1][0] in ("fld", "tgt", "arg") and depth < 4:
            out = {t + o for t in self.field_targets(K[1], depth + 1)}
        self._lmemo[fld] = out
        return out

    def field_targets(self, fld, depth=0):
        """The data addresses the pointer field `fld` holds (and, lane mn10300-typer: the records of a
        block a routine walks as an array, arg_array(); every record a chain of the kind reaches,
        chain_closure())."""
        if fld[0] == "tgt":
            return self.chain_closure(fld, {t for t in fld[1] if self.in_data(t)})
        if fld[0] == "arg":
            ts = set(self.arg_kinds().get(fld, ((),))[0])
            if fld in getattr(self, "_arg_arrays", {}):
                ts = self.array_records(fld, ts)
            return ts
        if fld not in self._tmemo:
            ts = set()
            for L in self.field_locs(fld, depth):
                if self.in_data(L) and self.in_data(L + 3):
                    v = self.m.u32(L)
                    if v and self.in_data(v):
                        ts.add(v)
            # (mem_ptrs, lane mn10300-typer) and what the code stores in the field at run time
            ts |= {v for v in self.stored_targets(fld, depth) if self.in_data(v)}
            self._tmemo[fld] = self.chain_closure(fld, ts)
        return self._tmemo[fld]

    def stored_targets(self, fld, depth=0):
        """(mem_ptrs) The data addresses the code stores in pointer field fld at run time
        (data_readers field_stores): stores keyed as fld itself, and stores to the same offset of the
        records another pointer field leads to that is read from the same words as fld's own
        (`(0x14, a0)` after `mov (0x34, a0), a0` through func_484288AC_Table[i] in SetApTimer and through
        func_484288AC_Table+0x34 elsewhere: one field, two spellings of its path)."""
        fs = getattr(getattr(self, "dr", None), "field_stores", None)
        if not fs:
            return set()
        out = set(fs.get(fld, ()))
        if fld[0] == "fld" and fld[1][0] == "ptr" and fld[1][1][0] == "fld" and depth < 4:
            idx = self.__dict__.setdefault("_fs_index", [(k[1][1], k[2], v) for k, v in fs.items()
                                                         if k[1][0] == "ptr" and k[1][1][0] == "fld"])
            mine = None
            for ks, off2, vals in idx:
                if off2 != fld[2] or ks == fld[1][1]:
                    continue
                if mine is None:
                    mine = self.field_locs(fld[1][1], depth + 1)
                if mine and mine & self.field_locs(ks, depth + 1):
                    out |= vals
        return out

    def chains(self):
        """(FEATURES["deep_records"]) {kind key: {field offset}}: data_readers' "chain" accesses, a loop
        that advances a pointer to records of the kind through their own field (a list, a tree path)."""
        ch = getattr(self, "_chains", None)
        if ch is None:
            ch = self._chains = collections.defaultdict(set)
            if self.deep_records and getattr(self, "dr", None) is not None:
                for x in self.dr.accesses:
                    if x.rw == "chain" and x.key[0] == "ptr" and x.key[1][0] in ("fld", "tgt") and 0 <= x.off < 0x1000:
                        ch[x.key[1]].add(x.off)
        return ch

    def chain_closure(self, fld, ts):
        """ts and every record the kind's chain fields lead to from them (field f of a record of the
        kind points at the next one), visited once each, at most 4,096 records."""
        offs = self.chains().get(fld)
        if not offs or not ts:
            return ts
        seen, todo = set(ts), list(ts)
        while todo and len(seen) < 4096:
            t = todo.pop()
            for f in offs:
                if self.in_data(t + f) and self.in_data(t + f + 3):
                    v = self.m.u32(t + f)
                    if v and self.in_data(v) and v not in seen:
                        seen.add(v)
                        todo.append(v)
        return seen

    def array_records(self, fld, ts):
        """(step_arrays) The records of each block in ts that arg_array() says the routine walks: the
        loop's count of them when it is proven, else as many as are free up to the next address
        anything names [INFERENCE: the block's extent]."""
        memo = self.__dict__.setdefault("_arr_memo", {})
        if fld in memo:
            return memo[fld]
        s_, n, _how = self._arg_arrays[fld]
        out = set()
        for t in ts:
            out.add(t)
            j = 1
            while j < (n or 4096):
                e = t + j * s_
                if not self.free(e, s_) or (n is None and (e in self.refs or e in self.fixed or e in self.label_at)):
                    break
                out.add(e)
                j += 1
        memo[fld] = out
        return out

    def kind_name(self, fld):
        """A name for what the field fld points at: its container's label and the field."""
        if fld[0] == "tgt":
            nm = getattr(self, "_tgt_names", {}).get(fld)
            return nm or f"data_{min(fld[1]):08X}_Selected"
        if fld[0] == "arg":
            return f"{fld[1]}_Arg{fld[2][0].upper()}{fld[2][1:]}"
        K, o = fld[1], fld[2]
        if K[0] == "abs":
            it = self.item_containing(K[1] + o)
            base = it.label if it is not None and it.label else f"data_{K[1]:08X}"
            off = K[1] + o - (it.start if it is not None else K[1])
        elif K[0] == "rec":
            it = self.item_containing(K[1])
            base = it.label if it is not None and it.label else f"data_{K[1]:08X}"
            off = (K[1] + o - (it.start if it is not None else K[1])) % (K[2] or 1 << 30)
        else:
            base, off = self.kind_name(K[1]), o
        return re.sub(r"^REC_", "", f"{base}_p{off}")

    def render_pointed(self, it, g):
        import data_structs as DS
        args_ = getattr(g, "arg_of", {}).get(it.start)
        if not args_ and it.start in getattr(self, "_arg_fill", ()):
            return [f"{it.label}:\t# {g.macro} ({g.stride} bytes) [INFERENCE: between two records of the kind,"
                    f" a whole number of records apart; no call the walk sees passes it]",
                    DS.record_line(self, g, self.rom, self.off(it.start))]
        if args_ and (not g.tail or it.size == g.stride):
            # (callee) the block a routine is handed: which routine, in which argument, and who passes it
            ev = "; ".join(self.arg_evidence(f) for f in args_[:2]) + (
                f"; +{len(args_) - 2} more routines" if len(args_) > 2 else "")
            out = [f"{it.label}:\t# {g.macro} ({g.stride} bytes): {ev}", DS.record_line(self, g, self.rom, self.off(it.start))]
            if it.size > g.stride:
                w, sg = g.arg_tail[it.start]
                o = self.off(it.start) + g.stride
                vals = [int.from_bytes(self.rom[o + w * i:o + w * i + w], "little", signed=sg)
                        for i in range((it.size - g.stride) // w)]
                kind = ("s" if sg else "u") + str(8 * w)
                out.append(f"\t# then {len(vals)} x {kind} up to the next label, which no instruction is seen to read"
                           f" (the table the field reads ran on into them)")
                for i in range(0, len(vals), 16):
                    out.append(f"\ttab_{kind}\t" + ", ".join(str(v) for v in vals[i:i + 16]) + f"\t# +{g.stride + w * i}")
            return out
        if not g.tail or it.size == g.stride:
            return [f"{it.label}:\t# {g.macro} ({g.stride} bytes)", DS.record_line(self, g, self.rom, self.off(it.start))]
        w, signed, at = g.tail
        o = self.off(it.start) + g.stride
        vals = [int.from_bytes(self.rom[o + w * i:o + w * i + w], "little", signed=signed)
                for i in range((it.size - g.stride) // w)]
        kind = ("s" if signed else "u") + str(8 * w)
        per = 12 if len(vals) % 12 == 0 else 16
        rd = DS.cite([a for _o, a in g.accs if a.inner == -1] or [a for _o, a in g.accs], 2)
        out = [f"{it.label}:\t# {g.macro} ({g.stride} bytes), then {len(vals)} x {kind} the code indexes"
               f" from +{at}" + (f" (read by {rd})" if rd else " (tools/data_struct_names.py OPTIONS)"),
               DS.record_line(self, g, self.rom, self.off(it.start))]
        for i in range(0, len(vals), per):
            out.append(f"\ttab_{kind}\t" + ", ".join(str(v) for v in vals[i:i + per]) + f"\t# [{i}]")
        return out

    def message_tables(self):
        """(`structs` profiles) {u32 key, code address} pairs, >= 3 in a row and
        8-aligned, in bytes no item holds.  [INFERENCE] dispatch tables: a routine
        looks the key up and jumps to or calls the address (the list-box message
        tables such as StyleListBoxMsgTable are this shape; a key that is a MILK
        id is written by its EV_ / MT_ / other id name).  A code address is a
        label (loc_<ADDR>, code_refs.txt)."""
        ids = dict(getattr(self, "ev_name", {}))
        for d in (getattr(self, "id_name", {}), getattr(self, "fn_name", {})):
            for k, v in d.items():
                ids.setdefault(k, v)
        o = R1_END + (-R1_END % 8)
        while o + 24 <= DATA_END:
            n = 0
            while o + 8 * (n + 1) <= DATA_END and self.free(self.addr_of(o + 8 * n), 8):
                w0 = int.from_bytes(self.rom[o + 8 * n:o + 8 * n + 4], "little")
                w1 = int.from_bytes(self.rom[o + 8 * n + 4:o + 8 * n + 8], "little")
                if not (self.in_code(w1) and self.code_ptr_ok(w1)) or self.is_addr(w0):
                    break
                n += 1
            if n >= 3:
                a = self.addr_of(o)
                ents = [(int.from_bytes(self.rom[o + 8 * k:o + 8 * k + 4], "little"),
                         int.from_bytes(self.rom[o + 8 * k + 4:o + 8 * k + 8], "little")) for k in range(n)]
                rd = [x for x in self.dr.accesses if x.key == ("abs", a) or (x.key[0] == "rec" and x.key[1] == a)]
                if not rd and FEATURES.get("msg_readers", True):
                    # (lane mn10300-data) a table handed to a routine: the accesses through the argument
                    rd = [x for x in self.dr.accesses if x.key[0] == "ptr" and x.key[1][0] == "arg"
                          and a in self.arg_kinds().get(x.key[1], ((),))[0]]
                nm = self.label_at.get(a) or self.fixed.get(a)
                guessed = nm is not None and a in self.fixed_by_code and (
                    self.GUESSED.match(nm) or (FEATURES.get("msg_readers", True) and re.fullmatch(r"MsgTable_[0-9A-F]{8}", nm)))
                if nm is None or guessed:
                    # (msg_readers, lane mn10300-data) named after the routine that reads the keys (not the
                    # caller that only passes the table on); the shape name an earlier generation gave is a guess
                    fr = sorted({re.sub(r"(_entry)?(_L[0-9a-f]+_*)?$", "", x.func) for x in rd
                                 if x.func and not x.insn.split()[0].startswith("call")})
                    base = f"{fr[0]}_MsgTable" if fr and FEATURES.get("msg_readers", True) else f"MsgTable_{a:08X}"
                    if nm is not None and ((not fr and re.fullmatch(r"MsgTable_[0-9A-F]{8}", nm))
                                           or re.fullmatch(re.escape(base) + r"(_\d+)?", nm)):
                        lab = self.name_at(a, nm)       # (no reader to name it after, or named so already)
                    else:
                        lab = self.rename_at(a, base)
                else:
                    lab = self.name_at(a, nm)

                def render(g, it, ents=ents, rd=rd):
                    import data_structs as DS
                    head = f"{it.label}:\t# {len(ents)} x {{u32 key, code address}}: a dispatch table" + (
                        f"; read by {DS.cite(rd)}" if rd else "")
                    return [head] + [f"\t.long\t{ids.get(i, f'0x{i:X}' if i > 0xFFFF else str(i))}, {g.ref(h)}"
                                     for i, h in ents]
                self.add(a, 8 * n, lab, "message table", render)
                o += 8 * n
            else:
                o += 8

    # The caller-supplied-bitmap blitters (annotations/gfx_draw.ann): a1 = pixels,
    # d0 = width, d1 = height; bits a pixel, and whether a row is padded to an even
    # byte count (all but SPFast4, whose rows are (W + 3) / 4 bytes).
    BLITTERS = {"DrawBitmapSP": 8, "DrawBitmapSPFast": 8, "DrawBitmapSPFast256": 8,
                "DrawBitmapSPFast16": 4, "DrawBitmapSPFast4": 2, "DrawBitmapSP2": 1}

    def drawn_bitmaps(self):
        """(`structs` profiles) Pixels the code hands to a caller-supplied-bitmap
        blitter with a constant width and height (data_readers: the call's a1, d0,
        d1), directly or through a pointer field / table entry: an indexed PNG in
        <data dir>/media/ (tools/table_png.py `pk D W H`, rows padded to an even
        byte count, or `p2 W H`), which the build turns back into the bytes."""
        import table_png as TP
        found = collections.defaultdict(set)      # address -> {(depth, w, h, blitter, caller, cpu)}
        self.build_index()
        self._lmemo, self._tmemo = {}, {}
        for acc in self.dr.accesses:
            if not acc.rw == "arg a1" or not acc.extra or acc.extra[0] not in self.BLITTERS:
                continue
            c = acc.extra[1]
            w, h = c.get("d0"), c.get("d1")
            if not w or not h or w <= 0 or h <= 0 or w > 640 or h > 240:
                continue
            k = acc.key
            if k[0] == "abs":
                ts = {k[1]}
            elif k[0] == "ptr" and k[1][0] in ("fld", "tgt") and acc.off == 0:
                ts = self.field_targets(k[1])
            else:
                continue
            for t in ts:
                found[t].add((self.BLITTERS[acc.extra[0]], w, h, acc.extra[0], acc.func, acc.cpu or 0))
        for a in sorted(found):
            uses = sorted(found[a], key=lambda u: (u[5], u[4]))
            shapes = {u[:3] for u in uses}
            if len(shapes) != 1:
                print(f"gen_data_s: bitmap at {a:#x} drawn with several shapes {sorted(shapes)}; not typed")
                continue
            depth, w, h = shapes.pop()
            if depth == 2:
                if w % 4:
                    continue
                fmt, n = f"p2 {w} {h}", w // 4 * h
            else:
                fmt, n = f"pk {depth} {w} {h}", TP.pk_stride(depth, w) * h
            if not self.in_data(a) or not self.free(a, n):
                print(f"gen_data_s: bitmap at {a:#x} ({fmt}) not free; not typed")
                continue
            blit, caller, cpu = uses[0][3], uses[0][4], uses[0][5]
            nm = self.label_at.get(a) or self.fixed.get(a)
            if nm is None or (a in self.fixed_by_code and self.GUESSED.match(nm)):
                lab = self.rename_at(a, f"Bitmap_{re.sub(r'_entry$', '', caller or 'x')}")
            else:
                lab = self.name_at(a, nm)
            fn = f"{lab}.png"
            raw = self.rom[self.off(a):self.off(a) + n]
            self.media_files[fn] = TP.to_png(fmt, raw)
            more = f" (+{len(uses) - 1} more)" if len(uses) > 1 else ""
            self.add(a, n, lab, "bitmap",
                     lambda g, it, fn=fn, fmt=fmt, blit=blit, caller=caller, cpu=cpu, w=w, h=h, depth=depth, more=more: [
                         f"{it.label}:\t# {w} x {h}, {depth} bit(s) a pixel: {caller} 0x{cpu:08X} draws it with"
                         f" {blit}{more} ({OUTDIR}/media/{fn})",
                         f'\t.incbin\t"{P.get("bitmap_dir", "build/bitmaps")}/{os.path.splitext(fn)[0]}.bin"\t# census: generated -- '
                         f"{SHARED}tools/table_png.py ({fmt}) from {OUTDIR}/media/{fn}"])

    # Glyphs the code addresses by name rather than through a blitter call's arguments:
    # label -> (tools/table_png.py format, why).  Lane media-files, 2026-10-30.
    NAMED_GLYPHS = {
        "SjisMissingGlyph": ("font 2 16 1",
                             "16 x 16, 1 bpp, column-major (two 8-pixel columns of 16 bytes): the glyph "
                             "DrawString_Impl 0x48425467 draws for a Shift-JIS code its font lacks "
                             "(annotations/gfx_draw.ann); a box with an X in it"),
    }

    def named_glyphs(self):
        """(`structs` profiles) The NAMED_GLYPHS: a PNG in <data dir>/media/, which the
        build turns back into the bytes, like drawn_bitmaps()."""
        import table_png as TP
        by_name = {}
        for a, nm in list(self.fixed.items()) + list(self.label_at.items()):
            by_name.setdefault(nm, a)
        for nm, (fmt, why) in self.NAMED_GLYPHS.items():
            a = by_name.get(nm)
            if a is None:
                continue
            _, (cols, h, count), _ = TP.parse_fmt(fmt)
            n = cols * h * count
            if not self.in_data(a) or not self.free(a, n):
                print(f"gen_data_s: glyph {nm} at {a:#x} not free; not typed")
                continue
            lab = self.name_at(a, nm)
            fn = f"{lab}.png"
            self.media_files[fn] = TP.to_png(fmt, self.rom[self.off(a):self.off(a) + n])
            self.add(a, n, lab, "bitmap",
                     lambda g, it, fn=fn, fmt=fmt, why=why: [
                         f"{it.label}:\t# {why} ({OUTDIR}/media/{fn})",
                         f'\t.incbin\t"{P.get("bitmap_dir", "build/bitmaps")}/{os.path.splitext(fn)[0]}.bin"\t# census: generated -- '
                         f"{SHARED}tools/table_png.py ({fmt}) from {OUTDIR}/media/{fn}"])

    def variables(self):
        """(`structs` profiles) What is left that an instruction reads or writes at a
        fixed address (data_readers: a load / store of `(Label)` or `(off, aN)` with aN a
        known address, or an unscaled index from one): a variable of that width, or a
        table of them up to the next address anything names, the instructions cited.
        In the initialised-RAM image these are the variables' initial values."""
        import bisect
        import data_structs as DS
        acc = collections.defaultdict(list)
        for x in self.dr.accesses:
            k = x.key
            if not x.width:
                continue
            if k[0] == "abs":
                acc[k[1]].append(x)
            elif k[0] == "rec" and k[2] is None:
                acc[k[1] + x.off].append(x)
        self.build_index()
        named = sorted({self.off(a) for a in acc if self.in_data(a)} | {self.off(a) for a in self.refs if self.in_data(a)}
                       | {self.off(a) for a in self.label_at})
        for a in sorted(acc):
            if not self.in_data(a) or not self.free(a, 1):
                continue
            xs = acc[a]
            w = collections.Counter(x.width for x in xs).most_common(1)[0][0]
            o = self.off(a)
            if o % w:
                w = 1
            k = bisect.bisect_right(named, o)
            end = named[k] if k < len(named) else DATA_END
            e = o
            while e < end and not self.claimed[e]:
                e += 1
            n = (e - o) // w
            if n < 1:
                continue
            signed = any(x.signed for x in xs if x.width == w)
            if self.in_arg_span(a, w * n):
                # (callee) a field of a block a routine is handed: ptr_records(only_arg=True)
                self._arg_deferred.append((o, o + w * n, w, signed))
                continue
            vals = [int.from_bytes(self.rom[o + w * i:o + w * i + w], "little", signed=signed) for i in range(n)]
            kind = ("s" if signed else "u") + str(8 * w)
            rd = sorted({(x.func, x.cpu, " ".join(x.insn.split())) for x in xs}, key=lambda r: (r[1] or 0, r[0] or "", r[2]))
            ram = RAMINIT_OFF <= o < RAMINIT_END
            nm = self.label_at.get(a) or self.fixed.get(a)
            if nm is None or (a in self.fixed_by_code and self.GUESSED.match(nm)):
                fn = next((r[0] for r in rd if r[0]), None)
                base = (re.sub(r"_entry$", "", fn) + ("_Var" if n == 1 else "_Table")) if fn else f"var_{a:08X}"
                lab = self.rename_at(a, base)
            else:
                lab = self.name_at(a, nm)
            self.add(a, w * n, lab, "variable" if n == 1 else "reader table",
                     lambda g, it, vals=vals, kind=kind, rd=rd, w=w, ram=ram: g.render_variable(it, vals, kind, rd, w, ram))

    # -- (lane mn10300-data) the widgets' RAM state variables -------------------------------------
    def code_bodies(self):
        """{function name: (CPU address or None, [instruction text, whitespace folded])} of the converted
        code: a function runs from a column-0 label that is no local label (data_readers.LOCAL:
        loc_<ADDR>, <function>_L<hex>) to the next such label."""
        if hasattr(self, "_bodies"):
            return self._bodies
        import glob as _glob
        import data_readers as DR
        body, cur = {}, None
        for f in sorted(_glob.glob(code_glob())):
            for ln in open(f, encoding="latin-1"):
                code = ln.split("#", 1)[0].rstrip()
                if not code.strip():
                    continue
                mo = re.match(r"^([A-Za-z_][\w.$]*):", code)
                if mo:
                    n = mo.group(1)
                    if not DR.LOCAL.search(n):
                        cur = n
                        body.setdefault(cur, (self.code_labels.get(n), []))
                    rest = code[mo.end():].strip()
                    if rest and cur:
                        body[cur][1].append(" ".join(rest.split()))
                    continue
                if cur and code[:1] in " \t":
                    body[cur][1].append(" ".join(code.split()))
        self._bodies = body
        return body

    def data_label_addr(self, name):
        """The data-region CPU address the code's name `name` stands for, or None."""
        a = self.prev_data_label.get(name)
        if a is None:
            a = self.code_labels.get(name)
        return a if a is not None and self.in_data(a) else None

    def code_funcs(self):
        """code_bodies() with a function's `<name>_entry` label (the KN7000's and the siblings'
        second entry after the prologue) folded into it: [(name, CPU, [instructions])]."""
        if hasattr(self, "_funcs"):
            return self._funcs
        out = []
        for n, (cpu, body) in self.code_bodies().items():
            if n.endswith("_entry") and out and out[-1][0] == n[:-6]:
                out[-1][2].extend(body)
                continue
            out.append((n, cpu, list(body)))
        self._funcs = out
        return out

    NUM = r"(-?0x[0-9a-f]+|-?\d+)"

    def maps128(self):
        """(FEATURES["maps128"], lane mn10300-data) The 128 x 64 maps of two-byte entries: a routine
        builds the row from a byte it checks against 0x7F (`cmp 0x7f, dN`) and the column from the
        next byte masked to 6 bits (`and 0x3f, dM`), then addresses Table + row * 128 (`asl 7, dR` and
        `add Table, dR` or `mov Table, dR` / `add dR, ...`) + column * 2 (`add dC, dC`) and reads the
        entry's two bytes (KN7000 func_48412A17, KN6000 func_4C15F0D9, KN2400 func_4863D95A).  Each map
        is 16,384 bytes; it is typed only when all of it is still free."""
        if not FEATURES.get("maps128", True):
            return
        found = collections.OrderedDict()
        for fn, cpu, L in self.code_funcs():
            if not any(re.fullmatch(r"cmp 0x7f, d\d", x) for x in L) or \
                    not any(re.fullmatch(r"and 0x3f, d\d", x) for x in L):
                continue
            for i, ins in enumerate(L):
                if not re.fullmatch(r"asl 7, d\d", ins):
                    continue
                win = L[max(0, i - 3):i + 5]
                if not any(re.fullmatch(r"add (d\d), \1", x) for x in win):
                    continue
                for x in win:
                    mo = re.fullmatch(r"(?:add|mov) ([A-Za-z_]\w*), d\d", x)
                    a = self.data_label_addr(mo.group(1)) if mo else None
                    if a is not None and a not in found:
                        found[a] = (fn, cpu, ins, x)
        tabs = sorted(found)
        for a in tabs:
            n = 128 * 128
            if not self.free(a, n) or any(a < b < a + n for b in tabs):
                continue
            fn, cpu, ins, x = found[a]
            lab = self.name_at(a, f"{fn}_Map")
            o = self.off(a)
            cite = f"{fn}{(' 0x%08X' % cpu) if cpu else ''}: `cmp 0x7f` (row), `and 0x3f` (column), `{ins}` / `{x}`"

            def render(g, it, o=o, cite=cite):
                out = [f"# 128 rows x 64 entries of two bytes, entry = row * 128 + column * 2, read as"
                       f" {{u8 lo, u8 hi}} and combined hi << 8 | lo ({cite}); 0xFFFF: no entry",
                       f"{it.label}:"]
                r = 0
                while r < 128:
                    row = g.rom[o + 128 * r:o + 128 * r + 128]
                    if row == b"\xff" * 128:
                        k = r
                        while k < 128 and g.rom[o + 128 * k:o + 128 * k + 128] == b"\xff" * 128:
                            k += 1
                        out.append(f"\t.space\t{128 * (k - r)}, 0xFF\t# row{'s' if k - r > 1 else ''} {r}"
                                   + (f"..{k - 1}" if k - r > 1 else "") + ": no entry")
                        r = k
                        continue
                    vals = [int.from_bytes(row[2 * c:2 * c + 2], "little") for c in range(64)]
                    out.append("\t.word\t" + ", ".join(f"0x{v:04x}" for v in vals) + f"\t# row {r}")
                    r += 1
                return out
            self.add(a, n, lab, "code map", render)

    SENTINELS = {1: (0xFF, 0), 2: (0xFFFF, 0), 4: (0xFFFFFFFF, 0)}

    def code_files(self):
        """The converted code's files as lines (data_readers' order: the sorted code glob), for an
        access's `pos` (file index, line index)."""
        if not hasattr(self, "_cfiles"):
            import glob as _glob
            self._cfiles = [open(f, encoding="latin-1").read().split("\n") for f in sorted(_glob.glob(code_glob()))]
        return self._cfiles

    @staticmethod
    def _ins(ln):
        c = ln.split("#", 1)[0].strip()
        mo = re.match(r"^[A-Za-z_][\w.$]*:\s*", c)
        if mo:
            return c[:mo.end()].strip()[:-1], " ".join(c[mo.end():].split())
        return None, " ".join(c.split())

    def sentinel_loop(self, x):
        """(sentinel_lists) The loop an access x reads a list's end marker in: x is a load `mov|movhu|movbu
        (OFF, aN), dX` (OFF 0 or absent), the next instruction is `cmp T, dX` with T the width's all-ones
        value (-1, 0xff, 0xffff) or 0, and a branch follows; the loop is a label L above x (or a `setlb`)
        with a branch back to it below x, and between them aN is stepped by S >= the load's width
        (`add S, aN`, `inc4 aN`, `inc aN`).  (S, T, the cmp, the step) or None."""
        if not x.pos or x.rw != "ld" or not x.width:
            return None
        fs = self.code_files()
        if x.pos[0] >= len(fs):
            return None
        return self.sentinel_core(fs[x.pos[0]], x.pos[1], x.width)

    def sentinel_core(self, L, i, width):
        """sentinel_loop() on the code lines L at line i (a load of `width` bytes): (S, T, cmp, step, OFF,
        the address register, the loop head's line) or None."""
        _l, ins = self._ins(L[i])
        mo = re.fullmatch(r"(mov|movhu|movbu) \((?:(0x[0-9a-f]+|\d+), )?(a\d)\), (d\d)", ins)
        di = None
        if not mo and FEATURES.get("sentinel_indexed", True):
            # (N-61c32961, lane mn10300-data3) the indexed form: `mov (dI, aT), dX` with dI a counter
            # stepped by one and scaled to the entry width right before the load (`asl2 dI` for 4 bytes,
            # `asl 1, dI` / `add dI, dI` for 2, none for 1): KN6000 func_4C11B347 / KN2400 func_4861CCC5
            # `inc d3` / `mov d3, d1` / `mov d1, d0` / `asl2 d0` / `mov (d0, a0), d0` / `cmp d2, d0` / `lne`
            mo = re.fullmatch(r"(mov|movhu|movbu) \((d\d), (a\d)\), (d\d)", ins)
            if not mo or i == 0:
                return None
            di = mo.group(2)
            prev = self._ins(L[i - 1])[1]
            scaled = {4: (f"asl2 {di}", f"asl 2, {di}"), 2: (f"asl 1, {di}", f"add {di}, {di}"), 1: ()}[width]
            if (prev not in scaled) if scaled else re.fullmatch(r"(asl2|asl \d+,|add d\d,) %s" % di, prev or ""):
                return None
        if not mo:
            return None
        foff, ar, dr = (0, mo.group(3), mo.group(4)) if di else (int(mo.group(2) or "0", 0), mo.group(3), mo.group(4))
        # (unoptimised code) the pointer lives in a stack slot: `mov (K, sp), aN` right before the load,
        # stepped as `mov (K, sp), dY` / `add S, dY` / `mov dY, (K, sp)`
        slot = None
        if i > 0 and not di:
            ms0 = re.fullmatch(r"mov \((0x[0-9a-f]+|\d+), sp\), %s" % ar, self._ins(L[i - 1])[1])
            if ms0:
                slot = int(ms0.group(1), 0)
        j, nxt = i + 1, []
        while j < len(L) and len(nxt) < 3:
            lab, t = self._ins(L[j])
            if lab and not t:
                break
            if t and not re.fullmatch(r"ext[bh]u? %s" % dr, t):
                nxt.append(t)
            j += 1
        if len(nxt) < 2:
            return None
        mc = re.fullmatch(r"cmp %s, %s" % (self.NUM, dr), nxt[0])
        if not mc:
            # the marker in a register: `mov T, dS` right before (or earlier in the function) and `cmp dS, dX`
            mr = re.fullmatch(r"cmp (d\d), %s|cmp %s, (d\d)" % (dr, dr), nxt[1] if re.match(r"mov ", nxt[0]) else nxt[0])
            if mr:
                dS = mr.group(1) or mr.group(2)
                cand = [nxt[0]] if re.match(r"mov ", nxt[0]) else []
                cand += [self._ins(L[q])[1] for q in range(i - 1, max(-1, i - (80 if di else 40)), -1)]
                for c in cand:
                    mv = re.fullmatch(r"mov %s, %s" % (self.NUM, dS), c or "")
                    if mv:
                        mc = mv
                        break
                    if c and c.split(" ")[-1] == dS and not c.startswith("cmp"):
                        break
                if mc is not None and re.match(r"mov ", nxt[0]):
                    nxt = nxt[1:]
        brx = r"b(eq|ne|lt|le|gt|ge|cs|cc|hi|ls) " + (r"|l(eq|ne|lt|le|gt|ge|cs|cc|hi|ls)$" if di else "")
        if not mc or not re.match(brx, nxt[1] if len(nxt) > 1 else ""):
            return None
        t = int(mc.group(1), 0) & ((1 << (8 * width)) - 1)
        if {"mov": 4, "movhu": 2, "movbu": 1}[mo.group(1)] != width or t not in self.SENTINELS[width]:
            return None
        # the loop head: a label or setlb above x, at most 60 lines up, inside the function
        heads = []
        for k in range(i, max(-1, i - 60), -1):
            lab, t2 = self._ins(L[k])
            if lab:
                heads.append((k, lab))
                if not re.search(r"^loc_|_L[0-9a-f]+_*$", lab):
                    break
            elif t2 == "setlb":
                heads.append((k, "#setlb"))
        for k, lab in heads:
            for e in range(i + 1, min(len(L), i + 120)):
                lab2, t3 = self._ins(L[e])
                if lab2 and not re.search(r"^loc_|_L[0-9a-f]+_*$", lab2):
                    break
                back = (lab == "#setlb" and re.fullmatch(r"l(eq|ne|lt|le|gt|ge|cs|cc|hi|ls|ra)", t3 or "")) or \
                    (lab != "#setlb" and re.fullmatch(r"(bra|jmp|b(eq|ne|lt|le|gt|ge|cs|cc|hi|ls)) %s" % re.escape(lab), t3 or ""))
                if not back:
                    continue
                step = None
                if di:
                    # (the indexed form) a counter stepped by one in the loop, the table register kept
                    for q in range(k + 1, e + 1):
                        _x, t4 = self._ins(L[q])
                        if re.fullmatch(r"(inc|inc4) %s|add [^,]*, %s|(mov|movhu|movbu) [^,]*, %s" % (ar, ar, ar), t4 or ""):
                            step = None
                            break
                        mi = re.fullmatch(r"inc (d\d)|add 1, (d\d)", t4 or "")
                        if mi and step is None:
                            step = (width, t4)
                    if step:
                        return step[0], int(mc.group(1), 0), nxt[0], step[1], 0, ar, k
                    break
                for q in range(k + 1, e):
                    _x, t4 = self._ins(L[q])
                    if slot is not None and q + 2 < e:
                        s1 = re.fullmatch(r"mov \((0x[0-9a-f]+|\d+), sp\), (d\d)", t4)
                        if s1 and int(s1.group(1), 0) == slot:
                            s2 = re.fullmatch(r"add %s, %s" % (self.NUM, s1.group(2)), self._ins(L[q + 1])[1])
                            s3 = re.fullmatch(r"mov %s, \((0x[0-9a-f]+|\d+), sp\)" % s1.group(2), self._ins(L[q + 2])[1])
                            if s2 and s3 and int(s3.group(1), 0) == slot and int(s2.group(1), 0) > 0:
                                step = (int(s2.group(1), 0), f"{t4} / {self._ins(L[q + 1])[1]} / {self._ins(L[q + 2])[1]}")
                                continue
                    if slot is not None and re.fullmatch(r"mov \((0x[0-9a-f]+|\d+), sp\), %s" % ar, t4 or ""):
                        continue
                    ms = re.fullmatch(r"add %s, %s" % (self.NUM, ar), t4)
                    if ms and int(ms.group(1), 0) > 0:
                        step = (int(ms.group(1), 0), t4)
                    elif t4 in (f"inc4 {ar}", f"inc {ar}"):
                        step = (4 if t4.startswith("inc4") else 1, t4)
                    elif re.fullmatch(r"(mov|movhu|movbu) [^,]*, %s|mov [ad]\d, %s" % (ar, ar), t4 or "") and q > i:
                        step = None      # aN reloaded in the loop: not a stepped pointer
                        break
                if step and step[0] >= width and foff + width <= step[0]:
                    return step[0], int(mc.group(1), 0), nxt[0], step[1], foff, (ar if slot is None else f"sp{slot}"), k
                break
        return None

    def sentinel_lists(self):
        """(FEATURES["sentinel_lists"], lane mn10300-data) The lists a loop walks until a record's field
        holds an end marker (sentinel_loop: KN7000 PanelButtonDispatch `mov (a2), d0` / `cmp -1, d0` /
        `add 0xc, a2`; func_484061F9 `cmp 0xff` / `add 0xd`; the u16 style lists `cmp 0xffff`): each list
        the loop's pointer starts at (a fixed address, or every target of the pointer field it was
        loaded from: field_targets) is typed as its records up to and including the marker's field
        (rows of the records' width when they divide it, else bytes), the loop cited.  A list is typed
        only when every byte of it is free and the marker is reached within 4,096 records."""
        if not FEATURES.get("sentinel_lists", True) or getattr(self, "dr", None) is None:
            return
        self._lmemo, self._tmemo = {}, {}
        lists = collections.OrderedDict()
        for x in self.dr.accesses:
            k = x.key
            if k[0] not in ("abs", "ptr"):
                continue
            r = self.sentinel_loop(x)
            if not r or (k[0] == "ptr" and x.off != r[4]):
                continue
            if k[0] == "abs":
                starts = {k[1] - r[4]} if self.in_data(k[1] - r[4]) else set()
            elif k[1][0] in ("fld", "tgt"):
                starts = set(self.field_targets(k[1]))
            else:
                continue
            if r[0] == x.width and len(starts) < 2:
                continue        # one array scanned for a marker: reader_tables types it as a table
            for a in sorted(starts):
                lists.setdefault(a, (x, r))
        # the loops the walk lost the pointer of (a label two paths reach with different tables:
        # PanelButtonDispatch's PanelButtonDescPtrTable[i] / PanelButtonDispatch_Table[i]): the pointer's
        # sources are read from the code above the loop head, `mov Table, aT` / `mov (dI, aT), aN` (each
        # entry of the pointer table typed at Table) or `mov Label, aN`
        X = collections.namedtuple("X", "func cpu insn width")
        for fi, L in enumerate(self.code_files()):
            func, fcpu = None, None
            for i, ln in enumerate(L):
                lab, ins = self._ins(ln)
                mh = re.match(r"# (\S+)\s+\((?:lib )?CPU (0x[0-9a-fA-F]+)", ln)
                if mh:
                    fcpu = int(mh.group(2), 16)
                if lab and not re.search(r"^loc_|_L[0-9a-f]+_*$|_entry$", lab):
                    func, fcpu = lab, self.code_labels.get(lab, fcpu)
                mo = re.fullmatch(r"(mov|movhu|movbu) \((?:(?:0x[0-9a-f]+|\d+), |d\d, )?a\d\), d\d", ins)
                if not mo:
                    continue
                w = {"mov": 4, "movhu": 2, "movbu": 1}[mo.group(1)]
                r = self.sentinel_core(L, i, w)
                if not r:
                    continue
                ar, head = r[5], r[6]
                starts = set()
                for k in range(head - 1, max(-1, head - 80), -1):
                    lb, t = self._ins(L[k])
                    if lb and not re.search(r"^loc_|_L[0-9a-f]+_*$|_entry$", lb):
                        break
                    if ar.startswith("sp"):
                        # (a stack slot) what was stored there: `mov rZ, (K, sp)`, rZ then the register
                        mz = re.fullmatch(r"mov ([ad]\d), \((0x[0-9a-f]+|\d+), sp\)", t)
                        if mz and int(mz.group(2), 0) == int(ar[2:]):
                            ar = mz.group(1)
                        continue
                    m1 = re.fullmatch(r"mov \((d\d), (a\d)\), %s" % ar, t)
                    m2 = re.fullmatch(r"mov ([A-Za-z_]\w*), %s" % ar, t)
                    m0 = re.fullmatch(r"mov (d\d), %s" % ar, t) if ar[0] == "a" else None
                    if m0:
                        ar = m0.group(1)       # (the cases set a data register, the join moves it: func_4C03CD2C)
                        continue
                    if m2 and self.data_label_addr(m2.group(1)) is not None:
                        starts.add(self.data_label_addr(m2.group(1)))
                    elif m1:
                        for q in range(k - 1, max(-1, k - 5), -1):
                            _b, t2 = self._ins(L[q])
                            m3 = re.fullmatch(r"mov ([A-Za-z_]\w*), %s" % m1.group(2), t2)
                            if m3:
                                ta = self.data_label_addr(m3.group(1))
                                it = self.items.get(self.off(ta)) if ta is not None else None
                                if it is not None and it.kind == "pointer table" and it.start == ta:
                                    starts |= {v for v in (self.m.u32(ta + 4 * e) for e in range(it.size // 4))
                                               if self.in_data(v)}
                                break
                    elif re.fullmatch(r"(mov|movhu|movbu) [^,]*, %s" % ar, t or ""):
                        break        # set some other way: stop
                if r[0] == w and len(starts) < 2:
                    starts = set()
                if starts:
                    x = X(func, fcpu, ins, w)
                    for a in sorted(starts):
                        lists.setdefault(a, (x, r))
        named = sorted({self.off(a) for a in self.label_at if self.in_data(a)} | {self.off(a) for a in self.refs if self.in_data(a)}
                       | {self.off(a) for a in lists if self.in_data(a)})
        import bisect
        for a, (x, (S, T, cmp_i, step_i, foff, _ar, _hd)) in sorted(lists.items()):
            w = x.width
            o = self.off(a)
            n = 0
            while n < 4096:
                q = o + n * S + foff
                if q + w > DATA_END:
                    n = None
                    break
                v = int.from_bytes(self.rom[q:q + w], "little")
                if v == T & ((1 << (8 * w)) - 1):
                    break
                n += 1
            if n is None or n == 4096:
                continue
            size = n * S + foff + w
            # the marker record's other bytes belong to the list when nothing is named inside them
            full = n * S + S
            kx = bisect.bisect_right(named, o)
            nxt = named[kx] if kx < len(named) else DATA_END
            if nxt < o + size:
                continue        # another list or a named address inside: not one list
            if not self.free(a, size) and FEATURES.get("reclaim_strings", True):
                self.reclaim_guessed_strings(a, max(size, full if nxt >= o + full and S > foff + w else size))
            if nxt >= o + full and self.free(a, full) and S > foff + w:
                size = full
            if not self.free(a, size):
                continue
            # the marker's fill up to a 4-byte boundary (0xFF or 0x00, unnamed, free) belongs to the list
            pad = 0
            while (o + size + pad) % 4 and o + size + pad < nxt and self.rom[o + size + pad] in (0, 0xFF) \
                    and self.free(a + size + pad, 1):
                pad += 1
            fn = re.sub(r"_entry$", "", x.func or "?")
            cite = f"{fn} 0x{x.cpu or 0:08X}: `{' '.join(x.insn.split())}` / `{cmp_i}`, `{step_i}`"
            lab = self.name_at(a, f"{fn}_List")
            unit = next((u for u in (4, 2) if S % u == 0 and (a % u == 0) and size % u == 0), 1)

            def render(g, it, o=o, n=n, S=S, w=w, unit=unit, cite=cite, size=size, foff=foff, pad=pad):
                d = {1: ".byte", 2: ".word", 4: ".long"}[unit]
                padl = [f"\t.byte\t" + ", ".join(f"0x{c:02x}" for c in g.rom[o + size:o + size + pad])
                        + "\t# the marker's fill to a 4-byte boundary"] if pad else []

                def word(v):
                    if unit == 4 and v and (g.in_data(v) or (g.in_code(v) and g.code_ptr_ok(v))):
                        return g.ref(v)
                    return f"0x{v:x}" if unit > 1 else str(v)
                if S == w:
                    vals = [int.from_bytes(g.rom[q:q + w], "little") for q in range(o, o + size, w)]
                    return [f"# {n} entries of {8 * w} bits up to the end marker that {cite} stops at, then the marker",
                            f"{it.label}:", f"\t{d}\t" + ", ".join(word(v) for v in vals)] + padl
                out = [f"# {n} records of {S} bytes up to the end marker (+{foff}, {8 * w} bits) that {cite} stops at"
                       + (", then the marker record" if size > n * S + foff + w else ", then the marker"), f"{it.label}:"]
                for r_ in range(n + 1):
                    lo, hi = o + r_ * S, min(o + r_ * S + S, o + size)
                    if lo >= o + size:
                        break
                    vals = [int.from_bytes(g.rom[q:q + unit], "little") for q in range(lo, hi - unit + 1, unit)]
                    tail = g.rom[lo + unit * len(vals):hi]
                    line = (f"\t{d}\t" + ", ".join(word(v) for v in vals)) if vals else ""
                    if tail:
                        line = (line + "\n" if line else "") + "\t.byte\t" + ", ".join(str(c) for c in tail)
                    out.append(line + (f"\t# end" if r_ == n else ""))
                return out + padl
            self.add(a, size + pad, lab, "sentinel list", render)

    def reclaim_guessed_strings(self, a, size):
        """(FEATURES["reclaim_strings"], lane mn10300-data2) Give back the bytes of [a, a + size) when
        every item there is a string an earlier pass took by its look alone (typed_refs: a referenced
        address whose bytes up to a NUL are printable; its label a guessed one, Str_ ...), so that a
        reader-typed list can have them: a record's head byte read as a one-character string
        (`Str_p_20` = 0x85 0x20 0x70 0x00, the first word of a PanelButtonDispatch record; opaque group
        false-string).  Returns True when the span is free afterwards."""
        o = self.off(a)
        self.build_index()
        import bisect
        i = max(0, bisect.bisect_right(self.starts, o) - 1)
        hit = []
        while i < len(self.ranges) and self.ranges[i][0] < o + size:
            s, e, _x = self.ranges[i]
            if e > o:
                it = self.items[s]
                if it.kind != "string" or not (it.label and self.GUESSED.match(it.label)) or s < o or e > o + size \
                        or it.start in self.fixed_by_code or (self.fixed.get(it.start) == it.label
                                                               and it.label in self.code_names):
                    return False
                hit.append(s)
            i += 1
        for s in hit:
            it = self.items.pop(s)
            self.claimed[s:s + it.size] = bytes(it.size)
            self.ranges = [r for r in self.ranges if r[0] != s]
            if self.label_at.get(it.start) == it.label:
                del self.label_at[it.start]
        self.reclaimed = getattr(self, "reclaimed", 0) + len(hit)
        self.build_index()
        return self.free(a, size)

    def chord_voicings(self):
        """(FEATURES["chord_voicings"], lane mn10300-data) The chord voicings and their inversions.  A
        routine checks a key below 12 (`cmp 0xb, dK`), takes chord type i's block from one pointer table
        (`mov Table, aR` / `mov (dI, aR), a1`) and copies its row `asl 3, dK` / `add dK, a1` / `mov 8, d0`
        / `call memcpy` (KN7000 func_4856DC66, KN6000 func_4C0FE8A1, KN2400 func_486F84EC); for an
        inversion n > 0 it reads the other table's list instead (`mov (dI, aR), d0`, then row base +
        8n - 7: its head byte and 7 notes, transposed by the key).  The index i is checked against the
        table's entry count (`cmp 0x15` 22, `cmp 0x26` 39).  So: a voicing block is 12 rows {u8 count;
        u8 note[7]} (one per key), an inversion list {u8 count; max(count, 1) rows {u8 head; u8
        note[7]}}.  Each is typed when its bytes are free and its rows parse (the count 1..7 and 0xFF
        past the notes; an inversion head's bits 3..5 numbering it)."""
        if not FEATURES.get("chord_voicings", True):
            return
        tabs = collections.OrderedDict()      # table address -> (kind, count, function, cpu, evidence)
        for fn, cpu, L in self.code_funcs():
            if not any(re.fullmatch(r"cmp 0xb, d\d", x) for x in L) or not any(x == "mov 8, d0" for x in L) \
                    or not any(re.match(r"call memcpy", x) for x in L):
                continue
            for i, ins in enumerate(L):
                mo = re.fullmatch(r"mov ([A-Za-z_]\w*), (a\d)", ins)
                a = self.data_label_addr(mo.group(1)) if mo else None
                if a is None:
                    continue
                for j in range(i + 1, min(i + 3, len(L))):
                    ml = re.fullmatch(r"mov \((d\d), %s\), ([ad]\d)" % mo.group(2), L[j])
                    if ml:
                        cnt = None
                        for k in range(i - 1, max(-1, i - 12), -1):
                            mc = re.fullmatch(r"cmp %s, d\d" % self.NUM, L[k])
                            if mc and k + 1 < len(L) and L[k + 1].startswith("ble "):
                                cnt = int(mc.group(1), 0) + 1
                                break
                        kind = "voicing" if ml.group(2) == "a1" else "inversion" if ml.group(2)[0] == "d" else None
                        if cnt and kind and a not in tabs:
                            tabs[a] = (kind, cnt, fn, cpu, f"`{ins}` / `{L[j]}`")
                        break
        blocks = collections.OrderedDict()
        for t, (kind, cnt, fn, cpu, ev) in tabs.items():
            for i in range(cnt):
                if not self.in_data(t + 4 * i):
                    break
                p = self.m.u32(t + 4 * i)
                if self.in_data(p):
                    blocks.setdefault(p, (kind, t, fn, cpu, ev))
        for p, (kind, t, fn, cpu, ev) in sorted(blocks.items()):
            o = self.off(p)
            if kind == "voicing":
                rows = [self.rom[o + 8 * r:o + 8 * r + 8] for r in range(12)]
                if not all(1 <= rw[0] <= 7 and all(c == 0xFF for c in rw[1 + rw[0]:]) for rw in rows):
                    continue
                size = 96
            else:
                n = self.rom[o]
                size = 1 + 8 * max(n, 1)
                if n > 7 or not (all(1 <= ((self.rom[o + 1 + 8 * k] >> 3) & 7) <= 5 for k in range(n))
                                 and (n > 0 or self.rom[o + 1] >> 3 == 0)):
                    continue
            if not self.free(p, size):
                continue
            lab = self.name_at(p, f"{fn}_{'Voicing' if kind == 'voicing' else 'Inversions'}")
            cite = (f"{fn}{(' 0x%08X' % cpu) if cpu else ''} {ev} ({self.label_at.get(t) or self.fixed.get(t) or hex(t)})")

            def render(g, it, o=o, kind=kind, size=size, cite=cite):
                if kind == "voicing":
                    out = [f"# 12 rows {{u8 count; u8 note[7]}}, one per key (row = key * 8, copied by memcpy 8): {cite}",
                           f"{it.label}:"]
                    for r_ in range(12):
                        rw = g.rom[o + 8 * r_:o + 8 * r_ + 8]
                        out.append(f"\t.byte\t{rw[0]}, " + ", ".join(str(c) if c != 0xFF else "0xff" for c in rw[1:])
                                   + f"\t# key {r_}")
                    return out
                n = g.rom[o]
                out = [f"# {n} inversions: u8 count, then max(count, 1) rows {{u8 head (bits 3..5: the inversion, 1..5);"
                       f" u8 note[7]}} (row base + 8n - 7): {cite}", f"{it.label}:", f"\t.byte\t{n}\t# count"]
                for r_ in range(max(n, 1)):
                    rw = g.rom[o + 1 + 8 * r_:o + 9 + 8 * r_]
                    out.append(f"\t.byte\t0x{rw[0]:02x}, " + ", ".join(str(c) if c != 0xFF else "0xff" for c in rw[1:])
                               + f"\t# inversion {(rw[0] >> 3) & 7}")
                return out
            self.add(p, size, lab, "chord voicing", render)

    def index_bounds(self):
        """(FEATURES["index_bounds"], lane mn10300-data) {table CPU address: (entries, stride, citation)}:
        the tables a routine indexes with an index it has bounded just before, as the code shows it:
        `and M, dI` with M = 2^k - 1, not 0xFF / 0xFFFF (M + 1 entries: KN7000 func_48466F2F's `and 0x1f, d1`, 32 hash
        slots), or `cmp N, dI` and a branch that goes on only below or at N (`ble` / `bls`: N + 1
        entries; `blt` / `bcs`: N; `bgt` / `bhi` / `bge` / `bcc` the same, as the exit), then within 8
        instructions the index scaled (`asl K`, `asl2`, `add dI, dI`: the stride) and added to the table's
        address (`add Table, dX`; `add dX, aY` or `(dX, aY)` with `mov Table, aY` within the 10
        instructions before).  The index is the record number, so the table has that many records of
        the stride (struct_arrays and reader_tables type up to it when the bytes are free)."""
        if hasattr(self, "_ixb"):
            return self._ixb
        out = {}
        if not FEATURES.get("index_bounds", True):
            self._ixb = out
            return out
        for fn, cpu, L in self.code_funcs():
            for i, ins in enumerate(L):
                if ins == "setlb":
                    # a counted hardware loop: `mov -N, dC` / setlb / ... (aR) ... step aR ... / `inc dC` / `lne`
                    # (KN6000 HpFlashWriteDefaults: 99 words) reads N records of the step from aR's table
                    mn = next((re.fullmatch(r"mov -(0x[0-9a-f]+|\d+), (d\d)", L[q]) for q in range(max(0, i - 4), i)
                               if re.fullmatch(r"mov -(0x[0-9a-f]+|\d+), (d\d)", L[q])), None)
                    if not mn:
                        continue
                    N, dC = int(mn.group(1), 0), mn.group(2)
                    tabs = {}
                    for q in range(max(0, i - 8), i):
                        mt = re.fullmatch(r"mov ([A-Za-z_]\w*), (a\d)", L[q])
                        if mt and self.data_label_addr(mt.group(1)) is not None:
                            tabs[mt.group(2)] = self.data_label_addr(mt.group(1))
                    body, e = [], None
                    for q in range(i + 1, min(len(L), i + 24)):
                        if re.fullmatch(r"l[a-z]+", L[q]):
                            e = q
                            break
                        body.append(L[q])
                    if e is None or N < 2 or not body or body[-1] != f"inc {dC}" or L[e] != "lne":
                        continue
                    for aR, ta in tabs.items():
                        ld = next((b for b in body if re.fullmatch(r"(mov|movhu|movbu) \(%s\), [ad]\d" % aR, b)), None)
                        stp = [b for b in body if b in (f"inc4 {aR}", f"inc {aR}") or re.fullmatch(r"add %s, %s" % (self.NUM, aR), b)]
                        if not ld or len(stp) != 1:
                            continue
                        S = 4 if stp[0].startswith("inc4") else 1 if stp[0].startswith("inc ") else int(stp[0].split()[1].rstrip(","), 0)
                        cite = f"{fn}{(' 0x%08X' % cpu) if cpu else ''}: `{L[i - 1] if L[i - 1].startswith('mov -') else mn.group(0)}` / setlb / `{ld}` / `{stp[0]}` / `inc {dC}` / lne ({N} passes)"
                        if ta not in out or out[ta][0] < N:
                            out[ta] = (N, S, cite)
                    continue
                cnt = None
                ma = re.fullmatch(r"and (0x[0-9a-f]+), (d\d)", ins)
                mc = re.fullmatch(r"cmp %s, (d\d)" % self.NUM, ins)
                if ma:
                    M = int(ma.group(1), 16)
                    # (0xff / 0xffff truncate a value to a byte / halfword: no table's size)
                    if M >= 3 and (M & (M + 1)) == 0 and M not in (0xFF, 0xFFFF):
                        cnt, dI = M + 1, ma.group(2)
                elif mc and i + 1 < len(L):
                    N = int(mc.group(1), 0)
                    mb = re.match(r"b(le|ls|lt|cs|gt|hi|ge|cc) ", L[i + 1])
                    if mb and 2 <= N < 65536:
                        cnt, dI = (N + 1 if mb.group(1) in ("le", "ls", "gt", "hi") else N), mc.group(2)
                if not cnt:
                    continue
                regs = {dI: 1}            # register -> the index times this
                tabs = {}                 # address register -> table address
                for q in range(max(0, i - 10), i):
                    mt = re.fullmatch(r"mov ([A-Za-z_]\w*), (a\d)", L[q])
                    if mt and self.data_label_addr(mt.group(1)) is not None:
                        tabs[mt.group(2)] = self.data_label_addr(mt.group(1))
                    mq = re.fullmatch(r"mov ([ad]\d), ([ad]\d)", L[q])
                    if mq and mq.group(1) == dI and q >= i - 3:
                        regs[mq.group(2)] = 1          # a copy made just before the compare
                    elif mq and mq.group(2) == dI and q >= i - 3:
                        regs[mq.group(1)] = 1
                hit = None
                for j in range(i + 1, min(len(L), i + 16)):
                    t = L[j]
                    if re.match(r"bra |jmp|ret|call|l[a-z]+$", t):
                        break                  # (a conditional branch skips a clamp: the scan goes on)
                    if re.match(r"b[a-z]+ ", t):
                        continue
                    mk = re.fullmatch(r"mov %s, ([ad]\d)" % self.NUM, t)
                    if mk and mk.group(2) in regs and int(mk.group(1), 0) in (0, cnt - 1):
                        continue               # the clamp: the index set to its bound or 0
                    mt = re.fullmatch(r"mov ([A-Za-z_]\w*), (a\d)", t)
                    if mt and self.data_label_addr(mt.group(1)) is not None:
                        tabs[mt.group(2)] = self.data_label_addr(mt.group(1))
                        continue
                    m1 = re.fullmatch(r"asl (\d+), (d\d)", t)
                    m2 = re.fullmatch(r"asl2 (d\d)", t)
                    m3 = re.fullmatch(r"add (d\d), \1", t)
                    m4 = re.fullmatch(r"mov ([ad]\d), ([ad]\d)", t)
                    m5 = re.fullmatch(r"add ([A-Za-z_]\w*), ([ad]\d)", t)
                    m6 = re.fullmatch(r"add ([ad]\d), (a\d)", t)
                    m7 = re.fullmatch(r"(?:mov|movhu|movbu) \(([ad]\d), (a\d)\), [ad]\d", t)
                    m8 = re.fullmatch(r"ext[bh]u? (d\d)", t)
                    if m1 and m1.group(2) in regs:
                        regs[m1.group(2)] *= 1 << int(m1.group(1))
                    elif m2 and m2.group(1) in regs:
                        regs[m2.group(1)] *= 4
                    elif m3 and m3.group(1) in regs:
                        regs[m3.group(1)] *= 2
                    elif m4 and m4.group(1) in regs:
                        regs[m4.group(2)] = regs[m4.group(1)]
                        tabs.pop(m4.group(2), None)
                    elif m4 and m4.group(1) in tabs:
                        tabs[m4.group(2)] = tabs[m4.group(1)]
                        regs.pop(m4.group(2), None)
                    elif m5 and m5.group(2) in regs and self.data_label_addr(m5.group(1)) is not None:
                        hit = (self.data_label_addr(m5.group(1)), regs[m5.group(2)], t)
                    elif m6 and m6.group(1) in regs and m6.group(2) in tabs:
                        hit = (tabs[m6.group(2)], regs[m6.group(1)], t)
                    elif m6 and m6.group(1) in tabs and m6.group(2) in regs:
                        hit = (tabs[m6.group(1)], regs[m6.group(2)], t)
                    elif m7 and m7.group(1) in regs and m7.group(2) in tabs:
                        hit = (tabs[m7.group(2)], regs[m7.group(1)], t)
                    elif m8 and m8.group(1) in regs:
                        continue
                    elif t.split(" ")[-1] in regs or (t.split(" ")[-1] in tabs and not t.startswith("cmp")):
                        regs.pop(t.split(" ")[-1], None)
                        tabs.pop(t.split(" ")[-1], None)
                    if hit:
                        break
                if hit:
                    a, st, use = hit
                    cite = f"{fn}{(' 0x%08X' % cpu) if cpu else ''}: `{ins}` ... `{use}`"
                    if a not in out or out[a][0] < cnt:
                        out[a] = (cnt, st, cite)
        self._ixb = out
        return out

    def fx_presets(self):
        """(profile `fx_presets` = (table, entries, variation table, entries), FEATURES["fx_presets"], lane
        mn10300-data; the KN2400) The DSP effect presets.  FxPresetGet 0x4863CDB5 returns
        FxPresetTable[(key & 0xFF) << 6 | (key >> 8) & 0x3F], FxPresetVarGet FxPresetVarTable[(key >> 8) &
        0x3F]; the record is 0x20 bytes: +0x00 the 16-character name, NUL-padded to 18 bytes; +0x12 u16 the
        effect descriptor's index (FxDescIndexGet `movhu (0x12, a0)`, an index into FxDescTable); +0x14 u16
        the parameter count (`movhu (0x14, a0)` after FxPresetGet / FxPresetVarGet); +0x16 u16 0; +0x18 the
        parameters' address (`mov (0x18, a0), a0`), n x u16 right before the record (0xFFFF to a 4-byte
        boundary); +0x1C the preset's own key (for every record of FxPresetTable, FxPresetTable[key] is
        the record [checked by the generator])."""
        spec = P.get("fx_presets")
        if not spec or not FEATURES.get("fx_presets", True):
            return
        tn, cnt, vn, vcnt = spec
        t, tv = self.data_label_addr(tn), self.data_label_addr(vn)
        if t is None or tv is None:
            return
        u16 = lambda a: int.from_bytes(self.rom[self.off(a):self.off(a) + 2], "little")   # noqa: E731
        recs = collections.OrderedDict()
        for base, n, var in ((t, cnt, False), (tv, vcnt, True)):
            for i in range(n):
                p = self.m.u32(base + 4 * i)
                if self.in_data(p):
                    recs.setdefault(p, var)
        desc_t = self.data_label_addr("FxDescTable")
        for p, var in sorted(recs.items()):
            o = self.off(p)
            n, par, key = u16(p + 0x14), self.m.u32(p + 0x18), self.m.u32(p + 0x1C)
            name = self.rom[o:o + 18]
            if u16(p + 0x16) != 0 or not self.in_data(par) or name[16:] != b"\0\0" or not is_text(name[:16].rstrip(b"\0")):
                continue
            plen = p - par
            if plen != ((2 * n + 3) & ~3) and not (n == 0 and plen == 4):
                continue
            if not self.free(par, plen + 0x20):
                continue
            own = (not var and self.m.u32(t + 4 * ((key & 0xFF) << 6 | (key >> 8) & 0x3F)) == p) or \
                (var and self.m.u32(tv + 4 * ((key >> 8) & 0x3F)) == p)
            nm = sanitize(name[:16].decode("latin-1").strip(), 24) or f"{p:08X}"
            lab = self.name_at(p, f"FxPreset_{nm}")
            plab = self.name_at(par, f"{lab}_Params")
            d = u16(p + 0x12)
            dref = self.ref(self.m.u32(desc_t + 4 * d)) if desc_t is not None and self.in_data(desc_t + 4 * d) else None

            def rpar(g, it, o=self.off(par), n=n, plen=plen):
                vals = [int.from_bytes(g.rom[o + 2 * k:o + 2 * k + 2], "little") for k in range(plen // 2)]
                return [f"{it.label}:\t# the parameters (u16 x {n}) of the preset after them; 0xFFFF pads to 4 bytes",
                        "\t.word\t" + ", ".join(f"0x{v:x}" if v >= 0x8000 else str(v) for v in vals)]

            def rrec(g, it, o=o, n=n, d=d, dref=dref, key=key, own=own, plab=plab, var=var):
                nm_ = g.rom[o:o + 16]
                return [f"{it.label}:\t# FX preset record (FxPresetGet{'' if not var else ' / FxPresetVarGet'}): "
                        f"name, descriptor index, parameter count, parameters, key",
                        f'\t.ascii\t"{c_escape(nm_)}"', "\t.byte\t0, 0",
                        f"\t.word\t{d}, {n}, 0\t# descriptor index" + (f" ({dref}, FxDescTable[{d}])" if dref else "")
                        + "; parameter count",
                        f"\t.long\t{plab}", f"\t.long\t0x{key:x}\t# key" + (" (FxPreset" + ("Var" if var else "")
                                                                          + "Table[key] is this record)" if own else "")]
            self.add(par, plen, plab, "fx preset params", rpar)
            self.add(p, 0x20, lab, "fx preset", rrec)

    def table_terminators(self):
        """(FEATURES["table_terminators"], lane mn10300-data) The end marker after a typed table: the
        all-ones word of the table's width right after it, still free, where a reader of the table compares
        the entry it loads with -1 (`cmp -1, dX`, or `cmp dS, dX` with `mov -1, dS` earlier in the function)
        and goes on otherwise (KN7000 PartHasDspUnit: `mov (d0, a2), d0` / `cmp d3, d0` / `bne`, d3 = -1).
        The loop stops at it, so it is the table's last entry (an item of its own after the table)."""
        if not FEATURES.get("table_terminators", True) or getattr(self, "dr", None) is None:
            return
        fs = self.code_files()
        by_tab = collections.defaultdict(list)
        for x in self.dr.accesses:
            if x.key[0] == "rec" and x.rw == "ld" and x.width and x.pos and x.key[2] == x.width:
                by_tab[x.key[1]].append(x)
        for o, it in sorted(self.items.items()):
            if it.kind not in ("reader table", "pointer table", "struct array") or it.start not in by_tab:
                continue
            xs = by_tab[it.start]
            w = xs[0].width
            e = it.start + it.size
            eo = self.off(e)
            if it.size % w or eo + w > DATA_END or self.rom[eo:eo + w] != b"\xff" * w or not self.free(e, w):
                continue
            hit = None
            for x in xs:
                L, i = fs[x.pos[0]], x.pos[1]
                _l, ins = self._ins(L[i])
                md = re.search(r", (d\d)$", ins)
                if not md:
                    continue
                dX = md.group(1)
                for j in range(i + 1, min(len(L), i + 3)):
                    _l2, t = self._ins(L[j])
                    mc = re.fullmatch(r"cmp (-1|0xff|0xffff|0xffffffff|d\d), %s" % dX, t)
                    if not mc:
                        continue
                    ok = not mc.group(1).startswith("d")
                    if not ok:
                        for q in range(i - 1, max(-1, i - 40), -1):
                            _l3, t3 = self._ins(L[q])
                            if t3 == f"mov -1, {mc.group(1)}":
                                ok = True
                                break
                    if ok and j + 1 < len(L) and re.match(r"b(ne|eq) ", self._ins(L[j + 1])[1]):
                        hit = (x, t)
                    break
                if hit:
                    break
            if not hit:
                continue
            x, t = hit
            cite = f"{re.sub(r'_entry$', '', x.func or '?')} 0x{x.cpu or 0:08X}: `{' '.join(x.insn.split())}` / `{t}`"
            d = {1: ".byte", 2: ".word", 4: ".long"}[w]

            def render(g, it2, w=w, d=d, cite=cite, tab=it.label):
                return [f"{it2.label}:\t{d}\t0x{(1 << 8 * w) - 1:x}\t# the end marker of {tab}: {cite} stops at it"]
            self.add(e, w, self.name_at(e, f"{it.label}_End"), "table end", render)

    def host_code_bodies(self):
        """(a plug-in, lane mn10300-data3) code_bodies() of the host firmware's converted code: the class
        procedures of the host's classes, which the plug-in's widgets are instances of, are there."""
        if hasattr(self, "_hbodies"):
            return self._hbodies
        import glob as _glob
        import data_readers as DR
        self._hbodies = body = {}
        hp = PROFILES.get(P.get("host") or "", {})
        if not hp or not FEATURES.get("host_widget_vars", True):
            return body
        root = os.path.normpath(os.path.join(KN7_DIR, hp.get("root", ".")))
        cur = None
        for f in sorted(_glob.glob(os.path.join(root, hp.get("code", hp["src"] + "/*.s")))):
            for ln in open(f, encoding="latin-1"):
                code = ln.split("#", 1)[0].rstrip()
                if not code.strip():
                    continue
                mo = re.match(r"^([A-Za-z_][\w.$]*):", code)
                if mo:
                    n = mo.group(1)
                    if not DR.LOCAL.search(n):
                        cur = n
                        body.setdefault(cur, (self.host.sym_by_name.get(n), []))
                    rest = code[mo.end():].strip()
                    if rest and cur:
                        body[cur][1].append(" ".join(rest.split()))
                    continue
                if cur and code[:1] in " \t":
                    body[cur][1].append(" ".join(code.split()))
        return body

    def field_deref(self, proc, off, bodies=None):
        """(widget_vars) How `proc` reads the variable a widget's field at +off points at: the field load
        (`mov (off, aR), aS`, or `add off, aR` then `mov (aR), aS`) and, within the next 8 instructions,
        a load or store through aS: (CPU, field instruction, access instruction, width), or None."""
        b = (bodies if bodies is not None else self.code_bodies()).get(proc)
        if not b:
            return None
        L = b[1]
        num = r"(0x[0-9a-f]+|\d+)"
        for i, ins in enumerate(L):
            m1 = re.fullmatch(r"mov \(%s, (a\d)\), (a\d)" % num, ins)
            m2 = re.fullmatch(r"add %s, (a\d)" % num, ins)
            tgt, at = None, i
            if m1 and int(m1.group(1), 0) == off:
                tgt = m1.group(3)
            elif m2 and int(m2.group(1), 0) == off:
                for j in range(i + 1, min(i + 3, len(L))):
                    mm = re.fullmatch(r"mov \(%s\), (a\d)" % m2.group(2), L[j])
                    if mm:
                        tgt, at = mm.group(1), j
                        break
            if not tgt:
                continue
            for j in range(at + 1, min(at + 8, len(L))):
                mm = re.fullmatch(r"(mov|movhu|movbu) (?:\((?:0, )?%s\), [ad]\d|[ad]\d, \((?:0, )?%s\))" % (tgt, tgt), L[j])
                if mm:
                    return (b[0], ins if at == i else ins + " / " + L[at], L[j], {"mov": 4, "movhu": 2, "movbu": 1}[mm.group(1)])
                if re.search(r"\b%s\b" % tgt, L[j].split(" ", 1)[-1].split(",")[-1]) and not L[j].startswith(("cmp", "btst")):
                    break           # aS overwritten
        return None

    def widget_vars(self):
        """(FEATURES["widget_vars"], lane mn10300-data) The RAM state variables the widget records point at
        (their `l` / `m` / `q` / `r` fields: `<object>_<field>`, gui_objects) that no other pass typed:
        a variable of the width the class's procedure reads it at.  Evidence per (class, field): a
        procedure of the class chain (the class's own first, then its ancestors') loads the field from
        the instance and loads or stores through it (field_deref); the variable is typed only when that
        width fits the bytes up to the next label.  The value is the variable's initial value (these
        records and their variables are in the initialised-RAM image)."""
        if not FEATURES.get("widget_vars", True):
            return
        m = self.m
        by_addr = {}
        for a, n in self.code_labels.items():
            by_addr.setdefault(a, n)
        memo = {}

        def reader(k, off):
            key = (k.id, off)
            if key not in memo:
                memo[key] = None
                for c in reversed(m.chain(k.id)):
                    pn = by_addr.get(c.proc) or self.extern.get(c.proc)
                    r = self.field_deref(pn, off) if pn else None
                    if not r and self.host is not None:
                        # (a plug-in, lane mn10300-data3) a host class: its procedure is the host's code
                        hn = self.host.sym_by_addr.get(c.proc)
                        r = self.field_deref(hn, off, self.host_code_bodies()) if hn else None
                        pn = f"the host's {hn}" if r else pn
                    if r:
                        memo[key] = (c.name, pn) + r
                        break
            return memo[key]
        import bisect
        named = sorted({self.off(a) for a in self.label_at if self.in_data(a)}
                       | {self.off(a) for a in self.refs if self.in_data(a)})
        done = set()
        for slot, b in sorted(m.blocks.items()):
            for i, o in enumerate(b["objects"]):
                for f in m.layout[o.klass.id]:
                    v = o.fvalues[f.off]
                    if f.sig not in "lmqr" or not v or not self.in_data(v) or v in done:
                        continue
                    r = reader(o.klass, f.off)
                    if not r:
                        continue
                    w = r[5]
                    oo = self.off(v)
                    k = bisect.bisect_right(named, oo)
                    end = named[k] if k < len(named) else DATA_END
                    if oo % w or end - oo < w or not self.free(v, w):
                        continue
                    done.add(v)
                    signed = False
                    val = int.from_bytes(self.rom[oo:oo + w], "little")
                    lab = self.name_at(v, f"{self.obj_label[(slot, i)]}_{sanitize(f.name)}")
                    cite = (f"the {o.klass.name} {self.obj_label[(slot, i)]}'s `{f.name}` (+0x{f.off:X}), loaded and"
                            f" dereferenced by {r[1]}{(' 0x%08X' % r[2]) if r[2] else ''}: `{r[3]}` -> `{r[4]}`")
                    kind = ("s" if signed else "u") + str(8 * w)

                    def render(g, it, w=w, val=val, kind=kind, cite=cite):
                        return [f"{it.label}:\t# {kind}, initial value of a RAM variable: {cite}",
                                f"\t{ {1: '.byte', 2: '.word', 4: '.long'}[w]}\t"
                                f"{val if w < 4 or val < 0x10000 else hex(val)}"]
                    self.add(v, w, lab, "widget variable", render)

    def render_variable(self, it, vals, kind, rd, w, ram):
        if len(vals) > 1:
            return self.render_table(it, vals, kind, rd, w)
        what = "initial value of a RAM variable" if ram else "a constant"
        cite = "; ".join(f"{f or '?'} {('0x%08X' % c) if c else ''}: `{ins}`".replace("  ", " ") for f, c, ins in rd[:2]) \
            + (" ..." if len(rd) > 2 else "")
        return [f"{it.label}:\t# {kind}, {what}; read / written by {cite}",
                f"\t{ {1: '.byte', 2: '.word', 4: '.long'}[w]}\t{vals[0] if w < 4 or vals[0] < 0x10000 else hex(vals[0])}"]

    def dsp_pool(self):
        """(`structs` profiles) The effects-DSP download records (src/include/dsp_records.inc,
        tools/gen_dsp_records.py): a chain of >= 10 records of 0x2004 blocks.  Each record is
        typed block by block, its PM words with the SHARC instruction the committed listing
        disassembly/dsp/recNN_*.asm gives the same word, its name and role from dsp/records.tsv
        (build 941's records; another build's record takes the name of a 941 record with the
        same bytes)."""
        import glob as _glob
        import hashlib

        def hdr(rom, o):
            return o + 12 <= len(rom) and rom[o] == 0x20 and rom[o + 1] == 0x04 and rom[o + 2] in (0, 0x80) \
                and rom[o + 3] in (0, 0xFF) and rom[o + 4:o + 6] == b"\0\0" and rom[o + 8:o + 10] == b"\0\0"

        def chain(rom, o, end):
            recs = []
            while o < end and hdr(rom, o):
                st, blocks = o, []
                while hdr(rom, o):
                    ln = rom[o + 10] << 8 | rom[o + 11]
                    blocks.append((o, rom[o + 2], rom[o + 3], rom[o + 6] << 8 | rom[o + 7], ln))
                    o += 12 + ln
                z = o
                while o < end and o - z <= 16 and rom[o] == 0 and not hdr(rom, o):
                    o += 1
                recs.append((st, z, o, blocks))
            return recs

        def find(rom, lo, hi):
            for mo in re.finditer(rb"\x20\x04[\x00\x80][\x00\xff]\x00\x00", rom[lo:hi]):
                r = chain(rom, lo + mo.start(), hi)
                if len(r) >= 10:
                    return r
            return []
        recs = find(self.rom, R1_END, DATA_END)
        if not recs:
            return
        # build 941's names and the listings' instruction text
        # (kn7000/'s files, whichever profile runs: a sibling's record takes the name of the 941 record
        # with the same bytes)
        ref941 = os.path.join(KN7_DIR, PROFILES["941"]["rom"])
        if not os.path.exists(ref941):
            sys.exit(f"gen_data_s: {ref941} missing (the DSP records' names): `make -C kn7000 baserom` first")
        ref = open(ref941, "rb").read()
        names = {}
        tsv = os.path.join(KN7_DIR, "dsp", "records.tsv")
        meta = {}
        if os.path.exists(tsv):
            for line in open(tsv, encoding="utf-8"):
                f = line.rstrip("\n").split("\t")
                if len(f) >= 7 and not line.startswith("#"):
                    meta[int(f[1], 16)] = (int(f[0]), f[5], f[6])
        for st, z, _e, _b in find(ref, PROFILES["941"]["r1"], PROFILES["941"]["end"]):
            if st in meta:
                names[hashlib.sha1(ref[st:z]).hexdigest()] = meta[st]
        insn = {}
        for f in _glob.glob(os.path.join(KN7_DIR, "disasm", "dsp", "rec*.asm")):
            for line in open(f, encoding="utf-8"):
                mo = re.match(r"^[0-9a-f]{4}: ([0-9a-f]{16}) (.*)$", line)
                if mo:
                    insn.setdefault(int(mo.group(1), 16), mo.group(2).strip())
        rom = self.rom
        for st, z, e, blocks in recs:
            a = self.addr_of(st)
            if not self.free(a, e - st):
                continue
            idx, role, name = names.get(hashlib.sha1(rom[st:z]).hexdigest(), (None, None, None))
            base = f"DspRecord{idx:02d}_{sanitize(name or role, 32)}" if idx is not None else f"DspRecord_{a:08X}"
            nm = self.label_at.get(a) or self.fixed.get(a)
            lab = self.rename_at(a, base) if nm is None or (a in self.fixed_by_code and self.GUESSED.match(nm)) \
                else self.name_at(a, nm)

            def render(g, it, st=st, z=z, e=e, blocks=blocks, idx=idx, role=role, name=name):
                out = [f"{it.label}:\t# effects-DSP download record" + (f" {idx:02d} [{role}]: {name}"
                                                                         f" (dsp/records.tsv, disasm/dsp/rec{idx:02d}_*.asm)"
                                                                         if idx is not None else "")]
                for o, mode, flag, tgt, ln in blocks:
                    pm = bool(mode & 0x80)
                    out.append(f"\tDSP_BLOCK\t{'DSP_PM' if pm else 'DSP_DM'}, 0x{flag:02X}, 0x{tgt:04X}, {ln}"
                               f"\t# {ln // (6 if pm else 5)} {'instruction' if pm else 'data'} words"
                               f" at {'PM' if pm else 'DM'} 0x{tgt:04X}")
                    p, w = o + 12, (6 if pm else 5)
                    for k in range(ln // w):
                        v = int.from_bytes(rom[p + w * k:p + w * k + w], "big")
                        if pm:
                            t = insn.get(v)
                            out.append(f"\tpm48\t0x{v:012X}" + (f"\t# {t}" if t else ""))
                        else:
                            out.append(f"\tdm40\t0x{v:010X}")
                    if ln % w:
                        out.append("\t.byte\t" + ", ".join(str(b) for b in rom[p + ln - ln % w:p + ln]))
                if e > z:
                    out.append(f"\t.space\t{e - z}\t# the record's zero terminator")
                return out
            self.add(a, e - st, lab, "dsp record", render)

    def render_structs(self, it, g):
        import data_structs as DS
        o = self.off(it.start)
        rd = DS.cite([x for _o, x in g.accs], 3)
        out = [f"{it.label}:\t# {g.count} x {g.macro} ({g.stride} bytes each); read by {rd}"]
        for k in range(g.count):
            out.append(DS.record_line(self, g, self.rom, o + k * g.stride)
                       + (f"\t# [{k}]" if k % 8 == 0 and g.count > 8 else ""))
        return out

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

    def pads(self):
        """TechnicsPadsResource (a manual-symbol name): the program's own built-in "Technics
        Pads" PERFORMANCE PAD bank, the table flash's segment 4 format (tools/gen_table_styles.py
        technics_pads(), the same lines here).  KN6000: TechnicsPadsResourceInit stores it to
        TechnicsPadsResourceInit_Var and calls TechnicsPadsResourceParse when the table flash's
        resource does not check, as with the Technics Rhythms resource."""
        import gen_table_styles as GTS
        # (lane mn10300-rest) the KN7000 program builds name the table flash's copy TechnicsPadsResource and
        # their own fallback copy TechnicsPadsResourceBuiltin (941 0x4872FE4C: TechnicsPadsResourceInit stores
        # it, `mov Str_Technics_Pads, a0` / `mov a0, (TechnicsPadsResourceInit_Var)`, when the table flash's
        # copy does not check, then TechnicsPadsResourceParse 0x48433F4A)
        nm = "TechnicsPadsResource"
        a = self.m.sym_by_name.get(nm)
        if a is None or not self.in_data(a):
            nm = "TechnicsPadsResourceBuiltin"
            a = self.m.sym_by_name.get(nm)
        if a is None or not self.in_data(a) or (nm.endswith("Builtin") and not FEATURES.get("builtin_pads", True)):
            return
        rom, s = self.rom, a - BASE
        try:
            o_tab, cnt = GTS.u24be(rom, s + 0x1E), GTS.u16be(rom, s + GTS.u24be(rom, s + 0x18) + 2)
            last = s + GTS.u24be(rom, s + o_tab + 3 * (cnt - 1))
            end = last + 0x37 + GTS.u24be(rom, last + 0x34)
            lines = GTS.technics_pads(rom, s, end, nm, None, None, inline=True)
        except (SystemExit, ValueError, IndexError) as e:
            print(f"gen_data_s: TechnicsPadsResource not typed: {e}")
            return
        # the table generator's comments name KN7000 program 941's addresses: say what they are here
        fix = [(r"# strncmp with the firmware's 0x485B6B68", "# strncmp with Str_Technics_Pads_2 (TechnicsPadsResourceParse)"),
               (r"\t# -> 0x50034C2[CF0]", ""), (r"# the pad count -> 0x50034C24; the index's limit", "# the pad count; the index's limit"),
               (r"\(func_48434591\)", "(the KN7000's func_48434591; [INFERENCE] the same fold here)")]
        for pat, rep in fix:
            lines = [re.sub(pat, rep, ln) for ln in lines]
        if not self.free(a, end - s):
            print("gen_data_s: TechnicsPadsResource overlaps a typed item; not typed")
            return
        if not self.rhythm_macros:
            import program_rhythm
            self.rhythm_macros = program_rhythm.macro_block()
        # the pad and event macros of src/table/style_macros.inc the pads use (its ev_* event
        # macros, not IC18's: tools/gen_table_styles.py event_lines), each with the comment above it
        have = {ln.split()[1] for ln in self.rhythm_macros if ln.startswith(".macro ")}
        sm = open(os.path.join(KN7_DIR, "src", "table", "style_macros.inc")).read().split("\n")
        want = {"pad_head", "pad_events", "ev_cc", "ev_pc", "ev_note", "ev_press", "ev_bend", "ev_sysex",
                "ev_at", "ev_beat", "ev_end"}
        extra, k = [], 0
        while k < len(sm):
            if sm[k].startswith(".macro ") and sm[k].split()[1] in want - have:
                c = k
                while c > 0 and sm[c - 1].startswith("#"):
                    c -= 1
                e = next(j for j in range(k, len(sm)) if sm[j].strip() == ".endm")
                extra += sm[c:e + 1]
                k = e
            k += 1
        self.rhythm_macros = self.rhythm_macros + ["", "# (from src/table/style_macros.inc: the built-in pads' macros)"] + extra
        self.label_at[a] = nm
        self.add(a, end - s, nm, "pads resource",
                 lambda g, it, lines=lines, cnt=cnt: [f"{it.label}:\t# the built-in \"Technics Pads\" bank, {cnt} pads"
                                                      " (the table flash's segment 4 format)"] + lines)
        print(f"gen_data_s: Technics Pads, {cnt} pads")

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
          tone        0x54-byte head (16-character name, SOUND_NAME_HEAD) + n x 0x7A units
                      (SOUND_MOD), n = 1..4
          TABLE tone  class 0x40 at +0x10: the 16-character name, a 0x17-byte head and
                      128 three-byte note entries (TgNoteOnTableTone reads +0x27 + note x 3)
          voice       a 13-character name and three bytes (VOICE_HEAD), then one or
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
                    out = [f"{it.label}:\t# tone record, {k} unit(s)",
                           f'\tSOUND_NAME_HEAD\t"{c_escape(raw[:16])}", {hx(raw[0x10:0x54])}']
                    out += [f"\tSOUND_MOD\t{hx(raw[0x54 + 0x7A * j:0x54 + 0x7A * (j + 1)])}" for j in range(k)]
                elif kind == "table":
                    out = [f"{it.label}:\t# TABLE tone record: one entry per note (TgNoteOnTableTone)",
                           f'\t.ascii\t"{c_escape(raw[:16])}"', f"\ttone_head_table\t{hx(raw[0x10:0x27])}"]
                    out += [f"\ttone_note\t{hx(raw[0x27 + 3 * j:0x2A + 3 * j])}\t# note {j}" for j in range(128)]
                else:
                    out = [f"{it.label}:\t# voice record, {k} sub-record(s)",
                           f'\tVOICE_HEAD\t"{c_escape(raw[:13])}", {hx(raw[13:16])}']
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
                # (a local label: _L<hex> in the siblings' code, loc_<ADDR> in the KN7000's)
                if mo and not re.search(r"_L[0-9a-f]+_*$|_entry$", mo.group(1)) \
                        and not (P.get("structs") and mo.group(1).startswith("loc_")):
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
                        if r.get("data") and r.get("w") and r.get("h") and "bits" not in r and P.get("bitmap_bits"):
                            r["bits"], r["bits_default"] = P["bitmap_bits"], True
                        if r.get("data") and r.get("w") and r.get("h") and r.get("bits") in (1, 2, 4, 8):
                            found.append((func, r))
                    func, body = mo.group(1), []
                body.append(line)
                if P.get("structs") and re.match(r"\s+(retf|ret|rets)\b", line):
                    mo = None
                    if func and len(body) < 400:
                        txt = "\n".join(body)
                        r = {}
                        # (both compilers' forms, as above: a `ret` in the plug-in's procedure
                        # must not lose its `cmp / bne / bra` answers)
                        pairs = re.findall(r"cmp\s+(\S+), d1\n\s+beq\s+(\w+)", txt) + re.findall(
                            r"cmp\s+(\S+), d[01]\n\s+bne\s+\w+\n\s+bra\s+(\w+)", txt)
                        for c, lab in pairs:
                            k = meth.get(val(c))
                            m2 = re.search(rf"^{lab}:\n\s+(?:mov\s+(\S+), d0|clr\s+d0)\n", txt, re.M)
                            if k and m2:
                                r[k] = val(m2.group(1)) if m2.group(1) else 0
                        if r.get("data") and r.get("w") and r.get("h") and "bits" not in r and P.get("bitmap_bits"):
                            r["bits"], r["bits_default"] = P["bitmap_bits"], True
                        if r.get("data") and r.get("w") and r.get("h") and r.get("bits") in (1, 2, 4, 8) \
                                and all(r.get("data") != f2[1].get("data") for f2 in found):
                            found.append((func, r))
                    body = []
        pal_of = {}
        for func, r in found:
            a, w, h, depth = r["data"], r["w"], r["h"], r["bits"]
            n = TP.pk_stride(depth, w) * h
            if not self.in_data(a) or not self.free(a, n):
                print(f"gen_data_s: bitmap of {func} at {a:#x} ({n} bytes) not free; not typed")
                continue
            if r.get("bits_default") and self.free(a + n, 1) and self.in_data(a + n) \
                    and (a + n) not in set(self.prev_data_label.values()) | set(self.label_at):
                # no MT_GetBitCount answer: the depth the drawer uses then (profile `bitmap_bits`).
                # Not an inference (N-c62a74fa, kn7000/notes/data-rest/README.md): VwUserBitmapProc
                # 0x48418625, the only code that asks MT_GetBitCount, draws any answer but 1 and 8 with
                # DrawBitmapSPFast16 (4 bpp), and a bitmap proc answers 0 to a message it has no case
                # for.  This test only guards the size: the pixels must end exactly where the next item
                # or label is
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
                     lambda g, it, fn=fn, fmt=fmt, func=func, w=w, h=h, depth=depth,
                            bits_default=bool(r.get("bits_default")): [
                         f"{it.label}:\t# {w} x {h}, {depth} bit(s) a pixel"
                         + (" (no MT_GetBitCount answer: VwUserBitmapProc draws it with DrawBitmapSPFast16)"
                            if bits_default else "") +
                         f", rows padded to even bytes: the bitmap"
                         f" {func} answers MT_GetBitmapData with ({OUTDIR}/media/{fn})",
                         f'\t.incbin\t"{P.get("bitmap_dir", "build/bitmaps")}/{os.path.splitext(fn)[0]}.bin"\t# census: generated -- '
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
                if P.get("header_funcs") and n and any(self.addr_of(o + 8 * n + k) in self.fixed for k in range(0, 8, 4)):
                    break       # (the plug-in) a curated name inside: not one table across it
                p = m.u32(self.addr_of(o + 8 * n))
                s = m.cstr(p) if p and self.in_data(p) else None
                if not s or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]{1,40}", s):
                    break
                v = m.u32(self.addr_of(o + 8 * n) + 4)
                if FEATURES.get("nv_not_ptrs", True) and v and self.in_data(v) and m.cstr(v) \
                        and re.fullmatch(r"[A-Za-z_][A-Za-z0-9_ ]{1,40}", m.cstr(v)):
                    # (lane mn10300-data2) the "value" is a name too: a pointer table of names read two words
                    # at a time (941 0x5000190C: "PT10", "PT11" ... after func_4848F914_Table's "PT 1".."PT 9")
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
        # (lane mn10300-data2) the KN6000 / KN6500 record is 0x700 bytes, 42 records (no part 0x1F):
        # its CUSTOM banks' records are 0x700 bytes apart (kn7000/notes/custom-data-ic21.md), and the
        # default one is copied record by record to the record at 0x84000020 (copies_into below)
        shapes = ((0x750, 43), (0x700, 42)) if FEATURES.get("panel_700", True) else ((0x750, 43),)
        loops = self.memcpy_loops() if FEATURES.get("panel_700", True) else {}
        while o < DATA_END - 0x700:
            if rom[o] == 0x40 and rom[o + 1] == 18 and not self.claimed[o]:
                recs, e = kn_panel.block(rom, o)
                if recs and (e - o, len(recs)) in shapes and self.free(self.addr_of(o), e - o):
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
                    cps = sorted({(fn, cpu, s, ln) for (base, fn, cpu, s, ln) in loops.get("all", [])
                                  if a <= base < self.addr_of(e)})
                    cite = ([f"# its records' payloads are copied by memcpy loops (record + 2, the length, the"
                             f" step): " + "; ".join(f"{fn} 0x{cpu or 0:08X} ({ln:#x} bytes, step {s:#x})"
                                                       for fn, cpu, s, ln in cps[:6])] if cps else [])
                    self.add(a, e - o, self.name_at(a, "PanelMemory_" + (sanitize(nm) or f"{a:08X}")), "panel memory",
                             lambda g, it, lines=lines, cite=cite: [f"{it.label}:"] + cite + lines)
                    o = e
                    continue
            o += 1

    def memcpy_loops(self):
        """{"all": [(table address, function, CPU, step, length)]}: the loops that copy one record at
        a time out of a table, `mov Table, dB` / `add dI, dB` / `mov K, aS` / `add dB, aS` / `mov L,
        d0` / `call memcpy` ... `add S, dI` / `cmp N, dI` / `blt` (KN6000 func_4C02FB29: the default
        panel memory's records, record + 2, 0x48 or 4 bytes, step 0x4A or 6)."""
        out = []
        for fn, cpu, L in self.code_funcs():
            for i, ins in enumerate(L):
                if not re.match(r"call memcpy(_entry)?\b", ins):
                    continue
                base = ln = step = None
                for x in L[max(0, i - 8):i]:
                    mo = re.fullmatch(r"mov ([A-Za-z_]\w*), d\d", x)
                    if mo and self.data_label_addr(mo.group(1)) is not None:
                        base = self.data_label_addr(mo.group(1))
                    mo = re.fullmatch(r"mov (0x[0-9a-f]+|\d+), d0", x)
                    if mo:
                        ln = int(mo.group(1), 0)
                for x in L[i + 1:i + 3]:
                    mo = re.fullmatch(r"add (0x[0-9a-f]+|\d+), d\d", x)
                    if mo:
                        step = int(mo.group(1), 0)
                if base is not None and ln and step:
                    out.append((base, re.sub(r"_entry(_L[0-9a-f]+)?$", "", fn), cpu, step, ln))
        return {"all": out}

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

    def sysex_strings(self):
        """(KN7000 program builds) MIDI system-exclusive messages a typed pointer points at:
        0xF0, data bytes below 0x80, 0xF7 (the MIDI framing; 0x50 after 0xF0 is Matsushita's
        manufacturer id), as one `.byte` row each.  They are the templates the switch records
        of func_484C01F1 (and others) point at with their +8 / +12 fields [INFERENCE: what sends
        them was not traced; the framing and the pointers are the evidence]."""
        self.build_index()
        n = 0
        for a in sorted(self.refs):
            if not self.in_data(a):
                continue
            o = self.off(a)
            if self.rom[o] != 0xF0 or self.claimed[o]:
                continue
            e = o + 1
            while e < DATA_END and e - o < 128 and self.rom[e] < 0x80 and not self.claimed[e]:
                e += 1
            if e >= DATA_END or self.rom[e] != 0xF7 or self.claimed[e] or e - o < 2:
                continue
            bs = self.rom[o:e + 1]
            man = " (Matsushita)" if bs[1] == 0x50 else ""
            self.add(a, len(bs), self.name_at(a, f"SysEx_{a:08X}"), "sysex",
                     lambda g, it, bs=bs, man=man: [f"{it.label}:\t.byte\t" + ", ".join(f"0x{c:02X}" for c in bs)
                                                    + f"\t# MIDI SysEx{man}"])
            n += 1
        print(f"gen_data_s: {n} SysEx messages")

    def copied_blocks(self):
        """(KN7000 program builds) a data address the code passes to memcpy / memcmp / strncmp /
        strncpy with a constant length: a block of that many bytes, as u8 rows whose header names
        the copy (tools/data_readers.py: the call's a0 / a1 and its d0)."""
        self.build_index()
        found = collections.defaultdict(set)
        for acc in self.dr.accesses:
            if not acc.rw.startswith("arg a") or not acc.extra:
                continue
            fn, c = acc.extra[0], acc.extra[1]
            if fn not in ("memcpy", "memcmp", "strncmp", "strncpy", "memmove") or not c.get("d0"):
                continue
            k = acc.key
            # (deep_records, lane mn10300-typer) also through a pointer field of a typed record: the
            # KN2400's switch descriptors, whose p8 block func_5016594F copies 12 bytes of
            ts = {k[1]} if k[0] == "abs" else set(self.field_targets(k[1])) if k[0] == "ptr" and \
                (k[1][0] == "tgt" or (self.deep_records and k[1][0] == "fld")) and acc.off == 0 else set()
            for t in ts:
                found[t].add((c["d0"], fn, re.sub(r"_entry$", "", acc.func or "?"), acc.cpu or 0))
        n = 0
        for a in sorted(found):
            uses = sorted(found[a], key=lambda u: (u[3], u[2], u[1], u[0]))   # (a full key: a set's order varies)
            size = min(u[0] for u in uses)
            if not 0 < size <= 4096 or not self.in_data(a) or not self.free(a, size):
                continue
            o = self.off(a)
            vals = list(self.rom[o:o + size])
            cite = "; ".join(f"{u[2]} 0x{u[3]:08X}: {u[1]}(.., {u[0]})" for u in uses[:3])
            self.add(a, size, self.name_at(a, f"{uses[0][2]}_Block"), "copied block",
                     lambda g, it, vals=vals, cite=cite: [f"{it.label}:\t# {len(vals)} bytes, copied whole by {cite}"]
                     + [f"\ttab_u8\t" + ", ".join(str(v) for v in vals[i:i + 16]) + f"\t# [{i}]"
                        for i in range(0, len(vals), 16)])
            n += 1
        print(f"gen_data_s: {n} copied blocks")

    def pointer_runs(self):
        """(KN7000 program builds) aligned runs of >= 3 words no item holds, each 0 or an address of
        this data region (at least two of them not 0): pointer arrays, written `.long Label`.  What
        they point at is labelled (and typed by the passes after this one where it parses: text,
        SysEx).  [INFERENCE: typed by value; the run's reader was not traced: an array the code
        reaches from a pointer it computes, e.g. a record's tail past the fields it reads]."""
        self.build_index()
        m, n, o = self.m, 0, R1_END + (-R1_END % 4)
        while o + 12 <= DATA_END:
            e, nz = o, 0
            while e + 4 <= DATA_END and not any(self.claimed[e:e + 4]):
                v = int.from_bytes(self.rom[e:e + 4], "little")
                if v and not self.in_data(v):
                    break
                nz += 1 if v else 0
                e += 4
            if e - o >= 12 and nz >= 2:
                vals = [int.from_bytes(self.rom[k:k + 4], "little") for k in range(o, e, 4)]
                while vals and vals[-1] == 0 and len(vals) > 3:
                    vals.pop()           # trailing zeros: fill, or the next item's first word
                e = o + 4 * len(vals)
                for v in vals:
                    if v:
                        self.refs.add(v)
                a = self.addr_of(o)
                self.add(a, e - o, self.name_at(a, f"ptrs_{a:08X}"), "pointer run",
                         lambda g, it, vals=vals: [f"{it.label}:\t# {len(vals)} pointers, typed by value"
                                                   " (every word 0 or an address of this region); reader not traced"]
                         + [f"\t.long\t{g.ref(v)}" for v in vals])
                n += 1
                o = e
            else:
                o = max(e, o + 4) if e > o else o + 4
        print(f"gen_data_s: {n} pointer runs")
        # what they point at: text first (the passes after this one take what is left)
        for a in sorted(self.refs):
            if self.in_data(a) and self.free(a, 1):
                o = self.off(a)
                z = self.rom.find(b"\0", o, min(DATA_END, o + 256))
                if z > o + 1 and is_text(self.rom[o:z]) and self.free(a, z - o + 1) and not self.pointerish(o, z):
                    self.str_item(a, "Str_" + (sanitize(self.rom[o:z].decode("latin-1"), 40) or "text"), "text")

    def residue(self):
        """(profiles with `residue`: the SP7001 plug-in) the bytes no other pass typed, piece by
        piece: an aligned word that is an address (of this image, its code, its RAM image or a
        name outside) as `.long` by name; a NUL-terminated text as `.asciz` (an empty one when
        something points at its NUL); in the initialised-RAM image an aligned word as `.long`, the
        initial value of the variable a widget field or the code names [INFERENCE: read as a
        32-bit word, as the field that points at it is a 32-bit `str_adr` / `extension` / `page`
        pointer]; fill as `.space` / `.align`; whatever is left as a `.byte` row."""
        self.build_index()
        refs = {self.off(r) for r in self.refs if self.in_data(r)} | {self.off(a) for a in self.label_at
                                                                      if self.in_data(a)}
        runs, o = [], R1_END
        while o < DATA_END:
            if self.claimed[o]:
                o += 1
                continue
            e = o
            while e < DATA_END and not self.claimed[e]:
                e += 1
            runs.append((o, e))
            o = e
        # what the runs' own pointer words point at is named first (a name table's last entry
        # points at the empty string that ends it)
        for o, e in runs:
            for p in range(o + (-o % 4), e - 3, 4):
                v = int.from_bytes(self.rom[p:p + 4], "little")
                if self.in_data(v):
                    refs.add(self.off(v))
                    self.refs.add(v)
        for o, e in runs:
            self._residue_run(o, e, refs)

    def _residue_run(self, o, e, refs):
        rom, p = self.rom, o
        ram = lambda q: RAMINIT_OFF <= q < RAMINIT_END      # noqa: E731

        def put(q, n, kind, lines, base):
            a = self.addr_of(q)
            lab = self.name_at(a, base) if q in refs else None
            self.add(a, n, lab, kind, lambda g, it, lines=lines: (
                [f"{it.label}:"] if it.label else []) + [x(g) if callable(x) else x for x in lines])
        while p < e:
            if p % 4 == 0 and p + 4 <= e:
                v = int.from_bytes(rom[p:p + 4], "little")
                if self.is_addr(v) or (v in (0, 0xFFFFFFFF) and ram(p)):
                    put(p, 4, "pointer", [lambda g, v=v: f"\t.long\t{g.ref(v)}" if v != 0xFFFFFFFF else
                                          "\t.long\t0xFFFFFFFF"], f"ptr_{self.addr_of(p):08X}")
                    p += 4
                    continue
            z = rom.find(b"\0", p, e)
            if z >= 0 and (z - p >= 3 or (z > p and p in refs)) and all(0x20 <= c < 0x7F for c in rom[p:z]):
                self.str_item(self.addr_of(p), "Str_" + (sanitize(rom[p:z].decode()) or "text"), "text")
                p = z + 1
                continue
            if rom[p] == 0 and p in refs and not ram(p):
                self.str_item(self.addr_of(p), "Str_empty", "text")
                p += 1
                continue
            if rom[p] == 0 and p % 4 and set(rom[p + 1:min(e, p + 4 - p % 4)]) <= {0xFF} and p not in refs:
                n = min(e, p + 4 - p % 4) - p
                put(p, n, "pad", ["\t.byte\t0\t# a NUL nothing names (an empty string), then the pad"]
                    + (["\t.align\t4, 0xFF"] if n > 1 else []), None)
                p += n
                continue
            if rom[p] == 0xFF and p % 4 and ram(p) and set(rom[p:min(e, p + 4 - p % 4)]) == {0xFF}:
                p = min(e, p + 4 - p % 4)       # the pad after a string: .align in the gap lines
                continue
            if rom[p] in (0x00, 0xFF) and not ram(p) and p not in refs:
                q = p
                while q < e and rom[q] == rom[p] and (q == p or q not in refs):
                    q += 1
                if q - p >= 4 or q % 4 == 0 or q == e:
                    put(p, q - p, "fill", [f"\t.space\t{q - p}, 0x{rom[p]:02X}"], None)
                    p = q
                    continue
            if p % 4 == 0 and p + 4 <= e:
                v = int.from_bytes(rom[p:p + 4], "little")
                bss = P.get("bss")
                if bss and bss[0] <= v < bss[0] + bss[1]:
                    put(p, 4, "pointer", [f"\t.long\t{bss[2]}+0x{v - bss[0]:X}\t# a pointer into the cleared work RAM"],
                        f"ptr_{self.addr_of(p):08X}")
                    p += 4
                    continue
                put(p, 4, "word", [f"\t.long\t0x{v:08X}" + ("\t# initial value" if ram(p) else "")],
                    f"word_{self.addr_of(p):08X}")
                p += 4
                continue
            q = p + 1
            while q < e and q % 4 and q not in refs:
                q += 1
            put(p, q - p, "bytes", ["\t.byte\t" + ", ".join(f"0x{c:02X}" for c in rom[p:q])
                                    + "\t# no reader traced"], f"bytes_{self.addr_of(p):08X}")
            p = q

    def pointerish(self, o, e):
        """True when at least half the aligned words of file bytes o..e are
        program addresses: pointers into 0x485B.... read as text ("t[H u[H"),
        so such bytes are not taken for a string (a long text may still hold
        one such word by chance: "...eH" ends a word)."""
        words = range(o + (-o % 4), e - 3, 4)
        # (lane mn10300-typer) not a word that lands inside an instruction: "RIGH" = 0x48474952 of
        # "RIGHT 1" (MidiPmemOutLGrid's labels) is no pointer
        hits = sum(1 for k in words if BASE <= (w := int.from_bytes(self.rom[k:k + 4], "little")) < BASE + len(self.rom)
                   and self.code_ptr_ok(w))
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
                if j - i >= 8 and L >= P.get("string_arrays_min", 2) + 1 and not (
                        P.get("structs") and P.get("text_strict") and all(self.fake_text(r) for r in parts[i:j])):
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
            if P.get("structs"):
                # (a typed item's printable last bytes -- a pointer's "GH" -- may run into the string)
                while o < e - 1 and self.claimed[o]:
                    o += 1
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
            txt = sum(1 for k in range(n) if all(0x20 <= c < 0x7F for c in rom[o + 8 * k:o + 8 * k + 8]))
            if n >= 4 and FEATURES.get("doubles_text", True) and 2 * txt >= nz:
                # (lane mn10300-data) a run whose words are mostly eight printable bytes is text, not doubles
                # (the KN6000's feature-demo script): printable_runs() types it
                o += 8 * n
                continue
            if n >= 4 and nz >= n // 2 + 1:
                vals = [struct.unpack_from("<IId", rom, o + 8 * k) for k in range(n)]
                a = self.addr_of(o)
                self.add(a, 8 * n, self.name_at(a, f"doubles_{a:08X}"), "double table",
                         lambda g, it, vals=vals: [f"{it.label}:\t# IEEE-754 doubles (lo word, hi word)"] + [
                             f"\t.long\t0x{lo:08X}, 0x{hi:08X}\t# {d:.9g}" for lo, hi, d in vals])
                o += 8 * n
            else:
                o += 8

    def printable_runs(self):
        """(FEATURES["doubles_text"], lane mn10300-data) What is left of 32 or more printable bytes in a row
        (0x20..0x7E, no NUL), in the program flash and no item's: text with no NUL, written as `.ascii`
        rows [INFERENCE: text; no pass typed it -- the KN6000's feature-demo XML script, which the doubles
        pass used to take for doubles]."""
        if not FEATURES.get("doubles_text", True):
            return
        import bisect
        rd = set()            # gap_note's reads (not its cache: refs still grow after this pass)
        for x in getattr(self, "dr", None).accesses if getattr(self, "dr", None) else ():
            k = x.key
            if k[0] in ("abs", "base", "step") and self.in_data(k[1]):
                rd.add(self.off(k[1]))
            elif k[0] == "rec" and self.in_data(k[1]):
                rd.add(self.off(k[1] + x.off))
            elif k[0] == "ptr" and k[1][0] == "tgt":
                rd.update(self.off(t + x.off) for t in k[1][1] if self.in_data(t + x.off))
        rd = sorted(rd)
        rom = self.rom
        o = R1_END
        while o < DATA_END:
            if self.claimed[o] or not 0x20 <= rom[o] < 0x7F or RAMINIT_OFF <= o < RAMINIT_END:
                o += 1
                continue
            e = o
            while e < DATA_END and not self.claimed[e] and 0x20 <= rom[e] < 0x7F and not RAMINIT_OFF <= e < RAMINIT_END:
                e += 1
            i = bisect.bisect_left(rd, o)
            if e - o >= 32 and not (i < len(rd) and rd[i] < e):
                a = self.addr_of(o)

                def rtext(g, it, o=o, e=e):
                    return [f"{it.label}:\t# {e - o} printable bytes with no NUL; no instruction reads them [INFERENCE: text]"] + [
                        f'\t.ascii\t"{c_escape(g.rom[q:min(q + 64, e)])}"' for q in range(o, e, 64)]
                self.add(a, e - o, self.name_at(a, f"text_{a:08X}"), "text", rtext)
            o = e

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
            if want != cur_base and want != BASE and P.get("raminit_label"):
                # the image's flash address, the copy loop's source (a label before the switch)
                body += ["", f"{P['raminit_label']}:\t# the initialised-RAM image's flash copy: {RAMINIT_LEN}"
                             f" bytes the start-up code copies to 0x{RAMINIT_RAM:08X}"]
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
            *([f'.include "{outdir}/data_structs.inc"', f'.include "{SHARED}src/include/dsp_records.inc"'] if P.get("structs") else []),
            f'.include "{outdir}/rhythm_macros.inc"',
            f'.include "{outdir}/gui_ids.inc"',
            f'.include "{outdir}/gui_classes.inc"',
            *([f"# the work RAM no initialised-RAM image covers (its code clears it): its words are named"
               f" from here", f".equ {P['bss'][2]}, 0x{P['bss'][0]:08X}"] if P.get("bss") else []),
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
        lab = dict(self.label_at)
        if P.get("raminit_label"):
            lab[RAMINIT_ROM] = P["raminit_label"]
        for a, n in sorted(lab.items()):
            sym.append(f"0x{a:08X}  {n}  {sizes.get(a, 0)}")
        self.write(os.path.join(outdir, "labels.sym"), sym)
        if FEATURES.get("frozen_obj_names", True) and any(not o.name for b in self.m.blocks.values() for o in b["objects"]):
            self.write(os.path.join(outdir, self.OBJ_NAMES_TSV), self.object_names_tsv())
            r = self.frozen_report
            print(f"gen_data_s: object names: {r['frozen']} from {self.OBJ_NAMES_TSV} ({r['map rows']} rows), {r['new']} new,"
                  f" {r['class changed']} with another class, {r['name taken']} whose name another source holds")
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
        if P.get("structs"):
            self.write(os.path.join(outdir, "data_structs.inc"), hdr + self.structs_inc())
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

    def gap_note(self, a, b):
        """(`structs` profiles) For the bytes a..b no pass could type: the census
        declaration when nothing reads them -- no load, store or call argument of the
        converted code lands in them (tools/data_readers.py) and no address the code or
        a typed item holds points into them -- else None (they stay generic: a reader
        exists that the passes could not turn into a type)."""
        import bisect
        if not hasattr(self, "_gap_reads"):
            rd = set()
            for x in self.dr.accesses:
                k = x.key
                if k[0] in ("abs", "base", "step") and self.in_data(k[1]):
                    rd.add(self.off(k[1]))
                elif k[0] == "rec" and self.in_data(k[1]):
                    rd.add(self.off(k[1] + x.off))
                elif k[0] == "ptr" and k[1][0] == "tgt":
                    rd.update(self.off(t + x.off) for t in k[1][1] if self.in_data(t + x.off))
            self._gap_reads = sorted(rd)
            self._gap_refs = sorted(self.off(r) for r in self.refs if self.in_data(r))
        i = bisect.bisect_left(self._gap_reads, a)
        if i < len(self._gap_reads) and self._gap_reads[i] < b:
            return None
        j = bisect.bisect_left(self._gap_refs, a)
        held = j < len(self._gap_refs) and self._gap_refs[j] < b
        bs = self.rom[a:b]
        words = [int.from_bytes(bs[k:k + 4], "little") for k in range(-a % 4, len(bs) - 3, 4)]
        what = ("printable bytes, not NUL-terminated text" if sum(1 for c in bs if 0x20 <= c < 0x7F) >= 0.6 * len(bs)
                else "words that look like addresses" if words and 2 * sum(1 for w in words if self.is_addr(w)) >= len(words)
                else "7-bit values" if all(c < 0x80 for c in bs) else "binary")
        where = "the initialised-RAM image (initial values no instruction names)" if RAMINIT_OFF <= a < RAMINIT_END \
            else "the program flash"
        return (f"# census: opaque -- unknown-dump: {b - a} bytes of {what} in {where}; no instruction reads them"
                f" (tools/data_readers.py: no load, store, base or call argument in them)"
                + ("; a typed pointer or a code immediate holds their address, but nothing is read through it"
                   if held else "; no address the code or a typed item holds points into them"))

    def typed_gap(self, a, b):
        """(the siblings) A gap no pass typed that is plainly one of two things, written as such:
        text with no NUL (every byte printable: `.ascii` rows), or words that are each 0 or the
        address of something with a name (`.long` rows, spelled symbolically).  The comment says
        whether an instruction reads the bytes (gap_note's reader search).  None otherwise."""
        bs = self.rom[a:b]
        n = b - a
        if n < 8:
            return None
        read = self.gap_note(a, b) is None
        why = ("read by an instruction no pass could turn into a type" if read
               else "no instruction reads them (tools/data_readers.py)")
        if all(0x20 <= c < 0x7F for c in bs):
            w = next((k for k in (16, 32, 12, 10, 8) if n % k == 0 and n // k >= 2), 16)
            return [f"\t# {n} bytes of text with no NUL, {w} characters a row [INFERENCE: fixed-width names]; {why}"] + [
                f'\t.ascii\t"{c_escape(bs[i:i + w])}"' for i in range(0, n, w)]
        if (self.addr_of(a) & 3) == 0 and n % 4 == 0:
            words = [int.from_bytes(bs[k:k + 4], "little") for k in range(0, n, 4)]
            refs = []
            for v in words:
                if v == 0:
                    refs.append("0")
                    continue
                if not self.is_addr(v) or (self.in_code(v) and v not in self.extern):
                    return None
                r = self.ref(v)
                if r.startswith("0x"):
                    return None
                refs.append(r)
            if sum(1 for v in words if v) * 2 < len(words):
                return None
            return [f"\t# {len(words)} addresses [INFERENCE: a pointer table: every word is 0 or a named"
                    f" address]; {why}"] + [f"\t.long\t{r}" for r in refs]
        return None

    def gap_lines(self, a, b):
        """The bytes a..b (file offsets) no typed item holds: a uniform run is
        .space (or .align, when it is the padding up to a 4-byte boundary after
        a string or record); the rest stays .incbin_range of the reference."""
        out = self._gap_lines(a, b)
        if P.get("structs"):
            res = []
            for ln in out:
                mo = re.match(r'\.incbin_range "[^"]+", 0x([0-9A-F]+), 0x([0-9A-F]+)', ln)
                if mo and "root" in P:
                    typed = self.typed_gap(int(mo.group(1), 16), int(mo.group(2), 16))
                    if typed:
                        res += typed
                        continue
                if mo:
                    note = self.gap_note(int(mo.group(1), 16), int(mo.group(2), 16))
                    if note:
                        res.append(note)
                    elif P.get("reader_rows"):
                        res += self.reader_rows(int(mo.group(1), 16), int(mo.group(2), 16))
                        continue
                res.append(ln)
            return res
        return out

    # -- the last fallback: a read gap as rows of its readers' widths (lane generic-zero) -------------
    def _reads_index(self):
        """{file offset: [Access]} of every load / store / base / argument of the walk that lands at
        that offset (gap_note's landing rule: a fixed address, a record array's first record + the
        field offset, each record a T value selects + the field offset), and the record arrays'
        (first landing, stride, Access) for the rows of the later records."""
        if hasattr(self, "_reads_at"):
            return self._reads_at, self._reads_strided
        at, strided = collections.defaultdict(list), []
        for x in self.dr.accesses:
            k = x.key
            if k[0] in ("abs", "base", "step") and self.in_data(k[1]):
                at[self.off(k[1])].append(x)
            elif k[0] == "rec" and self.in_data(k[1] + x.off):
                o = self.off(k[1] + x.off)
                at[o].append(x)
                if k[2] and x.width:
                    strided.append((o, k[2], x))
            elif k[0] == "ptr" and k[1][0] == "tgt":
                for t in k[1][1]:
                    if self.in_data(t + x.off):
                        at[self.off(t + x.off)].append(x)
        self._reads_at, self._reads_strided = at, sorted(strided, key=lambda s: s[0])
        self._gap_label_offs = None
        return self._reads_at, self._reads_strided

    def reader_row_refs(self):
        """(`reader_rows` profiles) Before gaps() labels the raw bytes: in every run no item holds
        that an instruction reads, a word-aligned word that is an address of this data region
        outside any item is a pointer reader_rows() writes `.long Label`: label its target, unless
        the target lies in a read run itself (then it is `Label+N` of the label before it in that
        run: a label there would split bytes the walk reads into a piece it does not)."""
        import bisect
        at, _st = self._reads_index()
        ks = sorted(at)
        o = R1_END
        runs = []
        while o < DATA_END:
            if self.claimed[o]:
                o += 1
                continue
            e = o
            while e < DATA_END and not self.claimed[e]:
                e += 1
            i = bisect.bisect_left(ks, o)
            if i < len(ks) and ks[i] < e:
                runs.append((o, e))
            o = e
        rs = [r[0] for r in runs]

        def in_read_run(q):
            i = bisect.bisect_right(rs, q) - 1
            return i >= 0 and runs[i][0] <= q < runs[i][1]
        n = 0
        for o, e in runs:
            for q in range(o + (-self.addr_of(o) % 4), e - 3, 4):
                v = int.from_bytes(self.rom[q:q + 4], "little")
                if self.in_data(v) and self.item_containing(v) is None and v not in self.refs \
                        and not in_read_run(self.off(v)):
                    self.refs.add(v)
                    n += 1
        print(f"gen_data_s: {n} addresses read rows point at")

    def _gap_ref(self, v):
        """A 32-bit value as a symbol: ref(), or `Label+N` where Label is the nearest label of
        the raw bytes before v with no typed item between them (a record's pointer into its own
        tail, or into the gap after it)."""
        import bisect
        r = self.ref(v)
        if not r.startswith("0x") or not self.in_data(v):
            return r
        if self._gap_label_offs is None:
            labs = sorted((self.off(a), n) for a, n in self.label_at.items()
                          if self.in_data(a) and self.item_containing(a) is None)
            self._gap_label_offs = ([o for o, _ in labs], [n for _, n in labs])
        offs, names = self._gap_label_offs
        o = self.off(v)
        i = bisect.bisect_right(offs, o) - 1
        if i < 0 or o - offs[i] > 0x1000:
            return r
        lo = offs[i]
        if any(self.claimed[lo:o]):
            return r
        return f"{names[i]}+{o - lo}" if o > lo else names[i]

    @staticmethod
    def _cite(cites, a):
        """The readers of a reader_rows() piece, for its header: function, address, instruction,
        and where in the piece it lands at what width (or as a base / a call argument)."""
        rd = []
        for q, x in sorted(cites, key=lambda c: (c[1].cpu or 0, c[1].func or "", c[1].insn, c[0])):
            fn = re.sub(r"_entry$", "", x.func or "?")
            t = f"{fn} 0x{x.cpu or 0:08X} `{' '.join(x.insn.split())}` (+{q - a}" + (
                f", {'s' if x.signed else 'u'}{8 * x.width}" if x.width else ", as a base" if x.rw == "base"
                else f", {x.rw}") + ")"
            if t not in rd:
                rd.append(t)
        return rd

    def reader_rows(self, a, b):
        """(`reader_rows` profiles) The bytes a..b (file offsets) that an instruction reads but no
        pass turned into a type: rows at the width and signedness of the reads that land in them
        (tab_u8 / tab_s8 / tab_u16 / tab_s16 / tab_u32), a 4-aligned word no read narrower than 4
        lands in and that is an address as `.long Label` (or `Label+N`), the bytes between the reads
        on the grid of the commonest read width, the rest as u8; the header names the readers and
        the instructions.  [INFERENCE] only the read fields are known; the other rows' width is
        the grid's, not traced."""
        at, strided = self._reads_index()
        n = b - a
        reads = collections.defaultdict(list)          # offset -> [Access] (width > 0)
        cites = []
        for q in range(a, b):
            for x in at.get(q, ()):
                cites.append((q, x))
                if x.width and q + x.width <= b:
                    reads[q].append(x)
        import bisect
        i = bisect.bisect_left(strided, (a,))
        for o, s, x in strided[i:]:
            if o >= b:
                break
            for q in range(o + s, b, s):
                if q + x.width <= b:
                    reads[q].append(x)
        width = {}
        for q, xs in reads.items():
            c = collections.Counter(x.width for x in xs)
            w = max(c, key=lambda k: (c[k], k))
            width[q] = (w, any(x.signed for x in xs if x.width == w))
        # the grid of the commonest read width, anchored at a read of that width
        wc = collections.Counter(w for w, _s in width.values())
        bs = self.rom[a:b]
        strarg = [x for _q, x in cites if x.rw.startswith("arg") and x.extra
                  and re.match(r"(str|sprintf|vsprintf|printf)", str(x.extra[0]))]
        z = bs.find(b"\0")
        if not wc and z >= 0 and all(0x20 <= c < 0x7F or c in (9, 10, 13) for c in bs[:z]) and set(bs[z + 1:]) <= {0xFF} \
                and (b - (a + z + 1)) < 4 and (self.addr_of(b) % 4 == 0 or z + 1 == n):
            # a (short or empty) string and its pad: handed to a string routine, or only as a base
            # [INFERENCE in the latter case: the NUL and the 0xFF pad of the string layout]
            why = ("handed to " + ", ".join(sorted({str(x.extra[0]) for x in strarg})) if strarg
                   else "[INFERENCE: a string by its layout, a NUL then the 0xFF pad to a word]")
            rd = self._cite(cites, a)
            return ([f"\t# a string, {n} bytes with its pad, read by {'; '.join(rd[:3])}"
                     + (f" (+{len(rd) - 3} more)" if len(rd) > 3 else "")
                     + f"; {why}", f'\t.asciz\t"{c_escape(bs[:z])}"']
                    + ([f"\t.align\t4, 0xFF"] if z + 1 < n else []))
        if wc:
            W = max(wc, key=lambda k: (wc[k], k))
            anchor = min(q for q, (w, _s) in width.items() if w == W)
            gsigned = any(s for w, s in width.values() if w == W)
            how = "between them the commonest read width"
        else:
            # read only as a base or a call argument (the width is the callee's): words when the
            # piece is word-aligned and every word is 0, an address or below 2^24 (a count, a
            # 0x00BBGGRR colour), else bytes
            words = [int.from_bytes(bs[k:k + 4], "little") for k in range(0, n - 3, 4)]
            W = 4 if self.addr_of(a) % 4 == 0 and n % 4 == 0 and all(
                w < 0x1000000 or self.is_addr(w) or w >> 24 == RAMINIT_RAM >> 24 for w in words) else 1
            anchor, gsigned = a, False
            how = ("word rows: the piece is word-aligned and every word is below 2^24 or an address" if W == 4
                   else "byte rows")
        elems = []                                      # (kind, text, offset)
        q = a
        while q < b:
            w, sg = width.get(q, (0, False))
            if (w in (0, 4)) and self.addr_of(q) % 4 == 0 and q + 4 <= b and not any(q < p < q + 4 for p in width):
                v = int.from_bytes(self.rom[q:q + 4], "little")
                if self.is_addr(v) and not (self.in_code(v) and v not in self.extern):
                    r = self._gap_ref(v)
                    if not r.startswith("0x"):
                        elems.append(("ptr", r, q))
                        q += 4
                        continue
            if not w:
                if (q - anchor) % W == 0 and q + W <= b and not any(q < p < q + W for p in width):
                    w, sg = W, gsigned
                else:
                    w, sg = 1, False
            v = int.from_bytes(self.rom[q:q + w], "little", signed=sg)
            elems.append((("s" if sg else "u") + str(8 * w), v, q))
            q += w
        # a kind any of whose values is 2^16 or more is written in hex throughout (addresses,
        # colours, flag words), the others in decimal
        hexk = {k for k, v, _q in elems if k != "ptr" and v >= 0x10000}
        elems = [(k, v if k == "ptr" else f"0x{v:X}" if k in hexk and v >= 0 else str(v), q) for k, v, q in elems]
        rd = self._cite(cites, a)
        kinds = sorted({k for k, _t, _q in elems if k != "ptr"}) + (["pointers"] if any(k == "ptr" for k, _t, _q in elems) else [])
        more = f" (+{len(rd) - 3} more)" if len(rd) > 3 else ""
        if wc:
            out = [f"\t# {n} bytes read by {'; '.join(rd[:3])}{more}; the read fields at their widths"
                   f" ({', '.join(kinds)}), {how} [INFERENCE: the fields no instruction is seen to read are"
                   f" not traced]"]
        elif self.readers_callee:
            out = [f"\t# {n} bytes the code takes the address of: {'; '.join(rd[:3])}{more}; {how}"
                   f" ({', '.join(kinds)}); {self.arg_why(a, cites)}"]
        else:
            out = [f"\t# {n} bytes the code takes the address of: {'; '.join(rd[:3])}{more}; {how}"
                   f" ({', '.join(kinds)}) [INFERENCE: what the callee reads through the address is not traced]"]
        i = 0
        per = {"u8": 16, "s8": 16, "u16": 12, "s16": 12, "u32": 8, "s32": 8, "ptr": 4}
        while i < len(elems):
            k = elems[i][0]
            j = i
            while j < len(elems) and elems[j][0] == k and j - i < per[k]:
                j += 1
            vals = ", ".join(t for _k, t, _q in elems[i:j])
            mn = ".long" if k == "ptr" else f"tab_{k}"
            out.append(f"\t{mn}\t{vals}\t# +{elems[i][2] - a}")
            i = j
        return out

    def arg_why(self, a, cites):
        """(callee) Why a reader_rows() piece the code only takes the address of is not a record of
        what a routine reads through it (data_readers.Reader(callee=), arg_kinds())."""
        t = self.addr_of(a)
        calls = sorted({(re.sub(r"_entry$", "", str(x.extra[0])), x.rw.split()[1]) for _q, x in cites
                        if x.rw.startswith("arg") and x.extra and x.extra[0] != "via"})
        why = []
        for F, r in calls:
            sk = [w for f_, r_, w in self.arg_skip.get(t, ()) if (f_, r_) == (F, r)]
            if sk:
                why.append(f"{F} ({r}): {sk[0]}")
            elif ("arg", F, r) in self._arg_kinds:
                why.append(f"{F} ({r}) reads fields of it, but the record would run into bytes another"
                           f" item holds")
            elif F.startswith("(") or not re.match(r"[A-Za-z_]", F):
                why.append(f"an indirect call {F} ({r}): the routine is not known")
            elif self.LIB_ROUTINE.match(F) or DR_LIBC.match(F):
                why.append(f"{F} ({r}): a library routine: what it reads is a string or a block, not fields")
            else:
                why.append(f"{F} ({r}) reads nothing through it the walk sees")
        if not why:
            return ("the address is not seen reaching a call: it is kept in memory, met at a label from"
                    " several paths, or returned [INFERENCE]")
        return "the callee walk: " + "; ".join(why[:3]) + (f" (+{len(why) - 3} more)" if len(why) > 3 else "")

    def _gap_lines(self, a, b):
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

    def structs_inc(self):
        import data_structs as DS
        out = ["# The record kinds of the data region's struct arrays, GENERATED by tools/gen_data_s.py from",
               "# their readers (tools/data_readers.py, tools/data_structs.py): one macro per kind, a parameter",
               "# per field.  Each header lists the fields, their types and the instructions that read them;",
               "# f<off> / p<off> / s<off> / x<off> are fields named by their offset only (a number, a pointer,",
               "# text, bytes no reader was seen to touch); tools/data_struct_names.py names the others.", ""]
        for g in self.struct_groups:
            out += DS.macro_lines(g)
        return out

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
        if getattr(self, "table_titles", None):
            out.append(f"# {len(self.table_titles)} titles no screen registers, named by the firmware's own title-name"
                       f" table ({P['title_names'][0]:#010x}, entry i = title i's name string)")
            out += [f".equ {self.id_name[i]}, 0x{i:08X}\t# \"{s}\"" for i, s in sorted(self.table_titles.items())] + [""]
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
        if "root" in P or FEATURES.get("builtin_pads", True):
            self.pads()
        self.tone_macros = False
        if P.get("tones"):
            self.tones()
            self.panel_banks()
        self.media()
        if P.get("bitmaps"):
            self.bitmaps()
        self.code_refs()
        if P.get("structs"):
            if P.get("readers_ext") or FEATURES.get("sibling_support", True):
                # (lane mn10300-data2) the siblings register the same SupportClass table (KN2400 slot 0xD,
                # KN6000 / KN6500 0x1C0: InitSptClassTable)
                self.support_classes()
            self.boot_sectors()
            self.style_genre_lists()
            if P.get("readers_ext") or FEATURES.get("sibling_trie", True):
                # (lane mn10300-rest) the siblings have the same trie (KN6000 func_4C02CA6A, KN2400 func_5014A95C)
                self.resource_trie()
            # reader-typed struct arrays (tools/data_structs.py) before the pointer and string guesses
            self.sound_alpha_lists()
            self.fx_descriptors()
            self.fx_streams()
            self.pow10_table()
            self.maps128()
            self.chord_voicings()
            self.fx_presets()
            self.zlib_tables()
            self.hash_tables()
            self.name_value_tables()
            self.panel_memories()
            self.dsp_pool()
            if P.get("string_arrays"):
                self.string_arrays()
            self.struct_arrays()
            self.style_panels()
            self.typed_refs()
            self.message_tables()
            self.drawn_bitmaps()
            self.named_glyphs()
            self.sentinel_lists()
            self.ptr_records()
            if P.get("readers_ext"):
                self.sysex_strings()
                self.copied_blocks()
            self.text_runs()
            self.doubles()
        else:
            self.pow10_table()
            self.typed_refs()
            self.name_value_tables()
            self.doubles()
            self.panel_memories()
            if P.get("string_arrays"):
                self.string_arrays()
            self.text_runs()
        if self.readers_callee:
            self.arg_reserve()
        self.reader_tables()
        if P.get("structs"):
            self.variables()
            if P.get("readers_ext"):
                self.pointer_runs()
        if self.readers_callee:
            # (lane callee-walk) the blocks a caller hands a routine, typed by what it reads through them;
            # then what a span arg_reserve() kept for a record that did not fit, as before
            self.ptr_records(only_arg=True)
            self.indexed_tails()
            if self.deep_records and not P.get("readers_ext"):
                # (lane mn10300-typer) the siblings: the blocks a pointer field of a record leads to that
                # the code copies whole (copied_blocks, which the KN7000 builds run with readers_ext)
                self.copied_blocks()
            self._arg_spans = []
            self.reader_tables()
            if P.get("structs"):
                self.variables()
        if P.get("structs"):
            self.widget_vars()
            self.table_terminators()
            self.printable_runs()
        self.short_strings()
        self.zlib_kinds()
        if P.get("residue"):
            self.residue()
        self.build_index()
        if P.get("reader_rows"):
            self.reader_row_refs()
        self.gaps()
        n = self.emit(outdir)
        if self.host is not None and P.get("scheme") == "naka":
            self.host_calls_tsv(outdir)       # (gen_image_s.py's plug-ins: the HD-SX3)
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
