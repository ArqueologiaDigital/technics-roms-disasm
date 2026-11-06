# Lane kn7000-research (2026-11-06, wave 11): MAME runs, song-record ids, 893's own code, IC21 fields

Wave 11 of the open-items work (`../../../notes/open-items/REGISTER.md`).  Five items: the PICTURE LOAD
silence (N-44e56012) and the unknown song-record ids (N-e411f8fa) with the kn7000_mame overlay build, the
names of program 893's own routines (N-99771106), and the IC21 fields still to trace (N-b8f49b1e, with
its pointer row N-f3c6a3ea).  The MAME probes and their outputs are in `../picload-silence-probes/`
(README there: every MAME result is observed in emulation, not on hardware); the other items' evidence
is in the note that listed them.

## Items

| item       | outcome | where                                                             | in one line                                                                                                                                                                                                                      |
|------------|---------|-------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-44e56012 | OPEN    | `../picload-silence-probes/README.md`, `../work-ram-map.md`       | in MAME the key reaches the TG on SD PICTURE LOAD (same 118 register writes, same loudness) and the screen writes nothing that mutes; next: trace the service manual's MUTE lines to their CPU pin, or measure on the instrument |
| N-e411f8fa | CLOSED  | `../presentation-control-probes/song-records.md` sections 3 and 6 | the firmware's parameter dump and three MAME probes name every listed id; 0x8006 / 0x8008 are SEQ / APC VOLUME; 0x20008C-8F were never on the lists (they hold 0x200088-8B)                                                      |
| N-99771106 | OPEN    | `../older-program-builds.md` "Still open"                         | the JPEG encoder named in 941, 893 and 935 (3 of 893's 7 own routines); 0x484101FD's name waits for the data regeneration; 0x48451649 = 941 func_484516EC, next step its callees                                                 |
| N-b8f49b1e | OPEN    | `../custom-data-ic21.md`, `../../src/customdata/customdata.inc`   | TCMP variation +0x00..+0x02 / +0x18 / +0x19, style +0x70, the part set-up's reader and four pad setting bytes traced; the m<id> names handed over; the voice record's fields untouched                                           |
| N-f3c6a3ea | OPEN    | `../custom-data-ic21.md` "Open questions"                         | pointer row: follows N-b8f49b1e (the blocked rows are unchanged)                                                                                                                                                                 |

## Handed over: panel-memory field names (N-b8f49b1e)

`src/include/panel_memory.inc` is written by `floppy/tools/kd/gen_panel_macros.py` (its field table
`PART_FIELDS` and the other records'), outside this lane's files.  The firmware's parameter dump
(`../presentation-control-probes/song_id_dump_names.py`) labels these `m<id>` fields; the proposed names
for the next run of that generator:

| field     | parameter                  | firmware label (PartParamDumpLine)                                                    | proposed name  |
|-----------|----------------------------|---------------------------------------------------------------------------------------|----------------|
| `m000000` | 0x000000                   | MASTER TUNE (Hz)                                                                      | `master_tune`  |
| `m0000a0` | 0x0000A0                   | MSA (ON / OFF)                                                                        | `msa_on`       |
| `m008008` | 0x008008 (bit 7: 0x008009) | APC VOLUME                                                                            | `apc_volume`   |
| `m00c080` | 0x00C080                   | APC TYPE                                                                              | `apc_type`     |
| `m00c081` | 0x00C081                   | APC TYPE (replaces 0xC080 when non-zero)                                              | `apc_type_alt` |
| `m00d000` | 0x00D000                   | RHYTHM SYNCHRO                                                                        | `rhythm_sync`  |
| `m200080` | 0x200080                   | DRAWBAR TYPE (ROCK / JAZZ)                                                            | `drawbar_type` |
| `m2000b0` | 0x2000B0-B7, one bit each  | TAB FLUTE 16', 8', 4', 2 2/3', 2', 1 3/5', 1', TROMBONE 16'                           | `tabs_1`       |
| `m2000b8` | 0x2000B8-BF, one bit each  | TAB TRUMPET 8', KINURA, CLARINET, VOX HUMANA, VIOLIN, PERC. 4', PERC. 2 2/3', VIBRATO | `tabs_2`       |

## Website page draft

*For the technics-docs KN7000 pages (another process publishes them; text only).*

**Picture loading and sound** (`../picload-silence-probes/README.md`).  The owner's manual says the
instrument produces no sound while the PICTURE LOAD display is up (and on four other SD-card screens).
In the MAME emulation of the firmware a key played on that screen goes through exactly the same steps
as on the home screen and is heard at the same level, and opening the screen touches nothing in the
tone generators or the effects DSP, only the SD card's select line.  So the silence is not made by the
program as far as the emulation runs it; it is most likely a hardware mute tied to the card access,
which the emulator does not model.

**The APC / SEQUENCER VOLUME slider** (`../presentation-control-probes/song-records.md`).  The slider
reaches the firmware as one of the control panel's continuous controls.  Normally it sets the APC
VOLUME (the automatic accompaniment), and while the sequencer plays it sets the SEQ VOLUME (all the
playback parts); whichever it does not drive is held at full level.  The firmware's own parameter list
also names the TOTAL EXPRESSION level the expression pedal sets, GLIDE, APC HOLD, the performance pads'
volume and mute, and every DIGITAL DRAWBAR and TAB ORGAN setting a song can record.

**Custom styles** (`../custom-data-ic21.md`).  Each variation of a stored style remembers which
built-in style it was copied from, and which two style parts the style's two DSP effects apply to; the
style itself carries the two effect presets.  A user performance pad stores its record key and chord,
its length in measures, its time signature and its LOOP and SYNCHRO switches.
