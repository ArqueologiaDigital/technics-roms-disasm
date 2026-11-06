#!/usr/bin/env python3
"""sysex_pccom.py -- question (N-abdfdef8): what do the 47 "type 4" Technics SysEx descriptors of
PROGRAM 941 (handler func_484C1B6F, sub-handlers func_484C1D13 .. func_484C2E55) carry, and what does the
instrument answer?

Signals read (converted source src/program/*.s as bytes, the data source, and baserom/kn7000_program.rom):
  1. each request sub-handler's request record: the byte it stores to (0x24, sp) (`mov N, d0` /
     `movbu d0, (0x24, sp)`) -- the command kind func_4858391E dispatches through func_4858391E_Table_3
     (kind 1..12; the record is copied to 0x50172F4C, its +1 is the file group, its +0xB a NUL-terminated
     path copied from the message at +0x14 by func_484C1B1A);
  2. func_4858391E_Table_3 / _Table / _Table_2: the file routine each kind (and, for kinds 4 / 3, each
     group 0..12 / 0..11) reaches -- the first named `call` after the case label;
  3. the reply frames func_484C35EF (ACK, Str_P_1_5) and func_484C364E (status, Str_P_1_4, code at +6);
  4. the check byte func_484C3517 / func_484C356A put / test before F7: XOR-and-look-up over bytes
     1 .. n-3 in the 256-byte table at Str_empty_307+2, then >> 1.  The probe rebuilds the table of the
     SD-card CRC-7 (polynomial x^7 + x^3 + 1, entries pre-shifted left by one) and compares;
  5. func_484C34ED: the 21-bit field of message bytes +9..+11 (b9 << 14 | b10 << 7 | b11);
  6. kind 10 (sub 0x0B, F0 50 32 ..) changes to title 0x12F = TT_PCCOM (gui_ids.inc), the screen titled
     "PC COMMUNICATION".
Expected (2026-11-06): sub 0x0E -> kind 2 LoadSmf, 0x0F -> 1 SaveSmf, 0x10 -> 4 (load group gg: Lsw Pmt Md
Fav Hmp Efc Sqt Cmp Msp Tm Rcm Cst SqfSeq), 0x11 -> 3 (save group gg), 0x12..0x16 -> 7, 8, 9, 5, 6 (SD-card
operations), 0x17 -> 12 PictureImport, 0x0B -> 10, 0x0C -> 11; table == CRC-7: True.

usage (from kn7000/):  python3 -I notes/presentation-control-probes/sysex_pccom.py
"""
import pathlib
import re

SRC = {p.name: p.read_bytes().decode("latin-1").splitlines() for p in pathlib.Path("src/program").glob("*.s")}
DATA = {p.name: p.read_bytes().decode("latin-1").splitlines() for p in pathlib.Path("src/program/data").glob("*.s")}
labels = {}
for ln in open("src/program/data/labels.sym"):
    p = ln.split()
    if len(p) >= 2 and p[0].startswith("0x"):
        labels[p[1]] = int(p[0], 16)
rom = open("baserom/kn7000_program.rom", "rb").read()
B = 0x48400000


def body(name):
    for f, L in SRC.items():
        for i, l in enumerate(L):
            if l == name + ":":
                out = []
                for x in L[i + 1:]:
                    if re.match(r"^func_[0-9A-F]{8}:$", x) or (re.match(r"^[A-Z]\w*:$", x) and not x.startswith(name)):
                        break
                    out.append(x)
                return out
    return []


def at_label(lab, n=40):
    for f, L in SRC.items():
        for i, l in enumerate(L):
            if l == lab + ":":
                return L[i + 1:i + 1 + n]
    return []


def table(name):
    for f, L in DATA.items():
        for i, l in enumerate(L):
            if l.startswith(name + ":"):
                out = []
                for x in L[i + 1:]:
                    m = re.match(r"\s+\.long\s+(\w+)", x)
                    if not m:
                        break
                    out.append(m.group(1))
                return out
    return []


