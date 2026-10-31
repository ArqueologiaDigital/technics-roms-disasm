# Lane open4/kn5000-b-display (2026-10-31): display and UI issues

Sub-lane `display` of lane kn5000-b (wave 4).  Issues: **kn5000-ezo** (MN89304 registers), **kn5000-rq0**
(screen layout), **kn5000-5dc** (how widgets paint themselves), **kn5000-nmg** (animation and transitions), and the
status of the epic **kn5000-8z5** (MAME display milestone).  Every address below is v10's; the same code is in v9,
v7, v6 and v5 (v8 builds from v9) and every source change was applied to all five trees.

| file                                          | what it is                                                                                     |
|-----------------------------------------------|------------------------------------------------------------------------------------------------|
| `scripts/renaming/rename_open4_display.sed`   | the label / RAM-name renames (one rule per name, with the reason)                              |
| `scripts/renaming/open4_display_title_ram.py` | PANEL_SW_HELD_* comments, five new RAM names 0x274a6-0x274ae, MainTitleCtrl_ChangeTitle header |
| `scripts/tools/open4_display_vga_ext_seq.py`  | VGA_ConfigExtSequencer_AltA label + `_VGA_SEQUENCER` respelling, headers of the VGA routines   |
| `probes/vga_register_writes.py`               | every MN89304 register write per routine, from the sources (kn5000-ezo)                        |
| `probes/screen_layout.py`                     | the soft-button zones from the widget records' rectangles, optional PNG (kn5000-rq0)           |
| `probes/widget_paint_calls.py`                | the drawing primitives each `*Proc` calls (kn5000-5dc)                                         |
| `probes/README.md`                            | per probe: question, command, what the output means                                            |
| `issue-comments.json`                         | the tracker comments the lane lead applies                                                     |

---------------------------------------------------------------------------------------------------------------------

## kn5000-ezo: the MN89304 register set

### What was traced

Three routines program the controller; `probes/vga_register_writes.py` lists every write of each in order.

| routine                       | v10 address | file                          | when                                                                |
|-------------------------------|-------------|-------------------------------|---------------------------------------------------------------------|
| `VGA_Setup`                   | 0xEF55A7    | `shared/vga_init.s`           | boot (also in the table-data ROM, called as `VGA_Setup + 0x600000`) |
| `VGA_Extended_Init`           | 0xEF5163    | `shared/vga_init.s`           | called by `VGA_Setup` after the palette                             |
| `VGA_Initialize`              | 0xFB2B06    | `display/graphics_text_vga.s` | init phase 0 of the display subsystem (`VGA_InitFuncTable` entry 0) |
| `VGA_ConfigExtSequencer`      | 0xFB36A9    | `display/graphics_text_vga.s` | called by `VGA_Initialize` after the palette                        |
| `VGA_ConfigExtSequencer_AltA` | 0xFB3264    | `display/graphics_text_vga.s` | **unreferenced** (label new in this lane; the bytes had none)       |
| `VGA_ConfigExtSequencer_AltB` | 0xFB3AED    | `display/graphics_text_vga.s` | **unreferenced** (was `_Alt`, commented "who calls here?")          |
| `Test_LCD_Controller_IC206`   | -           | `ui/ui_mode_handlers.s`       | factory test: writes 0 / 1 / 0 to port 0x3C3 and reads each back    |

All register access goes through `_Write_VGA_Register` (WA = port offset, C = value; it busy-waits 128 loops first,
then writes byte 0x170000 + WA) and `_Read_VGA_Register` (no delay).

**The extended registers** (everything that is not standard VGA):

- **seq 0x06** is a lock: every routine writes 0x01 before touching the extension registers and 0x00 after.  All of
  seq 0x07-0x13 and the seq 0x09-indexed table below are written only between the two.
- **seq 0x09 / 0x0A / 0x0B / 0x0C** are an index and three data ports: the code always writes seq 0x09 = N and then
  one value to each of 0x0A, 0x0B and 0x0C.  Even indices 0x00-0x10 receive all three; odd indices 0x01-0x11 receive
  only 0x0C, except 0x0D, 0x0F and 0x11, which also take 0x0A.  The order is 0x04, 0x06, 0x00, 0x02, 0x08, 0x0A,
  0x0D, 0x0C, 0x0F, 0x0E, 0x11, 0x10, then the odd ones 0x01 ... 0x11.  `[INFERENCE]` A register file of LCD timing
  or panel-drive parameters (18 entries); there is no datasheet to confirm it.
