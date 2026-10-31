# open4/wsa1-c probes (2026-10-31)

Probes of lane open4/wsa1-c, which closed the panel key-code, MODELING top and CPU 1 RAM-cell items
of the open-items register.  Each reads only `original_ROMs/` (and, for the listings, the committed
`.unidasm` files beside them) and exits 1 on drift.  Run from `wsa1/`.

| script                      | question it answers                                                                                                                     | command                                                       |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| `key_alt_code_census.py`    | Who raises key codes 0x11-0x18 (`KEY_SoftKeyCol*Alt`) and 0x19 (`KEY_PageAlt`)?  CPU 1's alt-code handlers, variant 1 only; 0x19 never  | `python3 notes/open4-c-probes/key_alt_code_census.py`         |
| `ram_cell_writer_census.py` | Does anything on CPU 1 write RAM 0x2742 or 0x272A?  No direct, pointer-based or immediate block-copy writer; RESET zeroes both          | `python3 notes/open4-c-probes/ram_cell_writer_census.py [-v]` |
| `tone_edit_c5_repaint.py`   | Is `ToneEditPage_ToggleRowFocus`'s literal 0xC5 repaint wrong on pages 0xA6 / 0xA7?  No: the three field-0 repaints draw the same bytes | `python3 notes/open4-c-probes/tone_edit_c5_repaint.py`        |

What each reads, and what passing means:

* `key_alt_code_census.py` -- C1: the byte patterns `8c ff 38 11` (`add (XIX-1),0x11`) and
  `bc ff 00 19` (`ld (XIX-1),0x19`) occur exactly four times each in prom_a+prom_b, all inside
  `PanelAction_PairPos0/1_HeldMaskAltCode` (0xF8AE68-0xF8AF4D), and no other immediate 0x11..0x19 is
  written to `(XIX-1)`.  C2/C3: the action pool (`PanelGroupActionTables_Variant1/2`, parsed by
  `notes/wave7_panel_event_index.py`) names those handlers only for variant-1 groups 3-6, whose
  event lists carry class 0xA9 codes 0x00-0x07 and are pairwise identical.  C4: with those bases
  the produced set is 0x11-0x18.  C5: no code loads 0xA9 as an immediate.
* `ram_cell_writer_census.py` -- W1: every occurrence of the two address bytes; W2: every
  `lda/ld Xrr,0x27nn` pointer followed to its reload; W3: block copies with immediate destinations
  (computed destinations are counted, not excluded -- `-v` lists them); W4: the RESET clear loop
  at 0xF8278A (0x1460 longwords from 0x0080).
* `tone_edit_c5_repaint.py` -- R1-R4 as its docstring says; the record bytes are
  `03 0b a6 27 01 00 05 aa 35 f0 00` on all three pages.
