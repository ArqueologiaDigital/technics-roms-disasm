# Wave 4, lane kn5000-b, sub-lane hwaudio (2026-10-31)

Issues: kn5000-xel (the DAC), kn5000-jy9 (the analog output path), kn5000-mhj (a measured boot
timeline) and kn5000-1oy (the effects DSP; split, see its section).

Sources used:

- the KN5000 service manual, `technics-docs/service_manual/technics_sx-kn5000.pdf` (59 PDF pages,
  scanned; no text layer).  Pages are rendered with `pdftoppm` (recipe in `probes/README.md`).  PDF
  page numbers are given with the printed page numbers:

| PDF page | printed      | sheet                                           |
|----------|--------------|-------------------------------------------------|
| 2        | (spec)       | Specifications, second half (OUTPUT, SPEAKERS)  |
| 33       | II-13/II-14  | CPU SECTION (B): sub CPU IC27                   |
| 34       | II-15/II-16  | TONE GENERATOR SECTION (A): IC303, wave ROMs    |
| 35       | II-17/II-18  | TONE GENERATOR SECTION (B): IC310, IC311, IC313 |
| 39-40    | II-24..II-26 | FAJ / ACP / JACK / HB boards                    |
| 41       | II-27/II-28  | SWA board (power amplifier)                     |

- MAME: the `kn5000` driver of the kn7000_mame overlay, binary
  `/home/fsanches/compartilhado/kn5000dsp_build/kn7000` (built 2026-10-23; that build tree is not a git
  checkout, so the binary is identified by its SHA-256,
  `26586387a648100c164ab0d4348f78539564e4a8d48a26bc69a75a540ceb54ca`), ROMs from
  `technics_roms/roms/kn5000` (default BIOS v10, sub-CPU payload v1.42).

Readings off the schematic are marked **(schematic)**; anything not read directly is marked
**inference**.

---

## kn5000-xel: the DAC is IC313, a Burr-Brown PCM69AU (not IC310)

The issue names IC310, which is the MN19413 DSP2.  The DAC is **IC313 PCM69AU**, on TONE GENERATOR
SECTION (B), PDF page 35, grid 16-17 F/E.

### Pin use (schematic)

Pin numbers sit above their lines on this sheet; read that way:

| pin | name  | connection                                                                          |
|-----|-------|-------------------------------------------------------------------------------------|
| 1   | +5A   | analog +5 V, decoupled by C352 0.1 uF and C363 100 uF/6.3 V                         |
| 2   | VCOML | left reference, to IC314B pin 5 (+), C354 0.1 uF to ground                          |
| 3   | NC    |                                                                                     |
| 4   | LOUT  | left output, to IC314B pin 6 (-)                                                    |
| 5   | SER   | C350 0.1 uF to ground                                                               |
| 6   | REF   | C351 10 uF/16 V to ground                                                           |
| 7   | ROUT  | right output, to IC314A pin 2 (-)                                                   |
| 8   | NC    |                                                                                     |
| 9   | VCOMR | right reference, to IC314A pin 3 (+), C355 0.1 uF to ground                         |
| 10  | AG    | analog ground                                                                       |
| 11  | DG    | digital ground                                                                      |
| 12  | TP2   | tied to +5A                                                                         |
| 13  | DA-R  | tied to ground                                                                      |
| 14  | BCK   | bit clock `BCK`, through R343 47 ohm (test point 11)                                |
| 15  | SYSCK | system clock `DACCK`, through R342 47 ohm (test point 10)                           |
| 16  | WDCK  | word clock `LRCK`, through R341 47 ohm (test point 9)                               |
| 17  | DA-L  | serial data from IC310 (MN19413) output `SDO1`, through R326 470 ohm (test point 8) |
| 18  | TP3   | tied to +5A                                                                         |
| 19  | TP1   | tied to ground                                                                      |
| 20  | +5D   | digital +5 V, C348 0.1 uF                                                           |

### What that says

- **One data line.**  Only DA-L carries data, from **IC310's SDO1**; DA-R is grounded.  So both
  channels arrive time-multiplexed on DA-L, with WDCK (= LRCK) selecting left or right
  (**inference** from the wiring: the PCM69A datasheet is not on this machine, so the mode that a
  grounded DA-R selects is not confirmed from it).
