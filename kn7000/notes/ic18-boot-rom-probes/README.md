# IC18 boot ROM probes (notes/ic18-boot-rom.md)

Run from this directory.

| script            | question it answers                                                                                   | command                                                                               |
|-------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| `digest.py`       | what does each routine of `src/ic18/boot.s` touch: callers, callees, strings, registers, variables?   | `python3 -I digest.py ../../src/ic18/boot.s [NAME_SUBSTRING ...]`                     |
| `placeholders.py` | which labels of `src/ic18/boot.s` are still address placeholders, by kind?                            | `python3 -I placeholders.py ../../src/ic18/boot.s [--list bss]`                       |
| `ic18_layout.py`  | what is where in the whole 4 MB: the boot ROM's extent, the rhythm header, its checksum, the version? | `python3 -I ic18_layout.py ~/compartilhado/technics_romsets/kn7000/c3cbnd000046.ic18` |

What they printed on 2026-10-24, at the commit that added this README:

    placeholders.py: loc 1734, old_loc 13, OldLink 11; named 1207 of 2965 labels and .equ's
    ic18_layout.py:  boot ROM used up to 0xFA18 (64024 bytes), 63148 bytes are not 0xFF;
                     "Technics Rhythms" checksum word 0xE2DA, recomputed 0xE2DA (equal);
                     byte at 0x1002A = 220; 0x3FFFE8 "jkr_33.ssf"

The routine and instruction counts quoted in the notes are printed by `tools/gen_ic18_s.py` itself
(`make ic18-src`).
