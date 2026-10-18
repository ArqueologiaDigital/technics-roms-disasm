# Probes behind annotations/gfx_bmpfile.ann

Two scripts the annotators and reviewers used to check claims in
`annotations/gfx_bmpfile.ann` (record of the review: `notes/gfx-bmpfile-review.md`).
Run both from the repository root.

| script         | question it answers                                                                 |
|----------------|-------------------------------------------------------------------------------------|
| `refs.py`      | Which instructions call, `calls`, jump or branch into a CPU range, and which 32-bit words point into it? |
| `sim_parse.py` | What do the ROM's own GetBitmapInfo and BmpUnpackRow do with good and malformed BMPs? |

## refs.py

    python3 notes/gfx-bmpfile-probes/refs.py baserom/kn7000_program.rom 0x48421DE1 0x48421E88

It decodes, at every byte offset of the image, the PC-relative `jmp`/`call`/`calls`
(d16 and d32 forms) and the 8-bit branches, and reports each one that lands in
`[LO, HI)` from outside it, plus every little-endian 32-bit word whose value lies
in the range. The library is mapped at file offset 0x3B8FD1 = CPU 0x4C000000.
Byte-level brute force over-reports; check each hit against a listing.

Expected for GetBitmapInfo (0x48421DE1..0x48421E88), as of 2026-10-18 on build
941: 13 calls to GetBitmapInfo_entry 0x48421DE6 -- from 0x484188EB, 0x48418EE9,
0x48421EB7, 0x48422188, 0x48424B2B, 0x48424D54, 0x4842832B, 0x48495937,
0x48497172, 0x485805E3, 0x485813AE, 0x48581676 and 0x485816E1 -- and one word,
the MILK reflection-table entry at 0x48727704. For Draw2BpFile
(0x4842829F..0x484284B4): the call at 0x4848878D (DbBitmapLoadProc), the
table word at 0x4872771C, and the word 0x484282E7 inside Draw2BpFile itself
(0x484282CB); 0x484284B5 and 0x48428955 are false positives.

## sim_parse.py

    python3 notes/gfx-bmpfile-probes/sim_parse.py

It runs the real ROM instructions of GetBitmapInfo (0x48421DE1) and
BmpUnpackRow (0x48422016) in `tools/mn10300_sim.py` on 21 + 6 hand-built inputs
and prints, per case, GetBitmapInfo's return value (d0), the 16-byte file-header
struct it filled, whether the 40-byte info header was copied, how many colour
bytes it copied and the pixel offset it returned, and BmpUnpackRow's output row
(0xEE marks bytes it did not write) with the Malloc/memcpy/Free calls it made.
Library calls (memcpy 0x4C003039, LibStrncmp 0x4C00203C, LibDiv32 0x4C0019D5) and
Malloc/Free are modelled in Python, and the script models `call`/`ret`/`retf`
itself (see the note on tools/mn10300_sim.py below). Results on 2026-10-18:

- only "BM" passes: "BA", "B\0" and "\0\0" all return 0 (LibStrncmp compares
  before it tests for NUL);
- biSize 12, 2 planes, 2 or 24 bpp, biClrUsed 257 and compression 1 return 0;
  1, 4 and 8 bpp with biClrUsed up to 256 return 1;
- the colour copy is (s16)(bfOffBits - 54) bytes when that is 0..0x400, else 0x400:
  bfOffBits 50 copies 0x400, 54 + 0x8000 copies 0x400, 54 + 0x10008 copies 8;
- width 0 and a top-down height of -2 are accepted;
- BmpUnpackRow: 4 bpp `12 34` -> `01 02 03 04`; 1 bpp `A5 81` ->
  `01 00 01 00 00 01 00 01 01 00 00 00 00 00 00 01`; 8 bpp and other depths leave
  the row unchanged; it Mallocs count*8/bpp bytes.

The annotator reported that `tools/mn10300_sim.py` returns from a 5-byte `cd` or
7-byte `dd` call to pc+4 / pc+6, one byte short; sim_parse.py works around it.
That report has not been checked against the simulator yet.