- **seq 0x07** = 0x20 (the boot code's comment "Horiz char counter reset" is unsupported), **seq 0x08** = 0x01,
  **seq 0x0D** = 0x03, **seq 0x0F** = 0x00 at boot; `VGA_Initialize` writes **0x44** unless the region code
  (`Get_Region_Code`) is 4, when it writes 0x00; `VGA_Initialize` alone also writes **seq 0x13** = 0x01.
- **CRTC 0x19** = 0x00 and **CRTC 0x1A** = 0x10 (both routines).
- **Port 0x3C3** (VGA enable) = 0x01.  The factory test reads it back, so it is a read/write register.

**Boot versus run time.**  `VGA_Initialize` (later, so its values are the ones in force) differs from `VGA_Setup` in:
CRTC 0x00 horizontal total **0x50** (boot 0x65); seq 0x0F (above); seq 0x13; and the palette, all **256** entries
from the work-RAM table at 0x00E3E8 (4 bytes per entry), each 8-bit component rounded to 4 bits (`v >> 4`, plus 1
when bit 3 is set and `v < 0xF0`), where the boot code loads 9 fixed colours.

The three seq 0x09 tables (`VGA_ConfigExtSequencer` is byte-for-byte the boot `VGA_Extended_Init`; AltA differs
from it in 19 values, AltB in 18; AltB also writes seq 0x0B twice for index 0x04, 0x21 then 0x24):

| seq 0x09 | VGA_ConfigExtSequencer (= boot VGA_Extended_Init): 0x0a / 0x0b / 0x0c | VGA_ConfigExtSequencer_AltA | VGA_ConfigExtSequencer_AltB |
|----------|-----------------------------------------------------------------------|-----------------------------|-----------------------------|
| 0x00     | 0x1c / 0x11 / 0x03                                                    | 0x1c / 0x11 / 0x03          | 0x1c / 0x12 / 0x03          |
| 0x01     | - / - / 0x74                                                          | - / - / 0x64                | - / - / 0x74                |
| 0x02     | 0x05 / 0x11 / 0x03                                                    | 0x05 / 0x11 / 0x03          | 0x05 / 0x11 / 0x03          |
| 0x03     | - / - / 0x09                                                          | - / - / 0x09                | - / - / 0x0a                |
| 0x04     | 0x10 / 0x13 / 0x05                                                    | 0x10 / 0x17 / 0x05          | 0x10 / 0x24 / 0x05          |
| 0x05     | - / - / 0x2b                                                          | - / - / 0x2b                | - / - / 0x2c                |
| 0x06     | 0x15 / 0x64 / 0x07                                                    | 0x25 / 0x13 / 0x08          | 0x15 / 0x64 / 0x07          |
| 0x07     | - / - / 0x68                                                          | - / - / 0x58                | - / - / 0x69                |
| 0x08     | 0x92 / 0x13 / 0x08                                                    | 0xaa / 0x10 / 0x08          | 0x92 / 0x13 / 0x08          |
| 0x09     | - / - / 0x05                                                          | - / - / 0x07                | - / - / 0x05                |
| 0x0a     | 0x01 / 0x14 / 0x06                                                    | 0x01 / 0x13 / 0x06          | 0x01 / 0x32 / 0x07          |
| 0x0b     | - / - / 0x01                                                          | - / - / 0x01                | - / - / 0x01                |
| 0x0c     | 0x00 / 0x72 / 0x09                                                    | 0x00 / 0x25 / 0x0c          | 0x01 / 0x35 / 0x0d          |
| 0x0d     | 0x01 / - / 0x0c                                                       | 0x01 / - / 0x0d             | 0x00 / - / 0x0d             |
| 0x0e     | 0x00 / 0x13 / 0x08                                                    | 0x00 / 0x33 / 0x08          | 0x00 / 0x32 / 0x08          |
| 0x0f     | 0x11 / - / 0x3a                                                       | 0x11 / - / 0x3a             | 0x11 / - / 0x3b             |
| 0x10     | 0xfe / 0x73 / 0x0f                                                    | 0xfb / 0x22 / 0x0e          | 0x33 / 0x25 / 0x0f          |
| 0x11     | 0xff / - / 0x0d                                                       | 0xf7 / - / 0x0c             | 0x33 / - / 0x08             |

`[INFERENCE]` The two unreferenced tables look like settings for other LCD panels or an earlier panel revision,
left in the image; nothing selects them.

**`VGA_CRTCTiming_ByteData` was misnamed.**  It is code: a palette loader (XWA = 4-byte {r, g, b, -} records, one
`VGA_WritePaletteEntry` call per entry, index in bank register QIZH) whose closing `jr` is unconditional, so it
never returns.  Nothing calls it.  Now `VGA_WritePalette256_Unterminated` / `VGA_WritePalette256_Loop`; AltA starts
right after its endless loop.

### What is left, and why

The meaning of every extended register value: there is no MN89304 datasheet in any collection we know of, and
the kn5000.cpp MAME device says "nothing is known about this".  Only measurements on a real unit (an LCD with the
registers changed) could name them.  That does not block emulation: MAME ignores these registers and the display
works (display-subsystem.md, "MAME Emulation Status").

### Website page draft

**Page:** `display-subsystem.md`.  **(1)** In "VGA Initialization Values", replace the row
`| 0x06-0x11 | various | MN89304 extended registers (LCD timing) |` with
`| 0x06 | 0x01 ... 0x00 | MN89304 extension lock: written 0x01 before and 0x00 after every extended-register write |`,
and change the CRTC rows `0x19` / `0x1A` "MN89304-specific" to "MN89304 extension (meaning unknown)".
**(2)** Insert after "VGA Initialization Values":

> ### MN89304 Extended Registers
>
> Everything beyond the standard VGA set is written only while sequencer register 0x06 holds 0x01 (an unlock);
> the routines write 0x00 there when they finish.  No datasheet exists for the MN89304, so the values are listed,
> not explained.  Source: `notes/open4-kn5000-b/display/probes/vga_register_writes.py` in the disassembly repo.
>
> | Register   | Boot (`VGA_Setup`) | Run time (`VGA_Initialize`)               |
> |------------|--------------------|-------------------------------------------|
> | seq 0x07   | 0x20               | 0x20                                      |
> | seq 0x08   | 0x01               | 0x01                                      |
> | seq 0x0D   | 0x03               | 0x03                                      |
> | seq 0x0F   | 0x00               | 0x44; 0x00 when the region code is 4      |
> | seq 0x13   | not written        | 0x01                                      |
> | CRTC 0x19  | 0x00               | 0x00                                      |
> | CRTC 0x1A  | 0x10               | 0x10                                      |
> | port 0x3C3 | 0x01               | 0x01 (the factory LCD test reads it back) |
>
> **Indexed table.**  Sequencer 0x09 is an index and 0x0A / 0x0B / 0x0C are three data registers: the firmware
> writes 0x09 = N, then one byte to each of 0x0A-0x0C.  Even indices 0x00-0x10 take all three; odd indices
> 0x01-0x11 take only 0x0C (0x0D, 0x0F and 0x11 also take 0x0A).  `VGA_Extended_Init` (boot, 0xEF5163) and
> `VGA_ConfigExtSequencer` (run time, 0xFB36A9) load the same 18 entries:
>
> | 0x09 | 0x0A | 0x0B | 0x0C |
> |------|------|------|------|
> | 0x00 | 0x1C | 0x11 | 0x03 |
> | 0x01 | -    | -    | 0x74 |
> | 0x02 | 0x05 | 0x11 | 0x03 |
> | 0x03 | -    | -    | 0x09 |
> | 0x04 | 0x10 | 0x13 | 0x05 |
> | 0x05 | -    | -    | 0x2B |
> | 0x06 | 0x15 | 0x64 | 0x07 |
> | 0x07 | -    | -    | 0x68 |
> | 0x08 | 0x92 | 0x13 | 0x08 |
> | 0x09 | -    | -    | 0x05 |
> | 0x0A | 0x01 | 0x14 | 0x06 |
> | 0x0B | -    | -    | 0x01 |
> | 0x0C | 0x00 | 0x72 | 0x09 |
> | 0x0D | 0x01 | -    | 0x0C |
> | 0x0E | 0x00 | 0x13 | 0x08 |
> | 0x0F | 0x11 | -    | 0x3A |
> | 0x10 | 0xFE | 0x73 | 0x0F |
> | 0x11 | 0xFF | -    | 0x0D |
>
> Two more versions of this table sit in the main-CPU ROM with no caller, `VGA_ConfigExtSequencer_AltA`
> (0xFB3264, 19 values differ) and `VGA_ConfigExtSequencer_AltB` (0xFB3AED, 18 differ) -- most probably settings
> for another LCD panel.
>
> **Run time differs from boot.**  `VGA_Initialize` (display init phase 0) runs after `VGA_Setup` and leaves the
> horizontal total (CRTC 0x00) at **0x50**, not 0x65; it also loads all 256 palette entries from the work-RAM
> table at 0x00E3E8, rounding each 8-bit component to the 4-bit DAC (`v >> 4`, plus one when bit 3 is set and the
> value is below 0xF0).
>
> MAME's `mn89304_vga_device` ignores all of these registers; the image is correct without them.

**(3)** In "Code References / Core Display" add rows for `VGA_Initialize` (0xFB2B06), `VGA_ConfigExtSequencer`
(0xFB36A9), `VGA_ConfigExtSequencer_AltA` (0xFB3264), `VGA_ConfigExtSequencer_AltB` (0xFB3AED),
`_Write_VGA_Register` (0xFB3087), `_Read_VGA_Register`.

---------------------------------------------------------------------------------------------------------------------

## kn5000-8z5: MAME display subsystem milestone (epic)

Children: kn5000-3c5 (framebuffer) **closed**, kn5000-hy8 (pixel format, palette) **closed**, kn5000-gln (drawing
primitives) **closed** (and RESOLVED in the register), kn5000-ezo: repo-side work done in this lane, draft above.
The emulator criteria of the epic (boot splash, UI elements, text) are met per display-subsystem.md "MAME Emulation
Status".  Outcome: the epic can close as soon as the kn5000-ezo draft is published; nothing else is open under it.

---------------------------------------------------------------------------------------------------------------------

## kn5000-rq0: the general screen layout

### What was traced

**Every title is a full-screen view.**  All 195 `TtlScreen` records in the v10 C sources have
`rect = NAKA_XYWH(0, 0, 320, 240)`.

**The title strip is drawn by code.**  `TtlScreenProc` (0xF9AA6D) handles `EVT_DRAW` by calling `ScreenProc` (the
wallpaper and the children) and then `DrawTitleBar` (`audio/presentation_sound_nav.s`).  `DrawTitleBar` takes the
screen rectangle and draws into x1 + 4 .. x2 - 4, y1 .. y1 + 27, i.e. **x 4-315, y 0-27**: an icon at the left
(the text box starts 24 px in when the title has an icon), the title string centred (left / right alignment by a
parameter) in font 4, re-measured in font 1 when it does not fit, colours 0xFF / 0xF7.  When the screen contains a
`PsPageBox` (found with `EVT_SEARCH_CLASS`), 64 px at the right are kept free for the page indicator
(`AcWindowPage`, typically at x 245, y 6, 71 x 18; `AcTempoBox` at x 248, y 4 takes the same corner on the
performance screens).

**The soft-button zones come from the records.**  A record's `editsw` field names the panel switch that operates it
(`ES_Left1..5` = 0x88-0x8C, `ES_Right1..5` = 0x08-0x0C, `ES_Bottom1..8` = 0x00-0x07, `ES_Exit` = 0x0F, from the
SupportClass value names).  `probes/screen_layout.py` counts the rectangles of the 916 v10 records whose `editsw`
names a switch (973 have the field; 57 say `ES_None`):

| switch     | records | most common x, y, w, h | share | next most common                               |
|------------|---------|------------------------|-------|------------------------------------------------|
| ES_Left1   | 43      | 8, 30, 149, 26         | 37%   | 8, 34, 31, 18 (x7); 8, 30, 165, 26 (x7)        |
| ES_Left2   | 62      | 8, 72, 149, 26         | 37%   | 8, 72, 165, 26 (x7); 8, 76, 31, 18 (x6)        |
| ES_Left3   | 55      | 8, 114, 149, 26        | 41%   | 8, 114, 50, 26 (x8); 8, 114, 165, 26 (x7)      |
| ES_Left4   | 44      | 8, 156, 149, 26        | 47%   | 8, 156, 60, 26 (x2); 8, 156, 228, 26 (x2)      |
| ES_Left5   | 22      | 8, 198, 149, 26        | 50%   | 8, 202, 42, 18 (x4); 8, 202, 31, 18 (x2)       |
| ES_Right1  | 56      | 163, 30, 149, 26       | 21%   | 272, 31, 40, 24 (x12); 281, 34, 31, 18 (x9)    |
| ES_Right2  | 56      | 163, 72, 149, 26       | 30%   | 281, 76, 31, 18 (x15); 208, 77, 104, 18 (x2)   |
| ES_Right3  | 70      | 281, 118, 31, 18       | 47%   | 163, 114, 149, 26 (x17); 270, 118, 42, 18 (x6) |
| ES_Right4  | 117     | 281, 160, 31, 18       | 70%   | 163, 156, 149, 26 (x16); 270, 160, 42, 18 (x4) |
| ES_Right5  | 22      | 163, 198, 149, 26      | 31%   | 270, 202, 42, 18 (x2); 275, 197, 37, 28 (x2)   |
| ES_Bottom1 | 51      | 4, 216, 32, 23         | 43%   | 4, 216, 72, 23 (x13); 4, 216, 112, 23 (x4)     |
| ES_Bottom2 | 39      | 44, 216, 32, 23        | 56%   | 44, 216, 72, 23 (x11); 43, 128, 39, 108 (x2)   |
| ES_Bottom3 | 63      | 84, 216, 32, 23        | 30%   | 84, 216, 72, 23 (x18); 44, 217, 72, 23 (x3)    |
| ES_Bottom4 | 47      | 124, 216, 72, 23       | 46%   | 124, 216, 32, 23 (x12); 124, 216, 112, 23 (x4) |
| ES_Bottom5 | 36      | 164, 216, 32, 23       | 55%   | 164, 216, 72, 23 (x8); 160, 128, 39, 108 (x2)  |
| ES_Bottom6 | 36      | 204, 216, 32, 23       | 55%   | 204, 216, 72, 23 (x12); 204, 184, 32, 55 (x2)  |
| ES_Bottom7 | 73      | 244, 216, 72, 23       | 72%   | 244, 216, 32, 23 (x11); 242, 216, 32, 23 (x2)  |
| ES_Bottom8 | 20      | 284, 216, 32, 23       | 55%   | 284, 184, 32, 55 (x2); 284, 217, 32, 23 (x1)   |
| ES_Exit    | 4       | 284, 216, 32, 23       | 50%   | 289, 222, 31, 18 (x2)                          |

So the screen is a fixed grid:

- **Title strip**: y 0-27 (code-drawn).
- **Five side rows**, top edges y = 30, 72, 114, 156, 198 (a 42-pixel pitch), 26 px high.  The left column's boxes
  start at x 8, the right column's at x 163; a full-width menu box is 149 px wide (so the two columns meet at the
  centre, 157 / 163), a wide parameter box 165.  Small boxes against the right edge (x 281, 31 x 18, or x 270,
  42 x 18) are the value boxes of the right-hand switches, vertically centred in the row (y + 4).
