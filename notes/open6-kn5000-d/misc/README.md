# Wave 6, lane kn5000-d, sub-lane misc (2026-11-02)

Items (rows of `notes/open-items/REGISTER.md`):

| id         | title                                            | outcome | section                                    |
|------------|--------------------------------------------------|---------|--------------------------------------------|
| N-29e0f8b4 | KN5000 audio: the EQUALIZING sections' responses | CLOSED  | [1](#1-n-29e0f8b4-the-equalizing-sections) |

Probes: `probes/` (README there says per script what it answers and how to run it).

---

## 1. N-29e0f8b4: the EQUALIZING sections

Source: the KN5000 service manual, `technics-docs/service_manual/technics_sx-kn5000.pdf`, PDF page 39
(printed II-24/II-25, "FAJ/ACP/JACK/HB P.C. Diagram"), grid 6-9 / A-C.  Rendered with

    P=/home/fsanches/compartilhado/technics-docs/service_manual/technics_sx-kn5000.pdf
    pdftoppm -r 250 -f 39 -l 39 -x 2050 -y 1580 -W 1600 -H 780 -png "$P" eqWide   # IC4..IC14, both channels
    pdftoppm -r 500 -f 39 -l 39 -x 5100 -y 3150 -W 1600 -H 750 -png "$P" eqA      # EQ, left channel
    pdftoppm -r 500 -f 39 -l 39 -x 5100 -y 3850 -W 1600 -H 800 -png "$P" eqB      # EQ, right channel
    pdftoppm -r 500 -f 39 -l 39 -x 4000 -y 3280 -W 1150 -H 680 -png "$P" ic7      # IC4A, IC7A
    pdftoppm -r 500 -f 39 -l 39 -x 6450 -y 3150 -W 1100 -H 650 -png "$P" ic14     # IC14A

