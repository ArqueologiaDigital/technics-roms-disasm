# The SX-WSA1R's GUI data, readable at a glance (lane gui-wsa1, 2026-10-29)

The owner's GUI goal (notes/data-semantics-2026-10-29/README.md, GUI addendum) asks that every menu, screen and
widget can be grasped from the source alone. This lane did that for the SX-WSA1R (`wsa1/`), with the ROM bytes
unchanged: `make gate-wsa1` PASS on every commit.

The WSA1 has no widget classes and no string table, unlike the KN5000. Its GUI has three kinds of data:

1. **Display-list records.** Every caption, box, rule, bitmap and live value on the 320 x 240 LCD is one
   record of a display list, run by one of two interpreters in prom_b.
2. **Panel key maps.** A screen's Button method indexes a table of handlers with the 5-bit panel key code.
3. **The screen-object table.** `PanelScreen_VtableTable` in prom_a holds the modes and screen ids. Each entry
   is three directory slots: Enter, Leave and Button.

All three now read as names, and a generated menu map indexes them.

## 1. What the source looks like now

```
DL_SoundEditWriteCopy:
	dl_text16x16_packed	x=110, y=5, text="SOUND EDIT"
	dl_text8x14	x=0, y=36, text="\020 WRITE"
	dl_text8x10	x=272, y=36, text="COPY"
	dl_box	x0=12, y0=31, x1=60, y1=50
	dl_value_glyph	glyph=16, x=80, y=1

	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=8, y=175

ButtonTable_SongClear:
	keymap_begin
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_SongClear
	...
	on_key	KEY_Exit,		ExitKey_SongClear
	...
	keymap_end
```

Each record kind is one macro of `wsa1/include/wsa1_gui.inc`, and the file's header gives the field
conventions. Geometry is in panel pixels. Text is inline, with the font's own glyph codes written as octal
escapes. Bitmaps and string tables are referenced by label, the live variable by its `wsa1_ram.inc` name, and
the drawing service by an `LCDSVC_*` name. Every length byte is computed by the macro, so a text or field that
was mis-read cannot rebuild the ROM.

### Record macros, with the evidence for each field

| macro family                                    | opcode / handler                         | fields                                     | evidence                                                                                                                           |
|-------------------------------------------------|------------------------------------------|--------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| `dl_line` ... `dl_box_shadow1` (12)             | A 00 01 02 05 09 0A 11 12 13 15 1B 22    | x0, y0, x1, y1 (pixels)                    | `DLHandler_4Words` 0xF31A75 copies +2..+9 to LCD_X0..LCD_Y1; `LCD_Svc_05_FillRect` counts `(0x2536)-(0x2532)+1` rows            |
| `dl_text8x14` ... `dl_text16x24` (12)           | A 06 07 08 16 18 19 1A 1D 1E 1F 20 21    | x, y, text                                 | `DLHandler_IX_Text` 0xF31A3A: IX = +2, BC = len - 4; `LCD_Svc_06_DrawText8x14`: IX = byte offset in layer; AP = 40 (SYSTEM SET) |
| `dl_text8x8_packed`, `dl_text16x16_packed`      | A 17 1C                                  | x, y (pixels), text                        | `DLHandler_2Words_Text` 0xF31A52: +2 -> LCD_X0, +4 -> LCD_Y0, BC = len - 6                                                         |
| `dl_plot`                                       | A 0B                                     | x, y                                       | `DLHandler_2Words` 0xF31AAC -> `LCD_Svc_0B_PlotPoint`                                                                              |
| `dl_clear_area`                                 | A 0E                                     | x, y, w, h                                 | `DLHandler_IY_BC_HL` 0xF31A9F -> `LCD_Svc_0E_ClearColumns` (IY offset, BC columns, HL rows)                                        |
| `dl_bitmap`, `dl_read_area`                     | A 03 04                                  | bitmap / buffer, x, y, w, h                | `DLHandler_FarPtr` 0xF31ABE -> `LCD_Svc_03_BlitColumns` / `_04_ReadColumns`                                                        |
| `dl_value_glyph`                                | A 23                                     | glyph, x, y                                | `DLHandler_Glyph24x24` 0xF31ACE: 72-byte glyph `n` of `DLGlyph_000_F78028`, IX = +3                                                |
| `dlb_number`, `dlb_number16`                    | B 00, 06                                 | var, mask, shift, svc, x, y, digits        | `DLB_Handler_Decimal` 0xF31BA1; op 06 reads a 16-bit word (`cp A,6`)                                                               |
| `dlb_number_signed`                             | B 05                                     | ... digits, signflag                       | `DLB_Handler_DecimalSigned` 0xF31BD7, `DisplayListB_ExtractFieldSigned` 0xF31CE4                                                   |
| `dlb_number_xy`, `_number16_xy`, `_signed_xy`   | B 09 0A 0B                               | ... x, y (pixels), digits [, signflag]     | `DLB_Handler_Decimal2Words` 0xF31C14, `DLB_Handler_DecimalSigned2Words` 0xF31C56                                                   |
| `dlb_string`, `dlb_string_xy`                   | B 02, 07                                 | ... table, width, x, y                     | `DLB_Handler_StringTable` 0xF31B21, `_StringTable2` 0xF31B39                                                                       |
| `dlb_rect_entry`, `_rect_entry_op08`            | B 03, 08                                 | var, mask, shift, svc, table               | `DLB_Handler_Array8` 0xF31B57 (`sla 3,HL`: 8-byte entries)                                                                         |
| `dlb_area_entry`                                | B 04                                     | var, mask, shift, svc, table               | `DLB_Handler_Array6` 0xF31B86 (`mul HL,6`)                                                                                         |
| `dlb_centred_span`                              | B 01                                     | var, mask, shift, x0, x1, y1               | `DLB_Handler_CentredSpan` 0xF31C9E (no record uses it)                                                                             |
| `keymap_begin` / `on_key` / `keymap_end`        | 32 handlers per map                      | KEY_* code, handler                        | `PanelButton_Route` 0xF8621E (`and L,0x1f` at 0xF861AE); key names: FINDINGS-prom_a-panel-control-map.md section 1               |
| `keymap_begin` / `on_key` / `fieldops_end`      | 17 handlers + a zero word                | KEY_* code 0x00-0x10, handler              | `PanelEvent_ToFieldIndex` 0xFD7905: codes 0x00-0x10 are their own operation (0xFD7946)                                             |

