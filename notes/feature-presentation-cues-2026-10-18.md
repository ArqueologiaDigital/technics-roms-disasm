# KN5000 / KN6000 feature presentations: what cues `<ACT NO=n>`, and can a user disk do it?

Investigation of 2026-10-18 (research agent; committed from its scratch). KN5000 addresses are v10
program ROM (`v10/maincpu/...` of this repository); KN6000 addresses are the linear KN6000 program
image `kn6000_prog.bin` (base 0x48400000; sha256 under *Reproduce*). The scripts are in
`feature-presentation-cues-probes/` (the *Reproduce* table calls it `scripts/`). The question came
with two others (KN7000 song records, KN7000 debug-screen reachability), answered in
`kn7000_disassembly/notes/presentation-control.md`.

## Verdicts

| # | question                                                  | answer in one line                                                                                                                                           | verdict                                                                                            |
|---|-----------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| 1 | what produces EVT_LSW_DATA 0xB80A                         | the sequencer replaying PART15-pan panel writes stored on track 14 of demo song 18; the value is the ACT number                                              | established (code + song bytes)                                                                    |
| 2 | what moves the drawbars                                   | track 0 (RIGHT1) of the same song writes drawbar record 0x44 at beat 104; the SoundEdit buffer is the sub-CPU reply channel, not song data                   | established (song bytes, record/playback maps); listener widget path inferred                      |
| 3 | can a user record such a song and make a FEATURE.PRE disk | yes in principle: real-time recording stores panel changes per track whitelist, a PART15 track records PART15 pan; SHOW OBJ searches every named view object | recording path established from code, never exercised; .SQT container and end-to-end disk inferred |
| 4 | KN6000 cue encoding                                       | track 14 event `pos B0 0E 0A n` = CC 10 (pan) of part 0x0E, value n = ACT number; firmware matches param 0x00B0000A, part 0x0E                               | encoding established (song bytes + firmware compare); playback-to-notification link inferred       |

## The mechanism in one paragraph

The "LSW id 0xB80A" is not a magic tag. It is the panel-parameter key of **PART15's pan**:
`0x8000 + 0x400*0x0E + 0x0A` (part tag 0x0E, Lsw number 0x0A = pan; descriptor
`SndParam_Part0E_Pan`, `audio/sndparam_records/run_edc980.c:2721`, record 0x0E byte +8, mask 0x7F,
range 0..127). The presentation is driven by the song setting PART15's pan to the number of the next
slide. Both ACT parsers say so: the KN5000 `<ACT>` handler (`demo/fdemotext_routines.s:1956-2061`,
0xF858D5) accepts `NO=n` **or `PAN=Ln / C / Rn`** (L n -> 64-n, C -> 64, R n -> 64+n) and stores the
ACT in a 128-entry slot table (pointer 0x024FD8) indexed by that value; the KN6000's (0x484ABF2E,
attribute list `NO`, `PAN` at 0x4C2010AC) does the same into 0x50286418.

## Q1 (KN5000): who produces EVT_LSW_DATA 0xB80A

The sequencer, replaying the Feature Presentation's own song. No timer, panel key or demo state
machine is involved; the demo countdown only starts the song. Full chain:

