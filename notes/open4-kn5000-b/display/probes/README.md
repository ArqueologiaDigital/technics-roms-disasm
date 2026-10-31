# Probes of lane open4/kn5000-b-display

Run from the repository root.  All three read the sources (no build needed); none writes into the tree.

| script                   | question it answers                                                                              | command                                                                                                                                                                                            |
|--------------------------|--------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `vga_register_writes.py` | Which MN89304 registers does each routine write, with which values, in which order? (kn5000-ezo) | `python3 notes/open4-kn5000-b/display/probes/vga_register_writes.py v10/maincpu/shared/vga_init.s v10/maincpu/display/graphics_text_vga.s`; add `--ext-table` for the seq 0x09-indexed tables only |
| `screen_layout.py`       | Where do the widgets operated by each panel switch sit on the 320 x 240 screen? (kn5000-rq0)     | `python3 notes/open4-kn5000-b/display/probes/screen_layout.py v10`; `--png OUT.png` draws the zones (do not commit)                                                                                |
| `widget_paint_calls.py`  | Which drawing primitives does each `*Proc` call? (kn5000-5dc)                                    | `python3 notes/open4-kn5000-b/display/probes/widget_paint_calls.py v10 [Proc ...]`                                                                                                                 |

Signals read:

- `vga_register_writes.py` follows the `VGA_WRITE` / `VGA_SEQUENCER` / ... macros and the open-coded
  `ld(w) wa, PORT` / `ld(w) bc, VALUE` / `calr _Write_VGA_Register` form; a port is CPU address 0x170000 + port.
  A line `seq 0x0b [seq9=0x04] = 0x13` means: sequencer register 0x0B written with 0x13 while sequencer 0x09 last
  held 0x04.  Straight-line only: branches (VGA_Initialize's region test for seq 0x0F) are read by hand.
- `screen_layout.py` reads the `editsw` and `rect` fields of the C records (`NAKA_XYWH(x, y, w, h)`); output
  2026-10-31 (v10 at 130735749): 195 TtlScreen records, all (0, 0, 320, 240); 916 records name a switch; the table
  is quoted in ../README.md.
- `widget_paint_calls.py` takes a proc to run until the next `...Proc:` label, so it over-collects for a proc
  followed by helpers (PsGridBoxProc lists the whole primitive module after it); read the EVT_DRAW path in the
  source for the final answer.
