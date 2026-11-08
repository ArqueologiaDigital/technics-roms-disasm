# MAME probes: the PICTURE LOAD silence, the APC / SEQ VOLUME slider, panel buttons -> M3 ids

Lane kn7000-research (wave 11, 2026-11-06).  Every result below is **observed in emulation, not on
hardware**: the kn7000_mame overlay build `/home/fsanches/compartilhado/kn7000_mame_build/kn7000`
(Oct 31, md5 `8b9865bd2e3849bea134c97315c9781e`), driver `kn7000`, default BIOS v16 = program 941 /
table 84, ROMs from `~/compartilhado/technics_romsets` (folder `kn7000/`), the SD slot holding a
writable copy of `~/compartilhado/technics_roms/media/sdcard_from_real_kn7000.img`.  The build was
used read-only.  Runs are headless with the debugger core on and no debugger UI, so that breakpoints
can count routines (`-debug -debugger none`; the `none` module answers every stop with `go`).

Common command line (from a scratch run directory with `cfg/`, `nvram/`, `snap/`, `diff/`; the
environment variables each probe reads are in its header):

    timeout 1800 ~/compartilhado/kn7000_mame_build/kn7000 kn7000 \
      -rompath ~/compartilhado/technics_romsets -skip_gameinfo -video none -sound none -nothrottle \
      -debug -debugger none -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
      -diff_directory diff -harddisk sd_real.img [-wavwrite out.wav] -autoboot_script <probe>.lua

At `-nothrottle` with breakpoints armed the emulation runs at about a third of real time: a 50 s
script takes 2 to 5 minutes.  `-wavwrite` works with `-sound none` (3 channels, 48 kHz).

| probe              | question it answers                                                                                                                                                            | run (env)                                                                                        |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `ports_list.lua`   | which input ports / fields the driver exposes (the names the other probes press)                                                                                               | `OUT=ports.txt`, no `-debug` needed                                                              |
| `picload_keys.lua` | with a screen opened the firmware's own way (a ChangeTitle call redirected by a breakpoint), where does a key-bed note stop: counts of the key path's routines, TG port writes | `TITLE=0xD6 AFTER="LCDR 2" OUT=x.txt` (+ `-wavwrite`); `IOLOG_FROM` / `IOLOG_TO` for the I/O log |
| `wav_rms.py`       | is the instrument audible in a time window of a `-wavwrite` capture (RMS / peak per channel)                                                                                   | `python3 -I wav_rms.py out.wav 21-22.2 36.5-37.7`                                                |
| `m3_watch.lua`     | which M3 ids does the APC / SEQ VOLUME slider set, at home, in DEMO, on leaving DEMO                                                                                           | `OUT=m3.txt`                                                                                     |
| `m3_sweep.lua`     | which M3 ids does each of a list of panel buttons set (PutM3Em breakpoint, one window per button)                                                                              | `BUTTONS="PAD 1,FADE IN" OUT=s.txt`                                                              |
| `m3_panelctl.lua`  | which panel event does each continuous control the driver does not model send (TYPE 2 frames injected into the panel RX ring)                                                  | `FRAMES="10:20,d3:e0" OUT=p.txt`                                                                 |

`runs/` holds the text outputs the notes quote (small; the WAV captures, snapshots and SD-card copies
were scratch and are not kept: rerun the probe to regenerate them).

## The runs in `runs/`

The SD card copy was byte-identical to the real-card dump before every run (md5
`c3bcea2346cb3bb7d803e8c48aebce78`).  `picload_keys.lua` changed during the lane only by adding the
I/O log and its `IOLOG_FROM` / `IOLOG_TO` window (the first runs logged 0 .. 3.8 s and left the
0xFC00 TG class out); rerunning with the current file reproduces the counts.

