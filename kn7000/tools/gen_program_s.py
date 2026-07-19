#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates src/program.s. Code region 1 is split at the recovered function
# boundaries (kn7000.sym reflection names + kn7000_manual.sym hand-recovered
# names). Functions named in CONVERT are emitted as REAL MN10300 assembly
# (via MAME unidasm for the mnemonics, verified byte-exact with the mn10300_asm
# encoder); every other function stays a raw .incbin_range block. Instructions
# the encoder can't reproduce (a handful of compiler non-minimal encodings and
# udf* coprocessor ops) fall back to a .byte escape, so the rebuild is always
# byte-identical.  Run:  make program-src   (or python3 tools/gen_program_s.py)

import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as ASM

BASE = 0x48400000
ROM = "baserom/kn7000_program.rom"
SYM = "kn7000.sym"
MANUAL_SYM = "kn7000_manual.sym"
UNIDASM = os.environ.get("UNIDASM", "../mame-sony-video/unidasm")
OUT = "src/program.s"

# Functions to emit as real assembly this pass (verified clusters). Growing this
# set converts more of the ROM from opaque .incbin into understood source.
CONVERT = {
    # task control
    "SleepMainTask", "WakeUpMainTask", "SleepApTask", "WakeUpApTask",
    "RefreshApTask", "RefreshSwEvent",
    # event queue / dispatch
    "InitializeEventQueue", "DispatchEvent", "SendEvent", "PostEvent",
    "DeleteSpecificEvent", "GetEvent", "GetCurrentTarget", "GetRootEvent",
    "SetFocusParam", "SetAutoInc", "KillApTimer", "GetRootObject",
    # object / view property accessors (these call the hot framework helper
    # GetLinkView, so the converted code shows readable named calls)
    "SetVisible", "SetMovable", "SetChange", "SetConst", "GetJpegSize",
    "ConvPaletteMono4", "VwEditSwLabelProc", "ScreenProc", "CaptureLcd",
    "DrawDesignBox", "PsUsrBmpToggleProc", "MusicStylistJpgData",
    "SetNeedUpdate", "SetDialFocus", "GetFrameSPSize", "GetCharHeight",
    "GetBitmapSize", "GetCharDescent", "CheckColorLcd", "SetLcdMode",
    # display / LCD / bitmap-resource accessor module
    "Check2BitLcd", "GetColorMode", "GetSoundDev", "GetBitmapCount",
    "GetIconCount", "GetFrameCount", "GetFontCount", "GetBitmapNameTable",
    "GetIconNameTable", "GetFrameNameTable", "GetSw2Mode", "GetMode2Sw",
    "GetModeNow", "GetTitleNow", "GetTitleOld", "GetViewInstance",
    "SetCurrentTarget", "SetBox", "SetDialEnable", "SetDialUp",
    "CheckProgDial", "SetProgDial", "GetColorMode", "SetHoldLed",
    "SetOtherPartLed", "GetRootParam", "SetRootParam", "CheckNotDrawFlag",
    "GetSw2Mode", "SetAutoIncDefault",
    # Techni-Chord harmony engine (kn7000_manual.sym names; RE'd in kn5000-docs
    # /kn7000-technichord/ + the users manual, corrected style mapping -- the
    # style param 0x8081 is a legacy order mapped to the GUI grid by the
    # 14-halfword table 0x485EC940; DUET 1 is stored last, param 13)
    "TechniChordOrchestratorPart", "TechniChordCompute",
    "TechniChordClose", "TechniChordDuet1", "TechniChordOpen1",
    "TechniChordOpen2", "TechniChordDuet2", "TechniChordCountry",
    "TechniChordTheatre", "TechniChordHymn", "TechniChordBlock",
    "TechniChordBigBandBrass", "TechniChordBigBandReeds", "TechniChordOctave",
    "TechniChordHardRock", "TechniChordFanfare", "TechniChordOff",
    "TechniChordAugDimFold",
}

# A converted function whose named block extends past its real end (because the
# next named boundary is far away) can cap the converted range here; the
# remainder of the block stays raw .incbin_range.
FUNC_END = {
    "TechniChordAugDimFold": 0x737D2,   # next (unnamed) function at 0x484737D2
}

