# The KN7000 SHARC reverb — algorithm annotation

Static reverse-engineering of the reverb microprograms in the effects-DSP
record pool (2026-07-19). Everything below is read off the committed listings
in `../disasm/dsp/` (PM addresses quoted throughout); live-emulation evidence
is cited from `kn7000_mame/notes/` where it corroborates or dates the claims.

**Headline: the KN7000's reverb engine is the rec51–56 record family** — a
mono-in / stereo-out **Moorer-style reverberator with Dattorro-style input
diffusion**: filtered early-reflection taps, a 4-allpass series diffuser, one
*absorbing* allpass, and two long lowpass-damped feedback combs, closed by an
output tone filter and a short stereo-decorrelation delay. The six records are
one byte-identical program (rec51=54=55=56; rec52/53 differ only in four
early-tap immediates) with per-preset coefficient banks. The unit-9 "Reverb"
whitelist records (rec06/07/09) turn out to be **modulated-delay ensemble /
flanger programs with no tail-capable structure** — see §6 and the honest
open question in §7.

Sample rate: nominal **fs = 44100 Hz** (one kernel IRQ0 = one sample frame).
Supporting evidence: rec53's early-reflection taps decode to exactly
42/16/40/12 ms at 44.1 kHz, and the live tail measurements were taken at 44.1k.

## 1. Execution context (kernel facts these programs rely on)

From `rec04` (kernel) and its listing:

- The mainloop (PM `0x8078..0x80A4`) dispatches **10 unit calls per sample**.
  In ROM every call targets the null unit `0x80F7`; the host **patches each
  CALL's target** to `0x8400+n*0x100` when it downloads an effect into slot n.
  Each `CALL (DB)`'s two delay slots advance the shared delay cursors
  (`MODIFY(I6, …)` / `MODIFY(I2, …)`) — that is how per-unit delay arenas are
  assigned.
- **Delay cursor scroll**: the per-frame I6 advances sum to `0x456EF = L6−1 ≡
  −1 (mod L6)` and the I2 advances to `0x1C5F = L2−1` — both circular cursors
  **scroll one word per sample**, so a read at (write address + D) returns the
  value written D samples earlier. Delay lengths fall straight out of the
  address arithmetic.
- Buffers (kernel init `0x8D00`): external-SDRAM ring `B6=0x20000,
  L6=0x456F0` (284,400 words) for I6; internal ring `B2=0xC3A0, L2=0x1C60`
  (7,264 words) for I2. Modify registers: `M1=2, M2=+1, M3=−1, M5=0x4D,
  M6=0` (DM) and `M8=+1, M9=+2, M11=−1, M13=0x50, M14=0` (PM).
- Per-unit pointers at effect entry: `I1` = parameter block (`0xC004 +
  slot*0x4D`), `I8` = state block (`0x9800 + slot*0x50`, accessed over the PM
  bus), `I4` = I/O slot cursor. **I/O convention: input = `DM(I4+0x20)` /
  `DM(I4+0x21)`, output = two writes that leave I4 advanced by 2.** For the
  first call slot I4 = `0xC342`: input `0xC362/3` (the TG effect send), output
  `0xC342/3` — the emulator bridge's "reverb return" slot.
- The kernel zero-fills the SDRAM delay region at boot (`0x8D7E`), so a
  freshly loaded reverb starts with silent delay lines.

Record DM/PM blocks are stored with unit-0 targets (`0x8400`, `0xC000`,
`0x9800`); the host rebases them per destination slot. All addresses below are
record-local (unit-0 form).

## 2. The reverb program (rec51 listing, PM `0x8400..0x8471`, 114 words)

Per-frame skeleton (quoting `rec51_effect_0x486C8219.asm`):

