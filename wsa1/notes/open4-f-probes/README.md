# open4-f-probes: fonts and P7/DSP unit programs (open-items wave 4, 2026-10-31)

Run from `wsa1/`.  Each script exits 1 when a check fails.  `swi7_text_hl.py` reads the
ELF symbol table, so run `make gate-wsa1` (from the repository root) first.

| script                     | question it answers                                                                                                                                                                  | command                                                        |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| `p7_unit_program_paths.py` | which code reads a PoolDir record's +12 body, is it gated, and which DSP each P7 unit's streams reach (N-9918e40f, N-10ecf076)                                                       | `python3 notes/open4-f-probes/p7_unit_program_paths.py`        |
| `swi7_text_hl.py`          | what the HL argument of the twelve SWI7 text services selects (N-b8a6a194)                                                                                                           | `python3 notes/open4-f-probes/swi7_text_hl.py`                 |
| `latin_b0_bc.py`           | the readings of Font_Svc06 0xB0/0xB9/0xBA/0xBC and of kana cells 0x15 / 0x66 (N-b6d3c4c7, N-735e380b)                                                                                | `python3 notes/open4-f-probes/latin_b0_bc.py`                  |
| `kanji_nearest_jis.py`     | can a standard JIS X 0208 16x16 font (X11 jiskan16) read the kanji cells? No: 16 and 15 of the 266 cells then read by eye agree (~6%; 267 cells, set A 0x38 not settled at the time) | `python3 notes/open4-f-probes/kanji_nearest_jis.py --selftest` |

The Japanese-text search of the nine WSA1R floppies (N-25f9f42b) uses the existing instrument,
not a new one: `make -C floppy gate-wsa1`, then
`python3 scripts/analysis/japanese_text_census.py --dict-test ../floppy/build/wsa1/*.img`
(dictionary: `--build-dict` from EDICT2, SHA256 in FINDINGS-fonts.md 6.3).

`kanji_nearest_jis.py` needs `/usr/share/fonts/X11/misc/jiskan16.pcf.gz` (Debian
xfonts-intl-japanese) and numpy; it takes about seven minutes.