# Reverse-engineering facts emitted as comments under the function headers.
# Sources: kn5000-docs /kn7000-technichord/, the KN7000 users manual (p.48),
# and the disassembly itself (matrix bases/strides, the 0x485EC940 param map).
FUNC_DOC = {
    "TechniChordOrchestratorPart": [
        "returns d0 = the part that sounds the harmony notes: param 0x8082",
        "(0xFF = auto -> part 0x10 or 0x11 by lib part-mask), then rejects the",
        "part (-1) when part-check param 0xB0007E[part<<24] == 1",
    ],
    "TechniChordCompute": [
        "the Techni-Chord harmony engine (pure software -- no TG registers):",
        " 1. GetCurrentChord copies {type, root, ...} from RAM 0x50000B18",
        " 2. chord-type normalise via jump table 0x485BC3EC (types 29..41 are",
        "    remapped to a basic type so the 28-row voicing matrices suffice)",
        " 3. gate on param 0x8080 == 1 (techni-chord ON), then dispatch the",
        "    voicing via the 14-entry jump table 0x485BC3B4 indexed by style",
        "    param 0x8081 (LEGACY order: the GUI grid maps through 0x485EC940;",
        "    param 13 = grid slot 3 = DUET 1, appended after FANFARE)",
        " 4. tail: fill each emitted note entry's flag byte from struct+0x27",
        "struct (a0): +0x26 melody note, +0x27 melody flag, +4 note count,",
        "+6 the 2-byte harmony note entries",
    ],
    "TechniChordClose": [
        "style CLOSE (param 0, and the base for OPEN 1/2 + DUET 1): fetch the",
        "chord-tone list (max 0x10), fold each tone by octaves into the octave",
        "below the melody, keep tones more than 2 semitones below it, max 4",
    ],
    "TechniChordDuet1": [
        "DUET 1 (param 13 = grid slot 3; the style Technics appended to the",
        "legacy 13-style enumeration): CLOSE voicing clamped to 1 note",
    ],
    "TechniChordOpen1": [
        "OPEN 1 (param 1): CLOSE, then drop the first harmony note an octave",
    ],
    "TechniChordOpen2": [
        "OPEN 2 (param 2): CLOSE re-spread by octave shifts (single close note",
        "raised above the melody; multi-note: first down, close followers up)",
    ],
    "TechniChordDuet2": [
        "DUET 2 (param 3 -- the ORIGINAL 'DUET' slot): one harmony note =",
        "melody - matrix[type][interval], matrix 0x485BA574 (28 rows x 12);",
        "interval = (melody - root + AugDimFold + 1) mod 12",
    ],
    "TechniChordCountry": [
        "COUNTRY (param 4): one note; matrix 0x485BAEA4 (28 x 12 x 1)",
    ],
    "TechniChordTheatre": [
        "THEATRE (param 5): two notes; matrix 0x485BA6C4 (28 x 12 x 2)",
    ],
    "TechniChordHymn": [
        "HYMN (param 6): three notes = four-part writing incl. the melody;",
        "matrix 0x485BAFF4 (28 x 12 x 3)",
    ],
    "TechniChordBlock": [
        "BLOCK (param 7): four notes; matrix 0x485BA964 (28 x 12 x 4)",
    ],
    "TechniChordBigBandBrass": [
        "BIG BAND BRASS (param 8): three notes; matrix 0x485BB3E4 (28 x 12 x 3)",
    ],
    "TechniChordBigBandReeds": [
        "BIG BAND REEDS (param 9): four notes; matrix 0x485BBE64 (28 x 12 x 4)",
        "-- 'big band reeds which adds four harmony notes' (users manual)",
    ],
    "TechniChordOctave": [
        "OCTAVE (param 10): fixed melody+12 & melody-12 (pair 0x485BC3A4);",
        "chord-independent -- works even unsplit (users manual)",
    ],
    "TechniChordHardRock": [
        "HARDROCK (param 11): fixed melody-5 & melody-12 (pair 0x485BC3A6,",
        "fourth + octave below = power chords); chord-independent",
    ],
    "TechniChordFanfare": [
        "FANFARE (param 12): fixed melody+10 & melody+5 (pair 0x485BC3A8,",
        "stacked fourths above the melody); chord-independent",
    ],
    "TechniChordOff": [
        "techni-chord off / style out of range: harmony note count = 0",
    ],
    "TechniChordAugDimFold": [
        "(d0 = chord type, d1 = root 1..12) -> root-fold offset for the",
        "symmetric chord types: type 4 in buckets of 4 semitones (0/4/8),",
        "type 7 in buckets of 3 (0/3/6/9); 0 otherwise, -1 for type 0 (no",
        "chord). Makes enharmonically identical aug/dim chords share one set",
        "of matrix columns in the 7 matrix voicing styles",
    ],
}

INSN = re.compile(r"([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2} )+)\s+(\S+)\s*(.*)")


def load_syms(data):
    syms = []
    for line in open(SYM):
        m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
        if m and not line.startswith(";"):
            a = int(m.group(1), 16)
            if a >= BASE:
                syms.append((a - BASE, m.group(2)))
    return sorted(syms)