- `0x8401-0x8402` save I6 to param `c003`; `0x8403` `MODIFY(I6, 0x10747)`
  puts the cursor at the **top of a 0x10748-word (1.53 s) arena**; every
  delay access then walks *down* with negative M7 post-modifies; `0x846E`
  restores I6 (the kernel's delay-slot MODIFYs own the arena walk).
- All delay taps follow one idiom: `M7 = −gap` then `Rx = DM(I6, M7)` (read,
  then descend), writes are `DM(I6, M3) = Rn` (write, descend 1). Because the
  arena scrolls −1/sample, **a line's delay = (its write's depth below the
  arena top) − (the read's depth)**.

### 2.1 Input conditioning + early reflections (`0x8404..0x8421`)

Two unity-DC-gain lowpass biquads (direct form II; coefficient order in DM is
`a1,a2,b1,b0,b2`) filter ± scaled mono sums, and each feeds a pre-delay line
with two taps:

- **Line A** ← LP1(−3.2·(L+R)) (gain `0x9801`, biquad `c004-c008`, poles
  r=0.547 ≈ 4.8 kHz). Write at `0x8418`; taps at **3712** and **1536**
  samples (84.2 / 34.8 ms).
- **Line B** ← LP2(+3.2·(L+R)) (gains `0x9804/5`, biquad `c009-c00d`, poles
  r=0.500 ≈ 5.8 kHz). Write at `0x8421`; taps at **2370** and **1280**
  samples (53.7 / 29.0 ms).
- The four taps are combined at `0x841F-0x8421` with a dual add/sub into a
  **sum/difference stereo pair**:
  `E1 = 0.129·A3712 + 0.034·B2370 + 0.2065·A1536 + 0.039·B1280`,
  `E2 = 0.129·A3712 + 0.034·B2370 − 0.2065·A1536 − 0.039·B1280`
  (gains = state words `0x9808-0x980B`). E1/E2 go straight to the two output
  channels — filtered, sign-alternating early reflections.

### 2.2 Input diffuser: 4 series allpasses (`0x8424..0x843A`)

Dry mono `0.64·(L+R)` (`c00e/c00f`) enters four chained Schroeder allpasses,
all with the same coefficient `k = 0.618` (`c010 = −0.618`; the code computes
`w = x + 0.618·D`, `y = D − 0.618·w`, e.g. ap1 at `0x8425-0x8429` with its
line write at `0x8428`):

| allpass | delay (samples) | ms |
|---|---|---|
| ap1 | 313 | 7.10 |
| ap2 | 607 | 13.76 |
| ap3 | 1227 | 27.82 |
| ap4 | 2587 | 58.66 |

ap3/ap4's tap reads are pre-scaled by `c011`/`c012` (1.0 in rec51; rec53
lowers them to 0.956/0.765 — an extra diffusion attenuator).

### 2.3 Absorbing allpass G (`0x843B..0x8444`)

A fifth allpass, delay **5239** (118.8 ms), with a **damping filter inside its
feedback loop** (Dattorro's "absorbing allpass" / Gardner's
lowpass-embedded allpass):

- tap → ×0.6618 (`c013`) → one-pole+zero damp `f_G`: `h' = in + 0.3741·h`
  (`c014`), `f = 0.313·h + 0.313·h'` (`c015/c016`) — unity DC gain, zero at
  Nyquist (state `0x980C`);
- `w_G = y_ap4 + 0.618·f_G(G@5239)` written at `0x8443`;
  `y_ap5 = f_G − 0.618·w_G` at `0x8444`.

### 2.4 The tank: two parallel damped feedback combs (`0x8444..0x845B`)

`y_ap5` feeds two long combs, each with its own unity-DC damping filter
(same one-pole+zero form; states `0x980D/0x980E`) in the feedback path and
the shared **tank-decay gain `c01a = −0.2435`** (the multiply is at `0x844A`
and `0x8454` — the live-traced "tank recirculation multiply"):

- **Comb H**: delay **16232** (368.1 ms), head written at `0x844C`:
  `w_H = y_ap5 − 0.2435·f_H(H@16232)`; damp `c017-c019`.