The macro bodies are data directives only, with no helper-macro calls. `scripts/analysis/data_range_census.py`
judges a macro by its body, and it read a first version that used helpers as code. The dispatch census then rose
in five figures, so the macros were rewritten (commit 5f6c2bdbc).

### Key codes

There are 32 key codes. `KEY_SoftKeyCol1..8`, `KEY_LcdRow1..5`, `KEY_MinusPlus`, `KEY_Exit`, `KEY_Page`,
`KEY_NumberPad` and `KEY_Compare` are the controls that FINDINGS-prom_a-panel-control-map.md maps.

The codes 0x11-0x19 were unexplained. They are now `KEY_SoftKeyCol1Alt..8Alt` and `KEY_PageAlt`. The evidence:

- `PanelEvent_ToFieldIndex` folds codes 0x11-0x18 onto operations 0-7 (`sub C,0x11`, then `or (XIX),0x80` sets
  a flag bit, 0xFD796A).
- It folds code 0x19 onto operation 0x10 (0xFD7986).
- In the 87 key maps, 182 of the 0x11-0x18 slots repeat the handler of their own soft-key column, and 41 differ.

Which physical action raises these codes is still open: no prom_a panel template emits them.

`KEY_Code0E`, `KEY_Code1A`, `KEY_Code1C`, `KEY_Code1D` and `KEY_Code1F` keep neutral names and a TODO.

## 2. How a record's interpreter was decided

The emitters that framed the lists left a comment naming the handler on each record header. That comment was
wrong for 118 records: it said interpreter A, but they are B's. `scripts/tools/gui_display_list_macros.py`
decides each record in this order:

1. **audit**: `notes/prom_b_dl_length_audit.py`'s walk from every call site, where it reaches the record. It
   reaches 4,097 records, and none of them is reached by both interpreters. The converter finds each record's
   address by assembling a scratch copy of the tree with a probe label before every header.
2. **comment**: otherwise, the comment.
3. **length**: B, when the A reading is impossible and the record's length is B's own. Each B opcode has exactly
   one length.
4. **adjacent**: B, when a neighbour in the same run is B and the record reads as B.
5. **geometry**: B, when the A reading puts a corner off the panel and the B reading does not.

A run of records that contains one unreadable record is left untouched as a whole. The reason is that a list
walked from the wrong start reads as plausible text for a while before it fails.

The 118 re-read records, by list (`../gui-data-2026-10-29-probes/reattributed-to-interpreter-B.txt`):