def load_manual_syms():
    """Hand-recovered names from kn7000_manual.sym (uncommented entries only).
    Names ending in `_entry` mark the MN10300 register-save-`call` entry a few
    bytes after a function's movm prologue: they become equates + in-code
    comment markers, but NOT function-split boundaries."""
    syms = []
    for line in open(MANUAL_SYM):
        if line.lstrip().startswith(";"):
            continue
        m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
        if m:
            syms.append((int(m.group(1), 16), m.group(2)))
    return syms


def discover_functions(d):
    """Every `call`/`calls` target in code region 1 is a function entry point.
    (On the MN10300 the call instruction itself saves the register list, so a
    callee does not begin with a uniform prologue -- it starts straight into its
    work -- which is why we key on *being called* rather than on a byte pattern.)
    These give the internal helpers the reflection tables don't name a synthetic
    `func_<ADDR>` label, so converted code shows named calls everywhere. `jmp`
    targets are excluded here (they can be intra-function), but a jmp that lands
    on one of these entries is still resolved by name_target."""
    out = subprocess.run(
        [UNIDASM, ROM, "-arch", "mn10300", "-basepc", f"0x{BASE + 0x80:x}",
         "-skip", "0x80", "-count", str(0x186000 - 0x80)],
        capture_output=True, text=True).stdout
    entries = set()
    for line in out.splitlines():
        m = re.match(r"[0-9a-f]+:\s+(?:[0-9a-f]{2} )+\s+calls?\s+0x([0-9a-f]+)", line)
        if m:
            t = int(m.group(1), 16)
            if BASE + 0x80 <= t < BASE + 0x186000:
                entries.add(t)
    return entries


def disasm_function(off, end):
    """Returns list of (file_off, bytes, mnem, ops) using unidasm; None on F4 gap."""
    cpu = BASE + off
    out = subprocess.run(
        [UNIDASM, ROM, "-arch", "mn10300", "-basepc", f"0x{cpu:x}",
         "-skip", f"0x{off:x}", "-count", str(end - off)],
        capture_output=True, text=True).stdout
    insns = []
    cur = off
    for line in out.splitlines():
        m = INSN.match(line)
        if not m:
            continue
        addr = int(m.group(1), 16) - BASE
        b = bytes.fromhex(m.group(2).replace(" ", ""))
        if addr != cur:          # misalignment (unidasm F4 length bug) -> bail
            return None
        insns.append((addr, b, m.group(3), m.group(4).strip()))
        cur += len(b)
        if cur >= end:
            break
    return insns if cur == end else None


# control-transfer mnemonics whose first operand is an absolute CPU target we
# can rewrite to a symbol name (only when it lands exactly on a named function).
CALL_MNEMS = {"call", "calls", "jmp"}


def name_target(ops, names, used):
    """Rewrite `call 0x48429388, ...` -> `call DispatchEvent, ...` when the
    target is a known function (semantic name or synthetic func_<ADDR>). Records
    the name in `used` so its equate can be emitted. Branch targets stay numeric."""
    m = re.match(r"(0x[0-9a-fA-F]+)(.*)", ops)
    if not m:
        return ops
    addr = int(m.group(1), 16)
    if addr in names:
        used.add(addr)
        return names[addr] + m.group(2)
    return ops


def emit_function(d, off, end, name, names, used):
    """Returns asm source lines for a converted function (byte-exact)."""
    insns = disasm_function(off, end)
    if insns is None:
        return None                       # contains an F4 gap; keep as .incbin
    lines = []
    for addr, b, mnem, ops in insns:
        cpu = BASE + addr
        if addr != off and cpu in names and names[cpu].endswith("_entry"):
            # register-save-`call` entry point (the caller's reg list + frame
            # size perform the prologue); referenced by name at the call sites
            lines.append(f"# {names[cpu]}:   (register-save `call` entry)")
            used.add(cpu)
        try:
            enc = ASM.encode(mnem, ops, cpu)
        except ASM.EncError:
            enc = None
        if enc == b:
            if mnem in CALL_MNEMS:
                ops = name_target(ops, names, used)
            lines.append(f"    {mnem:8s}{ops}".rstrip())
        else:
            # keep the exact bytes; annotate with the disassembly for the reader
            hexb = ", ".join(f"0x{x:02X}" for x in b)
            lines.append(f"    .byte {hexb}   # {mnem} {ops}".rstrip())
    return lines