- **Comb I**: delay **14464** (328.0 ms), head written at `0x8457`:
  `w_I = y_ap5 − 0.2435·f_I(I@14464)`; damp `c01b-c01d`.

Wet sum (`0x8457-0x845B`): `wet = w_H + w_I + 0.487·(H@8912 + I@8466)`
(`c01e`; the mid-line taps at 202.1 / 192.0 ms densify the output).

Decay time at DC (damping filters are unity-DC): per pass
`20·log10(0.2435) = −12.3 dB` per loop → **RT60 ≈ 1.8 s** (H) / 1.6 s (I) for
rec51's bank — matching the ~1 s+ exponential tail measured live
(`reverb-toggle-findings.md` 2026-07-13). HF decays faster through the damps.

### 2.5 Output stage (`0x845B..0x846D`)

- The wet sum passes an **output tone biquad** (`c01f-c023`; in rec51 the
  same 4.8 kHz LP as the input filter) → `y_out`, which is written to a short
  **line J** (`0x846A`) tapped at **1** and **257** samples.
- Channel mixes (`0x8464`, `0x8469`):
  `out[I4+1] = 0.5·(E2 − 0.5614·J@257)` and
  `out[I4+0] = 0.5·(E1 + 0.5614·J@1)`
  (`c024/c025` wet mixes; `c026/c028 = 0x40000000` act as **fixed-point Q31
  ×0.5** output scales — the earlier "2.0 float" reading was the same bits
  misread as float). `FIX`, `CLIP ±0x7FFFFF` (`c027`), then the two output
  writes `DM(M2,I4)` (pre-modify, slot+1) and `DM(I4,M1)` (slot+0, I4 += 2).
  Opposite wet signs + the 1-vs-257-sample tap = cheap stereo decorrelation.

### 2.6 Signal-flow diagram

```
            +--------------------------------------------------------------+
 L ---+     |  EARLY REFLECTIONS                                           |
      |     |   -3.2*(L+R) -> LP1(4.8k) -> lineA --taps 1536,3712--+       |
 R ---+--->-|   +3.2*(L+R) -> LP2(5.8k) -> lineB --taps 1280,2370--+-> E1  |
      |     |          (sum/diff mix, gains .2065/.129/.039/.034)  +-> E2  |
      |     +--------------------------------------------------------------+
      |
      |      0.64*(L+R)                                  (all k = 0.618)
      +--->  ap313 -> ap607 -> ap1227 -> ap2587 ---> absorbing ap5239
             (series diffuser)                        |  ^damped loop (f_G)
                                                      v
                                y_ap5 ----+----------------+
                                          |                |
                                  comb H 16232       comb I 14464
                                  fb -0.2435*f_H     fb -0.2435*f_I
                                  |        \             |       \
                                  w_H     tap@8912      w_I     tap@8466
                                  |          \x0.487     |        /x0.487
                                  +-----------+----------+-------+
                                              v
                                   output tone biquad -> lineJ (taps 1, 257)
                                              |
        out_ch1 = 0.5*( E1 + 0.5614*J@1   ) <-+
        out_ch2 = 0.5*( E2 - 0.5614*J@257 ) <-+
```

### 2.7 Verification anchors (live traces that match this reading uniquely)