| step | what                                                                                                             | where (v10)                                                                                                                                       |
|------|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | demo song 18, track 14 (TRACK ASSIGN 0x13 = PART15) holds `B0 pos 0E 08 n 7F` panel-write events                 | Table Data ROM 0x8E0000 (SLIDE4K), decompressed cells 0x70 -> 0x1F (+0x7700, +0x2600)                                                             |
| 2    | sequencer playback hands each event to the audio engine; status bits 6:4 = 3 selects the 0xBn handler            | Audio_SyncAndProcessSequencer 0xFCAD44 -> VoiceMode_ParamDispatch 0xFCAD7D -> VoiceMode_ParamHandler_3 0xFCB001                                   |
| 3    | (tag, offset) must be in the track's playback whitelist; PART15's list has 0E/08 m7F handler 6                   | VoiceMode3_InitChannelMatch 0xFCB369, VoiceMode3_BuildChannelTable 0xFCB3D0, SeqTrackAssign_PlaybackMapTable 0xFCBFA3 (entry 19 -> 0xFCC38F)      |
| 4    | handler 6 writes record 0x0E byte 8 under the mask and queues SwbtWr event {0E, 08, value, changed bits}         | VoiceMode3_EvType6 0xFCB0F2 -> SwbtWr_FlushAndAppendParams 0xFC9663 -> SwbtWr_AppendFixedParamBlock 0xFC9D8F (queue 0xBD3C)                       |
| 5    | main loop dispatches the queue through bank 2; code 0x0E's list ends in UIState_KeyScan_Dispatch                 | SwbtWr_DispatchLoop 0xFDB32E, SwbtB2_Code0E_Listeners 0xEE8180                                                                                    |
| 6    | ACTIVE_TITLE 0xE4's watch list is 0xFFFE (all), so EVT_ASSSWB is broadcast with param (tag, offset, value, bits) | UIState_KeyScan_Dispatch 0xF98697, SSF_PresentationGateTable 0xE01F80 (title E4 -> 0xE01EA0), EventDispatch_Direct 0xFA9945                       |
| 7    | GroupBoxProc turns EVT_ASSSWB into LSW keys by reverse lookup and sends EVT_LSW_DATA {0xB80A, pan}               | GroupBoxProc 0xF9983F -> 0xF9A273 (misnamed GroupBoxProc_StartSSFPresentation), SndParam_ResolveWidget 0xFCD4FF, SndParam_LookupReadOnly 0xFCD437 |
| 8    | presentation control turns LSW 0xB80A into EVT_ACTION(value)                                                     | AcPresentCtrl_CheckSSFStart 0xF84625 (drawbar_panel_ui.s:18667-18680)                                                                             |
| 9    | ApPreControl runs the ACT whose 128-entry slot = value                                                           | ApPreControl 0xF86694 -> FDemo_ProcessDisplayStateQuery 0xF867B2, ACT slot table pointer at 0x024FD8                                              |

The song is demo preset 18 (`DemoSongPreset18`, Table Data ROM 0x8E0000; decompressed 38,144 B,
`table_data/includes/demo_presets/demo_preset_18.bin`, sha256 `1477b30c…f54b`). Its track 14 is the
one with the developer memo *"These area means CUE data"* (README of that directory). Track types at
+0x20: `00 02 01 0B 0F 09 0A 03 04 05 06 07 11 12 13 0C`, so track 14 = assign 0x13 = PART15
(`SeqTrackAssign_PartTagTable` 0xFCBA03). First cell bytes: `80 00 00 1F 00 | B0 05 0E 08 01 7F 81 81 …`.

The 0xBn event of the KN5000 song format is **not a MIDI CC**: it is a panel-record write
`B0|f, tick, tag, offset, value, mask` (6 bytes, `SeqEvent_GetParamLength`), where the low status
bits restore bit 7 of a field: bit 2 -> tag, bit 0 -> value, bit 1 -> mask (encoder
`MIDI_EmitRecord_B0` 0xFCA976, decoder `VoiceMode3_InitChannelMatch` 0xFCB369). So `B2 … 44 05 15 70`
in song 18 is record 0x44, byte 5, value 0x15, mask 0xF0.

The 23 cues of song 18 (beat = count of 0x81 markers on track 14):

| beat (0x81 count) | tick | value n | ACT n shows      |
|-------------------|------|---------|------------------|
| 0                 | 0x05 | 1       | ftdemo01 (globe) |
| 22                | 0x40 | 2       | ftdemo04         |
| 41                | 0x30 | 3       | ftdemo05         |
| 48                | 0x00 | 4       | ftdemo41         |
| 49                | 0x00 | 5       | ftdemo42         |
| 50                | 0x00 | 6       | ftdemo43         |
| 52                | 0x00 | 7       | ftdemo44         |
| 53                | 0x00 | 8       | ftdemo45         |
| 55                | 0x00 | 12      | ftdemo06         |
| 61                | 0x00 | 13      | ftdemo07         |
| 67                | 0x00 | 14      | ftdemo08         |
| 73                | 0x00 | 15      | ftdemo09         |
| 78                | 0x00 | 16      | Accordion        |
| 82                | 0x00 | 17      | Accordion        |
| 88                | 0x00 | 18      | ftdemo10         |
| 94                | 0x00 | 19      | Drawbar          |
| 123               | 0x00 | 21      | ftdemo20         |
| 133               | 0x00 | 22      | ftdemo21         |
| 138               | 0x00 | 23      | ftdemo22         |
| 142               | 0x00 | 24      | ftdemo23         |
| 143               | 0x00 | 25      | Sdmixer          |
| 150               | 0x00 | 26      | ftdemo24         |
| 156               | 0x00 | 27      | ftdemo25         |

