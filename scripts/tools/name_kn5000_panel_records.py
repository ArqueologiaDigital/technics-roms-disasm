#!/usr/bin/env python3
"""name_kn5000_panel_records.py -- name the KN5000 live panel records (RAM 0xF9A0-0xFFBE) and spell every
operand inside one as RECORD+offset, in v10, v9 and v7.

QUESTION THIS ANSWERS / JOB IT DOES
  The panel work area is a run of TLV records {tag, length, payload} -- the records a .LSW file saves
  (technics-docs panel-parameter-keys.md).  The firmware keeps the RAM address of each record's payload
  in SndParam_BlockRamPtrs (256 longs indexed by tag; ui_widgets/widget_dispatch.s), and the default
  image SndParamRam_DefaultImage (extensions/extension_data.s) holds every record's tag and length.
  This script
    1. reads SndParam_BlockRamPtrs from each tree and requires the three tables to be equal (they are:
       the records sit at the same RAM in v7, v9 and v10, so one set of values serves all three);
    2. walks the default image (the same bytes in the v7, v9 and v10 ROMs) from 0xF9A0 (0xFF bytes between records are padding) and
       requires every table entry to be the payload of a walked record (entries 0xD5 / 0xD6 / 0xD8 alias
       the records of 0xD0 / 0xD3 / 0xD7);
    3. writes shared/ram_panel_records.s in each tree: one `.equ` per record payload, named from the
       record's keys where they are of one kind (PANEL_STYLE: style number, bank, tempo at +8 ...), by the
       mixer's part name for the 26 part records (PANEL_PART_RT1 ...), else by tag (PANEL_REC_44); the
       comment gives tag, payload length and, from the docs' key table, the keys it holds;
    4. rewrites, in every .s of the three trees, the numeric memory operands `(N)` / `(N:8|16|24)` and
       both operands of the ldmm8 / ldmm16 pseudos that fall inside a payload as NAME / NAME+offset, and
       a pointer loaded into an index register (`ld xix, N`) when N is a payload's first byte; 0xF9A0, the
       first record's tag byte, is PANEL_RECORDS.
  A number becomes an expression of the same value: the ROM bytes cannot change (make gate checks).

USAGE
  python3 scripts/tools/name_kn5000_panel_records.py [--dry-run]
"""
import argparse
import collections
import glob
import os
import re
import subprocess
import sys

REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                      text=True).stdout.strip() or "."
TREES = ("v10", "v9", "v7")
OUT = "shared/ram_panel_records.s"
IMAGE_ADDR = 0xEDB3FC          # SndParamRam_DefaultImage, the same in v7 / v9 / v10 (symbols/*.txt)
START, END = 0xF9A0, 0xFFBE

# the 26 part tags, named by the mixer's channel table (panel-parameter-keys.md, "The part namespace")
PARTS = {0x00: "RT1", 0x01: "RT2", 0x02: "LEFT", 0x10: "ACP1", 0x11: "ACP2", 0x12: "ACP3", 0x13: "BASS",
         0x14: "DRUM", 0x15: "CHRD", 0x16: "RTBS", 0x17: "MSP", 0x19: "CTRL"}
PARTS.update({t: "PT%d" % (t + 1) for t in range(0x03, 0x10)})
# records whose keys (panel-parameter-keys.md) are all of one kind get a name; the rest keep their tag
NAMED = {0x43: ("PANEL_MIC", "MIC reverb on/off, mute, volume"),
         0x47: ("PANEL_VOCALIST", "the Vocalist settings (chordal / vocoder ignore, MIDI channel, program, harmony, key sends ...)"),
         0x48: ("PANEL_STYLE", "style number (+0), bank (+1), APC memory / mode (+3), TechniChord on/off (+4), fill-in / ending / synchro break (+5), tempo (+8)"),
         0x61: ("PANEL_DSP_EFFECT", "DSP effect algorithm (+0) and its parameters"),
         0x63: ("PANEL_DIGITAL_REVERB", "digital reverb algorithm (+0) and its parameters"),
         0x64: ("PANEL_EQUALIZER", "equalizer algorithm (+0) and its parameters"),
         0x65: ("PANEL_ACOUSTIC_ILLUSION", "acoustic illusion algorithm (+0) and its parameters"),
         0x66: ("PANEL_MIC_REVERB", "MIC reverb algorithm (+0) and its parameters"),
         0x72: ("PANEL_MSP", "MSP mute / volume (+3), reverb (+7)"),
         0x80: ("PANEL_MIDI", "MIDI settings: common (note only, program change mode / to panel memory), MIDI OUT, realtime clock ... bits 0-1 of +0 = the MIDI mode"),
         0x92: ("PANEL_SCALE_TUNE", "scale tune type (+0), key / on-off (+1), user notes (+2..)"),
         0x93: ("PANEL_TOUCH", "initial touch velocity sense (+0), after touch curve (+5), on/off and threshold (+6)"),
         0x99: ("PANEL_FOOT_CONTROLLERS", "expression pedal (+2), foot switches 1-2 (+4/+5), foot controller switches 1-4 (+6..+9)")}