| rule      | records |
|-----------|---------|
| audit     | 12      |
| length    | 70      |
| adjacent  | 26      |
| geometry  | 10      |

So the "-- interpreter A" line in the header comment of these 19 lists is superseded by their macros:

- `DL_F0D081`, `DL_F0DA93`, `DL_F0DB91`, `DL_F0DCC1`, `DL_F0DE62`, `DL_F0DF7D`, `DL_F0E0E2`
- `MidiOutProgramChange_PaintBankLsb_DL`, `ModeScreen_PaintDirtyFields2_DL1`
- `DL_F3391E`, `DL_F34000`, `DL_F3B65B`, `DL_F3C351`
- `S0ngC0py_DrawFromSong_DL1`, `SequencerMedley_DrawPlayState_DL2`, `SequencerMedley_DrawPlayState_DL4`
- `TrackAssign_DrawLocalControlColumn_DL`, `TrackAssign_DrawOutChannelColumn_DL`, `TrackAssign_DrawSelectedPart_DL`

One example with direct call-site evidence: `DL_F0DA93` is run through `T_DLB_Handler_StringTable` (prom_a
0xF99D70, 0xF99E0E, 0xF99E46), which is interpreter B's op-02 handler.

## 3. The menu map

`wsa1/docs/gui-menu-map.md` is generated from the sources by `scripts/analysis/gui_menu_map.py`. Its docstring
says exactly what the script follows. The map has 4,050 lines, in two parts:

- an index of 183 objects: the panel modes, PanelScreen_VtableTable entries 0-47, and the screen ids, entry
  32 + n;
- a section per object, giving:
  - its Enter, Leave and Button methods;
  - the display lists they name, with the first texts of each;
  - its key map, with the handler on each key (do-nothing keys left out);
  - the screen requests those handlers write, decoded from UI_Request_Hi: bit 7 = go to the screen, bit 6 = ask
    for it, bit 1 = change mode, bit 4 = repaint;
  - which key on which screen leads to it.

To regenerate and check it:

```
make -C wsa1 gui-menu-map         # regenerate
make -C wsa1 gui-menu-map-check   # exit 1 when stale; also run by the root `make gate-wsa1`
```

The map is a static reading of the code, and it misses three things:

- a request written through a register;
- a list chosen through a pointer table;
- the sound-edit pages (0x80-0x9F). They ask CPU 2 for their parameter values and paint from the replies, so
  their Enter methods name no list at all.

## 4. The readability census (before -> after)

`python3 wsa1/scripts/analysis/gui_readability_census.py`, or `make -C wsa1 gui-census`. Its docstring defines
each column. The "before" column was measured at 9dbc03088, with the same script copied into a worktree of
that commit.

| figure (all four images)                                  | before  | after |
|-----------------------------------------------------------|---------|-------|
| display-list records as macros                            | 0       | 8,871 |
| display-list records as raw `.byte op, len` + operands    | 8,960   | 89    |
| anonymous operand fields in raw records                   | 30,119  | 330   |
| pointer fields spelled as a number                        | 103     | 30    |
| B variable addresses spelled as a number                  | 479     | 230   |
| B service numbers spelled as a number                     | 1,010   | 0     |
| key-map / field-operation entries named by key            | 0       | 3,558 |
| key-map / field-operation entries indexed only            | 3,558   | 0     |
| screen-table entries spelled as a number                  | 3       | 0     |
| macro records whose position lies off the panel           | n/a     | 1     |

prom_c (CPU 2) and prom_d (the tone database) have no GUI tables, so their rows are 0.

The KN5000 census columns for raw class ids and numeric object links have no counterpart here. A WSA1 list is
reached by a symbol in code, never by an index.

### Censuses that must not regress (run read-only)

- **Dispatch-table census.** The detectors A and U now read `on_key` lines as the `.long` lines they were (two
  lines in `scripts/analysis/dispatch_table_census/census.py`). Two snapshots of prom_a, prom_b and prom_c
  were written to scratch, one at 9dbc03088 and one at this lane's head. They differ only in the commit they
  name (`../gui-data-2026-10-29-probes/dispatch_census_wsa1_snapshot.py`).
- **Doc-quality census.** `python3 scripts/analysis/doc_quality_census.py --compare` against
  doc-quality-2026-10-24-04 reports "nothing rose".
- **Data-incbin census.** The `wsa1` row of `scripts/analysis/data_incbin_census.py` named `wsa1/src`, which
  does not exist. It now names the real directories: 0 `.incbin`, generic 0.