- **The clocks come from the tone generator.**  `LRCK` and `BCK` leave IC303 (TC183C230002) at pins 208
  and 207 through 220 ohm resistors (R311/R312; PDF page 34), and are shared by IC310 (`WSI`/`SCKI`),
  IC311 (`LRCKI`/`BCLKI`) and IC313.  `DACCK` also comes over from section (A) (R310); which IC303 pin
  drives it was not followed (**inference**: `MCKOUT`, pin 42).  IC303's crystal X301 is printed
  **36.8688 MHz**.  The sample rate is 44,100 Hz, proven from the firmware three ways on
  Effects DSP ("Board facts").  36.8688 MHz is
  not an integer multiple of 44.1 kHz (836.03x), so the printed value may be a misprint of 33.8688 MHz
  (= 768 x 44.1 kHz); the board would have to be read to settle it.
- **Current outputs into I/V converters.**  LOUT and ROUT each go to the inverting input of half of
  **IC314 (M5218AFP, dual op-amp on +-15 V)**, whose feedback is 6.8 kOhm || 680 pF (R339/C356 left,
  R340/C357 right), with VCOML/VCOMR on the non-inverting inputs.  That is the current-to-voltage
  converter topology, with a first-order roll-off at 1/(2 pi x 6.8 k x 680 p) = **34.4 kHz**.  The
  op-amp outputs are the board signals `LOUT` / `ROUT`, which leave the main board on CN9 (pins 6/7)
  for the FAJ board (see kn5000-jy9).
- **The audio rails.**  +5A comes from a discrete regulator on the same sheet (Q302 2SD592ARS, zener
  D304 MA8056, from +15A through R337 100 ohm 1 W); +-15A arrive from the FAJ board's supply.
- **IC312 (M5218AFP)** beside it is not on the DAC path: IC312B buffers +2.5 V (pin 5 = +2.5A), and
  the `MICIN` line from the FAJ board reaches IC310's analog inputs through R336 6.8 kOhm / R335 1 kOhm
  and IC312A (**inference** from the sheet: the MN19413 digitises the microphone input).

### Website page draft

Target: `hardware-architecture.md`, section "Audio / Sound Generation", new subsection after the IC
table; and `reverse-engineering.md` "### DAC (IC313)" (replace its one-line placeholder with a link to
it).

