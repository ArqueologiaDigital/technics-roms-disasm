# Wave ROM port probes (notes/wave-rom-port.md)

| script                 | question it answers                                                                                                      | command                                                            |
|------------------------|--------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `wave_rom_test_map.py` | which port and `+8` bit 0 does each WAVE ROM test index use, what sum does it expect, and which IC does the screen name? | `python3 -I wave_rom_test_map.py ../../baserom/kn7000_program.rom` |

What it reads, all in PROGRAM 941:

- `0x485CFD28[i]` TG argument (0 -> `0x98050000`, checked against the code at `0x484839AC`),
  `0x485CFD04[i]` the `+8` bit 0, `0x485CFD18[i]` the 32-bit golden sum;
- the `mov imm32, d0` object ids in `MainWaveRomTestFunc` at `0x484A2ED5/2F0C/2F45/2F7E/2FB7`;
- the 15 screen records at `0x4860AA80..0x4860AD40`. Object ids are the records' ordinals from
  `0xED`; the script asserts that every parent/child/next/prev field agrees before it maps an
  object to the text label on its row.

Output on 2026-10-18:

    15 records, ids 0xed..0xfb: every parent/child/next/prev link agrees with ordinal numbering

    | index | port       | +8 bit 0 | expected sum | OK/NG object | label left of it                |
    |-------|------------|----------|--------------|--------------|---------------------------------|
    | 0     | 0x98050000 | 0        | 0x8164c77c   | 0x010000f7   | MAIN TG   BANK 0-15 ROM: IC203= |
    | 1     | 0x98050000 | 1        | 0x815cfc83   | 0x010000f8   | ,  IC204=                       |
    | 2     | 0x98040000 | 0        | 0x8331ef0b   | 0x010000fa   | SUB TG    BANK 0-15 ROM: IC207= |
    | 3     | 0x98040000 | 1        | 0x83254f9d   | 0x010000f9   | ,  IC208=                       |

    overall result object 0x010000fb: record type 0x7, box (176, 182, 475, 217)

The disassembly of the routines themselves came from `tools/dis_view.py`, which as committed fails
on `G.MANUAL_SYM` being a list; replacing `(G.SYM, G.MANUAL_SYM)` with
`[G.SYM] + list(G.MANUAL_SYM)` makes it run:

    python3 tools/dis_view.py 0x484839A1 0x48483B63 r1     # checksum core
    python3 tools/dis_view.py 0x48483B63 0x48483F12 r1     # per-index check
    python3 tools/dis_view.py 0x484A2E11 0x484A2FEA r1     # MainWaveRomTestFunc