ACTs 9, 10, 11 (ftdemo46, 47, 48) and 20 (the second Drawbar) are **never cued** by the ROM song:
no other track carries tag 0x0E, and only an assign-0x13 track may play 0E/08 back. So the ROM
presentation never shows ftdemo46-48 (verdict: established for the song data; not checked on hardware).

**Correction to the docs.** `feature-demo.md` "Path 1 — Manual (Physical Button Press)" and
`ssf-presentation.md` Stage 1-5 describe `GroupBoxProc_StartSSFPresentation` as building a
"workspace tag 0xB80A" from a button press. It builds nothing: it is the generic
`EVT_ASSSWB -> EVT_LSW_DATA` translator for every panel-record change (it loops over all LSW keys
that `SndParam_ResolveWidget` maps to the changed `(tag, offset, bits)`), and 0xB80A comes out only
because the changed byte is PART15's pan. The "SSF gate table" is a per-title list of watched
`(tag<<8 | offset)` record bytes; 0xFFFE for title 0xE4 means "watch everything". The "SwbtWr" events
are panel-record change events, as the October corrections already suspected.

## Q2 (KN5000): what moves the drawbars

Song 18 again: track 0 (assign 0 = RIGHT1) writes RIGHT1's drawbar record 0x44 (bytes 3-7, the nine
footages, Lsw 0x8280-0x8288) at beat 104, ten beats after ACT 19 (`Drawbar`, beat 94). RIGHT1's
playback whitelist contains `44/03..44/07` (0xFCBFF3), the write is announced as SwbtWr code 0x44,
whose bank-2 list is `UIState_KeyScan_Dispatch` + `FDemoText_ByteData_VoiceProbeC`
(`SwbtB2_Code44_Listeners` 0xEE841C; the second one flags the drawbar organ for a resend to the tone
generator). Under title 0xE4 the change reaches the screen as `EVT_LSW_DATA {0x828x, value}` (step 7
above). `IvDrawbarProc` (0xF824C4) handles `EVT_LSW_DATA` for its part and passes the rest to its
children (`InheritedProc`); that the footage sliders are the LSW listeners is inferred, not traced.
Other automation in song 18: volume ramps (`xx/03`), track 10 pan sweeps (`0A/08`, 397 events), RIGHT2
sustain toggles (`01/04` mask 0x08), program changes (0xCn).

**The SoundEdit buffer is not song data.** `SeqBuf_SoundEdit_ReadByte` (0xEF2E2C) reads ring 0x204DF,
which `SeqDMA_MultiWrite_SoundEdit` (0xEF3245) fills from **sub-CPU packets** (header bits 7:5 = 1,
routed by `INTTC0_HANDLER` 0xEF35E8 through `SeqRingBuf_WriteDispatch_Table`). The main loop drains it
(`SeMenu_ListSelector_Select` 0xF0EB67 -> `SeMenu_PopupDialog_Init` 0xF0E92F) and hands a record to
the title named in its byte +5, only if that title is `ACTIVE_TITLE`: 0x20-0x3F through
`ToneGen_ParamTable_0x326`, 0xEA through `FDemoText_ParseControlMessage` (0xF84B6F), which emits the
memory-drawbar LSW ids of `MemDraw_LswIdTable`. The records answer requests the main CPU sends with
`sendCOMM`; `FDemoText_SendResetMessage` (0xF84C61) sends `{0x82, part, 2, 2, 1, 0xEA}`, the same
title byte (inferred: request/response). During the presentation `ACTIVE_TITLE` stays 0xE4, so that
path does not run.

Can song records set arbitrary parameters? The format can name any record byte, but playback applies
only the `(tag, offset)` pairs in the track's whitelist, ANDed with the whitelist's mask:

