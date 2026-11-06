# Lane kn7000-research2 (2026-11-06, wave 12): the audio mute lines, 893's key transform, the custom kit

Wave 12 of the open-items work (`../../../notes/open-items/REGISTER.md`), continuing lane
kn7000-research (`../kn7000-research/README.md`).  Four items: the PICTURE LOAD silence (N-44e56012),
program 893's own routines (N-99771106) and the IC21 fields (N-b8f49b1e, with its pointer row
N-f3c6a3ea).  Every MAME result is observed in emulation, not on hardware; the probes and the exact
commands are in `../audio-mute-probes/README.md`.

## Items

| item       | outcome | where                                                                          | in one line                                                                                                                                                                                                                                           |
|------------|---------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-44e56012 | BLOCKED | `../audio-mute-probes/README.md`, `../work-ram-map.md`                         | the manual's MUTE line is PMUT = CPU pin 148, P04 bit 2; with SPSW and the D/A converter's mode port (latch 0x98060000) no mute line moves on SD PICTURE LOAD, statically or in MAME (941 and 893); what is left needs a key played on the instrument |
| N-99771106 | OPEN    | `../older-program-builds.md` "Still open"                                      | 0x48451649 named (`KeyZoneNoteResolve`, 941 0x484516EC, 935 0x484516AA) with `SoundTableKeyMapOn`; 893 own 3 -> 2 (`oldbuilds_b893_func_census.py`: 6,316 func_, own 2): the two SD AUDIO player routines left                                        |
| N-b8f49b1e | OPEN    | `../custom-data-ic21.md`, `../../src/customdata/customdata.inc`                | the custom-sound block's 0x27-byte header is a TABLE tone head (class, key map traced); its 128 references are per note; the voice record's +0x0D bits 0 / 2 enable its layers; the sub-record and element bytes are still to trace                   |
| N-f3c6a3ea | OPEN    | `../ic21-own/README.md` (pointer to `../custom-data-ic21.md` "Open questions") | pointer row; follows N-b8f49b1e                                                                                                                                                                                                                       |

## N-44e56012: the mute lines

`../audio-mute-probes/README.md` has the trace, the static census and the MAME runs.  In short:

- the service manual's MUTE line (FAJ CN506 pin 1, to the ASUB amplifier board) is the +15PM rail, which
  Q514 switches on only while the **PMUT** net is high; PMUT is MAIN CN301 pin 11 and, on the CPU sheet, IC4
  (MN103002A) **pin 148, P22**, the same port whose pins 149 / 145 / 144 / 142 the firmware already uses as
  `P04` bits 1 / 4 / 5 / 7: **PMUT = 0x36008004 bit 2**;
- a second switch, **SPSW** (FAJ CN501 pin 13, the FET switches Q502 / Q503 before the headphone and
  speaker stages), and the main D/A converter IC311's mode port (ML / MC / MDI) are outputs of the latch
  IC25, which the firmware writes at **0x98060000** (the program's `SdPowerCtrl*`; renamed here:
  `DacModeWordWrite`, `DacModeInit`, `AudioOutSwitchM3Handler`);
- the firmware clears PMUT at reset (P04 := 2) and in the NMI handler, and sets it at the end of
  `BootPanelResetCheck`; nothing else touches it.  SPSW follows M3 id 0x600009, which the code only ever
  sends as 1.  The D/A converter gets two mode words at boot (0x1220, 0x1380) and never another;
- in MAME (programs 941 and 893) PMUT, SPSW and the D/A mode stay "sound on" from the end of the boot
  through SD PICTURE LOAD, a key held on it, and EXIT.

So none of the instrument's software-driven mute lines makes the PICTURE LOAD silence.  BLOCKED on
the instrument: play a key on SD PICTURE LOAD with a card that holds pictures, and note whether the
sound stops for the whole screen or only while the card is read.  The emulated card answers at once.
The MAME driver gap, for the kn7000_mame owner, is section 5 of that README: PMUT is stored but not used,
and the IC25 latch is not modelled.  Nothing was changed in kn7000_mame.

## N-99771106: 893's own routines

