# open10-kernel4-probes -- lane open10/kernel4 (wave 10, 2026-11-06)

Five register items: the KN5000 main CPU's kernel joined to `wsa1/kernel/kernel.s` (L-kernel-a3-kn5000-maincpu),
prom_a's SoftTimer_Request_Boot header (L-kernel-a3-softtimer-boot-header), `kernel_join_probe.py --verify`'s stale
failures (L-kernel-a3-join-probe-stale), and two WSA1R screen questions (N-1e4a337c, N-813b5071).

| script                       | question it answers                                                                                                   | run (exact command)                                                                     |
|------------------------------|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| `format_screen_requests.py`  | What are screen 0x52 and (0x21E8) bit 2 behind HiddenKey_FloppyDiskFormatSelectType, and what is UI_Request 0x0201? | `python3 wsa1/notes/open10-kernel4-probes/format_screen_requests.py` (repo root)       |

## N-1e4a337c: the hidden key count on FLOPPY DISK FORMAT (screen 0x50)

`sub_FF657B` (now `HiddenKey_FloppyDiskFormatSelectType`) is the handler of KEY_SoftKeyCol4 and KEY_SoftKeyCol5Alt on
screen 0x50.  While (0x21E8) bit 2 is set it counts presses in DiskScreen_RowOption; the press after the eighth posts
UI_Request 0x8052.  Measured off the EPROM bytes (`format_screen_requests.py`):

* A2: `PanelScreen_VtableTable_ViewB[0x52]` (0xF86F41 + 4 * 0x52) holds 0xF872C1 = `PanelScreen_NullVtable`, four
  `jr` to one `ret`: screen 0x52 is an EMPTY screen in this build (81 of the 256 entries hold that object).
* A3: of the 19 instructions in prom_a and prom_b whose (#16) operand covers 0x21E8, none can set bit 2 (reads; `res
  3/5`, `set 3`; `xor 0x08`; `or 0x80`; `and 0x7F`).  No (#24) form names it.  Eleven instructions load a pointer to
  0x21E7 or 0x21E8; read by hand, every 0x21E7 one is used only as `(XIX)` until XIX is reloaded, and the 0x21E8 one
  (Playback_SilenceAll, 0xFE2E97) sets and clears bit 6 only.
* So the count can never run in this firmware, and if it ran, it would open an empty screen: a test feature whose
  screen was removed (an inference; a block move or a computed address that nobody has found could still set the bit).

## N-813b5071: UI_Request 0x0201 after a format

YES on the confirmation (LcdKeyRow3_FloppyDiskFormatAreYouSure) posts 0x0201 after DiskFormat_Execute_Entry.

* B1: (0x2071) = 0x02 is bit 1, which PanelState_RunRequests hands to PanelScreen_ApplyModeChange (0xF86318, `bit
  1,A`): a MODE request, not a screen request.  PanelMode_Normalise (0xF86344) turns a requested mode 1 into 1, or
  into 2 when (0x7F02) & 0xF0 == 0x10, the cell Mode_SwitchToCombination sets.
* B2: `PanelMode_ToScreenIdMap[1]` / `[2]` are screens 0x01 / 0x02, whose ViewB objects are
  T_InstallPainter_SoundMode_Entry and T_InstallPainter_CombinationMode_Entry.
* B3: six places post 0x0201: the format YES, EXIT on the DISK menu (ExitKey_DiskMenu), DiskSaveFile_SaveNow,
  MidiFilePlay_OnSongSelect, EditScreen_EnterNoteEdit and 0xFF7590.  So 0x0201 means "back to the play screen of the
  current mode (SOUND or COMBINATION)".

Both answers are now in the routine headers (`wsa1/prom_a/modules/ff3800_ff7fff_disk_menu_screens.s`); the label is
renamed by `scripts/renaming/rename_kernel4_wsa1_screens.sed`.
