# DSPTONE: our own program on the KN7000's effects DSP (iteration 1)

The KN7000's tone generators play only what is in their wave ROMs. Sound of our own therefore has to come from
the effects DSP: IC306, an ADSP-21065L ("SHARC") with 1M words of SDRAM. It has no boot ROM. The main CPU (an
MN10300) host-boots it at every power-up and streams in the effect programs, which are embedded in the firmware
(`../../dsp/README.md`). DSPTONE is the first small step towards sound we supply. It is a program-menu application
(folder `DSPTONE\`) that:

1. puts a DSP program of our own into the running DSP, through the firmware's own host-port routines;
2. plays a 440 Hz sine, then (CHIRP) a one-second PCM sweep that the main CPU copied into the DSP's SDRAM;
3. stops on a button (STOP, or EXIT held), puts the firmware's own effect back exactly as it found it, and reads
   it back to prove it.

The screen shows each step as it happens: what was found and loaded, the DSP's frame count, what is playing, and
any error.

Contents: [On the instrument](#on-the-instrument) · [How the firmware runs the DSP](#how-the-firmware-runs-the-dsp) ·
[What our DSP program does](#what-our-dsp-program-does) · [What the main CPU does](#what-the-main-cpu-does) ·
[How it was checked](#how-it-was-checked) · [Risks and recovery](#risks-and-recovery) ·
[Iteration 2](#iteration-2-another-worlds-samples-through-the-dsp) · [Files](#files)

## On the instrument

**What goes on the card.** The folder `DSPTONE\` from `make card-dir` (or from the release,
`releases/2026-10-20-iter1/`), copied into the SD card's root beside the menu's other folders:

| file                   | what                                                          |
|------------------------|---------------------------------------------------------------|
| `DSPTONE\KN7APP.BIN`   | the program (SHA-1 in `releases/2026-10-20-iter1/SHA1SUMS`)   |
| `DSPTONE\MANIFEST.TXT` | its name in the menu: "DSP tone: our own effects-DSP program" |
| `DSPTONE\ICON.BMP`     | its icon                                                      |

The program menu (`../kn7menu`, the root's `KN7APP.BIN`) and the loader floppy (`KN7LOAD.CNV`, unchanged since
2026-10-19) are the ones already in use.

**Before starting it.**
- **REVERB on** (its button lit) and REVERB TOTAL DEPTH at its usual setting. Our sound goes out through unit 0 of
  the DSP, the panel REVERB unit, and the tone generator mixes that unit's return into the DAC only while REVERB
  is on (live capture 2026-07-20: the REVERB button moves only the return crossfade `0x803A`, depth `0x8338`).
- **MAIN VOLUME low to moderate.** The sine and the sweep are at -20 dBFS at the DSP. In MAME they come out about
  13 dB louder than a C4 note at the default touch; on the instrument the return level has never been calibrated.
- Play a few notes first, to hear the reverb as it is.

**Steps.** DISK MENU, STYLE CONVERT, `KN7LOAD.CNV`, OK; in the menu, the "DSP tone" row and RUN.

| when                  | the screen                                                                                | you hear                                                                    |
|-----------------------|-------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| the first 4 s         | "Looking for the firmware's DSP routines..." (four searches of the flash)                 | nothing new                                                                 |
| then, within a second | the lines fill: firmware build, routines, `SYSCON 00000410`, the slot, "Loaded", "Hooked" | a steady 440 Hz tone                                                        |
| RUN state             | "Heartbeat (MSGR7): N frames  44xxx per second", green                                    | the tone; your notes still sound, dry                                       |
| right 2, CHIRP        | "PCM: n of 44100 samples sent", then "PCMLEN read back 44100"                             | about 2.5 s of the tone, then a rising sweep (220 to 3520 Hz) once a second |
| right 1, SINE         | "Playing: sine"                                                                           | the tone again                                                              |
| right 3, MUTE         | "Playing: nothing"                                                                        | silence (your notes still sound)                                            |
| right 5, STOP         | "Restored: PM 8080 = 06BE04008400 = CALL 8400 (DB), read back", green                     | your notes with their reverb again                                          |
| right 4, LEAVE        | the firmware's message, then "Continue Next?": YES = the menu                             |                                                                             |

EXIT held for 1.5 s does STOP and, when it is let go, LEAVE.

**What to report.** A photo of the screen in RUN (the heartbeat line gives the DSP's real frame rate, to compare
with pass 8's 44,087 a second) and after STOP; whether the tone and the sweep were heard, and how loud against a
note; whether the reverb is back after STOP. Any red line.

**If something goes wrong.** Power the instrument off and on. At every power-up the firmware resets the DSP and
loads it afresh; DSPTONE writes nothing that outlives that (next sections).

## How the firmware runs the DSP

All of this is from the firmware and the DSP programs it carries (`../../dsp/kernel-architecture.md`,
kn7000_mame `notes/dsp-host-interface.md`), and the owner's unit (passes 6 to 8, `../cnv_romdump/README.md`).

- **The host port.** The MN10300 writes an ADSP-21065L IOP register number to `0x98000000` and moves the
  register's contents through `0x9C000000`, 16 bits at a time, low half first (SYSCON `0x410`: 16-bit host bus).
  Program and data go in through the external port's FIFO EPB0 (register 4) and DMA channel 8: IIEP0 (`0x40`) =
  address, IMEP0 (`0x41`) = 1, CEP0 (`0x42`) = words, DMAC0 (`0x1C`) = `0xA1` (program memory, three halves a
  48-bit word) or `0x41` (data memory, two halves), the halves, then DMAC0 = `0xA0`. That is the firmware's own
  upload (941 `0x48407AAB`, `0x48407A86`/`0x48407A99`, `0x48407ADF`).
- **The boot** (941 `0x48404FF6`, `0x48405470`): pulse the DSP's reset (`0x36008004` bit 7), check SYSCON reads
  its reset value `0x20` (ten tries; else the "DSP dead" flag), run the four SDRAM self-test records, then upload
  the resident kernel (rec04) and the effect programs.
- **The handshake.** Every data-port access goes through one routine (893 `calls` entries: read `0x4840B090`,
  write `0x4840B00D`) that takes a lock, writes 1 to G17ICR (`0x3400015C`) and waits for INTC group 0x17 to be
  raised again (up to `0x3FFFF` polls, 893 `0x4840AE77`). The DSP side raises it once per audio frame: pass 8 timed it on the unit at
  one per 22.68 us, 44,087 Hz by the firmware's tick. If a wait runs out, the firmware sets its dead flag (893
  `0x500066D8`) and sends the DSP nothing more until the next power-up. So the handshake the firmware polls is
  the kernel's own frame loop running: **DSPTONE keeps the firmware's kernel and changes only what one of its
  units calls**, and the handshake stays exactly as it was.
- **The kernel** (rec04): an IRQ0-paced loop that, every frame, walks ten CALL slots, one per effect unit
  (PM `0x8080`... `0x80A0`), each patched by the host to `0x8400 + unit x 0x100` when an effect is loaded (a
  single-word PM upload). Unit 0 is the panel REVERB (`0x8080`, "CALL (0x8400) (DB)", `06BE04008400` on the
  owner's unit, pass 7).
- **Where the output goes.** None of the DSP's serial outputs reaches a DAC. All four SPORT transmit lines go back
  into the tone generator, and the TX frame is a patchbay: unit 0 reads its input at DM `0xC362/63` (the TG's
  reverb send) and writes its return to `0xC342/43` (SPORT0 A). The tone generator mixes that return into the DAC,
  through the REVERB return crossfade and depth. So our sample, written into unit 0's return, is heard where the
  reverb is heard.

## What our DSP program does

`dsp_prog.py` builds it (91 instructions, encoded by `sharc_enc.py` and checked against MAME's SHARC
disassembler, instruction by instruction: `make` stops if one line differs). It is one effect unit, with the
kernel's unit ABI (`kernel-architecture.md` section 7), loaded at PM `0x8200`, which the firmware never writes
(power-on contents on the owner's unit, pass 7). Every frame, called from unit 0's slot:

1. reads unit 0's input pair, `DM(0x20, I4)` and `DM(0x21, I4)`;
2. adds 1 to MSGR7 (the heartbeat the main CPU reads);
3. by MSGR6: nothing (0), the sine (1: a 24-bit phase accumulator, kept in 24 bits by a mask because the kernel
   sets MODE1.ALUSAT and adds saturate, into a 256-entry table at DM `0x9D00`, 439.99 Hz at 44.1 kHz, -20 dBFS),
   or the PCM (2: the next of PCMLEN samples at SDRAM `0x70000`, looped);
4. if MSGR4 asks for a copy: unpacks two words of the staging buffer (DM `0x9E00`, two 16-bit samples a word,
   the earlier in the low half) into four 24-bit samples in SDRAM at `0x70000 + MSGR5 + 4k`; when MSGR4 words
   are done it sets PCMLEN and writes 0 to MSGR4;
5. writes input + sample, clipped to 24 bits (the SPORT's word), to unit 0's return pair, `DM(0, I4)` and
   `DM(1, I4)`, and moves I4 on by two, as an effect's two output writes do;
6. returns as every effect does: `RTS (DB); R4 = DM(I1, M5), R7 = PM(I12, M8); MODIFY (I8, 0x50)` (rec05's words;
   M5 = `0x4D` and M8 = +1 in every build).

**The modify registers differ between program builds** (`kernel_mregs.py`, which reads each build's kernel record).
The kernels of 941 and 942 (the disassembled listings) set M2 = +1 and their effects write `DM(I4, M2)`; those of
893 (the owner's) and 935 set M0 = +1, M1 = +2, M2 = +3 and their effects write `DM(I4, M0)`. The first build of
this program followed the 941 listing and, on 893 in MAME, wrote its output pair three words apart and unpacked the
PCM into the wrong places (33,053 of 44,100 SDRAM samples wrong, the high halves two places late); it now uses no
M0-M7 at all, and the SDRAM holds the sweep exactly (44,100 of 44,100).

It saves I5 and I7 and puts them back, and addresses memory only with immediate offsets (`DM(0x20, I4)`,
`DM(0, I5)`) and `MODIFY` by immediates, never through M0-M7, which the builds' kernels set differently (above). It uses DM `0x9D00`-`0x9F06` (internal, never written by the firmware) and SDRAM
`0x70000`-`0x7FFFF`, above the kernel's three rings (which end at `0x69D3F`) and well inside the 1M words of
IC307/IC308 (the kernel's own rings, 433K words, could not fit in less than 512K). It costs at most about 100
cycles of the 1,360 a frame has at 60 MHz: less than the reverb it stands in for.

**The message registers** MSGR4-MSGR7 (IOP `0x0C`-`0x0F`) carry the control. The kernel zeroes MSGR3-MSGR7 at
boot and nothing else uses MSGR4-7 (MSGR2 is the mic reverbs' I3 cell, MSGR3 the boot probes' answer).

| register | written by | what                                                            |
|----------|------------|-----------------------------------------------------------------|
| MSGR4    | host, DSP  | copy request: STAGE words to unpack; the DSP writes 0 when done |
| MSGR5    | host       | where the copy goes: a sample offset into the PCM area          |
| MSGR6    | host       | mode: 0 silence, 1 sine, 2 PCM                                  |
| MSGR7    | DSP        | heartbeat: +1 every frame our program runs                      |

## What the main CPU does

`dsptone.s`, an application of `KN7LOAD.CNV` (`../cnv_romdump/kn7cnv.inc`), one step per converter call,
answering request 5 every time (as the menu and Another World do):

1. **Finds** the panel's switch bitmaps (as `../kn7menu`) and the firmware's DSP routines: the handshake wait,
   the 2x16 register read and write, the index write and the guarded data read, as the DSP probe finds them
   (`../cnv_romdump/romdump_dsp.s` DspFind), and the guarded data **write**, which the uploads stream through:
   the register write's DM-word writer calls it (893 `0x4840B00D`, 941 `0x48404EF5`). `find_dspw.py` runs the
   same search over every program build we have: found and consistent in 893, 935, 941 and 942. Each of the four
   signatures gets a converter call of its own (about 0.9 s each in MAME), and DSPTONE does not touch the DSP
   unless every routine is found and agrees.
2. **Checks** the DSP is as the firmware leaves it: dead flag 0, kernel loaded, SYSCON's host bus 16-bit and low
   half first, DMAC0 without DEN or CHEN, channel 8 neither active nor chaining (pass 7's checks); then reads unit
   0's slot back (pass 7's readback: DMAC0 `0xA5`, EPB0) and keeps it. It must be the kernel's "CALL (0x8xxx)
   (DB)"; if it is already ours (an earlier run that never put it back), the firmware's `0x8400` is kept instead.
3. **Loads** the program, the table and the variables with the firmware's upload sequence, zeroes MSGR4/5/7,
   sets MSGR6 = 1, and reads all three back and compares (91 PM words, 256 + 7 DM words).
4. **Hooks**: the slot = `06BE04008200` ("CALL (0x8200) (DB)"), the same single-word PM upload the firmware makes
   for every effect change, read back.
5. **Runs**: reads MSGR7 every call and shows its rate over one-second windows; SINE, CHIRP, MUTE set MSGR6.
   CHIRP uploads the PCM first (44,100 16-bit samples carried in `KN7APP.BIN`): per chunk it waits for MSGR4 = 0,
   streams up to 256 words into STAGE, writes MSGR5 and MSGR4; at most 80 ms of this a call. At the end it reads
   PCMLEN back (it must be 44,100) and sets MSGR6 = 2.
6. **Stops**: MSGR6 = 0, the slot written back as found and read back, MSGR4-7 zeroed, channel 8's registers
   (IIEP0, IMEP0, CEP0, DMAC0's control bits) put back as found. Any failure after the hook goes through the same
   restore first.

**What it never does**: drive the host port itself (only the firmware's routines, with their lock, handshake and
dead-flag guard; `guard.py` refuses any reference to `0x98000000` or `0x9C000000`), write IC23, the user-memory
pools, the loader's area or the card (no file or sector service is even named: `guard.py`), or touch the DSP
memory the firmware uses, other than the one slot word it puts back.

**The screen.** The firmware repaints its whole STYLE CONVERT screen (76,160 LCD stores, 893 `0x48414F92`) after
a converter call that ran long. A first build that redrew everything in one 200 ms call (150,000 16-bit stores)
had the firmware repaint after every other call. Drawing now stores two pixels at a time, and a full redraw is
spread over five calls. Between redraws only the lines that changed are drawn. While the sine plays in MAME:
0.0 firmware repaints, about 17 converter calls a second (`test/analyze.py` "screen").

**One speed trap, for whoever writes the next search loop.** On MAME's MN103002A timing (G22, calibrated against
the unit's pass 9) the signature search took 4.85 s of emulated time when its five-instruction scan loop started
at an odd address, and 0.88 s once it starts on a 4-byte boundary (`.align 4, 0xCB`).

## How it was checked

Kept light, as asked: the build checks, then one end-to-end run in MAME, no sweeps.

**Build** (`make`): `dsp_prog.py --check`: all 91 SHARC words disassemble (`unidasm -arch sharc`) to the text
each was meant to be; `guard.py`: clean (5 allowed service-table loads, 59 call targets framed, the map inside the
application area). `find_dspw.py`: the routines are found in 893, 935, 941 and 942.

**MAME** (`test/run_mame.sh OUT`; the published overlay `kn7000-emulator/kn7000` md5 `3077b137...`, `-bios v13` =
program 893, the owner's; the released loader floppy; the program menu `0566fba3...` and `DSPTONE\` copied into a
fresh copy of the real card's image; `-wavwrite`). The rig plays a C4, starts the menu, picks DSPTONE, RUN; waits
12 s; CHIRP; 10 s; MUTE; 3 s; STOP; 3 s; LEAVE; another C4. `test/tone_tap.lua` logs the DSP every 0.25 s;
`test/analyze.py` decides. The run of `KN7APP.BIN` `5d7d5df5...` (the release), 2026-10-20, 10 of 10:

| check      | result                                                                                                                    |
|------------|---------------------------------------------------------------------------------------------------------------------------|
| `dead`     | the firmware's dead flag 0 at all 355 samples (25-113.5 s)                                                                |
| `hooked`   | PM `0x8080` = `06BE04008200` from 73.28 to 94.03 s; MSGR7 rises 44,100 a second (median of 83 intervals)                  |
| `restored` | PM `0x8080` `06BE04008400` before and at the end; MSGR4-7 all 0; V_RESTORED 1                                             |
| `reverb`   | DM `0xC003` (the reverb's per-frame store of I6): 8 values in the last 8 samples before the hook, 1 while hooked, 8 after |
| `sine`     | peak 440.0 Hz, -34.4 dBFS; silence before the first note -240 dBFS; the C4 note's first second -47.5 dBFS                 |
| `sdram`    | 44,100 of 44,100 samples read back from SDRAM `0x70000` equal to the sweep                                                |
| `chirp`    | 142 loud 40 ms frames, peaks 231-3237 Hz, 95 % within 10 % of the sweep, looped once a second                             |
| `mute`     | -240 dBFS (exact silence: no note played)                                                                                 |
| `screen`   | while the sine plays: 0.0 firmware repaints, 17.2 converter calls a second                                                |
| `note`     | the C4 after the restore against the one before: +0.00 dB, envelope correlation 1.000, tails -71.3 / -71.3 dBFS           |

The timeline (the rig's log and the tap): RUN at 68.2 s; DSPTONE's first call at 69.3 s (the menu reads and starts
it); hooked and playing at 73.3 s; CHIRP at 80.5 s, the PCM playing at 83.0 s (2.5 s of upload); MUTE at 90.8 s;
STOP at 94.1 s, restored by 94.3 s; LEAVE at 97.4 s. The heartbeat line read about 44,122 frames a second (MAME's
DSP runs at exactly 44,100 Hz, against the firmware's tick of 1.0005 ms; pass 8 measured 44,087 on the unit). The
snapshots (`OUT/snap/`) show the screen in RUN and after STOP.

**What MAME cannot tell, and what the unit decides instead.**
- *The level.* MAME mixes unit 0's return at a makeup constant that was never calibrated against the instrument
  (technics-docs `kn7000-effects-dsp.md`, "absolute wet level"). How loud the tone is on the unit is
  the unit's answer.
- *The route.* In MAME the reverb return reaches the speakers only with REVERB on (the bridge follows the TG's
  `0x803A` crossfade); that matches the live capture, but MAME does not model the tone generator's own SPORT
  input.
- *The host DMA.* MAME writes uploaded words straight into DSP memory; the chip moves them through the EPB0 FIFO
  and DMA channel 8. The firmware's own uploads, and pass 7's readback on the unit, use the same channel the same
  way, so this is the firmware's path, not a new one; and every upload is read back on the unit before it is used.
- *The SHARC encodings.* Checked against MAME's disassembler and run by MAME's SHARC core (the final run on the
  recompiler, MAME's default), not by the chip. The forms are the commonest ones, some of them
  word for word what the firmware's own programs contain (`R0 = DM(0x20, I4)`, the epilogue).
- *MSGR writes by the host.* The unit has shown MSGR2 written by the DSP and read by the host (passes 6 and 7);
  host writes to MSGR4-7 are new on the unit (the firmware writes other IOP registers the same way all the time).
- *The handshake.* MAME raises group 0x17 on its frame tick whatever the DSP does; on the unit it depends on the
  DSP. DSPTONE leaves the kernel's frame loop as it is, and its heartbeat counts each frame, so a stalled DSP shows
  as a red heartbeat line (and the firmware's dead flag, which DSPTONE checks every call).

## Risks and recovery

- **If our DSP program misbehaved on the chip** (a stalled or endless unit 0), the kernel's frame loop would stop,
  the firmware's next handshake wait would run out and it would set its dead flag: no more effects, and with
  REVERB on the main sound may go quiet (the DAC takes the DSP's return), until a power cycle. DSPTONE would show
  "marked the DSP dead ... Power-cycle". **Recovery: power off and on**: the firmware resets and reloads the DSP
  at every power-up.
- **Persistent state**: none. DSPTONE writes only DSP memory and IOP registers (all reset and reloaded at
  power-up) and its own RAM in the converter's area. No IC23, no user-memory pools, no card writes.
- **Leaving without STOP** (e.g. the firmware ends the converter some other way): our program keeps running in
  unit 0 until the power is cycled or a REVERB type is chosen on the REVERB screen (the firmware then reloads unit
  0 and its slot).
- **Loudness**: start with MAIN VOLUME low (above).
- **Firmware builds**: only those where `find_dspw.py` finds the routines (893, 935, 941, 942); on any other the
  routines are searched for at run time and DSPTONE refuses to touch the DSP if anything is missing.

## Iteration 2: Another World's samples through the DSP

What it would need, on top of what this iteration establishes:

1. **A sample bank in SDRAM.** Another World's sound resources (8-bit signed PCM, loop points) uploaded at game
   start through the same staging route. The host port moves one 16-bit half per DSP frame, about 88 KB a second,
   so a few hundred KB is a few seconds of loading; packing four 8-bit samples a word halves the SDRAM use.
2. **A four-voice mixer on the DSP.** Per voice: a 32-bit fractional phase increment (AW's period table gives
   the rates), volume, start, length and loop, read from a small voice table in internal DM; interpolation
   optional. Four voices cost a few hundred cycles of the 1,360.
3. **A command path.** Four message registers are too few: a command ring in internal DM written by DMA (a voice
   start is a handful of words, a few hundred microseconds of host traffic), with MSGRx as the write index.
4. **A return that does not depend on REVERB.** MULTI (unit 1) or a Sound-DSP insert unit has its own return
   level, independent of the REVERB button (`kn7000-effects-dsp.md`, "Per-effect returns"); which one the tone
   generator always mixes in needs checking on the unit, or the app sets REVERB on itself.
5. **Integration** into Another World's `audio.s`, which today plays its sounds on the tone generator over MIDI;
   and the restore on every way out of the game.
6. **The unit's numbers from this iteration first**: the heartbeat rate, whether the tone was heard, its level
   against a note, and that STOP brought the reverb back.

## Files

| file                         | what                                                                                            |
|------------------------------|-------------------------------------------------------------------------------------------------|
| `dsptone.s`                  | the application: states, the DSP routines and uploads, the buttons, the screen                  |
| `dsptone.inc`                | its memory map, variables, constants                                                            |
| `dsp_prog.py`                | the DSP program, the sine table, the chirp; `--check` against unidasm; writes `build/dsp_*.inc` |
| `sharc_enc.py`               | the minimal SHARC encoder `dsp_prog.py` uses                                                    |
| `guard.py`                   | build guards: forbidden addresses, frames before calls, the memory map                          |
| `find_dspw.py`               | the run-time routine search, in Python, over every program build                                |
| `kernel_mregs.py`            | each build's kernel: the modify registers it sets, and the one its copy stub writes with        |
| `Makefile`                   | `make` (KN7APP.BIN), `make card-dir` (the card folder)                                          |
| `test/run_mame.sh`           | the MAME check (above)                                                                          |
| `test/tone_test.cmd.in`      | its button script, for the remote rig (kn7000_mame `tools/rigs/remote.lua`)                     |
| `test/tone_tap.lua`          | the DSP and LCD log it reads                                                                    |
| `test/analyze.py`            | the verdict: the recording, the log, the rig's times                                            |
| `releases/2026-10-20-iter1/` | the card folder as released, `SHA1SUMS`, `README.txt`                                           |