| file                   | probe and environment                                                                         | what it shows                                                                                                                                                          |
|------------------------|-----------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ports.txt`            | `ports_list.lua`, `OUT=ports.txt`                                                             | the 233 input fields                                                                                                                                                   |
| `picload_sd_4.txt`     | `picload_keys.lua`, `TITLE=0x12B`                                                             | SD PICTURE LOAD opened straight from RECORD & EDIT                                                                                                                     |
| `picload_sswl_1.txt`   | `picload_keys.lua`, `TITLE=0xD6 AFTER="LCDR 1"`, `-wavwrite`                                  | the PICTURE LIST (LCDR 1 is no item there)                                                                                                                             |
| `picload_fd_1.txt`     | `picload_keys.lua`, `TITLE=0xD6 AFTER="LCDR 2"`, `-wavwrite`                                  | PICTURE LIST -> PICTURE LOAD -> SD PICTURE LOAD, the manual's way                                                                                                      |
| `wav_rms.txt`          | `wav_rms.py` on the last two runs' captures (md5 `a02c6863...`, `9a14e033...`)                | the audio of each key window                                                                                                                                           |
| `picload_fd_final.txt` | as `picload_fd_1`, the committed `picload_keys.lua`, fresh cfg / nvram / SD copy, `-wavwrite` | the same counts in every window; RMS 321.2 / 322.5 / 322.5 against 321.2 / 322.5 / 320.0 (the capture is not bit-identical: the first runs reused one nvram directory) |
| `io_ctl_1.txt`         | `TITLE=0xD6 AFTER="LCDL 5" IOLOG_FROM=4.5 IOLOG_TO=8`                                         | I/O writes while a press opens nothing (control)                                                                                                                       |
| `io_pl_1.txt`          | `TITLE=0xD6 AFTER="LCDR 2" IOLOG_FROM=4.5 IOLOG_TO=8`                                         | I/O writes while SD PICTURE LOAD opens                                                                                                                                 |
| `io_ctl_2.txt`         | as `io_ctl_1`, `IOLOG_FROM=9 IOLOG_TO=14`                                                     | steady state on the PICTURE LIST                                                                                                                                       |
| `io_pl_2.txt`          | as `io_pl_1`, `IOLOG_FROM=9 IOLOG_TO=14`                                                      | steady state on SD PICTURE LOAD (same writes as the control)                                                                                                           |
| `m3_watch_2.txt`       | `m3_watch.lua`                                                                                | the slider's M3 messages (window labels: see below)                                                                                                                    |
| `m3_sweep_1.txt`       | `m3_sweep.lua`, default BUTTONS                                                               | the M3 ids of eleven panel buttons                                                                                                                                     |
| `m3_panelctl_1.txt`    | `m3_panelctl.lua`, default FRAMES                                                             | the panel events of controls 0x10, 0x17, 0xD0, 0xD1, 0xD3                                                                                                              |

In `m3_watch_2.txt` each window's ids are printed when the NEXT window opens (`pre-<next>`) when the two
share a boundary: `pre-demo-enter` holds the home-slider window's ids, `pre-home-after` the demo-exit
window's.

## N-44e56012: the keys are not silent on PICTURE LOAD in emulation

**How the screen is reached.**  The owner's manual (QQTG0671 p. 91, "Loading your original images")
opens PICTURE LOAD from the STEP RECORD CONTROL display's PICTURE button (the PICTURE LIST,
`TT_SSWLIST`) and its PICTURE LOAD item.  Driving the panel that deep from Lua is fragile, so
`picload_keys.lua` presses PROGRAM MENUS, LCDR 2 (SEQUENCER) and, with a redirect armed, LCDL 3 (SEQ
MENU's RECORD & EDIT): AcTitleMenuProc calls `ChangeTitle` (0x4842B3EF, call entry 0x4842B3F4) with
d0 = 0xF0093, and a breakpoint replaces d0 by the wanted title index before the routine runs.  With
`TITLE=0xD6` the firmware itself opens the PICTURE LIST; pressing its PICTURE LOAD item (LCDR 2) then
makes the firmware call `InterruptTitle(0x12B)`: the SD PICTURE LOAD screen (`TT_PICTLDSD`,
`SdcFmmPictureLoadFunc`), the same path as on the instrument (no floppy is inserted; pressing DISK
there gives "ERROR 02: There is no disk in the disk drive.").  `TITLE=0x12B` opens SD PICTURE LOAD
straight from the RECORD & EDIT press.

**Observed** (C4 held 1 s; counts are breakpoint hits in the window; `runs/picload_fd_1.txt`,
`runs/picload_sd_4.txt`):

| window                         | KeyToPart | PartNotePost | TgcNoteOnSend | TgcBufWrite | TgPartKeyEvent | TG port writes | audio RMS ch0 / ch1 |
|--------------------------------|-----------|--------------|---------------|-------------|----------------|----------------|---------------------|
| home screen                    | 2         | 2            | 2             | 4           | 2              | 118            | 321.2 / 277.1       |
| SD PICTURE LOAD (manual route) | 2         | 2            | 2             | 3           | 2              | 118            | 322.5 / 277.4       |
| home again, after EXIT         | 2         | 2            | 2             | 3           | 2              | 118            | 320.0 / 276.8       |
| SD PICTURE LOAD, no key        | 0         | 0            | 0             | 0           | 0              | 0              | 0.1 / 0.1           |

The note messages are identical on both screens: `KeyToPart d0=10700000 d1=0000423c` (key 60,
velocity 0x42), `TgcBufWrite 04 90 10 3c 42` (note on, part 0x10 = RIGHT1) and `04 90 10 3c 00`
(note off), `TgPartKeyEvent d0=90 d1=10`.  The home screen's extra TgcBufWrite is a controller
message (`04 b0 10 c8 ..`).  So in emulation the note passes every routine of the path traced in
`../work-ram-map.md`, the tone generators receive the same 118 register writes, and the output is as
loud as on the home screen.  The same holds for the PICTURE LIST (`runs/picload_sswl_1.txt`) and for
SD PICTURE LOAD opened directly (`runs/picload_sd_4.txt`).

**What the firmware writes when the screen opens** (`IOLOG`, every distinct write to the two TG
register ports, the DSP host ports 0x98000000 / 0x9C000000 and the GPIO block 0x36008000..FF, from the
PICTURE LIST until SD PICTURE LOAD is up, against the same window with a press that opens nothing;
`runs/io_pl_1.txt`, `runs/io_ctl_1.txt`): no DSP port write in either; TG writes only to the idle
registers FC08..FC0B (0) in both; the SD PICTURE LOAD opening adds GPIO 0x36008004 := 0x84 (bit 1 low,
the SD card's chip select: the folder scan), 0x36008024 := 0 and 0x36008064 := 1.  Once the screen is up
(`runs/io_pl_2.txt` against `runs/io_ctl_2.txt`, 5 s including a key) the writes are the same distinct
set on SD PICTURE LOAD as on the PICTURE LIST: no further card access, the 0x36008004 bit 5 heartbeat,
the key's six voice registers per TG and the idle class.

**Reading.**  The emulated firmware does not gate the keyboard on this screen anywhere between the
key-bed FIFO and the tone generators' registers, and it writes nothing to the TG or DSP that would
mute them.  So the silence the manual describes ("After the PICTURE LOAD display appears, no sound is
produced on the instrument", p. 91; the SD chapter's "SD IN USE" box, p. 139, lists PICTURE LOAD (SEQUENCER)
with LOAD (TECH) PAGE 3, SD SONG MEDLEY, COPY FROM DISK and SD-SOUND EXPORT/IMPORT) is not produced by
any code path this emulation runs.  [INFERENCE] It comes from something the driver does not model:
the candidates are a hardware mute tied to the SD card access (GPIO 0x36008004 bit 1 is the only line
the screen's opening moves that the home screen does not), the GPIO strobes 0x36008024 / 0x36008064
(the driver's note: "strobe/select the sub-CPUs"), or tone-generator / DSP behaviour that differs from
the emulation.  **Followed up 2026-11-06 (lane kn7000-research2, `../audio-mute-probes/README.md`):** the
schematics' MUTE line (CN506 pin 1, the +15PM rail that biases the power amplifiers) is switched by the
PMUT net, CPU pin 148 = P04 (0x36008004) bit 2; the speaker / headphone switch SPSW and the D/A
converter's mode port hang on the latch at 0x98060000.  The firmware moves PMUT only at reset, at the end
of the boot and in the NMI handler, and in MAME none of the three lines changes on SD PICTURE LOAD (941
and 893).  So no mute line makes the silence either; what is left needs the instrument (that README,
section 4).

## N-e411f8fa / N-4b34dd8b: the APC / SEQUENCER VOLUME slider

The driver sends the slider (ioport `VOL_APCSEQ`) as the panel's TYPE 2 frame `[0xD2, data]`; the
firmware latches it in `PanelCtrlLatch32` (0x5006BEA6, inverted; the remapped value 0..0x7F in
0x5006BEAD) and `PanelCtrlValueGet(0xC2)` reads it back: "panel control 0xC2" is this slider (the
index drops the TYPE bits, so 0xC2 and the wire byte 0xD2 select the same latch).  **Observed**
(`m3_watch.lua`, `runs/m3_watch_2.txt`): moving it on the home screen posts M3 id 0x701009 (panel
event 0x1009) with the remapped value (0x19, 0x7F, 0x66 for adjuster 20, 100, 80) and sets neither
0x8006 nor 0x8008; leaving DEMO (EXIT), the panel's re-send sets 0x8006 := 0x7F and 0x8008 := 0x66,
the slider's current value.  That is `ApcSeqSliderRoute`'s case for `ApcSeqSliderOnSeq() == 0`, which is the
normal one: `ApcSeqSliderOnSeq` answers 0 in DEMO and, on a screen its title tables do not list, whenever
`GetSeqPlyPart()` is 0; it answers 1 when the sequencer has play parts (and on some SEQUENCER screens, by
title), and then the roles swap
(0x8008 := 0x7F, 0x8006 := the slider).  The firmware's parameter dump names the two (`PartParamDumpLine`,
`../presentation-control-probes/song_id_dump_names.py`): **0x008008 "APC VOLUME", 0x008006 "SEQ VOLUME"**,
each 0..127.  This matches the manual (p. 56: the slider lowers the automatic accompaniment; p. 85: with a
recorded performance playing, it lowers all the playback parts; MAX = their own settings, OFF = 0): the
slider drives the APC level normally and the sequencer level while a song plays, and the other is held at
127.  (Lane mn10300-data2's note read `ApcSeqSliderOnSeq` the other way round, "0 in DEMO mode or while the
sequencer plays"; the code returns 0 at its end when `GetSeqPlyPart()` is 0.)

**The other continuous controls** (`m3_panelctl.lua`, `runs/m3_panelctl_1.txt`; frames injected into the
RX ring, observed in emulation): wire 0x10 posts panel event 0x701011 (the remapped value), 0x17 ->
0x701020 (raw), 0xD0 -> 0x701005 (value / 2 remapped), 0xD1 -> 0x701004 (a 14-bit value, 0x3200 /
0x0D40 for data 0x20 / 0xE0: [INFERENCE] the pitch-bend wheel), 0xD2 -> 0x701009 (APC / SEQ VOLUME, above),
0xD3 -> 0x701010 (inverted: 0x7F / 0x11).  None of them sets an M3 parameter of its own through
PutM3Em at once.  0x008002 is "TOTAL EXPRESSION" in the parameter dump; `func_4C01D176` gives it
`PanelCtrlValueGet(0xC3)`, the 0xD3 control's latch, when the FOOT CONTROLLERS screen assigns the
expression pedal to TOTAL EXPRESSION (record 0x48 byte 2 = 0xB6, `AcFootSwProc_Table`), so [INFERENCE]
wire 0xD3 is the expression pedal input; on leaving DEMO the probe saw 0x8002 := 0x80, that latch's reset
value (`PanelCtrlLatchReset`).

**Panel buttons** (`m3_sweep.lua`, `runs/m3_sweep_1.txt`): PERFORMANCE PADS STOP posts panel event
0x702033, whose handler `TempoSyncE000Set` sets 0xE000 := 0x007F7F7F; FADE IN / FADE OUT ramp 0x8004
(0x7F down to 0x4E within the window, and on into the next); PAD 1 sets the pad parts' (0x1D / 0x1E)
controllers and program; START / STOP sets 0x000001 (1, then 0) and CC 64 of parts 0x13..0x14 (127 at start, 0 at stop).