- **Eight bottom slots**, x = 4 + 40 k (k = 0..7), y 216-238, 32 px wide; a 72-px box spans two slots and a
  112-px box three, still operated by the switch of the first slot.  EXIT's boxes sit in the last slot.  The bottom row overlaps the fifth side row (y 198-223), so a screen fills one or
  the other in that band.
- Records with no switch (`ES_None`) are free-placed: list and edit boxes in the middle (for example
  44, 111, 233 x 72).

`python3 probes/screen_layout.py v10 --png layout.png` draws these zones on a blank 320 x 240 canvas (3x scale);
the PNG is a derived output and is not committed.

### What is left

Nothing for the issue's "header area, content area, status bar": the KN5000 has no fixed status bar; the title
strip is the only fixed region drawn on every title.  An annotated **screenshot** (as opposed to the zone drawing)
needs a MAME snapshot of a real screen; the docs lane may take one (any title with a menu, e.g. DISK MENU) and lay
the zone PNG over it.

### Website page draft

**Page:** `display-subsystem.md`, section "Screen Layout and Regions".  Insert before "Region Architecture", and
retitle "Region Architecture" to "Step-record screen regions":

> ### Common title layout
>
> Every title is a full-screen `TtlScreen` view (0, 0, 320 x 240) laid out on one grid, which the widget records
> themselves show: each record carries the panel switch that operates it (`editsw`) and its rectangle.  Counted
> over the 916 v10 records that name a switch (`notes/open4-kn5000-b/display/probes/screen_layout.py`):
>
> | Zone             | Rectangle (x, y, w, h)                                                  | Switches                              |
> |------------------|-------------------------------------------------------------------------|---------------------------------------|
> | Title strip      | 4, 0, 312, 28 (drawn by `DrawTitleBar`, not a record)                   | -                                     |
> | Left rows 1-5    | 8, 30 + 42 (n - 1), 149, 26                                             | LEFT 1-5 (0x88-0x8C)                  |
> | Right rows 1-5   | 163, 30 + 42 (n - 1), 149, 26; value boxes 281, 34 + 42 (n - 1), 31, 18 | RIGHT 1-5 (0x08-0x0C)                 |
> | Bottom slots 1-8 | 4 + 40 (k - 1), 216, 32, 23; a 72-wide box spans two slots              | buttons 1-8 below the LCD (0x00-0x07) |
> | EXIT             | the eighth bottom slot (284, 216)                                       | EXIT (0x0F)                           |
>
> The title strip: `TtlScreenProc` answers `EVT_DRAW` with `ScreenProc` (wallpaper and children) and then
> `DrawTitleBar`, which draws the title's icon at the left and its string centred in font 4 (font 1 if it does not
> fit) inside x 4-315, y 0-27.  When the screen has a page box (`PsPageBox`), the right 64 px are left to it: the
> `AcWindowPage` page indicator at (245, 6) or, on the performance screens, the `AcTempoBox` at (248, 4).  There is
> no fixed status bar.  The fifth side row (y 198-223) and the bottom row (y 216-238) overlap, so a screen uses one
> or the other there.  The 11 regions below belong to the sequencer's step-record screen only.

