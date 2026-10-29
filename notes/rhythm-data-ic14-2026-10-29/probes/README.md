# IC14 probes (2026-10-29)

Every script reads the descrambled image `original_ROMs/kn5000_rhythm_data_rom.ic14` (git-ignored; `make
original_ROMs/kn5000_rhythm_data_rom.ic14` copies it from the private romset and checks SHA-1
`fef7f1927935d8fdada2afbdbfac29aac56e1c3c`), or the path given as the first argument. Each refuses an image
with another SHA-1. `ic14_common.py` holds the shared grammar and helpers. Run them from anywhere in the
worktree:

    python3 notes/rhythm-data-ic14-2026-10-29/probes/<script>.py

| script                       | question it answers                                                                                                       | signal read                                                                   | pass / measured value (2026-10-29)                                                                       |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `layout_probe.py`            | Is IC14 made of style records, tracks and FF fill only? Where does the 12-byte signature occur?                           | 1 KB chunks: starts with `00 01 04 05 83 00 01 04 05 83 00 01`, all FF, other | 404 signature chunks 0x000000-0x064FFF, then track runs with FF tails per 64 KB bank, FF from 0x378800   |
| `track_grammar_probe.py`     | Do banks 6..0x37 decode as tracks with the reader's grammar, and is every track referenced by a record slot?              | event status bytes and lengths; slot words + bank byte +0x3D1                 | exit 0; 28,400 tracks, 601,568 events, 46,056 slot references, 0 unreferenced, 0 bad                     |
| `record_constancy_probe.py`  | Which bytes of the 404 record halves are fixed layout and which are fields?                                               | per-offset distinct-value count over the halves of each parity                | constant: +0x000..+0x117, +0x1FC..+0x247, sound-block tails, +0x3D2..+0x3DA, +0x3E5, +0x3F3..+0x3FF      |
| `part_stats_probe.py`        | What does each of the six parts play (basis of the part names)?                                                           | note numbers of 0x90/0x91 events per part                                     | parts 0 and 1 identical in 404 of 404 halves, GM drum notes 36/49/38; part 2 median 36; parts 3-5 ~62-64 |
| `slot_bars_probe.py`         | How long is each slot's track, in bars of the half's time signature (+0x3D0 through AccTone_LookupByProgram_Table)?       | 0x81 beat count / beats per bar                                               | slots 0..15 and 17: exactly 1 bar, 2,424 of 2,424 each; slots 16 and 18: 1..8 bars                       |
| `locator_selection_probe.py` | Which (bank, program) of RhythmROM_BankProgramLocators selects which record, and is the table the same in every firmware? | v10 table at 0xE45142, record id at +0x3DB; table searched in v5..v10         | 201 records located, 0x000000 (8br86d) by none; identical table in v5, v6, v7, v8, v9, v10               |
| `swap_framing_probe.py`      | Do the firmware's track pointers fit the descrambled image or the raw read?                                               | 6-byte track header at each slot target, in both images                       | descrambled 46,056 of 46,056; raw read 17,608 of 46,056                                                  |

The A19/A21 transform itself is `scripts/build/rhythm_rom_address_swap.py`, run by `make verify-rhythm-data-raw`
(part of `make gate`).
