# Probes for the kn5000-existing lane (2026-10-29)

Run from the repository root, after `make gate` (it copies the git-ignored v5/v6 references and builds the images).

| script                    | question it answers                                                                                                                                         | command                                                                               |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| `help_db_layout_probe.py` | What layout do the five decompressed HELP databases have: pointer slots, shared empty string, pool order, alignment pads, fill, escapes, Latin-1 letters? With `--titles`, which topic title belongs to each slot? | `python3 notes/kn5000-existing-includes-2026-10-29/probes/help_db_layout_probe.py [--titles]` |
| `maincpu_slices_probe.py` | Are the v6/v5 bytes that were romslice `.incbin`s EQUAL to v7's bytes under the same labels, and are the v6/v5 boot banners byte-identical to v10's?           | `python3 notes/kn5000-existing-includes-2026-10-29/probes/maincpu_slices_probe.py`    |

What the output means:

- `help_db_layout_probe.py` reads the factory streams (`original_ROMs/help_db_<lang>_compressed.original.bin`),
  not the build products. It is consistent with `scripts/build/help_db_text.py` when every language shows
  `shared=none`, `topic-major=True`, `odd starts=0`, `pad values={0: n}`, `fill after pool={0}` and
  `control bytes=0`. Measured 2026-10-29: all five do.
- `maincpu_slices_probe.py` reads `symbols/maincpu_<v>_symbols_reference.txt` for the addresses. `EQUAL` on every
  v6 row, and on the four v5 rows that had slices, is what allowed v7's lines to be used verbatim. The v5
  `BitMapOut_CopyExtTable_Check` row says DIFFERENT, as expected: v5's routine is shorter (0x93 B) and was never a
  slice.