`0x48451649` is 941's `func_484516EC`, now **`KeyZoneNoteResolve`** in 941 (and 935, `0x484516AA`, by port)
and in 893 (`kn7000_b893_own.sym`).  The key-bed router calls it for each zone a key sounds in.  It
copies the key and velocity, checks the zone, and reads the zone's part and that part's SOUND.  A TABLE
tone (a kit: `func_48449207` = 2) has its key mapped through `func_48449462` when M3 0x2025 is 1.  Any
other sound gets TRANSPOSE (M3 0x000003 - 64, when M3 0x2013 is 1) plus `func_48451060(8, zone)`.  893's
edit: its TABLE-tone test is a call of **`SoundTableKeyMapOn`** (893 `0x4845027B` = 941 `0x484502BD`, the
same code, also named now; 941 inlines it).  A kit with M3 0x2025 not 1 therefore gets TRANSPOSE in 893,
while 941 and 935 leave its key alone.  `func_48449207` and `func_48449462` keep their `func_` names,
because data labels are derived from them (`func_48449462_Records`, `_Table`).  Those labels belong to
the data regeneration (lane mn10300-data4's `gen_data_s.py`).  The names proposed for them are
`SoundKindGet` and `TableToneKeyMap`.

Still own in 893 (`../mn10300-names-probes/oldbuilds_b893_func_census.py b893`: 6,316 `func_` labels,
twin-unnamed 6,304, near-twin 10, own 2): the SD AUDIO player routines `0x485785B0` and `0x485788D8`
(`0x484101FD` was already `DspUnitsResetUnused` at the lane's base).  They
belong to a family of player routines (`func_4857890C`, `func_4857895B`, ...) that is unnamed in 941 too.
Next step: name 941's SD AUDIO player family, `0x485790A9`..`0x4857A0xx`, from its callers, the SD AUDIO
soft keys, and then name 893's two edited routines from their places in that family.

## N-b8f49b1e: the custom kit

The custom-sound block (`03custm3` slot 7) is a **TABLE tone**.  The tone library takes the block as the
part's tone record.  Its 0x27-byte header is the tone head: the name, class 0x40, the **key map** byte
`+0x11` (0..6, read by `func_48449462`), and 21 unread bytes, identical to 20 of the table flash's kits.
The 128 references are **one per note** (`TgNoteOnTableTone`).  A voice record's **`+0x0D` bits 0 / 2**
enable its two layers.  `src/customdata/` spells the header with the new `CSOUND_HEAD` macro
(`tools/gen_customdata_s.py`), and `make verify-customdata` reproduces all nine banks.  Details and the
next step: `../custom-data-ic21.md`.

## Commits and regeneration

Names go in `kn7000_manual.sym` and `kn7000_b893_own.sym`.  The ported files come from
`make symbols-sp7001 exports-941 symbols-935 symbols-893`, and the program sources from
`make program-src program-src-sp7001 program-src-935 program-src-893`.  The custom data comes from
`make customdata-src`.  `tools/gen_program_s.py` changed only in its routine-header comments for the
0x98060000 routines.

## Website page drafts

*For the technics-docs KN7000 pages; text only, another process publishes them.*

**Sound muting (hardware)** (new section on the KN7000 hardware page).  The KN7000 can silence its
built-in amplifier from software.  The main CPU's port line P22 (signal PMUT; GPIO byte `0x36008004` bit 2)
switches the +15 V bias supply of the power-amplifier stages on the ASUB board (+15PM, the MUTE line of
connector CN506).  The program holds it low from reset until the end of its start-up, and pulls it low
again when a power failure or system error triggers the NMI.  A second line, SPSW, opens or closes the
FET switches between the mixed sound and the headphone and speaker stages on the FAJ board.  It comes from
a six-bit latch at `0x98060000` (IC25), which also carries the USB-MIDI wait line, the SD board's mode line,
and the serial mode port of the main D/A converter.  The program writes the converter's two mode words
once at start-up.  None of these lines moves on the SD-card screens: the PICTURE LOAD silence the owner's
manual describes is not made by them.

**Drum kits and user kits** (the KN7000 sounds page).  A drum kit is a "table" tone: a short head (its
name, the class, and a key-map number 0..6) followed by one entry per MIDI note naming the drum voice that
plays it.  Each voice can sound one or two layers.  A user kit saved with a CUSTOM style has exactly this
layout, so the instrument plays it like a built-in kit.  The factory User Kit in the Custom Style disk's
third set has the same head as Standard Kit1.  When the relevant setting is on, the key-map number picks
which of seven key layouts maps the keyboard onto the kit.