> #### DAC: IC313, Burr-Brown PCM69AU
>
> The main mix is converted by **IC313, a PCM69AU** (18-bit stereo), on Tone Generator Section (B)
> (service manual p. II-18).  Not IC310, which is the MN19413 DSP2 that feeds it.
>
> | signal       | from                       | to IC313       |
> |--------------|----------------------------|----------------|
> | serial data  | IC310 `SDO1`, R326 470 ohm | DA-L (pin 17)  |
> | word clock   | `LRCK`, IC303 pin 208      | WDCK (pin 16)  |
> | system clock | `DACCK`, from section (A)  | SYSCK (pin 15) |
> | bit clock    | `BCK`, IC303 pin 207       | BCK (pin 14)   |
>
> DA-R (pin 13) is grounded: both channels share the one data line, selected by LRCK.  The three
> clocks are generated by the tone generator IC303 and shared with IC310 and IC311; the sample rate
> is 44.1 kHz ([Effects DSP](effects-dsp/#board-facts-verified-on-the-kn5000-by-felipe)).
>
> The outputs are currents: LOUT (pin 4) and ROUT (pin 7) feed the inverting inputs of the dual
> op-amp **IC314 (M5218AFP, +-15 V)**, wired as current-to-voltage converters (6.8 kOhm || 680 pF
> feedback, a first-order roll-off at 34.4 kHz) with the DAC's VCOML/VCOMR as reference.  Their
> outputs, `LOUT` and `ROUT`, go to the FAJ board on CN9; see [Audio output path](#audio-output-path).
>
> IC303's crystal X301 is printed 36.8688 MHz, which is not a multiple of 44.1 kHz; it may be a
> misprint of 33.8688 MHz (768 x 44.1 kHz).

---

## kn5000-jy9: the analog output path, DAC to jacks and speakers

From the FAJ / ACP / JACK / HB sheet (PDF pages 39-40) and the SWA sheet (PDF page 41), all
**(schematic)** unless marked.

### Boards

| board | contents (audio)                                                                                                                                                                                                |
|-------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MAIN  | IC313 DAC and IC314 I/V converters (above); `LOUT`/`ROUT`/`MICIN` and +-15 V on CN9                                                                                                                             |
| FAJ   | power supply (T1 secondary, bridge, IC2 M5F78M15L +15 V, IC3 M5F79M15L -15 V, Q4 -7 V), mixing amp, filters, equaliser, headphone amp, microphone amp, muting control, jacks LINE OUT / AUX IN / MIC (via JACK) |
| SWA   | the speaker amplifier: two full-range channels and one bass channel                                                                                                                                             |
| HB    | the PHONES jack (and, not audio, the BEND and MODULATION wheels' pots VR2 50 kOhm B / VR1 10 kOhm, wired to CPL CN3)                                                                                            |
| ACP   | the AC inlet, power switch, fuses and line filter                                                                                                                                                               |

### Signal path

```
IC313 PCM69AU --(current)--> IC314A/B I/V (6.8k||680p)        MAIN board
      | LOUT / ROUT (CN9 pins 6/7 -> FAJ CN3)
      v
C37/C38 10 uF --> IC4A/IC4B "MIXING AMP" (M5218AL), inverting summers:
                  DAC via R82/R84 10k, a second input via R51/R83 15k,
                  feedback R85/R86 33k || C46/C45 220p (gain -3.3 for the DAC, pole 21.9 kHz)
      v
IC7A/IC7B "LOW PASS FILTER" (C48/C47 0.068, C96/C97 0.068, R87/R88 150k, R38/R37 10k)
      v
IC8 / IC10 / IC11 / IC12 "EQUALIZING" (four filter sections per channel)
      v
IC14A/IC14B summers (R41/R42 82k in, R91/R92 150k || C98/C99 33p) -> R90/R89 100 ohm
      | LIN / RIN, MUTE (FAJ CN8 -> SWA CN1)
      v
SWA board:  L: IC1A high-pass -> IC1B integrator -> comparator Q2-Q7 -> gate drive Q8-Q11
            R: IC2B high-pass -> IC2A integrator -> comparator Q12-Q17 -> gate drive Q18-Q21
               L and R power stage: Q32 SLA5007 ("Lch Rch POWER DRIVE")
               output filters L1 / L2 60 uH + C17 / C30 1.5 uF   -> SPL, SPR
            bass: IC3A "LOW PASS FILTER" sums LIN + RIN (R39/R40 100k)
               -> IC3B integrator -> comparator Q22-Q27 -> gate drive Q28-Q31
               -> Q33 2SJ425 / Q34 2SK1188 power MOSFETs -> L3 60 uH + C43 -> SPWF
      | SWA CN2 -> FAJ CN6 -> CN4 / CN5
      v
speakers: SP1, SP2 12 cm 4 ohm; SP3, SP4 6.5 cm 8 ohm (fed through TF-marked capacitors C33/C56
          on TWL / TWR); SP5 14 cm 3 ohm on SPW (the bass channel)
```

- **The speaker amplifier is a switching (class-D) amplifier** (**inference**, strong: each channel is
  drawn as INTEGRATOR -> COMPARATER -> GATE DRIVE -> POWER DRIVE, with power MOSFETs and 60 uH output
  inductors).  The specification page gives **66 W: 18 W x 2 for mid/high and 30 W x 1 for bass**, and
  **12 cm x 2, 6.5 cm x 2 for mid/high, 14 cm x 1 for bass** (PDF page 2).
- **The bass channel is the mono sum of L and R**, low-passed on the SWA board itself (IC3A).
- **Muting.**  The main board's `MUTE` line (FAJ CN7 pin 11) drives the FAJ board's MUTING CONTROL
  (Q10 2SA1015, Q11/Q12 2SC1815) and the SWA board's muting transistor Q1 (2SB709AR); the PHONES jack's
  switch contacts return `HPS` (headphone sense, HB CN1 pin 1 -> FAJ CN9) to Q3 (2SA1015) on the FAJ board
  (**inference**: plugging headphones in mutes the speakers, as on the instrument).
- **Headphones.**  IC5A/IC5B (M5218AL) inverting summers (two 15 kOhm inputs each, 47 kOhm || 150 pF
  feedback) -> IC6A/IC6B (150 kOhm / 150 kOhm) with complementary followers Q5/Q6 and Q7/Q8 (2SD592ARS /
  2SB621ARS, R53/R54 22 ohm) -> FAJ CN9 `HPL`/`HPR` -> HB board -> PHONES JK1 (L1 15 uH x 3, C1/C2 0.033 uF).
- **AUX IN** (JK5 R/R+L, JK4 L; front-panel labels "R/R+L, L" in the specification: the R jack carries
  the mono sum when L is unplugged) enters through L5 and C43/C39 1 uF, with R33/R34 33 kOhm loads, and
  feeds the 15 kOhm inputs of the mixing amps and the headphone summers (**inference** on the exact
  nets: the wires are followed on the scan, not continuity-checked).
- **LINE OUT** (JK8 R/R+L, JK7 L) is loaded by R59/R64 2.2 kOhm; its source net is the pair of lines that
  also carry the headphone amp's outputs through R62/R63 820 ohm and C64/C66 10 uF (**inference**: not
  followed unambiguously on the scan).
- **MIC** (JK9) -> C73 1 uF / R27 4.7 kOhm -> MICROPHONE AMPLIFIER IC13A/IC13B (M5218AL, Q9 2SC1815) ->
  `MICIN` (CN9 pin 9) -> main board -> IC310's analog input (see kn5000-xel).

### Left open, and why

- Signal **levels** (line-out level, headphone power) are not printed on these sheets and need a
  measurement on an instrument.
- The LINE OUT and AUX IN nets above are marked inference; a continuity check on a FAJ board settles them.
- The EQUALIZING sections' individual responses were not computed (component values are on the sheet).

### Website page draft

Target: `hardware-architecture.md`, section "### Audio Output Path".  ⚠ That section currently holds
text about the sub CPU's serial port ("Sync byte 0xFE...", ring buffers, 0xF4/0xF5), which belongs in
`audio-subsystem.md` "Serial Port 1 Interface"; the draft replaces it.

> ### Audio Output Path
>
> The main mix leaves the DAC (IC313, see above) as two currents, converted to voltages by IC314 on the
> main board and sent to the **FAJ board** as `LOUT` / `ROUT` (main CN9, with +-15 V and `MICIN`).
>
> | stage             | parts (FAJ board unless noted) | notes                                                                  |
> |-------------------|--------------------------------|------------------------------------------------------------------------|
> | I/V converter     | IC314 M5218AFP (main board)    | 6.8 kOhm parallel 680 pF, roll-off 34.4 kHz                            |
> | mixing amp        | IC4A/B M5218AL                 | DAC in at 10 kOhm (gain -3.3), second input at 15 kOhm                 |
> | "low pass filter" | IC7A/B                         | per the manual's label                                                 |
> | equaliser         | IC8, IC10, IC11, IC12          | four filter sections per channel                                       |
> | output summers    | IC14A/B                        | to the SWA board as LIN / RIN                                          |
> | speaker amp       | SWA board                      | switching amplifier: integrator, comparator, gate drive, MOSFET bridge |
> | headphone amp     | IC5, IC6 + Q5-Q8               | to the PHONES jack on the HB board                                     |
> | microphone amp    | IC13 + Q9                      | MIC jack -> `MICIN` -> IC310 on the main board                         |
>
> **Speakers.**  The SWA board drives three channels: left and right (Q32 SLA5007, 60 uH output
> filters) and a bass channel that sums L and R through its own low-pass filter (IC3) into a MOSFET pair
> (Q33 2SJ425 / Q34 2SK1188).  The specification gives 66 W (18 W x 2 mid/high, 30 W bass) into
> 12 cm x 2 (4 ohm), 6.5 cm x 2 (8 ohm, through capacitors) and one 14 cm (3 ohm) bass speaker.
>
> **Muting.**  A `MUTE` line from the main board, and the PHONES jack's switch (`HPS`), drive muting
> transistors on the FAJ and SWA boards.
>
> **Jacks.**  PHONES (HB board), LINE OUT R/R+L and L, AUX IN R/R+L and L, MIC.  AUX IN is summed into
> both the speaker and the headphone paths.  Levels are not given in the service manual.
>
> Source: service manual pp. II-24 to II-28 (FAJ/ACP/JACK/HB and SWA sheets).

---

## kn5000-mhj: the boot timeline, measured in MAME

`probes/boot_timeline_tap.lua` puts a read tap on each CPU's program space at each milestone and
logs the first instruction fetch made with PC equal to the milestone (method and limits in the
script header); `probes/run_boot_timeline.sh` runs it on a cold boot (fresh nvram) for 900 frames.
Output: `probes/boot_timeline.txt` (the run quoted here).  Re-run: `probes/run_boot_timeline.sh`;
the run is deterministic (four runs gave identical times).

### Result (emulated seconds after reset)

| t (s)    | CPU  | milestone                       | what it marks                                                  |
|----------|------|---------------------------------|----------------------------------------------------------------|
| 0.000000 | main | `RESET_HANDLER`                 | MAME answers reset from the program flash                      |
| 0.0035   | main | `Boot_InitIOPorts` (NEAR)       | entered by fall-through, so logged at the previous instruction |
| 0.600227 | main | `SubCPU_Send_Payload`           | start of the 5 x 64 KB tone-database transfer                  |
| 0.6004   | sub  | `RESET_ENTRY` (NEAR)            | the sub CPU's boot ROM starts at about the same moment         |
| 2.064647 | main | `SLIDE_Parse_Header`            | tone database sent; a payload image is found at 0x3E0000       |
| 3.085985 | main | `SLIDE_Decompress_4K_Done`      | the image is decompressed into DRAM (1.02 s)                   |
| 3.086011 | main | `SubCPU_Payload_TransferPart2`  | start of the 192 KB executable transfer                        |
| 3.960601 | sub  | `PAYLOAD_ENTRY`, `RESET`        | the sub CPU jumps into the payload                             |
| 3.960771 | main | `SubCPU_Payload_DelayLoop_Long` | the 0x100000-iteration wait                                    |
| 3.968435 | sub  | `Audio_System_Init`             |                                                                |
| 3.968456 | sub  | `DSP_System_Init`               |                                                                |
| 4.864515 | main | `SubCPU_Payload_Verify`         | the wait loop ended (0.90 s)                                   |
| 4.865145 | main | `ScreenGroup_Dispatch`          | subsystem init phases begin                                    |
| 5.505162 | main | `InitializeGraphics`            |                                                                |
| 5.741250 | main | `Boot_DisplayScreen`            |                                                                |
| 7.693235 | main | `MainLoop`                      | the main loop is entered                                       |
| 7.748644 | main | `AcWelcomScreenProc`            | the first screen procedure runs                                |

Durations: tone database 1.46 s (320 KB, about 219 KB/s through the latch); decompression 1.02 s;
executable 0.87 s (192 KB + 256 B, about 225 KB/s); the fixed wait 0.90 s; subsystem init to the main
loop 2.83 s.  Total to the main loop: **7.7 s**.

### Caveats

- This is **emulated** time: it is as right as MAME's TMP94C241 timing (16 MHz main CPU, 20 MHz sub CPU in
  the driver), which is not validated against a real instrument.  A stopwatch or logic-analyser capture on
  hardware is the check; the wait loop's 0.90 s for 0x100000 iterations (about 14 cycles each at 16 MHz)
  is at least plausible.
- The romset carries the **compressed v1.42 payload in the custom-data flash at 0x3E0000**, i.e. an
  instrument that has had a type-7 update.  An instrument without a valid image there skips the 1.02 s
  decompression (`SubCPU_Send_Payload` falls back to 0x800000).
- Cold boot: no saved settings.
- Times are the scheduler's time at the tap, good to one scheduling slice (tens of microseconds where
  neighbouring milestones show it).
- `SubCPU_Payload_Done` is never fetched with PC at its address (the loop exit falls through into it);
  its NEAR line in the output is the loop's first-pass prefetch and is not used above.
- A first attempt with debugger breakpoints (`-debug -debugger none`) perturbed the boot: the main CPU
  never reached `SubCPU_Send_Payload` in 22.8 s.  Recorded in the script header.

The old estimate on boot-sequence.md ("Payload load ~100 ms", total ~100 ms to payload execution) is
off by a factor of about 40: the payload starts executing at 3.96 s.

### Website page draft

Target: `boot-sequence.md`, "### Boot Time Estimates": replace the table and the sentence "These
durations are unmeasured estimates." with:

> ### Boot timeline (measured in MAME)
>
> Measured 2026-10-31 in the kn7000_mame overlay's `kn5000` driver (v10 program, sub-CPU v1.42), cold
> boot, by the Lua tap `notes/open4-kn5000-b/hwaudio/probes/boot_timeline_tap.lua` in
> technics-roms-disasm.  Emulated time, not yet checked on an instrument.
>
> | t (s) | CPU  | milestone                                              |
> |-------|------|--------------------------------------------------------|
> | 0.000 | main | `RESET_HANDLER`                                        |
> | 0.600 | main | `SubCPU_Send_Payload` (tone database, 5 x 64 KB)       |
> | 2.065 | main | payload image at 0x3E0000 found, decompressed (1.02 s) |
> | 3.086 | main | executable transfer (192 KB)                           |
> | 3.961 | sub  | `PAYLOAD_ENTRY`                                        |
> | 3.968 | sub  | `Audio_System_Init`                                    |
> | 4.865 | main | `SubCPU_Payload_Verify`, then `ScreenGroup_Dispatch`   |
> | 5.505 | main | `InitializeGraphics`                                   |
> | 7.693 | main | `MainLoop`                                             |
> | 7.749 | main | `AcWelcomScreenProc`                                   |
>
> The latch transfers run at about 220 KB/s; the main CPU then waits a fixed 0x100000-iteration loop
> (0.90 s) before subsystem init.  An instrument without an updated payload image at 0x3E0000 skips the
> decompression, so it would reach the main loop about 1 s sooner.

---

## kn5000-1oy: the effects DSP (split)

The issue asks to trace the DSP register writes at 0x130000, map the effect parameters, analyse the
algorithms and the effect chain.  Most of that has been done since January (Effects DSP, uPD6383 decode
status, the 38 flowcharts in `dsp/`).  The triage plan lists three remaining parts.  Outcome per part:

### Part 1: the 0x130000 block's registers 0x10-0x17: DONE (what the firmware does with them)

Static reading (v142 and boot ROM sources; the only 32-bit operands 0x00130000 in the payload image are
the three `ld` instructions below, the others are case-offset data):

- Writers: `DSP_Init_Channels` (0x01FC95, called once from `Audio_System_Init`), `DSP_Write_Channel`
  (0x01FCDE), and the never-called `DSP_WriteAllChannelRegs` / `DSP_WriteChannelRegs_Inner` (no branch,
  no pointer to 0x01FCFB anywhere in the image) and `DSP_Init_Channels_FromBootTable` (gated off by the
  boot ROM flag); in the boot ROM `INIT_TONE_GEN` (0xFF84A8) / `TONE_GEN_WRITE`, byte-identical.
- No instruction anywhere reads the block.

Measured: `probes/subcpu_130000_write_tap.lua` (run with `probes/run_subcpu_130000_tap.sh`) logs every
access to sub-CPU 0x130000-0x130003 over a cold boot; output `probes/subcpu_130000_writes.txt`.

| t (s)    | PC       | what                                                                     |
|----------|----------|--------------------------------------------------------------------------|
| 0.600340 | boot ROM | 4 x (latch 0x50..0x57, data 0x00): 64 byte writes                        |
| 0.600384 | boot ROM | 4 x 16-bit (0x130000 <- 0x1F1F/0x3F3F/0x5F5F/0x7F7F, 0x130002 <- 0x0101) |
| 4.992943 | payload  | 4 x (latch 0x10..0x17, data 0x00): 64 byte writes                        |
| 4.992992 | payload  | the same four 16-bit mode-word pairs                                     |
| total    |          | 144 writes, **0 reads**, in 22.8 s                                       |

So:

1. **The 0x5A5A5A5A test pattern never reaches the block.**  Both copies of the init routine pass the
   pattern pointer in XWA and the channel in BC, but the write routine takes the channel in A and the
   source in XBC (the 2026-09-25 correction in the source said so; now measured).  Each of the four calls
   writes one register group, picked by the pointer's low byte (boot ROM: 0x50-0x57; payload:
   0x10-0x17), with bytes read from sub-CPU addresses 0-10 (SFRs; 0x00 in MAME, port latches on hardware).
