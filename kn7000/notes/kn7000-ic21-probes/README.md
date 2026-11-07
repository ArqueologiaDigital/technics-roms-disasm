# kn7000-ic21 probes (lane kn7000-ic21, wave 13, 2026-11-07)

Which program-941 code reads which byte of an IC21 CUSTOM record while the instrument uses it: the user
kit of `03custm3` slot 7 (its custom-sound block), the slot's "TCMP" style and its "TPAD" pads, and, for
comparison, the table flash's 'JK' voice archive that the built-in kits come from.  Lane notes:
[`../kn7000-ic21/README.md`](../kn7000-ic21/README.md).

Every MAME result here is **observed in emulation, not on hardware**: the kn7000_mame overlay build
`/home/fsanches/compartilhado/kn7000_mame_build/kn7000` (built 2026-11-06 22:49, after kn7000_mame b0fd265;
md5 `20455440aa8db9739bf9f930e6066dec`), BIOS v16 = program 941, used read-only with every MAME directory
in scratch.

| file               | question it answers                                                                                                                                                                                 | run (from `kn7000/`)                                                                                        |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `make_rompath.py`  | how to boot the MAME build with a given factory bank in IC21's CUSTOM memory (the driver delivers `kn7000_custom_data.rom` halfword-swapped, so the script swaps it first)                          | `python3 -I notes/kn7000-ic21-probes/make_rompath.py ~/compartilhado/technics_romsets/kn7000 BANK.ic21 OUT` |
| `kit_readers.lua`  | in MAME, with CUSTOM slot 7 selected and its pads played, which PC reads which byte of the tapped regions (the kit block, by default); breakpoints count the kit routines and log the pad selection | see below                                                                                                   |
| `reader_fields.py` | which record and field each logged read is (from the generated sources' macros), and which routine read it (from `build/kn7000_program.labels`); one row per field                                  | `python3 -I notes/kn7000-ic21-probes/reader_fields.py RUN.txt [--table-labels T] [--phase P]`               |

## The runs

Rompath: `make_rompath.py` with `03custm3.ic21` into `~/compartilhado/tmp/open14-kn7000-ic21/rom`.  From a
scratch run directory with `cfg/ nvram/ snap/ diff/` (a fresh `nvram/` each time: the firmware writes
IC21), about 4 minutes each:

    REDIRECT_PAD=0x200000 REGIONS="kit=968E0100-968E49A6,tcmp=968E4C27-968E8868,tpad=968E8869-968E8FAF" \
    OUT=kit_readers.txt timeout 2400 ~/compartilhado/kn7000_mame_build/kn7000 kn7000 \
      -rompath ~/compartilhado/tmp/open14-kn7000-ic21/rom -skip_gameinfo -video none -sound none -nothrottle \
      -debug -debugger none -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
      -diff_directory diff -autoboot_script <kn7000>/notes/kn7000-ic21-probes/kit_readers.lua

The second run takes `REGIONS="kit=968E0100-968E49A6,archive=4806EA98-48138FFF"` instead, and its fields need
the table build's label addresses:
`python3 tools/kn7asm.py src/table.s -I . -o SCRATCH/table.rom --labels SCRATCH/table.labels`, then
`reader_fields.py RUN.txt --table-labels SCRATCH/table.labels`.

Slot 7 is in blocks 24..25 (`0x968E0000`); its record header gives the custom-sound block at `+0x100`
(`0x48A7` bytes), the TCMP container at `+0x4C27` (`0x3C42`) and the TPAD container at `+0x8869`
(`0x747`).  The probe's route: CUSTOM, LCDR 3 ("8: Bossa Nova", slot 7), PERFORMANCE PADS/AUTO, then
START/STOP and PAD 1 ("PERCUSSION": its part 1 is the user kit `{0, 0, 0x19}`), PADS STOP and PAD 4
("RIDE BELL", part 0 the kit), then keys C2..C6 with pads and rhythm stopped.

**The pad redirect.**  With this route the firmware never selected the CUSTOM style's own pads: every
`PadSelectById` call got a built-in bank id (`0x371`, `0x178`, the run logs), and no byte of the TPAD
was read.  `PadSelectById` takes a CUSTOM style's TPAD only for an id with `0x200000` set.  So
`REDIRECT_PAD=0x200000` replaces the id of the first call from the pad1 phase on (a debugger breakpoint at
`0x48433FEE`, d0 / d2 := 0x200000), the way lane kn7000-research's picload probe redirected a title.
From there the firmware's own code binds the pads (`PadBindCustom`) and plays them; the kit reads come
from the pad streams' notes.  How the instrument itself selects a CUSTOM style's pads was not traced.

| run file                            | what it shows                                                                                                                                                                                                                                                                   |
|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `runs/kit_tcmp_tpad_941.txt`        | the raw log (kit, TCMP and TPAD regions): `R` lines, the `H` breakpoint counts (`TgNoteOnTableTone` 74 times on the pad parts: 0x1E is pad 1's part 1, the user kit, 0x1D its part 0, a built-in kit; `CustomVoiceRecFetch` 84), the `B` bucket counts of the whole slot record |
| `runs/kit_tcmp_tpad_941.fields.txt` | `reader_fields.py` of that log: the readers of each kit, TCMP and TPAD field                                                                                                                                                                                                    |
| `runs/kit_archive_941.fields.txt`   | `reader_fields.py` of the archive run (its raw log is 1.7 MB and is not committed; regenerate it with the command above)                                                                                                                                                        |
| `runs/kit_archive_941.log.txt`      | that run's log without its `R` lines (timeline, `H` and `B` counts)                                                                                                                                                                                                             |

## What the signals mean

- An `R <region> <phase> <pc> <offset> <count>` line is a CPU read through MAME's read tap.  The PC is the
  CPU state's CURPC at the time of the bus read, which this core reports 1 byte past the instruction's start
  (`0x4C02FC98` for the `movbu (a0), d2` at `0x4C02FC97`); `reader_fields.py` takes the routine whose label
  is the nearest at or below the PC, skipping `loc_<8 hex>` labels, so this offset cannot cross a routine
  boundary except at a routine's first byte.
- A field is "read" when a routine fetched it while the kit played.  A field with no row was not read in
  this route: that is evidence of absence for this route only (an edit screen may read more).
- `func_4844B07D` reads whole archive voice records (a copy); `memcpy` / `strncpy` rows are copies too.