| TRACK ASSIGN                  | part tag     | recorded (SeqTrackAssign_RecordMapTable 0xFCBA47)                                                                                                               | played back (SeqTrackAssign_PlaybackMapTable 0xFCBFA3)                          |
|-------------------------------|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| 0 RIGHT1 / 2 RIGHT2 / 1 LEFT  | 00 / 01 / 02 | B4 B1 B2 B3 (aftertouch, bend, mod, expression), tag/00 sound, +03 volume, +04 m48, +05, +07, +08 pan, +09, +0A, +0B, drawbar record 44/45/46 bytes 3-7, AD, AE | same part bytes (+03 h5, rest h6), drawbar 44/45/46 bytes 3-7, AD, AE, 9A/04-13 |
| 3-11, 17-19 (PART4..PART15)   | 03-0E        | as above without drawbars                                                                                                                                       | +03..+0B, AD, AE                                                                |
| 12 DRUMS                      | 0F           | B3, 00, +03, +04, +05, +07, AD, AE                                                                                                                              | +03, +04, +05, +07, AD, AE                                                      |
| 15 CONTROL                    | 00           | 48/03,04,00,07,08; 90/00,01,03; 60/01; 70/00,02; 98/0B,01,02,03; B0/01; 10-14/03; 72/03,07                                                                      | same set (handlers 0/1/6)                                                       |
| 13 CHORD / 14 APC / 16 RHYTHM | 15 / 15 / 00 | none / 48/03, 90/03, 10-14/03 / 48/00,08,07                                                                                                                     | 48/05,06 (+ APC: 48/03, 90/03, 10-14/03; RHYTHM: 48/07)                         |

Do they reach other screens? Only titles whose watch list contains the changed `(tag, offset)`:
title 0xEA (drawbar) watches 00-02 (2 each), 44 (8), 45/46 (5), 70; titles 0x20-0x3F (sound edit)
watch nothing (lists "disabled", `sequencer/ssf_gate_states.s`), they are fed only by the sub-CPU
replies. Title 0xE4 watches everything, which is why `Accordion`, `Drawbar` and `Sdmixer` come alive
when shown during the presentation.

## Q3 (KN5000): can a user record such a song and build a FEATURE.PRE disk?

**Recording (established from code, not exercised).** `MidiStream_ProcessTempoRingBuf` (0xFCA810)
scans the SwbtWr events queued since the last dispatch. It is called from `Audio_MainPeriodicUpdate`
(0xFC84A0, main loop `MainLoop_ReinitSwbtWr`, when the panel-write request queue 0xC039 is not empty)
and from `Audio_ProcessAllMidiStreams` (after MIDI input, `boot/system_handlers.s:1375`; also
`display/scoop_display.s:1814`, `midi/midi_dispatch_handlers.s:8328`). Its track mask (0x91C5) comes
from `MIDI_SelectTempoExpressionSource` (0xFCA770): in mode `MD_SEQ_REAL` (0x0B) with transport bit 2
set it is the record-track mask at 0x28A8 (MD_SEQ_STEP: 0x0D4F; titles 0x87/0x88: 0x28AA). For each
masked track, `TempoRing_InitPartStream` (0xFCAB09) loads that track's `SeqTrackAssign_RecordMapTable`
list (0xFCBA47) and a matching change is emitted as a `B0|f, tick, tag, offset, value, mask, track`
record (`MIDI_EmitRecord_B0`, `TempoRingBuf_ProcessEntry` 0xFCAB5F). The PART15 list (0xFCBE8B) has
`0E/08 m7F` (pan). So: assign a track to PART15, real-time record it, and set PART15's pan to the
slide number at each cue point; the result is byte-for-byte the factory cue format. The `PAN=` form
of `<ACT>` exists for exactly this: an author can key ACTs by the pan shown on the panel (L63..C..R63)
instead of 0..127. Caveat (inferred): the song's initial panel state is announced when it starts, so
PART15's starting pan fires its ACT too; put ACT `value` = the initial pan, or start with a cue at
tick 0 as the factory song does. Up to 128 slides (pan 0..127).

**The disk (inferred end-to-end).** `FEATURE.PRE` is `<PRESENTATION><EXEC SONG=n SRC="NAME"
NAME="title"></PRESENTATION>`; the EXEC handler (`FDemoText_ByteData_LayoutEngine` 0xF85729) stores
`SONG-1` at 0x024876 and requests `<SRC>.SQT` (`FDemo_DisplayResourceData` 0xF864A0) and `<SRC>.ACT`.
`.SQT` is the KN5000's own SEQUENCER file type (index 2 of `FileIO_TypeExtensions`; `SingleLoad_LoadSong`
reads 2048-byte song headers + cells). The presentation loader copies the first 0x800 header, skips
72 blocks when header byte +4 is 1, then copies the cells, so a whole-sequencer save from the disk menu
is the natural input; not verified by building one.