`kn7000_mame/notes/dsp-effect-execution-chain.md` (2026-07-11 f–s), taken
while the GUI reverb ran: pure-float path `0x840A-0x846F` ending in RTS at
`0x846F` ✓ (rec5x family is the only pool shape with that RTS); the
"inter-section scale exactly 1.0 at `0x842F`" ✓ (= `c011`); the "tank
recirculation multiply `F10=F10*F9` at `0x844A/0x8454`" with constant damped
F9 ✓ (= `c01a`; the live −0.2805 is a preset variant of rec51's −0.2435);
allpass g −0.618 ✓; input gain ±3.2 ✓ (state `0x9800/1`); SDRAM ring
`B6=0x20000 L6=0x456F0` ✓; I6 saved to `DM[I1−1]` at frame entry ✓.

## 3. The six presets

PM is identical across rec51=54=55=56; rec52/53 differ **only** in the four
early-tap `M7` immediates (`0x8406/0x8410/0x841A/0x841D`). Everything else is
the DM bank. Early taps (samples @ 44.1 kHz):

| rec | types | A taps | B taps | character (from the bank) |
|---|---|---|---|---|
| 53 | 0x10/0x11 | 706, 1852 (16/42 ms) | 529, 1764 (12/40 ms) | small room: tank decay −1/24 (RT60(DC) ≈ 0.8 s), diffusion scaled .956/.765, absorber gain .478, mid-tap out 1/12 |
| 54 | 0x12/0x13 | 1536, 3712 | 1280, 2370 | bright: all three loop damping filters bypassed (p=0, out=1·h') |
| 51 | 0x14/0x15 | 1536, 3712 (34.8/84.2 ms) | 1280, 2370 (29.0/53.7 ms) | reference bank; RT60(DC) ≈ 1.8 s |
| 55 | 0x16/0x17 | 1536, 3712 | 1280, 2370 | dark output: wet-sum LP poles r=.868 (≈1.8 kHz) |
| 56 | 0x18/0x19 | 1536, 3712 | 1280, 2370 | presence: output shelf, unity DC, Nyquist gain 1.45 (**boot-default program at PM 0x8400**) |
| 52 | 0x1E/0x1F | 2513, 4544 (57/103 ms) | 448, 2600 (10.2/59 ms) | long/dark: input LP poles r=.816 (≈1.4 kHz), damping p=.799, early tap B1 muted |

Fixed across all presets: diffuser 313/607/1227/2587, absorber 5239, combs
16232/14464 (+ taps 8912/8466), line J 1/257, k=0.618, wet ±0.5614.
Whitelist pairs (0x10/0x11 etc.) are the usual mono/stereo type aliases.
**GUI-name map PINNED LIVE 2026-07-20**
(`kn7000_mame/notes/dsp-unit-roles-live-capture.md`): the reverb screen's
page-1 presets select, on **unit 0** (the reverb unit — not unit 9),

| GUI | type | record |
|---|---|---|
| Room1 | 0x10 | rec53 |
| Plate1 | 0x12 | rec54 |
| Concert1 | 0x14 | rec51 |
| Dark1 | 0x16 | rec55 |

and each "…2" partner (Room2/Plate2/Concert2/Dark2) issues **no type
change** — a DM-bank-only rewrite of the same record (coefficient cells
c011–c01e/c026/c028 + the single PM word `0x8463`), i.e. each GUI pair =
one record + two host voicings. This matches the live checksum observation
(same PM, different DM) and the descriptor-table names for the un-driven
page 2 (rec56 = Bright1/2 0x18/0x19, the boot default; rec52 = Live
Stage/Stadium 0x1E/0x1F; rec51's alias types also serve Long1/2 + Large
Hall1/2).

## 4. Classification

Not a textbook Schroeder (no parallel-comb-then-allpass ordering alone), and
not a full Dattorro plate (no figure-of-eight modulated tank). It is a
**hybrid**: Moorer's recipe (tapped early-reflection FIR with tone filters +
lowpass-damped combs) with **Dattorro-style series input diffusion (4
allpasses) and an absorbing allpass**, economized to two combs. Every loop
filter is the same cheap unity-DC one-pole+zero; all delay state lives in one
scrolling SDRAM arena addressed purely by immediate offsets — an elegant
fit for the 10-unit scheduler.

## 5. Memory footprint

Deepest write depth = 0xB7A9 (47,017) words < the 0x10748 (67,400) arena the
kernel grants call-slot 1. Sum of all line lengths ≈ 46.8 kwords ≈ 1.06 s of
distinct delay storage.

## 6. The unit-9 "Reverb"-whitelist records are NOT reverbs

Full traces of rec06/07/09 (syms updated accordingly):

- **rec06** (types 0x01/0x2C): one sine LFO (table `c029`, 16-pt + guard,
  linear-interpolated); two fractional taps per channel at 250 ± 64 samples
  modulated in quadrature (table read +4 = +90°), right channel antiphase;
  voices averaged, wet-only. No feedback. A doubling/ensemble chorus.
- **rec07** (types 0x02/0x07/0x2D): same engine + a second slow LFO
  (`0x9800 = 0x055000` ≈ 7.2 Hz) mixed at 0.15 (`c005`) into both
  modulators. **Correction: `c005` is LFO cross-mix, not a feedback gain** —
  nothing recirculates.
- **rec09** (types 0x04/0x0B): one modulated tap per channel at 300 ± 64
  samples with **0.70 float regeneration** (`c006/c00a`; previous tap saved in
  `c003/c002`) — a stereo flanger. The "float allpass" previously reported at
  `0x842E` is the fractional-tap linear interpolation.

None of these can produce a seconds-long exponential tail (longest loop
≈ 7 ms), so **the audible GUI reverb cannot be rec06/07/09**. Their delay
lines live in the small internal I2 ring (B2=0xC3A0), not SDRAM.
**Mystery closed 2026-07-20**: the live unit-role capture
(`kn7000_mame/notes/dsp-unit-roles-live-capture.md`) shows unit 9 is the
**CHORUS** unit (the hold-CHORUS GUI selects {u9, 0x52=rec49} / {u9,
0x02=rec07}); the "Reverb" label on its whitelist was wrong — of course the
unit-9 records are all choruses. The GUI reverb runs on unit 0, whose
whitelist admits exactly this document's rec51–56.

Provisional oddity: the shipped LFO increment templates (`0x800000` = fs/256
≈ 172 Hz under the 2^31 FDEP phase wrap) are audio-rate. Since the host
rewrites the 0x9800 state block at select time (observed in the live upload
captures), the templates are probably placeholders; the wrap/scale reading
could also hide a 40-bit-shifter subtlety. Marked PROVISIONAL in the syms.

These three records now have their own full annotation at the standard of
this document — `chorus-family-algorithms.md` — with two corrections to the
summaries above: rec09's LFO phase templates are **90°** apart (not 45°; the
2^31 wrap makes `0x20000000` 4 of 16 table steps), and the kernel's MODE1
write `0x3000` sets **ALUSAT** (not NESTM), so rec07's ±1.15 modulator sums
saturate at ±1.0 and its tap swing stays ±64 samples.

