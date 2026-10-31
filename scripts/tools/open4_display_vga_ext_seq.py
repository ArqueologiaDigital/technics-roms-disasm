#!/usr/bin/env python3
"""Lane open4/kn5000-b-display (2026-10-31, kn5000-ezo): the MN89304 extended-sequencer code in
<tree>/maincpu/display/graphics_text_vga.s, every main-CPU tree (v10, v9, v7, v6, v5).

* VGA_WritePalette256_Unterminated (ex VGA_CRTCTiming_ByteData) gets a header: it is a palette
  loader whose `jr VGA_WritePalette256_Loop` is unconditional, so it never returns.
* The bytes after that `jr` (v10 0xFB3264) are a routine of their own, the first of three
  extended-sequencer tables; it gets the label VGA_ConfigExtSequencer_AltA and a header, and its
  open-coded `ldw wa, 964` / `ld(w) bc, N` / `calr _Write_VGA_Register` triples are respelled
  with the file's _VGA_SEQUENCER macro, which expands to the same instructions (`ld bc, N:i3`
  for N <= 7, `ldw bc, N` above; the script refuses a triple that would not).
* VGA_ConfigExtSequencer and VGA_ConfigExtSequencer_AltB (ex _Alt; its comment was
  "who calls here?") get headers.
Bytes are unchanged (make gate).  Files are read and written as bytes.  Idempotent.

    python3 scripts/tools/open4_display_vga_ext_seq.py
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ('v10', 'v9', 'v7', 'v6', 'v5')

HDR_PAL = (b"; Unreferenced (no call, jump or pointer reaches it in any tree).  Writes palette entries from\n"
           b"; the 4-byte {r, g, b, -} records at XWA through VGA_WritePaletteEntry, entry index in QIZH\n"
           b"; (bank register 251) counting from 0; the closing `jr` is unconditional, so after entry 255\n"
           b"; the index wraps and the loop never ends -- most probably a C `for (u8 i = 0; i < 256; i++)`.\n")
HDR_A = (b"; The first of three MN89304 extended-sequencer setups (with VGA_ConfigExtSequencer, which\n"
         b"; VGA_Initialize calls, and VGA_ConfigExtSequencer_AltB): seq 0x06 = 0x01 opens the extension\n"
         b"; registers, then for each index written to seq 0x09 the data registers seq 0x0a / 0x0b / 0x0c\n"
         b"; get one value each (even indices 0x00-0x10 all three, odd indices 0x01-0x11 only 0x0c), and\n"
         b"; seq 0x06 = 0x00 closes them (tail call).  Unreferenced; it starts right after the endless loop\n"
         b"; of VGA_WritePalette256_Unterminated.  Values differ from VGA_ConfigExtSequencer's in 19 places;\n"
         b"; their meaning is unknown (no MN89304 datasheet).  Table: notes/open4-kn5000-b/display/README.md.\n")
HDR_MAIN = (b"; MN89304 extended-sequencer setup, the one in use: VGA_Initialize calls it after the palette.\n"
            b"; Same values as the boot ROM code's VGA_Extended_Init (shared/vga_init.s).  Layout as in\n"
            b"; VGA_ConfigExtSequencer_AltA: seq 0x06 = 1 opens, seq 0x09 selects, seq 0x0a-0x0c take data,\n"
            b"; seq 0x06 = 0 closes.\n")
HDR_B = (b"; The third extended-sequencer setup; unreferenced.  Its seq 0x09 = 0x04 entry writes seq 0x0b\n"
         b"; twice (0x21, then 0x24 straight to the data port); otherwise laid out like the other two.\n")

TRIPLE = re.compile(rb"\tldw\twa, (964|965)\n\t(ld\tbc, (\d+):i3|ldw\tbc, (\d+))\n\tcalr\t_Write_VGA_Register\n")


def respell(block):
    out, pos, pend = [], 0, None
    for m in TRIPLE.finditer(block):
        if m.start() != pos:
            sys.exit('unexpected text in the AltA block at %r' % block[pos:m.start()][:60])
        pos = m.end()
        port = int(m.group(1))
        v = int(m.group(3) or m.group(4))
        if (m.group(3) is not None) != (v <= 7):
            sys.exit('a triple the macro would not reproduce: %r' % m.group(0))
        if port == 964:
            if pend is not None:
                sys.exit('two index writes in a row')
            pend = v
        else:
            if pend is None:
                sys.exit('a data write without an index')
            out.append(b"\t_VGA_SEQUENCER 0x%x, 0x%x\n" % (pend, v))
            pend = None
    return b"".join(out), block[pos:], pend


def fix(data):
    if b"VGA_ConfigExtSequencer_AltA:" in data:
        return data
    head = b"VGA_WritePalette256_Unterminated:\n"
    i = data.index(head)
    data = data[:i] + HDR_PAL + data[i:]
    loop_end = b"\tjr VGA_WritePalette256_Loop\n"
    a = data.index(loop_end, i) + len(loop_end)
    b = data.index(b"\nVGA_ConfigExtSequencer:\n", a)
    body, rest, pend = respell(data[a:b])
    # the tail: index 6 written, then `ldw wa, 965 / ld bc, 0:i3 / jrl _Write_VGA_Register`
    if pend != 6 or rest != b"\tldw\twa, 965\n\tld\tbc, 0:i3\n\tjrl\t_Write_VGA_Register\n":
        sys.exit('unexpected tail %r' % rest)
    tail = (b"\t; For byte-matching purposes:\n\t; This is equivalent to:\n\t;\n"
            b"\t; _VGA_SEQUENCER 06h, 000h\n\t; RET\n\t;\n"
            b"\t_VGA_WRITE 0x3c4, 0x6\n\tldw wa, 0x3c5\n\tld bc, 0:i3\n\tjrl _Write_VGA_Register\n")
    data = data[:a] + b"\n" + HDR_A + b"VGA_ConfigExtSequencer_AltA:\n" + body + tail + data[b:]
    data = data.replace(b"\nVGA_ConfigExtSequencer:\n", b"\n" + HDR_MAIN + b"VGA_ConfigExtSequencer:\n", 1)
    old_b = b"; who calls here?\nVGA_ConfigExtSequencer_AltB:\n"
    if old_b not in data:
        sys.exit('AltB anchor not found')
    data = data.replace(old_b, HDR_B + b"VGA_ConfigExtSequencer_AltB:\n", 1)
    return data


for t in TREES:
    p = os.path.join(ROOT, t, 'maincpu', 'display', 'graphics_text_vga.s')
    d = open(p, 'rb').read()
    n = fix(d)
    if n != d:
        open(p, 'wb').write(n)
    print(('patched ' if n != d else 'unchanged ') + os.path.relpath(p, ROOT))