**SHOW OBJ lookup (established).** `FDemoText_GetInstanceID` (0xF8526E) walks object classes 255 down
to 0 and every instance that `CheckViewObject` accepts, comparing the OBJ string with the object's
`EVT_GET_NAME` name, or, when it has none, its title's name plus the instance number (`"%s%d"`). So
**any named view object** is reachable, not only slot 0xFD and the three live screens; classes are
searched from 255 down, first match wins. What an arbitrary screen does when shown inside the
presentation is unknown. A user `.ACT` can also draw its own slides: `<IMG SRC="file">` loads the file
from the disk on the first pass (`FDemo_FileOpenAndProcess`, `demo/file_demo_proc.s:492`) and lays it out
on the second (`FDemoText_ByteData_LayoutB`), plus `FONT`, `CENTER`, `BR` and text; that the KN5000 draws
only BMPs (`DrawBitmapFile_Impl`: "BM", <= 8 bpp) is inferred from the ROM path, not from a disk test.

## Q4 (KN6000): the cue in the 'I KD' songs

Same mechanism, MIDI-style encoding. The four `.SQT` files (sha256 below) are `I KD` + `00 01 00 F0`,
part 1 (0x5460 = 10 song records of 0x876) and part 2 (cells of 256 B, the KN5000 cell layout:
`[3..4]` next, payload `[5..255]`), both raw deflate. Song 1's track directory sits at +0xD0 as on the
KN5000. Events are `tick, status, data…`, and CC events are `B0 part cc value`. Track 14 of every song
holds only `B0 0E 0A n`, CC 10 (pan) of part 0x0E, with `n` stepping through the ACT numbers
(`scripts/kn6000_find_cue.py`):

| disk     | song       | ACTs in .ACT | track 14 cue values (event `pos B0 0E 0A n`)                          | spacing       |
|----------|------------|--------------|-----------------------------------------------------------------------|---------------|
| CA-6FP01 | WESERL.SQT | 1-25         | 1..15, 12..15, 16..24, 21..25 (33 events; refrains repeat ACTs)       | 16 or 8 beats |
| CA-6FP02 | SEXYGI.SQT | 1-20         | 1..21 (21 events; 21 has no ACT)                                      | 12 beats      |
| CA-6FP03 | HANDY.SQT  | 1-8          | 1..8 (8 events)                                                       | irregular     |
| CA-6FP04 | LETSGE.SQT | 1-20         | 0..17 (18 events; 0 has no ACT; a further 18 sits after the 0x82 end) | 8 beats       |

Firmware side (KN6000, disassembled with `scripts/dis6.sh`):

* The presentation control proc at **0x484CDB31** dispatches through the table at 0x4860D1B4. Its
  handler for event **0x01800014** (0x484CDD50) takes the record pointer, and if
  `(word0 & 0x00FFFFFF) == 0x00B0000A` (B0 = controller, 0x0A = pan) and `word1 >> 24 == 0x0E`, posts
  event **0x01800004** with `word1 & 0xFF`. This is the KN5000's `AcPresentCtrl_CheckSSFStart`, with
  the parameter named `{status B0, controller 0A, part 0E}` instead of Lsw key 0xB80A.
* Event 0x01AF0032 (0x484CDD1E) reads the current value of that parameter (`0x0E000000`,
  `0x00B0000A`, call 0x484259FF) and posts 0x01800004 with it: the slide for the pan PART15 already
  has is shown at start.
* Event 0x01800005 (0x484CDBC9 -> 0x484CDC66) steps a counter at 0x50003630 by +-1 (1..0x7F) and
  writes it as the same parameter (`0x00B0000A`, `0x0E000000 | value`, call 0x4840E543): manual slide
  stepping goes through PART15's pan too, and relies on the parameter-change notification to come
  back as 0x01800014 (this is what makes the "playback -> 0x01800014" link credible; not traced).
* 0x01800004 reaches the main pre-control table at 0x48601340 (entry key 1, handler 0x484AD077):
  `0 <= n <= 0x7F`, `a0 = [0x50286418 + 4n]`, run the ACT (0x484ABAF2) if not empty.
* The KN6000 `<ACT>` handler 0x484ABF2E fills that table from `NO=` or `PAN=` exactly as the KN5000's.

KN7000-style `0x8A` picture events are absent (`kn7000_mame tools/slideshow/kn6000_sqt_pic_scan.py`);
they are not needed. The KN6000 tag table (0x48600F80) also carries a short name table
`Sdmixer -> 0x0C, Drawbar -> 0x0E, ChordFinder -> 0xEE` beside `"Error! (GetInstanceID)"` (0x48600FC0);
how SHOW uses it was not traced.

