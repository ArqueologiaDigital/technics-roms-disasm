#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates src/program.s. Code region 1 is split at the 443 recovered function
# boundaries. Functions named in CONVERT are emitted as REAL MN10300 assembly
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


def insn_len(d, o):
    return ASM  # placeholder (unused; unidasm gives lengths)


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


def emit_function(d, off, end, name):
    """Returns asm source lines for a converted function (byte-exact)."""
    insns = disasm_function(off, end)
    if insns is None:
        return None                       # contains an F4 gap; keep as .incbin
    lines = []
    for addr, b, mnem, ops in insns:
        cpu = BASE + addr
        try:
            enc = ASM.encode(mnem, ops, cpu)
        except ASM.EncError:
            enc = None
        if enc == b:
            lines.append(f"    {mnem:8s}{ops}".rstrip())
        else:
            # keep the exact bytes; annotate with the disassembly for the reader
            hexb = ", ".join(f"0x{x:02X}" for x in b)
            lines.append(f"    .byte {hexb}   # {mnem} {ops}".rstrip())
    return lines


def main():
    d = open(ROM, "rb").read()
    syms = load_syms(d)
    r1 = [s for s in syms if 0x80 <= s[0] < 0x186000]
    pal = [struct.unpack_from("<I", d, 0x32573C + 4 * i)[0] for i in range(512)]

    L = ['# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>',
         '# Licensed under the terms of the GNU General Public License v3 or later',
         '#',
         '# KN7000 "Program" flash image (kn7000_program.rom) - byte-exact.',
         '# Panasonic MN10300, mapped at CPU 0x48400000. Code region 1 is split at',
         '# the 443 recovered functions; functions listed in tools/gen_program_s.py',
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
    if r1[0][0] > 0x80:
        L.append(f".incbin_range {ROMQ}, 0x000080, {r1[0][0]:#08x}")

    converted = 0
    for i, (off, name) in enumerate(r1):
        end = r1[i + 1][0] if i + 1 < len(r1) else 0x186000
        L.append(f"# {name}  (CPU {BASE + off:#010x})")
        block = emit_function(d, off, end, name) if name in CONVERT else None
        if block is not None:
            L.extend(block)
            converted += 1
        else:
            L.append(f".incbin_range {ROMQ}, {off:#08x}, {end:#08x}")

    # data / resources region, with the display palette as typed .long
    L += ['',
          '# ---- data / resources region ----',
          f'.incbin_range {ROMQ}, 0x186000, 0x32573C',
          '',
          '# ---- display palette (256-entry 0x00RRGGBB CLUT + a themed sub-range) ----',
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