def first_call(lab, depth=0):
    """the first named routine a case calls, following one `beq` (SavePmt's bank check)"""
    skip = ("func_484C304F", "strrchr", "strcpy", "LibStrlen", "memcpy", "SetSavePMBankNUM", "func_48583FD2")
    for x in at_label(lab):
        m = re.match(r"\s+call\s+(\w+)", x)
        if m and not m.group(1).startswith(skip):
            return m.group(1).replace("_entry", "")
        m = re.match(r"\s+beq\s+(loc_\w+)", x)
        if m and depth == 0:
            return first_call(m.group(1), 1)
        if re.match(r"\s+jmp\s+loc_48583FB[AC]", x):
            break
    return "-"


SUBS = [(0x0B, "func_484C1E1A", "F0 50 32 7E 31 1F cc F7"), (0x0C, "func_484C1EDE", "F0 50 33 7E 31 1F 00 cc F7"),
        (0x0E, "func_484C1FAF", "7F 10 00"), (0x0F, "func_484C214D", "7F 10 04"),
        (0x10, "func_484C22CD", "7F gg 00"), (0x11, "func_484C24B1", "7F gg 04"),
        (0x12, "func_484C262D", "7F 20 00"), (0x13, "func_484C27A9", "7F 20 01"),
        (0x14, "func_484C295F", "7F 20 02"), (0x15, "func_484C2B23", "7F 20 04"),
        (0x16, "func_484C2C9F", "7F 20 05"), (0x17, "func_484C2E55", "7F 30 00")]
T3 = table("func_4858391E_Table_3")
print("request -> command kind (record byte 0) -> func_4858391E case -> first file routine")
for sub, fn, tmpl in SUBS:
    L = body(fn)
    kind = None
    for i, x in enumerate(L):
        if re.match(r"\s+movbu\s+d0, \((0x24|0x1c), sp\)", x) or re.match(r"\s+mov\s+0x[0-9a-f]+, d0$", x) and \
                i + 1 < len(L) and "(0x24, sp)" in L[i + 1]:
            m = re.match(r"\s+mov\s+(0x[0-9a-f]+|\d+), d0", L[i - 1] if "movbu" in x else x)
            if m:
                kind = int(m.group(1), 0)
                break
    if kind in (10, 11):        # tested at func_4858391E's head, before the table (loc_4858395C / loc_485839A2)
        head = {10: "ChangeTitle(0x12F = TT_PCCOM), returns 0", 11: "leaves PC COMMUNICATION (ChangeMode / InterruptTitle)"}
        full = tmpl
        print(f"  sub 0x{sub:02X} {fn} '{full}': kind {kind}  func_4858391E head: {head[kind]}")
        continue
    case = T3[kind - 1] if kind and 1 <= kind <= len(T3) else "-"
    full = tmpl if tmpl.startswith("F0") else "F0 50 2C 20 31 1F " + tmpl
    print(f"  sub 0x{sub:02X} {fn} '{full}': kind {kind}  {case}  {first_call(case) if case != '-' else ''}")
print("kind 4 (load) by group:", [first_call(l) for l in table("func_4858391E_Table")])
print("kind 3 (save) by group:", [first_call(l) for l in table("func_4858391E_Table_2")])
for nm in ("Str_P_1_5", "Str_P_1_4"):
    a = labels[nm]
    s = rom[a - B:a - B + 12]
    print(f"{nm} 0x{a:08X}: {s[:s.index(0xF7) + 1].hex(' ')}")
t = rom[labels["Str_empty_307"] + 2 - B:labels["Str_empty_307"] + 2 - B + 256]
crc7 = []
for i in range(256):
    c = i
    for _ in range(8):
        c = ((c << 1) ^ (0x12 if c & 0x80 else 0)) & 0xFF
    crc7.append(c)
print("check table == CRC-7 (x^7+x^3+1, <<1) table:", list(t) == crc7)
print("func_484C34ED:", "; ".join(x.strip() for x in at_label("func_484C34ED_entry", 16) if "(9, a0)" in x or "(0xa, a0)" in x
                or "(0xb, a0)" in x or "asl" in x))
for ln in open("src/program/data/gui_ids.inc", encoding="latin-1"):
    if "0x000F012F" in ln:
        print(ln.rstrip())