2. **The mode loop works**: latch 0x1F / 0x3F / 0x5F / 0x7F, data 0x01, i.e. register +0x0F of each
   channel's 0x10-0x1F window is set to 1.
3. **Nothing else ever touches the block**, at boot or after, and nothing reads it.  So the eight
   registers 0x10-0x17 of each channel carry no firmware meaning beyond "written once, with zeros or junk,
   by a buggy init"; their hardware meaning depends on which chip decodes the block.

Source comments updated (v142 `DSP_Init_Channels` / `DSP_Write_Channel`, boot ROM `INIT_TONE_GEN`;
v141/v140 regenerated).

**BLOCKED (chip identity):** which chip decodes sub-CPU 0x130000 needs either the sub CPU's chip-select
programming (the B*CS/MSAR/MAMR writes are not in the readable part of IC30, the sub-CPU boot ROM, which is
a BAD_DUMP with 97 % unread) or a continuity check on a board from IC27's CS0/CS1/CS2/CS4 pins (PDF page 33,
pins 60-64) to the chip they enable.  The payload sets none of those registers either (no reference to
SFR 0x140-0x157 in v142).

### Part 2: the R1 decode cascade: proposed as a new issue

`upd6383-decode-status.md` section 8 item 1 and 3: the bit-11 alternate `lo12` encoding (169 words, first
target `8801308BC`), then `f31` 3..7, `ACT 0x0B`, addressing classes 0/1/4.  No hardware and nothing external
blocks it; it is corpus and LLE work with the instruments in `dsp/tools/` (`pair_gate.sh`, the relocation
test, `dsp_coverage.py`), estimated on that page at weeks.  Read `dsp/analysis/DECODE-QUEUE-HANDOVER-2026-09-14.md`
first (its ten nulls).  Not started in this lane.