KEYS = {0x60: "acoustic illusion / equalizer / reverb on/off (+1)", 0x70: "rotary speed, split point (+0/+1), transpose (+2), orchestrator (+3), TechniChord type (+4), fade in / out time (+5/+6)",
        0x90: "conductor (+0), APC on bass / left hold (+3), R1R2 octave (+4)", 0x91: "GM on/off (+3)",
        0x98: "panel memory mode / number (+0/+1), music style arranger (+3), metronome mute / volume (+4), panel memory filter (+7)"}

MEM = re.compile(r'\((0x[0-9a-fA-F]+|\d+)(:8|:16|:24)?\)')
MM = re.compile(r'^(\s*ldmm(?:8|16)\s+)(0x[0-9a-fA-F]+|\d+)(\s*,\s*)(0x[0-9a-fA-F]+|\d+)(\s*)$', re.I)
PTR = re.compile(r'^(\s*ld\s+x(?:ix|iy|iz|hl)\s*,\s*)(0x[0-9a-fA-F]+|\d+)(\s*)$', re.I)


def read(f):
    return open(f, "rb").read().decode("latin-1").split("\n")


def block_ram_ptrs(t):
    f = os.path.join(REPO, t, "maincpu", "ui_widgets", "widget_dispatch.s")
    L = read(f)
    i = next(k for k, l in enumerate(L) if l.startswith("SndParam_BlockRamPtrs:"))
    vals = []
    for l in L[i + 1:]:
        code = l.split(";")[0].strip()
        if code.startswith(".long"):
            vals += [int(x, 0) for x in code[5:].split(",")]
        elif code and not code.endswith(":"):
            break
        if len(vals) >= 256:
            break
    assert len(vals) == 256, (t, len(vals))
    return vals


def walk_image():
    imgs = []
    for t in TREES:
        rom = open(os.path.join(REPO, "original_ROMs", "kn5000_%s_program.rom" % t), "rb").read()
        imgs.append(rom[IMAGE_ADDR - 0xE00000:IMAGE_ADDR - 0xE00000 + (END - START) + 64])
    assert imgs[0] == imgs[1] == imgs[2], "the default panel image differs between versions"
    img = imgs[0]
    recs, i = [], 0
    while START + i < END:
        if img[i] == 0xFF:
            i += 1
            continue
        tag, n = img[i], img[i + 1]
        recs.append((tag, START + i + 2, n))
        i += 2 + n
    return recs


def records():
    ptrs = [block_ram_ptrs(t) for t in TREES]
    assert ptrs[0] == ptrs[1] == ptrs[2], "SndParam_BlockRamPtrs differs between trees"
    recs = walk_image()
    byaddr = {p: (t, n) for t, p, n in recs}
    for tag, p in enumerate(ptrs[0]):
        if p:
            assert p in byaddr, "tag 0x%02x -> 0x%x is no record payload" % (tag, p)
    out = []
    for t, p, n in recs:
        assert ptrs[0][t] == p, "record 0x%02x at 0x%x is not the table's 0x%x" % (t, p, ptrs[0][t])
        if t in PARTS:
            name, what = "PANEL_PART_%s" % PARTS[t], "part record (mixer channel %s)" % PARTS[t]
        elif t == 0x18:
            name, what = "PANEL_PART_18", "part record of tag 0x18 (no mixer channel)"
        elif t in NAMED:
            name, what = NAMED[t]
        else:
            name, what = "PANEL_REC_%02X" % t, KEYS.get(t, "keys not identified")
        out.append((name, t, p, n, what))
    return out


