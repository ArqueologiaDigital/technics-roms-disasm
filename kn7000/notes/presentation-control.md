# Can a presentation disk open screens and operate the instrument? (2026-10-18)

Three questions from the owner:

1. Does the KN5000's internal Feature Presentation use the same technique as the
   feature-presentation disks?
2. Can a floppy (or an SD card) carry a presentation that opens screens and operates the
   instrument?
3. Could that reach the KN7000's Panel Simulator or LCD capture without the SP7001 build?

Evidence: `presentation-control-probes/reachability.md` and `song-records.md` here (static,
PROGRAM 941); `kn5000-roms-disasm/notes/feature-presentation-cues-2026-10-18.md` (KN5000 v10 and
KN6000); the MAME runs SHOW1/SHOW2 in `kn7000_mame/tools/slideshow/` (published overlay build, md5
`f88039d7908c07715d38044e1c1cd927`).

## 1. Same engine, and the song does the driving

The KN5000's built-in presentation is an `.ACT`-style script in ROM (`hkst_55.ssf`: `<ACTION>`,
`<ACT NO=n><SHOW OBJ="…">`), run by the same controller that loads a disk's `FEATURE.PRE` / `.ACT` /
`.SQT`. Its live screens (Accordion, Drawbar, Sdmixer) are just named view objects that `SHOW` puts
up. What makes it move is the song (demo song 18, Table Data ROM 0x8E0000):

- **Slide steps are PART15's pan.** Track 14 (assigned to PART15, the one with the developer memo
  "These area means CUE data") writes PART15's pan to n; the panel-change notification for that
  setting (Lsw key `0xB80A` = PART15 pan) becomes `EVT_ACTION(n)`, which runs `<ACT NO=n>`. The
  `<ACT>` parser also accepts `PAN=Ln / C / Rn` for exactly this. 23 cues; ACTs 9-11 and 20 are never
  cued by the factory song.
- **The drawbars move because the song sets them.** Track 0 (RIGHT1) writes RIGHT1's drawbar record
  at beat 104, ten beats after the Drawbar screen is shown; the screen follows because title 0xE4
  (the presentation) watches every panel setting.
- **The KN6000 disks do the same with MIDI:** track 14 of each CA-6FP song holds only `B0 0E 0A n`,
  controller 10 (pan) of part 0x0E, n stepping through the ACT numbers; the KN6000's presentation
  proc 0x484CDB31 matches that parameter and runs ACT n.

So the KN5000 technique is the disks' technique: script for what to show, song for when and what
to change. Its song events are not MIDI controllers but panel-record writes, filtered by a per-
track-type whitelist; a user could record such a song (pan moves on a PART15 track) on the
instrument (established from code, not run).

## 2. On the KN7000: screens can be painted, settings can be played, screens cannot be switched

What a KN7000 `.ACT` can do (tag table 0x486AF204):

| tag    | handler      | effect                                                                                                |
|--------|--------------|-------------------------------------------------------------------------------------------------------|
| `SHOW` | `0x4857FB88` | looks `OBJ` up over every GUI view slot (`0x48580EE6`) and sends the object `EV_PAINT` (`0x00050009`) |
| `DA`   | `0x4857F73D` | `MT_SleepMainTask`, `LibParamSet(0x90600007, NO 0..3)`, `MT_WakeUpMainTask`                           |
| others | —            | pictures, text, fonts, the score band, USER slots (see the kn5000-docs slide-show page)               |

`EV_PAINT` is the ROM's own name for 0x00050009 (event names table 0x48726BF0, class 5; MT names
0x48726CE4, class 6). So `SHOW` draws an existing object; it does not make it the active screen. In
MAME (run SHOW2) the demo screens resolve (`fdemo_a1` = object 0x2900002, `fdemo_a5` = 0x290000D,
`fdemo_b1` = 0x2900025, view slot 0x29) and are painted; `PPanelSimulator`, `simulator1`,
`DbMemoryDump` and `DbVariableMenu` are not object names (lookup -1).

What a KN7000 song can do (`song-records.md`): notes, tempo, PIC slide cues, controller / program
changes, and parameter events with any 24-bit id, filtered per track kind: a CONTROL track can play
rhythm, variation, intro, fill, ending, start/stop, tempo, transpose, panel-memory number,
TECHNI-CHORD and fade; part tracks voices and mixer. The open screen follows (`EV_MMMDATA`), and the
recorder captures panel operations into those tracks, so an automated demo can be recorded on the
instrument. A song cannot store SysEx (SysEx in an SMF is converted at load), cannot change global
effect types, and nothing in it switches screens.

From an SD card: `FEATURE.PRE` is read from the floppy only, but a song loaded from SD brings its
`.ACT` and pictures with it and its PIC points show the slides (kn7000_mame `tools/slideshow`, run
SEQ3), so `SHOW` slides work from SD too.

## 3. No route to the Panel Simulator, DEBUG TOOLS or LCD capture on 941

`reachability.md`: of the 103 `ChangeMode` calls, the only one with mode 0 is the gated chord
(`0x484148EC`, gate `0x484148E4` on the release byte `0x4840000F` = 0xFF); title 0xFF is opened only
from inside the Panel Simulator; `CaptureLcd` has only the two gated chord callers, and
`CaptureLcdArea` / `CaptureLcdCheck` have none. No mode or title changer is called from the
slide-show engine, the demo loader, the song loader, the file layer, the SMF parser or the MIDI
receive handlers, and every data-driven `ChangeMode` / `ChangeTitle` reads ROM tables. A
presentation can at most paint objects that exist; the debug screens are not among the names `SHOW`
finds, and painting would not make them operable anyway. The doors stay the release byte (0xFF in
the SP7001 build 942) or a patched ROM.
