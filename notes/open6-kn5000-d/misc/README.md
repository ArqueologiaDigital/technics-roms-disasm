# Wave 6, lane kn5000-d, sub-lane misc (2026-11-02)

Items (rows of `notes/open-items/REGISTER.md`):

| id         | title                                            | outcome                        | section                                                                      |
|------------|--------------------------------------------------|--------------------------------|------------------------------------------------------------------------------|
| N-29e0f8b4 | KN5000 audio: the EQUALIZING sections' responses | CLOSED                         | [1](#1-n-29e0f8b4-the-equalizing-sections)                                   |
| N-1fe9a5df | Scoop unknowns: the glyph for the 0x09s          | CLOSED                         | [2](#2-n-1fe9a5df-the-glyph-drawn-for-the-0x09-bytes-of-tbl_accomppartnames) |
| N-52dcf02a | What IC307 sequence words encode                 | CLOSED (rest BLOCKED on IC306) | [3](#3-n-52dcf02a-what-ic307s-record-sequence-words-encode)                  |
| N-d352b868 | IC307 entries with no selector                   | CLOSED                         | [4](#4-n-d352b868-the-ic307-entries-no-selector-names)                       |

Probes: `probes/` (README there says per script what it answers and how to run it).

Renames for the lead to apply (not applied here): `rename_misc.sed`, one rule,
`Voice_Slot_ApplyPitchJitter` -> `WaveSel_AddRandomEntryOffset` (section 4).

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


---

## 2. N-1fe9a5df: the glyph drawn for the 0x09 bytes of Tbl_AccompPartNames

The last of the six Scoop unknowns (`notes/scoop-lane-2026-09-25/README.md`, "What remains"; the other
five were closed by lane kn5000-a on 2026-10-31).  Probe: `probes/accomp_part_popup_glyph.py`, output
`probes/accomp_part_popup_glyph.txt` (reads the six program ROMs v5-v10 and the table-data ROM; nothing
emulated).

### The draw path

1. `ParamPopup_AccompPart` (v10 0xEFFF88) clears the pop-up line (`DisplayStr_ClearRegion`: 27 spaces from
   RAM 0x0ECD), copies 16 bytes from `Tbl_AccompPartNames + 16 * (A >> 5)` to 0x0ECF, writes `Str_OffAccomp`
   ("OFF") to 0x0EDC when `(A & W) == 0`, and marks region 3 dirty.
2. `Display_RedrawMainContent` draws `SqStep_PopupLineField` (v10 0xE0BD89) through
   `Scoop_CurveUpdate_SegmentEnd`: the record's bytes are `02 0f 9b 11 00 00 06 ca 0e 00 00 1e 00 21 1c`, i.e.
   style 6 (+6), buffer 0x00000ECA (+7), 30 characters (+11), cell 0x1C21 = x 8, y 180 (+13).
3. `Scoop_CurveUpdate_SegmentEnd` copies the 30 bytes into its frame **through `Scoop_CharGlyphMap`**
   (`lda xhl, (Scoop_CharGlyphMap:24) / ld a, (xhl+wa)`), terminates the copy with 0, and draws it with
   the font `TextStyle_FontTable[6 & 0x3f]`.

### The answer

- `Scoop_CharGlyphMap[0x09]` = **0x20**: every code 0x01-0x0F maps to 0x20 (0x00 stays 0, the
  terminator; 0x10-0x1F map to UI symbols).  So DrawString never sees 0x09.
- `TextStyle_FontTable[6]` = **font 0** (8x16 fixed, glyph bank 0x945CB0 in the table-data ROM), and its
  glyph 0x20 is 16 zero bytes, **a blank cell, the same glyph as the space**.
- Identical in v5, v6, v7, v8, v9 and v10 (the probe checks each image; the table and map bytes are the same).

So the 0x09 bytes draw as **spaces**.  Byte 0x09 is ASCII TAB; [INFERENCE] the strings were typed with tab
characters (leading indentation of "ACCOMP PART1 ON" and "ACCOMP PART3 ON"), and the renderer's map turns
every control code into a blank, so a tab costs exactly one blank cell.  Nothing in the code treats 0x09
specially (no compare with 9 on this path).

### What the pop-up actually shows

The reader's 16-byte stride does not match the table: the three visible strings start at offsets 2, 18
and 36, never at a multiple of 16, and the reader's "OFF" overwrite at +13 is placed for a chunk that
starts with "ACCOMP PART" (as in its siblings: `ParamPopup_ApcMemory` writes "OFF" at +11 of
"APC MEMORY ON ", `ParamPopup_DynamicAccomp` at +15 of "DYNAMIC ACCOMP ON").  The caller
(`VoiceSlot_StatusRet`, sequencer control event `0x48` sub-code 3, on the step-record screen) calls it
only when bits 7-5 of the flag byte are not all 0, so A >> 5 is 1..7.  The probe replays it:

| A >> 5 | flag bits | parts on (`A & W` != 0) | parts off (`A & W` == 0) |
|--------|-----------|-------------------------|--------------------------|
| 1      | 00100000  | `N ACCOMP PART2 O`      | `N ACCOMP PARTOFF`       |
| 2      | 01000000  | `N   ACCOMP PART3`      | `N   ACCOMP PAOFF`       |
| 3      | 01100000  | ` ON OFF` + code bytes  | ` ON OFF` + code + `OFF` |
| 4-7    | 1xx00000  | program-code bytes      | code bytes + `OFF`       |

(The two blanks after "N" in A = 2 are the 0x09 0x09.)  [INFERENCE] This is a firmware bug, the same in
every version v5-v10: no reachable A yields "ACCOMP PARTn ON/OFF".  The 0x09s are part of the misalignment
(without them the strings would sit at 0, 16, 32, and A = 1, 2 would at least show PART2 and PART3 whole),
but even then part 1 would need A = 0, which the caller excludes.  Which flag bit stands for which part is
not settled here (the event's writer was not traced); the table above covers every value.  Seeing it on an
instrument or in MAME needs a sequencer song with that control event, opened on the step-record screen.

### Website page draft

Target: `display-subsystem.md`, section "### Character Encoding", after the paragraph "**Character → glyph
map:**".  Add:

> Codes 0x01-0x0F map to 0x20, so every control character draws as a blank cell, and 0x00 stays 0 and ends
> the string.  The step-record screen's own copy of the map (`Scoop_CharGlyphMap`, 0xE0CB1A in v10,
> byte-identical) is applied by `Scoop_CurveUpdate_SegmentEnd` to its pop-up line (RAM 0x0ECA, 30 characters,
> style 6 = font 0, at x 8, y 180).  That is why the two pairs of TAB bytes (0x09) in `Tbl_AccompPartNames`
> draw as spaces.
>
> **A firmware bug in the ACCOMP PART pop-up.**  `ParamPopup_AccompPart` copies 16 bytes from
> `Tbl_AccompPartNames + 16 × (flags >> 5)` and overwrites "ON " at +13 with "OFF", but the table's three
> strings start at offsets 2, 18 and 36 (0x09 0x09 "ACCOMP PART1 ON ACCOMP PART2 ON " 0x09 0x09 "ACCOMP PART3 ON ").
> No flag value the caller allows (1-7) lands on a string: the line reads `N ACCOMP PART2 O`,
> `N ACCOMP PARTOFF`, `N   ACCOMP PART3` and so on, or bytes of program code past the table.  The same in
> v5-v10.  *[INFERENCE]* from the code and the ROM bytes (probe `notes/open6-kn5000-d/misc/probes/accomp_part_popup_glyph.py`
> in technics-roms-disasm); not yet seen on an instrument.

---

## 3. N-52dcf02a: what IC307's record "sequence words" encode

Probe: `probes/ic307_record_words.py`, output `probes/ic307_record_words.txt`.  It pairs each IC307 entry with
the KN7000 entries that play the same recording (the KN7000 dumps hold both chips of each pair) and measures.

Starting point (2026-10-30, `notes/media-files-2026-10-30/README.md`): IC307 is the Y chip of a word-interleaved
pair.  A KN7000-style record `[B, p0, p1, p2, ...]` lies in the stream as B (Y), p0 (X), p1 (Y), ..., so IC307
holds `B, p1, p3, p5, ...` and its partner **IC306** holds `p0, p2, p4, ...`; 456 IC307 records equal a
KN7000 twin's odd words exactly (reproduced here: 456 exact, 0 on the even words, 9 differing, 65 with no twin,
965 head-only).  What this item adds, word by word:

| field (IC307 notes' name)         | meaning                                                                                            | evidence (probe section)                                                                                                                |
|-----------------------------------|----------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| `value`, s8, mostly -1..-8        | as u8 >= 0x80: a **segment of (256 - value) granules**; -1..-8 = 1..8 granules                     | A: 5,215 + 116 + 84 IC307 "sequence" words are KN7000 segment words; KN7000 `loop_probe.py` (945 of 954 loops)                          |
| key-split words (multiples of 8)  | the KN7000 "split list" (values < 0x80, descending by 8); meaning open on both models              | A: 423 + 53 words                                                                                                                       |
| `0x0080` spelled `WaveSplit 0x80` | a **segment of 128 granules**, not a split value                                                   | A: 37 words the IC307 byte rule calls "split" are KN7000 segments                                                                       |
| `end`, bit 7 (0x8000)             | LOOP_END on a segment word; with bit 6 (0xC000) REC_END; always the record's last word             | A: on the twins 0x8000 sits on the last word 1,421 of 1,421 times                                                                       |
| `mark`, bit 6 (0x4000)            | LOOP_START: the loop starts at this segment's end                                                  | A: 84 IC307 words; 197 in the twins' full records                                                                                       |
| `b`, bits 10:8                    | **this segment's gain exponent**; 0 on every 16-bit segment                                        | B1: 16-bit twins 96 of 96 code 0, 8-bit 5,262 of 5,356 non-zero; B3                                                                     |
| `a`, bits 13:11                   | **the gain exponent of the segment played next**: the next one, or after LOOP_END the loop's first | B2: 46,497 of 46,497 inner 8-bit segments, 372 of 372 8-bit loop ends, 582 of 582 16-bit; last segment without a loop: a = b 574 of 580 |

- **Why |a - b| <= 1 in 94 % of IC307's words:** a is the neighbour's b, and the encoder keeps neighbouring
  exponents within one step (B2: 92.4 % on the KN7000 8-bit records).  a carries no level of its own: the
  stored level does not change with a inside a segment (even/odd bytes, Y/X words, first/last quarter all flat)
  and at a boundary the regression gives 0.011 per unit of a against 0.750 per unit of b.  [INFERENCE] the
  tone generator reads the next segment's exponent ahead so that its interpolator can scale the samples it
  fetches across a segment boundary, including the wrap from LOOP_END back to the loop start.
- **The size of one exponent step (B3):** across 46,265 boundaries of the KN7000's 8-bit recordings the stored
  level jumps by a median 0.71-0.80 log2 per unit change of b, the same at every step from 0->1 to 4->5, up and
  down.  Decoding with gain `2^(-0.75 b)` leaves the smallest boundary jump (median 0.499 log2, against 0.538
  for `2^(-b/2)`, 0.541 for `2^(-b)` and 0.837 raw; the jump inside a segment, measured mid-segment, is 0.490).
  So the stored samples are normalised per segment and one step is **about 4.5 dB** (2^(-3/4)), if the decoded
  signal is continuous at boundaries.  That is a measurement of the data, not of the chip: the g13 emulation fit
  (`2^(-b/2)`, 3 dB) and this estimate disagree, and a line-out recording of an 8-bit sound on an instrument
  settles it (kn7000 `wave-roms-2026-10-29.md`, "The 8-bit gain law: BLOCKED").
- **How a word maps to a stretch of samples (C):** segments are laid end to end from the entry's first sample,
  `(256 - value) x L` samples each, `L = 2^(K+4)` with K = P bits 2:0 (8-bit segments count bytes).  IC307's
  visible word m is segment `2m + 1`, so it covers stream samples `[S(2m+1), S(2m+2))` with S the running sum
  of all earlier segments, X-chip ones included.  Checked on the 30 IC307 entries that start inside another
  entry's audio and have twins: each starts inside the other's segment 2m (the IC306 word before their first
  shared IC307 word), and its own first, IC306-side, segment is shortened so that it **ends exactly where that
  segment ends: 30 of 30**; the rest of its twin record equals the other's from word 2m + 1 on, 30 of 30.  That
  is the "words-to-granules ratio is not constant" observation of the IC307 notes, explained.

### What is BLOCKED, and on which chip

- **IC306** (QSIGT3C32A01, `notes/sound-2026-10-31/README.md` section 3; IC307's partner, which holds the odd words): for every IC307 entry it
  holds the directory P word (K, hence the granule L that turns a segment count into samples; the 8-bit flag;
  the pitch exponent E), the Q word and the even record words p0, p2, ...  So for the **65 + 9 IC307 entries
  without an exact KN7000 twin** neither the granule nor half of the segments are known, and no IC307 word can
  be placed on its samples.  For the 456 twinned ones the KN7000 twin gives them, which is an [INFERENCE] that
  the KN5000's IC306 holds the same words (the recordings are byte-identical; the records were checked only on
  the Y half).
- Recoverable from IC307 alone: half of the IC306 words' gain exponents, because each IC306 segment word's b is
  the a of the IC307 word before it (B2).
- Not settled by data: the split list's meaning (also open on the KN7000), the code on REC_END words, and the
  absolute step of the gain law (above).

### Corrections to `notes/waveform-ic307-2026-10-29/README.md`

The "Open questions" bullet on the sequence words is answered there with a pointer here; the "two kinds"
table gains the KN7000 names; the IC307 macro rule spells the 37 `0x0080` words as `WaveSplit 0x80` though
they are 128-granule segments.  The source (`waveform/`) is left as it is (bytes identical either way);
respelling them as `WaveSeq` would need `waveform_macros.inc` to accept value 0x80 with a, b = 0, and a gate run.

### Website page draft

Target: `waveform-rom-format.md`, section "### 2. Parameter Records (0x0318 - 0x1A2F)", after its description
of the word layout; and in "## Open Questions" replace the bullet "~~What do the sequence words encode?~~ ..." by
the shortened one below.

> **The 6-bit code is two gain exponents.**  On an 8-bit segment word, bits 10:8 (b) are the segment's own gain
> exponent and bits 13:11 (a) are the exponent of the segment that plays next: the next one in the record, or,
> on the LOOP_END segment, the first segment of the loop (checked on all 47,449 8-bit segment words of the
> SX-KN7000's wave ROMs, whose two chips are both dumped; on 16-bit segments both fields are 0).  The stored
> 8-bit samples are normalised per segment: across segment boundaries their level jumps by about 0.75 log2 per
> step of b, so one step is about 4.5 dB if the decoded signal is continuous (*[INFERENCE]*; an emulation fit
> used 3 dB, and only a recording from an instrument can decide).
>
> **Segments are laid end to end** from the entry's first sample, `(256 - value) × 2^(K+4)` samples each, K from
> the directory's P word (8-bit segments count bytes).  IC307's word m is segment 2m + 1.  An entry that starts
> inside another entry's audio starts inside one of that entry's segments, and its own first segment is
> shortened to end where that segment ends (30 of 30 such IC307 entries).
>
> So IC307 alone cannot place its words on its samples: the granule (P word) and every other segment are on
> IC306.  For the 456 IC307 entries whose recordings and records match a KN7000 entry, the KN7000 supplies them.
>
> Probe: `notes/open6-kn5000-d/misc/probes/ic307_record_words.py` in the disassembly repository.

Open Questions bullet:

> - ~~What do the sequence words encode?~~ The KN7000's record words seen from one chip: segment lengths, loop
>   marks, and a 6-bit code = (next segment's gain exponent, this segment's) ([above](#2-parameter-records-0x0318---0x1a2f)).
>   The step size of the gain law (about 4.5 dB from the data, 3 dB in the emulation fit) needs a recording from
>   an instrument; placing IC307's words on its samples needs IC306.

---

## 4. N-d352b868: the IC307 entries no selector names

Probe: `probes/ic307_unselected_entries.py`, output `probes/ic307_unselected_entries.txt`.

The walk of `notes/waveform-ic307-2026-10-29` (`tonedb_selector_users.py`) leaves 72 IC307 entries without a
factory selector: page 0 entries 0, 152, 159; page 1 entries 77, 80, 83, 85; page 2 entries 0, 24 and 63 of
41-111.  The paths it did not walk, one by one:

1. **No SET or drawbar record names any of them.**  All 487 SET descriptors' zone records (including SETs 116,
   117, 459-461, which the walk does not reach) and all drawbar zone records: 0 of the 72.
2. **RAM user tones and disk sounds cannot reach them.**  `VoiceParam_Update`'s user-tone path (part flags bit
   0) points a part at `ToneDB_RamBankA` / `ToneDB_RamBankB` velocity-split records (`SlotParam_WriteType3`..`7`:
   `RamBank + 0x1D6 * n + 0x1BA + 0x0B * p`, kits `+ 0x50 * n + 0x4AE1`); their band pairs still go through the
   factory StageA2 maps to the factory SETs, none of which names these entries.  [INFERENCE] a user sound saved to
   or loaded from floppy is such a RAM record, so the same holds for disk sounds.  A sound the HD-AE5000 supplies
   would reach the sub CPU the same way ([INFERENCE]: the expansion is main-CPU storage; the sub CPU's only
   non-factory tone path is the RAM bank).
3. **The random entry offset explains 63 of the page-2 entries.**  `Voice_Slot_ApplyPitchJitter` (v142
   0x02B3C0), called only from `Voice_Init_Type1`, adds `(tick & 7)` to the staged word at 0x0451CE, which the
   `ToneGen_StagingBlock` banner maps to TG register +0x040, the **recording selector** (not a pitch).  So that
   path picks one of 8 consecutive directory entries at random.  Page 2's unselected entries 41-111 are exactly
   `s + 1 .. s + 7` for the nine used selectors `s` = 40, 48, ..., 104 (0x6028 .. 0x6068), all multiples of 8 and
   all the **Organ Click** source (SET 62); each group of 8 is 8 start points into one click recording (entries
   that share a wave or start inside the group's first audio, the "tail" records of section 3, C).
   `Voice_Init_Type1` runs only from `Voice_SetPitch` / `Voice_NoteOff`, whose guard `(patch record +0x10 & 0xC0)
   == 0x40` holds for exactly two of the 607 patch records: `<Jazz Drawbars>` (0x8706BD) and `<Rock Drawbars>`
   (0x870867), +0x10 = 0x60.  [INFERENCE] the drawbar organ's key-click layer (key-on through `Voice_SetPitch`,
   key-off through `Voice_NoteOff`) plays Organ Click with a random start: a randomised key click.  The binding
   of that layer to SET 62 was **not traced** (it goes through `Voice_Allocate_1of4`, partial block +0x0B..+0x0D,
   `ToneDB_Find_ToneRecord` / `ToneDB_Find_SubToneRecord`); the next step is to trace that, or to log
   `WaveSel_StageB_Store_Reg040` / `Voice_Slot_ApplyPitchJitter` in MAME while a drawbar organ plays.
   Proposed rename (`rename_misc.sed`): `Voice_Slot_ApplyPitchJitter` -> `WaveSel_AddRandomEntryOffset`.
4. **What is left: 9 entries, none selectable by any data in this repository.**

| page | entry | what it is                                                                                               | KN7000 twin                               |
|------|-------|----------------------------------------------------------------------------------------------------------|-------------------------------------------|
| 0    | 0     | the 256-word test sine (already known)                                                                   | main page 0x00, 1 entry (`Main_P00_W000`) |
| 2    | 0     | the same sine                                                                                            | the same                                  |
| 0    | 152   | a 7,680 B wave with the split list 0x40 0x30 0x20 of its used neighbours 150 and 151 (Italian Acdn 4)    | none                                      |
| 0    | 159   | starts 296 units inside entry 157's audio, like the used 158 (section 3, C)                              | main page 0x05, 1 entry                   |
| 1    | 77    | 64 bytes of zeros, empty record, between HiHat Pedal (76) and Reverse Cymbal (78)                        | a zero run, no entry                      |
| 1    | 80    | the same, before 81                                                                                      | a zero run, no entry                      |
| 1    | 83    | the same, before 84                                                                                      | a zero run, no entry                      |
| 1    | 85    | points back at an earlier wave (24105); its record is 84's (0x0080 0x409E 0x80D4) without the loop marks | none                                      |
| 2    | 24    | shares entry 23's wave (Bright E.Bass) with entry 22's split list 0x38 0x28 0x18                         | (23's wave)                               |

[INFERENCE] these are leftovers of the build that laid out the shared wave set: zero placeholders (77, 80, 83),
alternative split or loop variants of a neighbour (24, 85, 152), and one more start point into a recording whose
other start points are used (159).  The KN7000 keeps 159's start as an entry of its own, so it may be used there.
Nothing in the KN5000's factory data, RAM user-tone path or disk sounds can name them; only a firmware path that
writes TG register +0x040 from somewhere other than a zone record could, and `WaveSel_StageB_Store_Reg040`, the
six `SlotParam_Write_Stride*` emitters, the clear in core/06 and the (tick & 7) offset are the only instructions in
v142 that name 0x0451CE (`Payload_Bss_Start+0x6358`) as a destination (a write through a computed pointer would
not show in that search).

### Website page draft

Target: `waveform-rom-format.md`, "## Open Questions": replace the bullet "Why do page 0 entries 152 and 159 ..."
with:

> - ~~Why do some entries have no selector?~~ 63 of page 2's are reached at random: the drawbar organ's
>   key-click path (`Voice_Init_Type1`, only for the `<Jazz Drawbars>` / `<Rock Drawbars>` parts) adds
>   `(tick & 7)` to the recording selector, and the nine Organ Click selectors 0x6028..0x6068 are multiples of 8
>   whose next seven entries are seven more start points into the same click (*[INFERENCE]* that the click layer
>   is Organ Click; not yet traced or seen in emulation).  No SET, drawbar record, RAM user tone or disk sound
>   names the other nine: the two test sines, three 64-byte silent entries on page 1 (77, 80, 83), split or loop
>   variants of a neighbour (page 0 152, page 1 85, page 2 24) and one more start point into page 0's entry 157
>   (159).  Probe: `notes/open6-kn5000-d/misc/probes/ic307_unselected_entries.py`.

and in "## IC307 as Source" (or wherever the class 6 = page 2 finding is given), add one sentence:

> Page 2's entries 40-111 are nine groups of eight: each group is one organ key-click recording with eight start
> points, and the firmware's drawbar key-click path picks one of the eight at random.