**Image (optional):** the docs lane can generate `assets/images/kn5000-screen-zones.png` with the probe's `--png`
option, or overlay it on a MAME snapshot of DISK MENU.

---------------------------------------------------------------------------------------------------------------------

## kn5000-5dc: how widgets paint themselves

### The paint protocol (ViewableProc, `ui/ui_widget_defs.s`)

Three events, all answered by `ViewableProc` (0xFA5995) unless a class overrides them:

| event                     | handler                             | what it does                                                                                                                                                                                                               |
|---------------------------|-------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `EVT_PAINT` (0x1C0000B)   | `ViewableProc_OnPaint` (0xFA5AEE)   | if the view is visible (`GetVisible`: flag word +12 bit 0 clear): `EVT_DRAW` to itself, then `EVT_PAINT` to its first subview (`GetSubView`, Viewable +6); in any case `EVT_PAINT` to its next sibling (`GetNextView`, +8) |
| `EVT_REPAINT` (0x1C0000C) | `ViewableProc_OnRepaint` (0xFA5B34) | if visible: `EVT_DRAW` to itself, then `EVT_PAINT` to its subview; **not** to its siblings                                                                                                                                 |
| `EVT_DRAW` (0x1C0000D)    | `Viewable_ReturnZero`               | nothing: every visible class overrides it to draw its own rectangle only                                                                                                                                                   |