## 5. What is left, and why

- **89 raw records.**
  - 88 of them are one run at 0xF3D1B9 (`DL_F3D1B9`). Its caller draws only `BC * 35` bytes of it (prom_a
    0xF81F08: `muls BC,0x0023 / add XIX,XBC`). The run's later records read as interpreter A only until they
    fail, at a record of 33 bytes whose opcode is 0x00, and the bytes there look like interpreter-B records
    and their string tables. The framing of that region needs a walk from its real entry points before it is
    respelled.
  - The 89th is `TrackAssign_PaintTrackGroup_DL` (0xF3B651), the one record whose length byte over-declares
    (advance 11, extent 10; FINDINGS-ui-display-list-interpreter-b.md). A macro that computes the length
    cannot spell it.
- **1 record off the panel.** `DL_SerDisketteStammenVonEinemAnderenGer` puts a text at y = 649. That is German
  message text that an earlier emitter framed as one 8x10 text record. It now carries a TODO; its framing is
  unconfirmed.
- **30 numeric pointers.** 21 point into RAM at addresses with no `.equ` in `wsa1_ram.inc`, such as 0x2300,
  0x2310 and 0x2320. 9 are prom_b addresses with no label within 0x400 bytes below them. The other pointers are
  spelled `Label+offset` from the nearest label, which points inside that object.
- **230 numeric variable addresses** (65 distinct).
  - 43 are `var=0x0000` with mask 0, which always reads index 0.
  - Most of the rest are the per-part block at 0x7659-0x789F (stride 0x40) and screen-local cells such as
    0x26B0, 0x2740 and 0x27A3.
  - Naming them is RAM-map work. A name needs the routine that writes the cell, which a display record does
    not give.
- **TODO fields.** Opcodes 0x03 and 0x08 share `DLB_Handler_Array8`, and nothing in that handler reads the
  opcode, so what tells them apart is open. The physical source of the key codes in section 1 is also open.

## 6. Tools (all committed; run inside `wsa1/`)

| script                                          | question it answers                                             | command                                          |
|-------------------------------------------------|-----------------------------------------------------------------|--------------------------------------------------|
| `scripts/tools/gui_display_list_macros.py`      | respell every display-list record as its macro                  | `--stats`, `--fails`, `--apply`                  |
| `scripts/tools/gui_keymap_macros.py`            | respell every key map / field-operation table as `on_key` lines | `--check` (every row's EXIT slot), `--apply`     |
| `scripts/analysis/gui_readability_census.py`    | how much GUI data is still raw numbers                          | `make gui-census`, `--odd`                       |
| `scripts/analysis/gui_menu_map.py`              | the menu map                                                    | `make gui-menu-map`, `make gui-menu-map-check`   |
| `../scripts/renaming/rename_wsa1_key_codes.sed` | KEY_Code11..19 -> KEY_SoftKeyColNAlt, KEY_PageAlt               | `sed -i -f`                                      |
| `notes/gui-data-2026-10-29-probes/`             | the re-read records, the dispatch-census comparison             | see its README                                   |

## 7. Website page draft (for technics-docs; not written there by this lane)

> **SX-WSA1R: how the screens are built**
>
> The SX-WSA1R draws every screen from *display lists*: short byte-coded programs run by two interpreters in
> program ROM B (0xF31A09 and 0xF31AF0). A record names a graphics service and its operands: a box, a line, a
> string in one of ten fonts, a bitmap, or a live value. The opcode of an interpreter-A record *is* the
> service number of the CPU's SWI 7 graphics call (34 services, table at 0xF8E9C6). Interpreter B reads a
> bit-field from a RAM variable and draws it as digits, as an entry of a string table, or as a rectangle
> taken from a table.
>
> Positions are SED1330 display-RAM byte offsets, y * 40 + x / 8, on a 320 x 240, 1-bit, three-layer panel.
> A screen is an object of three methods (Enter, Leave, Button) in a 256-entry table at 0xF86EC1. Its Button
> method dispatches the 5-bit panel key code through a 32-entry key map: soft-key columns 1-8, the five LCD-row
> key pairs, -1/+1, EXIT, PAGE, the number pad and COMPARE, plus a second event for each soft-key column and
> for PAGE.
>
> The disassembly spells all of this as macros (`wsa1/include/wsa1_gui.inc`), and a generated menu map lists
> every screen, what it draws, which key does what, and which key leads to it (`wsa1/docs/gui-menu-map.md`).