### Part 3: the reverb micro-topology: proposed as a new issue

`effects-dsp.md` section 19: the coefficient map is complete; the first-order all-pass reading was
rejected; the topology is open.  It depends on Part 2's decode of the reverb body's undecoded words.  Not
started in this lane.

### Website page draft

Target: `audio-subsystem.md`, "### DSP Channel Register Map (Memory-Mapped at 0x130000)": replace the
sentence "Initialization writes test pattern 0x5A5A5A5A to all 4 channels, then sets initial config value
0x101001F with 0x20 channel spacing." with:

> **What the firmware writes (measured in MAME, 2026-10-31).**  Only two routines ever touch this
> block, the boot ROM's `INIT_TONE_GEN` and the payload's byte-identical `DSP_Init_Channels`, each once
> per boot; nothing reads it.  Both mean to write the pattern 0x5A5A5A5A into the eight registers of each
> channel, but pass their arguments in the wrong registers for the write routine, so each writes a single
> register group four times with bytes from SFR addresses 0-10 (boot ROM: 0x50-0x57; payload: 0x10-0x17).
> Their second loop works: it writes 0x01 to register 0x1F, 0x3F, 0x5F and 0x7F.
> `DSP_WriteAllChannelRegs` is never called.  So the registers carry no firmware meaning; what they do
> in hardware depends on the chip that decodes the block, still unidentified (it needs the sub CPU's
> chip-select setup, in the unread part of IC30, or a continuity check on a board).

And in its "Next Steps" checklist, replace "The 0x130000 block's channel registers 0x10-0x17 (owning chip
not identified; see DSP Channel Register Map) still need semantic mapping." with "The 0x130000 block:
firmware use fully mapped (written once at boot, never read); owning chip unidentified (IC30 redump or
board continuity)."