(renders are the manual's own pages and are not committed).

### Reading of the sheet

All op-amps are M5218AL halves ("IC4,7,8,10-12,14 M5218AL").  Every value below was legible at 500 dpi,
and **the left (IC*A) and right (IC*B) channels carry the same values**, which is the main check on the
reading; no value is marked uncertain.  One caveat on the **topology**: the nets were followed on the scan
(dots at the junctions are clear), not continuity-checked on a board.

```
IC4A out -> C42 0.047u -> node J;  J - R38 10k - gnd;  J - C48 0.068u - IC7A(-);  J - C96 0.068u - IC7A out
            IC7A: (+) = gnd, feedback R87 150k || C67 22p                            => MFB high-pass
IC7A out -> R55 3.3k -> BUS
BUS - IC8A network:  BUS-R28 6.8k-OUT8; BUS-C59 4700p-Y; Y-R60 4.7k-OUT8; Y-C60 0.01u-P; P-R57 150k-gnd;
                     IC8A (+)=P, (-)=OUT8 (follower)
BUS - IC10A network: same shape, R95 6.8k, C4 0.01u, R7 4.7k, C57 0.047u, R2 150k
BUS - IC11A network: BUS-C84 0.015u-M; M-R13 1k-OUT11; M-C85 2200p-P; P-R11 150k-gnd; follower
BUS - IC12A network: BUS-R18 10k-OUT12; BUS-C89 0.015u-P; P-R16 8.2k-gnd; follower
BUS -> R41 82k -> IC14A(-), (+) = gnd, feedback R91 150k || C98 33p; out -> R90 100 -> LIN (R22 2.2k, C22 150p)
```

| function         | left          | right         | value                       |
|------------------|---------------|---------------|-----------------------------|
| input coupling   | C37           | C38           | 10 uF 16 V                  |
| mixing amp in/fb | R82, R85, C46 | R84, R86, C45 | 10k, 33k, 220p              |
| IC7 high-pass    | C42, R38      | C41, R37      | 0.047u, 10k                 |
|                  | C48, C96      | C47, C97      | 0.068u, 0.068u ("TF" marks) |
|                  | R87, C67      | R88, C68      | 150k, 22p                   |
| bus series R     | R55           | R56           | 3.3k                        |
| IC8 network      | R28, C59, R60 | R78, C61, R61 | 6.8k, 4700p, 4.7k           |
|                  | C60, R57      | C62, R58      | 0.01u, 150k                 |
| IC10 network     | R95, C4, R7   | R96, C82, R10 | 6.8k, 0.01u, 4.7k           |
|                  | C57, R2       | C83, R3       | 0.047u, 150k                |
| IC11 network     | C84, R13      | C86, R15      | 0.015u, 1k                  |
|                  | C85, R11      | C87, R12      | 2200p, 150k                 |
| IC12 network     | R18, C89, R16 | R21, C91, R17 | 10k, 0.015u, 8.2k           |
| IC14 summer      | R41, R91, C98 | R42, R92, C99 | 82k, 150k, 33p              |

### What each section does

`probes/faj_eq_response.py` solves each stage exactly (MNA over polynomials in s with rational
coefficients, ideal op-amps), then reports poles / zeros as f0 / Q and the magnitude at the 1/3-octave
centres.  Its output is committed as `probes/faj_eq_response.txt`.

- **The equaliser is a shunt equaliser.**  Each of the four sections is a one-port from the bus to ground:
  an op-amp follower whose output closes a resistor back to the bus, i.e. a **gyrator** (simulated
  inductor).  The bus is fed from IC7's low-impedance output through R55 3.3k and loaded by R41 82k into
  IC14A's virtual ground, so the bus voltage is the divider `Zshunt || 82k / (3.3k + Zshunt || 82k)`.  A
  section can only **cut**, and it cuts where its impedance is lowest.  None of them has a pot: the EQ is
  fixed.
- **IC8** (two capacitors: a second-order gyrator): its impedance has a zero pair at **874 Hz, Q 2.6**, and
  is 6.8k at low frequency, 136k at 20 kHz.  Alone on the bus: a **dip at 802 Hz, -6.7 dB** re the treble
  level, a -3.2 dB shelf below it, and a +0.9 dB rise near 1.4 kHz.
- **IC10** (the same circuit, C4 0.01u / C57 0.047u): zero pair at **277 Hz, Q 2.1**.  Alone: a **dip at
  246 Hz, -5.9 dB** re treble, the same -3.2 dB low shelf.
- **IC11** (C84 in series with a classic gyrator, L = R13 x R11 x C85 = 0.33 H): a series R-L-C to ground,
  resonant at **2262 Hz, Q 4.1** (R13 1k being the series resistance).  Alone: a **notch at 2262 Hz,
  -11.3 dB**, flat elsewhere.
- **IC12** (gyrator without series C, R16 8.2k < R18 10k): its impedance only moves from 10k at low
  frequency to 8.2k at high (pole 1061 Hz, zero 1294 Hz), so alone it is a level drop of 2.7-3.2 dB that
  varies by **0.45 dB**: a very gentle treble cut.  That is odd for a gyrator (usually R16 >> R18), but
  8.2k is printed on both channels.  `--set=R16=82000` shows what an 82k part would do (a 2 dB treble
  shelf); the reading stands as printed.
- **All four together**: dips at **241 Hz (-9.2), 789 Hz (-8.2), 2272 Hz (-12.6)** with maxima at 390 Hz
  and 1165 Hz (bus voltage re IC7 output, dB).
- **IC7 ("LOW PASS FILTER") is a high-pass.**  C42 in series, R38 to ground, C48 into the inverting input
  and C96 from the junction to the output is the multiple-feedback **high-pass**: poles at **60.4 Hz,
  Q 1.44**, double zero at DC, in-band gain -C42/C48 = -0.69 (-3.2 dB), a +0.5 dB bump at 69 Hz,
  -18.5 dB at 20 Hz re band.  R87's 22p (C67) only matters far above 20 kHz.  The manual's label is
  wrong for this drawing; whether the drawing or the label is wrong is not settled without a board.
- **IC4A**: -3.3 (+10.4 dB) for the DAC input, pole at 21.9 kHz (R85 || C46); C37 10 uF with R82 gives a
  1.6 Hz high-pass.  **IC14A**: -1.83 (+5.2 dB), pole at 32.2 kHz.

### The whole speaker path, `LOUT` (main CN9) to `LIN` (to the SWA board)

| f (Hz) | IC7   | EQ bus | whole path | re 1 kHz |
|--------|-------|--------|------------|----------|
| 20     | -21.7 | -7.4   | -13.5      | -21.9    |
| 50     | -2.8  | -7.5   | +5.3       | -3.1     |
| 100    | -0.9  | -7.7   | +7.1       | -1.4     |
| 250    | -2.8  | -9.2   | +3.6       | -4.9     |
| 500    | -3.1  | -6.1   | +6.4       | -2.0     |
| 800    | -3.2  | -8.2   | +4.2       | -4.2     |
| 1000   | -3.2  | -4.0   | +8.4       | 0.0      |
| 2000   | -3.2  | -9.7   | +2.6       | -5.8     |
| 2500   | -3.2  | -10.9  | +1.4       | -7.0     |
| 5000   | -3.2  | -4.1   | +7.9       | -0.5     |
| 10000  | -3.2  | -3.7   | +7.5       | -0.9     |
| 20000  | -3.2  | -3.6   | +4.8       | -3.7     |

(dB; the full 1/3-octave table, with every section alone, is in `probes/faj_eq_response.txt`.)

So the speakers get a 60 Hz high-pass and three fixed dips, at about 245 Hz, 790 Hz and 2.27 kHz.
[INFERENCE] This is the cabinet / driver voicing: the dips would flatten resonances of the 12 cm and
6.5 cm drivers and the cabinet; nothing on the sheet says so, and no acoustic measurement exists.
[INFERENCE] The headphone amplifier (IC5/IC6, two 15k inputs) is fed ahead of IC7 (the hwaudio net
reading), so headphones and LINE OUT do not get this EQ.  The bass channel on the SWA board sums LIN and
RIN, so it gets the 60 Hz high-pass and the 245 Hz dip.

### Corrections made in `notes/open4-kn5000-b/hwaudio/README.md`

`notes/open-items/notes-errors-2026-10-31.md` row 1, and what this item found:

- X301 is a **33.8688 MHz** part (parts list QSXG1I3386A; the schematic's 36.8688 is a misprint), not
  "maybe a misprint"; text and draft corrected.
- 44.1 kHz is now stated as an **inference** for the hardware (crystal ratio, and the firmware's DSP maths
  assumes it), not "proven".
- The jy9 draft's target: the published subsection "#### Audio Output Path" under "### Audio / Sound
  Generation" in `hardware-architecture.md`; the old text named a "### Audio Output Path" section
  holding serial-port text that does not exist.
- IC7 is not a low-pass: signal-path sketch and draft table row corrected; the EQ row now gives the dips.
- A new subsection "EQUALIZING sections (computed 2026-11-02)" summarises this item; the "Left open"
  bullet is struck through.

### Website page draft

Target: `hardware-architecture.md`, subsection "#### Audio Output Path".  Replace the two table rows

    | "low pass filter" | IC7A/B | per the manual's label |
    | equaliser         | IC8, IC10, IC11, IC12 | four filter sections per channel |

with

> | "low pass filter" | IC7A/B                         | labelled so, but drawn as a high-pass: 60.4 Hz, Q 1.44                 |
> | equaliser         | IC8, IC10, IC11, IC12          | four fixed gyrator shunts: dips at 245 Hz, 790 Hz and 2.27 kHz         |

and add after the table:

> **Speaker equaliser.**  IC7's output reaches a bus through R55 (3.3 kΩ); four gyrator networks (an
> M5218AL half wired as a follower, with RC around it) shunt that bus to ground, and IC14 (82 kΩ in,
> 150 kΩ feedback) buffers it.  Each network can only cut, where its impedance is lowest.  Computed from the
> printed values (both channels identical):
>
> | section | network                                    | effect (alone)                                        |
> |---------|--------------------------------------------|-------------------------------------------------------|
> | IC7     | MFB high-pass, 10k / 150k, 47n / 68n / 68n | high-pass 60.4 Hz, Q 1.44 (manual: "low pass filter") |
> | IC8     | second-order gyrator, 6.8k / 4.7k / 150k   | dip at 800 Hz, about -6.7 dB                          |
> | IC10    | the same, with 10n / 47n                   | dip at 245 Hz, about -5.9 dB                          |
> | IC11    | 15n in series with a 0.33 H gyrator, 1k    | notch at 2.26 kHz, Q 4.1, about -11 dB                |
> | IC12    | gyrator 10k / 8.2k / 15n                   | almost flat (0.45 dB)                                 |
>
> From `LOUT` to the speaker amplifier the path gains +8.4 dB at 1 kHz and, relative to that, is -3 dB at
> 50 Hz, -4.9 dB at 245 Hz, -4.2 dB at 790 Hz, -8.7 dB at 2.27 kHz and -3.7 dB at 20 kHz.  The headphone
> output does not pass through it.  *[INFERENCE]* The dips voice the cabinet and drivers; no acoustic
> measurement exists.  Computed by `notes/open6-kn5000-d/misc/probes/faj_eq_response.py` (technics-roms-disasm)
> from service manual p. II-25.