So `EVT_PAINT` sent to a screen walks the whole view tree depth-first (self, children, then siblings), and an
invisible view hides its whole subtree.  `EVT_REPAINT` redraws one widget and its children after a value change.
Two further events split a widget's drawing in two on the `Ps*` classes: `EVT_DRAW` draws the static part (box,
edit-switch marker), `EVT_PARA_DRAW` (0x1C0000F) the value text, and `EVT_SELE_DRAW` / `EVT_DRAW_SELECTED` the
cursor.  Drawing goes to the off-screen buffer; `UpdateScreen` copies it to VRAM (display-subsystem.md, "Rendering
Pipeline").

The view-link helpers were mislabelled and are renamed in this lane: `View_GetSuperViewInstance` read +6, the
**sub**view (now `GetSubView`); `View_GetParentOffset` (+4) is `GetSuperView`, `View_GetNextSibling` (+8)
`GetNextView`, `View_ResolveInstanceAddr` (+10) `GetPrevView`; ViewableProc's EVT_GET_SUPERVIEW / _SUBVIEW /
_NEXTVIEW / _PREVVIEW cases are `Viewable_OnGet*View`.

### Per class: what EVT_DRAW calls

From the source of each proc (the probe `probes/widget_paint_calls.py` lists the candidate calls; the table is the
EVT_DRAW path read by hand).  "base" = the parent class's proc, called first.

| class (proc)                                       | base       | draws                                                                                                                                                                                                                                                                                                                                                                   |
|----------------------------------------------------|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Viewable (`ViewableProc`)                          | -          | nothing                                                                                                                                                                                                                                                                                                                                                                 |
| Box (`BoxProc`, 0xF99581)                          | Viewable   | `DrawDesignBox` of the rectangle                                                                                                                                                                                                                                                                                                                                        |
| VwBox (`VwBoxProc`)                                | Viewable   | `DrawDesignBox(rect, border +24, colour +22)`; `EVT_DRAW_SELECTED` (`VwBox_OnDrawSelected`): `DrawDesignFrame` 2 px inside the client box, colour 0xF2 to select, the box colour to deselect                                                                                                                                                                            |
| GroupBox (`GroupBoxProc`)                          | Box        | the box; its last switch case, `GroupBoxProc_OnAllPaint`, re-sends `EVT_PAINT` to the view (the whole group repainted); the rest of GroupBoxProc handles switches, the dial and title events                                                                                                                                                                            |
| Screen (`ScreenProc`, 0xF9A69F)                    | GroupBox   | `Screen_Paint`: `DrawWall` (the 320 x 240 wallpaper) only; the wall and its palette are chosen on `EVT_SHOW` (`Screen_Init_SetWall`: `ChangeWall`, `ChangeWallPalette`)                                                                                                                                                                                                 |
| TtlScreen (`TtlScreenProc`, 0xF9AA6D)              | Screen     | `DrawTitleBar`: icon (`DrawDesignBox` + `DrawIcons`) and title text (`DrawStringCentered` / `LeftJustify` / `RightJustify`)                                                                                                                                                                                                                                             |
| Label (`LabelProc`, 0xF9C4B6)                      | Viewable   | `DrawString` at (x1 + 2, y1 + 1), font +26, colour +30 on 0xF7                                                                                                                                                                                                                                                                                                          |
| StringBox (`StringBoxProc`, 0xF9C44E)              | Box        | the box, then `DrawStringAlignment` of the string, centred in the client box (`GetClientBox`, `GetBoxCenter`)                                                                                                                                                                                                                                                           |
| Line (`LineProc`, 0xF9C723)                        | Viewable   | `DrawLine` (horizontal or vertical by field +24)                                                                                                                                                                                                                                                                                                                        |
| Frame (`FrameProc`, 0xF9C7A5)                      | Viewable   | `DrawDesignFrame`: `DrawFrame` repeated, shrinking one pixel per pass, for the frame thickness (style 1 only)                                                                                                                                                                                                                                                           |
| Bitmap (`BitmapProc`)                              | Viewable   | `DrawBitmap` of bitmap id +22 at (x1, y1)                                                                                                                                                                                                                                                                                                                               |
| VwUserBitmap (`VwUserBitmapProc`)                  | Viewable   | asks the application function for data / width / height (`EVT_GET_BITMAP_*`) and draws with `DrawBitmapSPFast` (fallback `DrawBitmap`)                                                                                                                                                                                                                                  |
| Icon (`IconProc`)                                  | Viewable   | `DrawDesignBox` (a 28 x 28 frame, style 0xC4, colour 0xF0) and `DrawIcons`                                                                                                                                                                                                                                                                                              |
| EditSw (`EditSwProc`, 0xF9C8BE)                    | Label      | the label's text; it handles only `EVT_SW_IN` itself                                                                                                                                                                                                                                                                                                                    |
| PsMenuBox (`PsMenuBoxProc`)                        | VwBox      | EVT_DRAW: the box, then `DrawEditSw` (the one-character marker beside the operating switch); `EVT_PARA_DRAW`: the text from `EVT_GET_STRING` with `DrawStringAlignment`                                                                                                                                                                                                 |
| PsEditBox (`PsEditBoxProc`)                        | VwBox      | as PsMenuBox, with `DrawStringReverse` for the highlighted value                                                                                                                                                                                                                                                                                                        |
| PsEditSwBox (`PsEditSwBoxProc`)                    | VwBox      | the box, `DrawEditSw`, `DrawBox` and the button-state painter `ButtonState_PaintProc`                                                                                                                                                                                                                                                                                   |
| AcTitleMenu (`AcTitleMenuProc`)                    | PsMenuBox  | menu text (`DrawString`, width by `CalcTotalWidth` / `GetCharHeight`) and the entry's icon (`DrawDesignBox` + `DrawIcons`)                                                                                                                                                                                                                                              |
| PsGridBox (`PsGridBoxProc`) and every `Ac*GridBox` | VwBox      | EVT_DRAW (`PsGridBox_OnDraw`): the box, then `EVT_PARA_DRAW` to itself (`PsGridBox_OnParaDraw`: cell dividers with `DrawLine`, cell text with `DrawStringAlignment`, the derived class supplying text through `EVT_REQUEST_GRID_DRAW` / `EVT_GET_FIXED_ROW_STR` / `_COL_STR`), then `EVT_SELE_DRAW` (`PsGridBox_OnSeleDraw`: `DrawDesignFrame` round the selected cell) |
| PsMixerControl (`PsMixerControlProc`)              | its parent | the parent's box, then `EVT_REFRESH_PARA_DRAW`: for each control record the per-type painter `PsMixer_CtlTypeProc0..10` (`PsMixer_ControlProcTable`), built from `DrawEditSw`, `PsMixer_DrawFrameBox` / `_DrawFrameBoxWithDividers` / `_DrawCaptionFrame`, `DrawStringCentered`, `DrawLine`                                                                             |
| AcMixerVol (`AcMixerVolProc`)                      | VwBox      | `DrawBox`, `DrawBitmapFast`, `DrawStringCentered` / `DrawStringReverse` (`[INFERENCE]` the mixer fader: a bar, the knob bitmap, the value)                                                                                                                                                                                                                              |
| AcLswPartPan (`AcLswPartPanProc`)                  | its parent | the pan meter: `DrawBox`, `DrawLine`, `DrawDesignBox`                                                                                                                                                                                                                                                                                                                   |
| IvDrawbar (`IvDrawbarProc`, 0xF824C4)              | its parent | nothing of its own: `IvDrawbar_OnDraw` calls the parent and sends `EVT_PARA_DRAW`; the `Iv*` classes are invisible controllers that send refresh events to the drawbar widgets                                                                                                                                                                                          |

### What is left

The issue's "piano keyboard display, waveform displays, level meters": no class draws a keyboard picture or a
waveform; the level / pan meters are the mixer classes above.  The step-record screen's own regions are covered
on display-subsystem.md.  This lane documented the base classes and the ones the plan names; the other derived
classes mostly call their parent (`InheritedProc`) and add one of the primitives above.  `python3 probes/widget_paint_calls.py v10` lists the candidate primitives of all of them.

### Website page draft

**Page:** `ui-framework.md`.  Insert a new section after "Widget Type System" (before "Widget records in the C
sources"), and in "Research Needed" tick nothing new (it does not list this item):

> ## How Widgets Paint Themselves
>
> Painting is three events, answered by `ViewableProc` (the base of every view) unless a class overrides them:
>
> | Event                     | Viewable's answer                                                                                                                                   |
> |---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
> | `EVT_PAINT` (0x1C0000B)   | if visible: `EVT_DRAW` to self and `EVT_PAINT` to the first subview; then, visible or not, `EVT_PAINT` to the next sibling (`ViewableProc_OnPaint`) |
> | `EVT_REPAINT` (0x1C0000C) | if visible: `EVT_DRAW` to self and `EVT_PAINT` to the subview, no siblings (`ViewableProc_OnRepaint`)                                               |
> | `EVT_DRAW` (0x1C0000D)    | nothing; each visible class draws its own rectangle here                                                                                            |
>
> So painting a screen is a depth-first walk of its view tree, and a hidden view (flag word bit 0) hides its
> subtree.  The tree links are the record's +4 super, +6 sub, +8 next and +10 prev words (`GetSuperView`,
> `GetSubView`, `GetNextView`, `GetPrevView`).  The `Ps*` value widgets draw in two steps: `EVT_DRAW` paints the
> box and the marker beside the panel switch that operates them (`DrawEditSw`), and `EVT_PARA_DRAW` paints the
> value text, so a value change redraws only the text.  Grids add `EVT_SELE_DRAW` for the cursor.
>
> [then the per-class table from notes/open4-kn5000-b/display/README.md, section kn5000-5dc, "Per class"]
>
> All drawing goes to the off-screen buffer; `UpdateScreen` copies the changed rectangle to VRAM (see
> [Display Subsystem]({{ site.baseurl }}/display-subsystem/#rendering-pipeline)).

**Page:** `display-subsystem.md`, "Widget Event Handlers": replace the four-row table with a link to that section,
and fix "EditSwitch | `EditSwProc` | Toggle/checkbox control" (EditSw is a Label that handles `EVT_SW_IN`; it is not
a toggle) and "TextBox | `TextBoxProc`" if kept.

---------------------------------------------------------------------------------------------------------------------

## kn5000-nmg: animation and transition effects

### Findings

**There is no screen-transition state machine.**  The page's "Screen Transition State Machine" rested on
`MainTitleCtrl_ChangeTitle`'s old header, which called three RAM words a transition progress counter, timer and
type.  Every reader and writer of those words (33 references per tree) is in the panel-switch code:

- `SwbtB3_OnPanelEvent` (`boot/main_title_ctrl_panel.s`) handles the 0xA9 switch records.  For switch group N
  (payload byte 1, 0..16) it sets `CtrlPanel_SwitchRowBit[N]` (1 << N) in 0x2749A when the group's UP switch
  (payload bit 1, switch number N) is pressed and clears it on release, and does the same in 0x2749E for the DOWN
  switch (bit 0, switch number N | 0x80).  When a press makes both halves of a group held it posts `EVT_SW_BOTH`.
- `CtrlPanel_DispatchCombinedState` stores the AND of the two masks in 0x274A2 and acts on four combinations:
  0x1100 (groups 8 and 12: LEFT 1 + RIGHT 1 and LEFT 5 + RIGHT 5) calls `CaptureLcd` when the firmware version
  byte is 0xFF; 0xA1 interrupts with `TITLE_SOFTVER`; 0x91 changes to `TITLE_PS`; 0x89 posts `EVT_SHOW` to object 7.
- `MainTitleControl` clears all three words on every mode and title change, and `RefreshApTask` / `RefreshSwEvent`
  on a panel refresh, so a held switch does not carry over to a new screen.  `AccPatch_ReadModeFlags` and a
  `scoop_display.s` reader OR the two masks to see whether any switch is held.

Renamed: `TRANSITION_PROGRESS` / `_TIMER` / `_FLAGS` -> `PANEL_SW_HELD_UP` / `_DOWN` / `_BOTH`.
`MainTitleCtrl_ChangeTitle` itself only records the title: PREVIOUS_TITLE := CURRENT_TITLE, ACTIVE_TITLE_PREVIOUS
:= ACTIVE_TITLE, CURRENT_TITLE = ACTIVE_TITLE := new id, then panel indicator request 0x61, the mask clear and
`AudioMode_ResetVoiceState`; the new screen is shown at once.  The "additional transition parameters" at
0x274A6-0x274AE are MainTitleControl's delayed requests: `MT_SetTitleFlag` stores the title-flags word at 0x274A8
with a count of 10 at 0x274AA, `MT_OtherPartLed` its request at 0x274AC with a count at 0x274AE, and
`MT_MainLoopCount` (once per main-loop pass) counts both down, latching the flags into 0x274A6 (read by
`CtrlPanel_GetSelectionState`) and applying the LED.  Now `TITLE_FLAGS_LATCHED` / `_PENDING` / `_DELAY`,
`OTHER_PART_LED_PENDING` / `_DELAY`, and the handlers `MainTitleCtrl_OnSetTitleFlag` / `_OnOtherPartLed` /
`_OnMainLoopCount`.

**"SlideMove" and "SlideBase" are bitmap names**, not slide animation: entries 3 and 2 of `BitmapIDProc_PtrTable`
(`idSlideMove` = file "slmove.bmp", `idSlideBase` = "slide.bmp"), next to `MixerControl` / `MixerPoint` -- slider
artwork.  No widget record in the C sources uses either id.

**What does exist** (already on the page, checked): palette changes (`ChangePalette`, `PaletteBankRotate`), the
fade-in / fade-out *setting* bitmaps of the Entertainer, blanking during large updates (`VGA_ScreenBlank`), timers
for UI repeat (`IvOneShotTimerProc`), and software scrolling (`MovePixels`).  None of them animates a change of
title.

### Website page draft

**Page:** `display-subsystem.md`, section "Animation and Transition Effects".
**(1)** Replace "### Screen Transition State Machine" and its text with:

> ### Title changes are immediate
>
> The firmware does not animate a change of screen.  `MainTitleCtrl_ChangeTitle` (0xF9936D), MainTitleControl's
> `EVT_CHANGE_TITLE` case, only records the title ids (`PREVIOUS_TITLE`, `CURRENT_TITLE`, `ACTIVE_TITLE`), requests
> a panel indicator update, clears the held-switch masks and resets the audio voice state; the new title's view is
> painted on the next screen update.  The RAM words 0x02749A / 0x02749E / 0x0274A2, once described here as a
> transition counter, timer and type, are the panel's held-switch masks (`PANEL_SW_HELD_UP`, `_DOWN`, `_BOTH`; see
> [Control Panel Protocol]({{ site.baseurl }}/control-panel-protocol/)), and 0x0274A6-0x0274AE hold
> MainTitleControl's delayed title-flag and "other part" LED requests, applied ten main-loop passes later.

**(2)** In "Scrolling", replace the last paragraph with: "`SlideBase` and `SlideMove` (0xEAB8D8) are the names of
bitmap resources 2 and 3 (`slide.bmp`, `slmove.bmp`), slider artwork beside `MixerControl` and `MixerPoint`; they
are not a slide animation, and no widget record uses them."
**(3)** "MAME Emulation Status": change the row `Page transitions | Partial | Palette fade works` to
`Palette changes | Working | ChangePalette / PaletteBankRotate (there are no title transitions to emulate)`.

**Page:** `control-panel-protocol.md`, after the 0xA9 switch table, add:

> **Held switches.**  `SwbtB3_OnPanelEvent` keeps two masks of the 0xA9 switch groups: bit N of `PANEL_SW_HELD_UP`
> (0x02749A) is set while group N's UP switch is held, bit N of `PANEL_SW_HELD_DOWN` (0x02749E) while its DOWN switch
> is.  Pressing the second half of a group posts `EVT_SW_BOTH`.  Their AND, `PANEL_SW_HELD_BOTH` (0x0274A2), picks
> four combinations: 0x1100 (LEFT 1 + RIGHT 1 with LEFT 5 + RIGHT 5) saves an LCD screenshot (`CaptureLcd`) on a
> debug build (version byte 0xFF); 0xA1 opens the software-version screen (`TITLE_SOFTVER`); 0x91 returns to
> `TITLE_PS`; 0x89 posts `EVT_SHOW` to object 7.  All three masks are cleared on every mode or title change.

---------------------------------------------------------------------------------------------------------------------

## Leads noticed, not acted on (for other lanes)

- `VwBox_HandleGetColor` (VwBoxProc's `EVT_GET_BOX_COLOR` target) sits inside unrelated code whose tail stores into
  (xwa+14) / (xwa+18); its label may be misplaced.
- `EditSw_ByteData` (ui/ui_window_procs.s) is code (it builds the edit-switch marker string and its position), and its
  internal labels are `DrawDesignFrame_Skip*`, borrowed from an unrelated routine; likewise `DrawWidget_Hline_N_*`
  inside the view-link helpers of ui/ui_widget_defs.s.
- `PsMenuBox_Paint` / `_Confirm` / `_HitTest` handle EVT_DRAW / EVT_PARA_DRAW / EVT_CHECK_EDIT_SW (same naming problem
  as PsGridBox, not renamed here).
- `VGA_Initialize` reads its 256-entry palette from the 16-bit address 0xE3E8, spelled as a number.

## Gates and censuses (2026-10-31)

- `make -j3 gate`: exit 0 at 3a20d0b7c (symbol files regenerated, `l2_symbol_reference.py --check` PASS).  The
  view-link headers added after it are comments only (v10 and v5 rebuilt and compared).
- `doc_quality_census.py --compare` (read-only): every touched figure fell (v10 routines without a header
  5471 -> 5469, numeric operands 18421 -> 18409; the same in v9, v7, v6) except **v5 routines without a header,
  7829 -> 7830, which is not this lane's**: the base commit 130735749 already measures 7832 (`--routines v5`, NO-HEADER
  count), and this lane takes it to 7830 (VGA_ConfigExtSequencer and VGA_WritePalette256_Unterminated gained headers;
  the new VGA_ConfigExtSequencer_AltA has one).  The committed snapshot doc-quality-2026-10-31-02 predates a merge.