def main():
    d = open(ROM, "rb").read()
    syms = load_syms(d)
    manual = load_manual_syms()
    r1 = [s for s in syms if 0x80 <= s[0] < 0x186000]
    # manual function starts inside code region 1 become split boundaries too
    # (the `_entry` register-save entries deliberately do not)
    known = {off for off, _ in r1}
    for a, nm in manual:
        off = a - BASE
        if 0x80 <= off < 0x186000 and off not in known \
                and not nm.endswith("_entry"):
            r1.append((off, nm))
            known.add(off)
    r1.sort()
    sym_by_addr = {BASE + off: nm for off, nm in syms}
    pal = [struct.unpack_from("<I", d, 0x32573C + 4 * i)[0] for i in range(512)]

    # Full name map: reflection-table names + manual names + synthetic
    # func_<ADDR> for the internal helpers neither covers, so every call in
    # converted code resolves to a label. `used` records which get referenced
    # (to emit equates; manual names are not in symbols.inc, so they are
    # equated here when used).
    names = dict(sym_by_addr)
    names.update({a: nm for a, nm in manual})
    for a in discover_functions(d):
        names.setdefault(a, f"func_{a:08X}")
    used = set()

    L = ['# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>',
         '# Licensed under the terms of the GNU General Public License v3 or later',
         '#',
         '# KN7000 "Program" flash image (kn7000_program.rom) - byte-exact.',
         '# Panasonic MN10300, mapped at CPU 0x48400000. Code region 1 is split at',
         '# the recovered functions (kn7000.sym + kn7000_manual.sym); functions',
         '# listed in tools/gen_program_s.py',
         '# CONVERT are emitted as real MN10300 assembly (verified byte-exact by the',
         '# mn10300_asm encoder), the rest remain raw .incbin_range. Regenerate with',
         '# tools/gen_program_s.py. make verify guarantees byte-identity.',
         '',
         '.equ PROGRAM_ROM_BASE, 0x48400000',
         '.mnbase 0x48400000   # CPU address of output offset 0 (for PC-relative ops)',
         '.include "src/symbols.inc"',
         '',
         '# ---- boot header (0x0..0x80) ----',
         '_reset:',
         '    .byte 0xDC, 0x7E, 0xFF, 0x00, 0x00      # jmp  0x4840FF7E   (reset entry)',
         '    .byte 0xCB, 0xCB, 0xCB, 0xCB, 0xCB      # nop x5',
         '_vector_0a:',
         '    .byte 0xDC, 0xC5, 0x77, 0x0D, 0x00      # jmp  0x484D77CF',
         '_rom_marker:',
         '    .byte 0x16                              # ROM-present marker (cmp vs 0xFF)',
         '    .space 0x80 - 0x10, 0xFF',
         '    .org 0x000080',
         '',
         '# ============================================================================',
         '# Code region 1 -- organised by recovered function.',
         '# ============================================================================']

    ROMQ = '"baserom/kn7000_program.rom"'
    body = []
    if r1[0][0] > 0x80:
        body.append(f".incbin_range {ROMQ}, 0x000080, {r1[0][0]:#08x}")

    converted = 0
    for i, (off, name) in enumerate(r1):
        end = r1[i + 1][0] if i + 1 < len(r1) else 0x186000
        body.append(f"# {name}  (CPU {BASE + off:#010x})")
        for doc in FUNC_DOC.get(name, ()):
            body.append(f"#   {doc}")
        end_conv = min(end, FUNC_END.get(name, end))
        block = emit_function(d, off, end_conv, name, names, used) if name in CONVERT else None
        if block is not None:
            body.extend(block)
            converted += 1
            if end_conv < end:
                body.append(f"# (unnamed code follows to the next boundary)")
                body.append(f".incbin_range {ROMQ}, {end_conv:#08x}, {end:#08x}")
        else:
            body.append(f".incbin_range {ROMQ}, {off:#08x}, {end:#08x}")

    # equates for the synthetic helper labels actually referenced by converted code
    auto = sorted(a for a in used if a not in sym_by_addr)
    if auto:
        L.append(f"# {len(auto)} synthetic labels for internal helpers called by "
                 "converted code")
        for a in auto:
            L.append(f".equ {names[a]}, 0x{a:08X}")
        L.append("")
    L.extend(body)

    # data / resources region, with the display palette as typed .long
    L += ['',
          '# ---- data / resources region ----',
          f'.incbin_range {ROMQ}, 0x186000, 0x32573C',
          '',
          '# ---- display palette (256-entry 0x00BBGGRR CLUT + a themed sub-range) ----',
          'display_palette:']
    for i in range(0, 512, 8):
        row = ", ".join(f"0x{v:08X}" for v in pal[i:i + 8])
        L.append(f"    .long {row}   # idx {i:3d}")
    L += ['.org 0x325F3C',
          f'.incbin_range {ROMQ}, 0x32573C + 0x800, 0x3B8000',
          '',
          '# ---- code region 2 (MILK MN10300 kernel + zlib 1.0.4) ----',
          f'.incbin_range {ROMQ}, 0x3B8000, 0x3F6F01',
          '',
          '.org 0x3F6F01   # end of image']

    open(OUT, "w").write("\n".join(L) + "\n")
    print(f"wrote {OUT}: {converted}/{len(CONVERT)} requested functions converted to asm")


if __name__ == "__main__":
    main()