## 7. ~~Open question~~ RESOLVED (2026-07-20): the unit-number / GUI-role mapping

The decisive experiment this section called for was run
(`kn7000_mame/notes/dsp-unit-roles-live-capture.md`): tapping the
DspEffectSelect param block AND the download ports while driving the REVERB
screen shows **reading 1 was correct** — DspEffectSelect unit numbers DO
equal mainloop call-slot numbers, and the *labels* were wrong: **unit 0 IS
the REVERB unit** (Room1/Plate1/Concert1/Dark1 → {unit 0, types
0x10/0x12/0x14/0x16} → records to PM `0x8400`) and **unit 9 IS the CHORUS
unit** (Chorus1–4 → {u9, 0x52=rec49}, GM Chorus1–4 → {u9, 0x02=rec07} → PM
`0x8D00`). The "…2" GUI partners are DM-bank-only voicings of the same
record (§3). `dsp-effect-catalog.md` §3's role column is corrected
accordingly (unit 7 = MIC REVERB as well).

## 8. Cross-model

The KN6000/KN6500 pool's DM blocks are byte-identical to the KN7000's for all
80 records (only PM was revised). All coefficient banks, delay immediates
included in DM, and therefore all preset *voicings* above carry over; the
KN6xxx PM should be re-checked for the same four early-tap immediates before
assuming identical early patterns.
