#!/usr/bin/env python3
"""Probes for lane open6/kn5000-d sub-lane subcmd (kn5000-1gu, kn5000-a1f).

Reads only original_ROMs/kn5000_v10_program.rom, symbols/maincpu_v10_symbols_reference.txt and the
v10/maincpu sources (as bytes).  Run from the repository root:

    python3 notes/open6-kn5000-d/subcmd/probes/subcmd_probe.py registry
    python3 notes/open6-kn5000-d/subcmd/probes/subcmd_probe.py recordmap
    python3 notes/open6-kn5000-d/subcmd/probes/subcmd_probe.py syssenders

registry    -- SndParam_Registry entries whose key is < 0x100: key, panel record, field, mask, min, max,
               shift, xor, type.  Answers: which panel bit is system parameter 0x00C0 (the one
               SndParam_ApplySystemParam turns into sub-CPU sub-command 0x09)?  Expect key 0xc0 ->
               record 0x91 field 3 mask 0x04 (PANEL_GM+3 bit 2, GM ON/OFF), range 0..1, shift 2.
recordmap   -- SeqTrackAssign_RecordMapTable: per TRACK ASSIGN value, the panel events 0xB0-0xB4 that a
               track records and the emitter index (MidiStream_ProcessorDispatchC_Data: 3 = D2, 4 = D1,
               5 = D3, 6 = D0).  Answers: which song event each controller record becomes.
syssenders  -- every call of the sub-CPU system-record sender {F0, A, C, E} in v10/maincpu with the
               sub-command (BC) and byte 1 (WA) loaded just before it.  Answers: who sends 0x09.
"""
import re
import struct
import sys
from pathlib import Path

ROM = Path("original_ROMs/kn5000_v10_program.rom")
SYM = Path("symbols/maincpu_v10_symbols_reference.txt")
BASE = 0xE00000


def syms():
    out = {}
    for line in SYM.read_text(errors="replace").splitlines():
        p = line.split()
        if len(p) == 2 and not line.startswith("#"):
            try:
                out[p[0]] = int(p[1], 16)
            except ValueError:
                pass
    return out


def first(s, *names):
    for n in names:
        if n in s:
            return s[n]
    raise SystemExit("none of %s in %s" % (names, SYM))


def registry():
    rom = ROM.read_bytes()
    s = syms()
    reg = first(s, "SndParam_Registry")
    print("key    rec field mask min max shift xor type  (raw 0..15)")
    for i in range(0x3CC):  # SndParam_RegisterAllWidgets loops 0x3cc entries
        p = struct.unpack_from("<I", rom, reg - BASE + 4 * i)[0]
        b = rom[p - BASE:p - BASE + 16]
        key = struct.unpack_from("<I", b, 0)[0]
        if key < 0x100:
            print("0x%04x 0x%02x %5d 0x%02x %3d %3d %5d 0x%02x %4d  %s"
                  % (key, b[4], b[5], b[6], b[7], b[8], b[9] & 15, b[10], b[13], b.hex()))


def recordmap():
    rom = ROM.read_bytes()
    s = syms()
    rmt = first(s, "SeqTrackAssign_RecordMapTable")
    emit = {3: "D2", 4: "D1", 5: "D3", 6: "D0"}
    for assign in range(20):
        p = struct.unpack_from("<I", rom, rmt - BASE + 4 * assign)[0]
        rows = []
        a = p
        while rom[a - BASE] != 0xFF and len(rows) < 64:
            rec, field, mask, em = rom[a - BASE:a - BASE + 4]
            if 0xB0 <= rec <= 0xB4:
                rows.append("{0x%02x,%d,0x%02x}->%s" % (rec, field, mask, emit.get(em, "#%d" % em)))
            a += 4
        print("TRACK ASSIGN %2d: %s" % (assign, " ".join(rows) or "-"))


def syssenders():
    names = (b"SeqVoice_CheckAndRet_Prologue", b"SubCPU_SendSystemRecord")
    for f in sorted(Path("v10/maincpu").rglob("*.s")):
        lines = f.read_bytes().split(b"\n")
        for n, ln in enumerate(lines):
            if re.search(rb"\b(calr|call)\s+(" + b"|".join(names) + rb")\b", ln):
                wa = bc = b"?"
                for back in lines[max(0, n - 12):n][::-1]:
                    m = re.search(rb"\bldw?\s+(wa|bc),\s*([0-9a-fx]+)(:i3)?\s*$", back.strip())
                    if m:
                        if m.group(1) == b"wa" and wa == b"?":
                            wa = m.group(2)
                        if m.group(1) == b"bc" and bc == b"?":
                            bc = m.group(2)
                def num(x):
                    return "?" if x == b"?" else "0x%02x" % int(x, 0)
                print("%s:%d  byte1=%s sub-command=%s" % (f, n + 1, num(wa), num(bc)))
            # inline builders of the same packet {4, 0xf0, b1, sub, value} on the stack
            if re.search(rb"ld\s+\(xsp \+ 1\),\s*0xf0\s*$", ln):
                b1 = sub = b"?"
                for fwd in lines[n + 1:n + 4]:
                    m = re.search(rb"ld\s+\(xsp \+ ([23])\),\s*(0x[0-9a-f]+)\s*$", fwd)
                    if m and m.group(1) == b"2":
                        b1 = m.group(2)
                    if m and m.group(1) == b"3":
                        sub = m.group(2)
                print("%s:%d  inline F0 record: byte1=%s sub-command=%s"
                      % (f, n + 1, b1.decode(), sub.decode()))


if __name__ == "__main__":
    {"registry": registry, "recordmap": recordmap, "syssenders": syssenders}[sys.argv[1]]()