AREA = ("PANEL_RECORDS", START, "the first record's tag byte: the start of the record run the panel-memory "
        "copies move (Mem_Copy of 960 bytes from here to the recall backup PANEL_RECALL_BACKUP)")


def write_defs(recs):
    hdr = ["; ram_panel_records.s -- the live panel records, RAM 0xF9A0-0xFFBE: TLV records {tag, length, payload},",
           "; the ones a .LSW file saves (technics-docs panel-parameter-keys.md).  Each name is a record's payload,",
           "; as SndParam_BlockRamPtrs (ui_widgets/widget_dispatch.s) holds it per tag; tags and lengths are the",
           "; default image's (SndParamRam_DefaultImage).  The table is the same in v7, v9 and v10, so are these",
           "; values.  An operand inside a record is spelled NAME+offset.  Generated by",
           "; scripts/tools/name_kn5000_panel_records.py."]
    width = max(8 + 5 + len(r[0]) + 1 for r in recs + [AREA]) // 8 * 8 + 8
    body = []
    cur = 8 + 5 + len(AREA[0]) + 1
    body.append("\t.equ %s,%s0x%04x\t; %s" % (AREA[0], "\t" * (1 + (width - (cur // 8 + 1) * 8) // 8), AREA[1], AREA[2]))
    for name, t, p, n, what in recs:
        cur = 8 + 5 + len(name) + 1
        tabs = 1 + (width - (cur // 8 + 1) * 8) // 8
        body.append("\t.equ %s,%s0x%04x\t; tag 0x%02x, %d bytes: %s" % (name, "\t" * tabs, p, t, n, what))
    text = "\n".join(hdr + body + [""])
    for t in TREES:
        open(os.path.join(REPO, t, "maincpu", OUT), "wb").write(text.encode("latin-1"))
        rv = os.path.join(REPO, t, "maincpu", "shared", "ram_variables.s")
        L = read(rv)
        inc = '\t.include "shared/ram_panel_records.s"'
        if inc not in L:
            while L and L[-1] == "":
                L.pop()
            L += ["; the live panel records (TLV payloads), named from SndParam_BlockRamPtrs", inc, ""]
            open(rv, "wb").write("\n".join(L).encode("latin-1"))


def rewrite(t, recs, apply):
    spans = [(p, p + n, name) for name, _, p, n, _ in recs]
    base = {s: nm for s, e, nm in spans}
    base[AREA[1]] = AREA[0]

    def spell(v):
        if v == AREA[1]:
            return AREA[0]
        for s, e, name in spans:
            if s <= v < e:
                return name if v == s else "%s+%d" % (name, v - s)
        return None

    st = collections.Counter()
    for f in sorted(glob.glob(os.path.join(REPO, t, "maincpu", "**", "*.s"), recursive=True)):
        if f.endswith(OUT):
            continue
        L = read(f)
        ch = False
        for i, l in enumerate(L):
            code, sep, cmt = l.partition(";")
            s = code.strip()
            if not s or s.startswith(".") or re.match(r'^[A-Za-z_][\w$]*:\s*$', s):
                continue

            def mem(m):
                x = spell(int(m.group(1), 0))
                if x:
                    st["memory operands"] += 1
                    return "(%s%s)" % (x, m.group(2) or "")
                return m.group(0)

            new = MEM.sub(mem, code)
            q = MM.match(new)
            if q:
                a, b = spell(int(q.group(2), 0)), spell(int(q.group(4), 0))
                st["ldmm operands"] += bool(a) + bool(b)
                new = q.group(1) + (a or q.group(2)) + q.group(3) + (b or q.group(4)) + q.group(5)
            p = PTR.match(new)
            if p and int(p.group(2), 0) in base:
                st["pointer loads"] += 1
                new = p.group(1) + base[int(p.group(2), 0)] + p.group(3)
            if new != code:
                L[i] = new + sep + cmt
                ch = True
        if ch and apply:
            open(f, "wb").write("\n".join(L).encode("latin-1"))
    return st


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    recs = records()
    print("%d records, 0x%x-0x%x" % (len(recs), recs[0][2], recs[-1][2] + recs[-1][3]))
    if not a.dry_run:
        write_defs(recs)
    for t in TREES:
        print("%s: %s%s" % (t, dict(rewrite(t, recs, not a.dry_run)), " (dry run)" if a.dry_run else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
