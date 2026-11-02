# IC18 boot ROM probes (notes/ic18-boot-rom.md)

Run from this directory.

| script             | question it answers                                                                                                                   | command                                                                                        |
|--------------------|---------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `digest.py`        | what does each routine of `src/ic18/boot.s` touch: callers, callees, strings, registers, variables?                                   | `python3 -I digest.py ../../src/ic18/boot.s [NAME_SUBSTRING ...]`                              |
| `placeholders.py`  | which labels of `src/ic18/boot.s` are still address placeholders, by kind?                                                            | `python3 -I placeholders.py ../../src/ic18/boot.s [--list bss]`                                |
| `ic18_layout.py`   | what is where in the whole 4 MB: the boot ROM's extent, the rhythm header, its checksum, the version?                                 | `python3 -I ic18_layout.py ~/compartilhado/technics_romsets/kn7000/c3cbnd000046.ic18`          |
| `leftovers.py`     | what in `src/ic18/boot.s` is still a bare number or untyped bytes, and how many LCD registers does `LcdControllerInit` name?          | `python3 -I leftovers.py ../../src/ic18/boot.s`                                                |
| `ic18boot_xref.py` | who reads or writes a RAM address, in the boot ROM and (`ADDR=FWADDR`) in program 941? (exact accesses, plus address loads to review) | `cd ../.. && python3 -I notes/ic18-boot-rom-probes/ic18boot_xref.py 0x500102EF=0x5006BDA3 ...` |

What they printed on 2026-10-24, at the commit that added this README:

    placeholders.py: loc 1734, old_loc 13, OldLink 11; named 1207 of 2965 labels and .equ's
    ic18_layout.py:  boot ROM used up to 0xFA18 (64024 bytes), 63148 bytes are not 0xFF;
                     "Technics Rhythms" checksum word 0xE2DA, recomputed 0xE2DA (equal);
                     byte at 0x1002A = 220; 0x3FFFE8 "jkr_33.ssf"

`leftovers.py`, run against the generated source of the reviewer's fixes (2026-10-24), and in
brackets against the file before them (`git show 49b986be7:kn7000/src/ic18/boot.s`):

    numeric memory operands: 0 uses of 0 addresses              [222 uses of 145 addresses]
    numeric immediates >= 0x20000000 in code: 104 uses of 38 values   [114 of 43]
    uncommented .byte: 193 bytes under 23 labels                [422 bytes under 25 labels]
    LcdControllerInit names 106 distinct LCD controller registers

and `placeholders.py` then: loc 1734, old_loc 13, OldLink 11; named 1334 of 3092 labels and .equ's
(the new hardware .equ's; the address placeholders are unchanged).

The routine and instruction counts quoted in the notes are printed by `tools/gen_ic18_s.py` itself
(`make ic18-src`).

`ic18boot_xref.py` (lane mn10300-names, agent ic18boot, 2026-11-02) is the evidence for the
`kn7000_ic18.sym` comments that say "nothing reads it" or "only written": run against the tree of that
day it printed, for the exact accesses (its `base?` lines were each read by hand and are FIFO
descriptors or the table bases the code indexes below the address):

    0x500102EF=0x5006BDA3  boot: 1 write (PanelLinkInit)        941: 1 write (PanelLinkInit)
    0x500102F6=0x5006BDAA  boot: 1 clear + 3 in PanelTxPump      941: the same 4
    0x500102F2..F4=0x5006BDA6..A8  boot: writes only            941: writes only
    0x50019734=0x50151C00  boot: 10 bset (TickIsr)              941: 10 bset + 8 btst/bclr pairs (0x4C02BBCD)
    0x50019738..44         boot: 1 read each (TickHookPass), no write
    0x50010192             boot: 1 read (SdFlashUpdate), 1 write (SdUpdateStart)
