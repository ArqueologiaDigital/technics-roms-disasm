# Probes behind notes/work-ram-map.md

Each script answers one question the note relies on. Run the Python ones from the
repository root; the Lua ones are MAME autoboot scripts (MAME build and ROM set as in
`kn7000_mame/INTEGRATION.md`).

| script              | question it answers                                                                                    |
|---------------------|--------------------------------------------------------------------------------------------------------|
| `decode_all.py`     | Linear decode of the program ROM's code regions (input for `scan_ramrefs.py`).                         |
| `scan_ramrefs.py`   | Which work-RAM addresses does the firmware touch, from which functions, and how (the reference sweep)? |
| `rom_facts.py`      | What do the data words the map rests on hold (.data image, RTOS config, reset-time clear loops)?       |
| `limit_arith.py`    | Which explanations of the 0x4D800 picture-import limit fit, and with how much slack?                   |
| `bmp_sizes.py`      | Which BMP files fit the 0x18000 debug read and the 0x4D800 import limit?                               |
| `arena_verify.lua`  | At runtime, which address does the zlib-arena allocator return right after a reset?                    |
| `gap_write_tap.lua` | Does anything write 0x50298000..0x502B7FFF during boot, and what is in the main pool header?           |
| `gapwatch2.lua`     | Which code writes the RAM spans no instruction references (ignoring the reset clears)?                 |

## Commands and expected results (build 941, 2026-10-18)

    python3 notes/work-ram-map-probes/decode_all.py $TMPDIR/decode.tsv
    python3 notes/work-ram-map-probes/scan_ramrefs.py $TMPDIR/decode.tsv $TMPDIR/ramrefs-out

`scan_ramrefs.py` also reads `$TMPDIR/kn7000-drawbitmap/entries.txt`, the call-target
cache that `dump_range.py` writes (research-scratch); its outputs are listed in its
docstring. The two independent censuses of 0x50000000..0x502B8000 found 4130 and 4129
distinct addresses, differing only at 0x5004AD64.

    python3 notes/work-ram-map-probes/rom_facts.py

prints, among others: Malloc control 0x500006E0 = [0x50022004, 0x8000, 0]; .data word
0x500058B8 = 0x502B8000; RTOS config 0x487B8B44.. = [0x50380000, 0x50387FFF,
0x50388000, 0x503BBFFF, ...]; the reset clears 0x50007F44..0x50180000 and
0x50298000..0x50400000 (941; 942 starts the first at 0x50007F54).

    python3 notes/work-ram-map-probes/limit_arith.py

prints 0x4D800 = 317,440 bytes = 310 KiB = 640 x 496; a 640x480 8-bpp BMP = 308,278
bytes (fits, 9,162 spare); file + RGB crop buffer = 0xBE000, last byte 0x50375FFF.

    python3 notes/work-ram-map-probes/bmp_sizes.py

prints the BMP sizes in the note's table (640x240 4 bpp = 76,918 fits 0x18000; 640x240
8 bpp = 154,678 does not).

`arena_verify.lua` (run with `-debug -debugger none`, a fresh empty nvram directory so
the custom flash is blank, `-seconds_to_run 20`): the signal is `ALLOC_OUT
a0=503BB810` after `RESET` and `ALLOC_IN d0=42B6`. `gap_write_tap.lua` and
`gapwatch2.lua`: in a 40-60 s idle boot nothing but the reset clear writes
0x50298000..0x502B7FFF, and the main pool header word +0x0C reads 0x94E5C. The Lua
scripts write their logs to a path set at their top (`OUT` / `$GW_LOG`); point it at a
scratch directory before running.