## Reproduce

Scripts: `feature-presentation-cues-probes/` (named `scripts/` below). Decoded inputs are not
committed; they regenerate from the ROMs and the CA-6FP disks with these scripts.

| script (under scripts/)   | question it answers                                                                               | command                                                                                                               |
|---------------------------|---------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| dump_demo_track.py        | what events does one track of a decompressed demo song hold (track 14 of song 18 = the cue track) | `python3 -I scripts/dump_demo_track.py <repo>/table_data/includes/demo_presets/demo_preset_18.bin 14`                 |
| scan_demo_panel_events.py | which 0xBn panel-write events (tag, offset) does each track of a demo song carry                  | `python3 -I scripts/scan_demo_panel_events.py demo_preset_18.bin --summary`                                           |
| dump_track_assign_maps.py | which (tag, offset) pairs a track of each TRACK ASSIGN records and plays back                     | `python3 -I scripts/dump_track_assign_maps.py <repo>/original_ROMs/kn5000_v10_program.rom`                            |
| extract_kn6000_pres.py    | the files of the four CA-6FP floppies                                                             | `python3 -I scripts/extract_kn6000_pres.py kn6000-files ~/compartilhado/tmp/kn6000-presentations/ca6fp0[1-4]_std.img` |
| kn6000_sqt_decode.py      | the two inflated parts of an 'I KD' .SQT                                                          | `python3 -I scripts/kn6000_sqt_decode.py F.SQT prefix`                                                                |
| kn6000_song_events.py     | the non-note events per track of song 1 of a decoded 'I KD' .SQT                                  | `python3 -I scripts/kn6000_song_events.py p_part1.bin p_part2.bin`                                                    |
| kn6000_find_cue.py        | which (track, status, a, b) event group counts 1, 2, 3 ... (the ACT cue)                          | `python3 -I scripts/kn6000_find_cue.py p_part1.bin p_part2.bin`                                                       |
| dis6.sh                   | KN6000 disassembly of a range (copy of tmp/kn6000-pres/dis6.sh that slices into this directory)   | `scripts/dis6.sh 0x484CDB31 0x484CDDE0`                                                                               |
| mdtable.py                | aligned Markdown tables for this file                                                             | `python3 -I scripts/mdtable.py < rows`                                                                                |

Input hashes (sha256):

* `kn5000-roms-disasm/original_ROMs/kn5000_v10_program.rom` `9a054eef0f40f49ce098c70883498d1db807ad357538498a7fe2044a5f45e644`
* `…/original_ROMs/demo_preset_18_compressed.original.bin` `0bc7dabb6d29d429278ea9beb4d3d95806842ba08fe07fcf2313c1da5493654e`
* `…/table_data/includes/demo_presets/demo_preset_18.bin` `1477b30c39206ffdb7431fb22da0e1c769da7ad6e5f460bc3eecd4a32792f54b`
* `tmp/kn6000_prog.bin` `04048135f833c6a31daec5adeab1829da130b6e9de482676ef3470a7709af40f`
* WESERL.SQT `e947021d…03b7`, SEXYGI.SQT `7b0a835d…12f`, HANDY.SQT `f5679abc…1ec7`, LETSGE.SQT `5fe44eff…24a9`
  (extracted from `tmp/kn6000-presentations/ca6fp0N_std.img`; full hashes: `sha256sum kn6000-files/*/*.SQT`)

## Open

* The KN6000 path from a played `B0 0E 0A n` to event 0x01800014 (inferred from the handlers above
  and the MAME runs F01-F04, where the slides follow the song).
* Whether a disk-menu `.SQT` save loads as `FEATURE.SQT` unchanged (header byte +4, `SONG=`).
* Whether a PART15 pan edit made on a screen while recording passes through one of the recorder
  scans above. The edit goes through `SoundParam_NotifyChange`; its descriptor callback either appends
  the SwbtWr event directly (types 1/2) or queues a write request on 0xC039 (type 4,
  `SndParam_WidgetDispatch`, `audio/sndparam_routines.s:2856`); which one a mixer edit takes was not
  traced. The record whitelist listing `0E/08` for PART15 tracks says it is meant to be recorded.
* What `SHOW` of an arbitrary named screen looks like inside the presentation.
