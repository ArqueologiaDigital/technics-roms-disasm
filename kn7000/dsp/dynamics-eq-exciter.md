# The KN7000 SHARC exciter, dynamics family, EQs — and the distortion variants

Static reverse-engineering of the tone-shaping cluster (2026-07-19), at the
standard of `reverb-algorithm.md` / `insert-effects-algorithms.md` /
`phaser-enhancer-gate.md`: everything below is read off the committed listings
in `../disasm/dsp/` (PM addresses quoted), with coefficient roles, exact
constants and topology pinned. Records covered: **rec20** (type 0x23, GUI
EXCITER1–3), **rec21/rec25** (0x24/0x29, GUI Comp.1–4 / Limiter1–4 — one
PM-identical program), **rec22** (0x25, GUI Slow Attacker1–4), **rec23** (0x27,
GUI Parametric EQ presets), **rec34** (0x4F, the unit-8 output EQUALIZER), and
the remaining distortion variants **rec17/rec18/rec19** (0x20/0x21/0x22, the
GUI distortion banks) and **rec38/rec39/rec40** (0x83/0x84/0x85), byte-diffed
against the documented rec37/rec62 engines. GUI names are ROM fact via the
preset-descriptor table (`tremolo-rotary-family.md` §1). All are on the
units-1–6 insert whitelist except rec34 (unit 8 only).

**Headline — four findings:**

1. **The real exciter generates harmonics the way an exciter should** (rec20):
   drive → an interpolated 33-point waveshaper (the same c028 table window as
   rec37, template = the identical 7.5/1.5/0.5 hard-knee curve) → a
   **unity-peak resonant bandpass at 3.56 kHz** that selects the presence-band
   distortion products → **added to the dry signal** at 0.5. Nonlinearity,
   band-select, parallel mix: the textbook harmonic exciter — completing the
   contrast with rec08, the "Enhancer" that adds *no* harmonics.
2. **The compressor's gain computer is a closed-form reciprocal law**, not a
   table: gain = 1/3 + 2³¹/(6·env), computed with `RECIPS` + **three
   Newton–Raphson iterations** (full precision — the distortion AGCs use the
   seed only), clamped at 2.0 below 0.1 FS **where the curve meets the clamp
   exactly**. The resulting static curve is a soft knee whose ratio glides
   6:1 → 1.5:1 with level. Detector: peak-style, attack 1/32 (0.73 ms),
   release 1/2048 (46 ms).
3. **rec22 "Slow Attacker" is a two-target gain state machine**, not a
   compressor: above −24 dBFS the gain slews toward 1.0 with τ = 2¹⁵ samples =
   **743 ms** (the bowed-string fade-in); below, toward 0 with τ = 2⁷ = 2.9 ms
   (fast reset so the next note starts silent).
4. **Both EQs ship mathematically flat**: rec23 and rec34 are the same
   5-section cascade (1st-order + three biquads + 1st-order) whose template
   numerators are **bit-exact mirrors of their denominators** — pole/zero
   cancellation, H(z) ≡ 1 — with the *pole frequencies pre-placed* (~124 Hz /
   ~0.5 k / ~1 k / ~2 k / high). The presets only move the zeros off the
   poles. rec34 is a 13-word wrapper around **kernel helper `0x831B`, which
   is this cascade** (correcting the old "3-tap interpolation coefficient
   generator" reading), and its I/O convention is pure in-line insert —
   settling what the u8 "master EQ" slot expects (§5.4).

Sample rate: nominal fs = 44100 Hz. Execution context = the kernel contract
(`kernel-architecture.md` §7): `I1` params (`0xC004+slot·0x4D`), `I8` state
(`0x9800+slot·0x50`, PM bus), `I4` I/O cursor (inputs at `+0x20/+0x21`),
`I2` internal delay ring scrolling −1/sample (read at write+D = D samples
ago), `M1=+2, M2=+1, M3=−1, M4=−2, M6=0`. Addresses are record-local (unit-0
form). Q31 = fixed-point /2³¹.

## 1. rec20 — the EXCITER (type 0x23, GUI Exciter1–3)

70 PM words (`rec20_effect_0x486C1D29.asm`). Corrects "waveshaper/distortion
+ biquad EQ (enhancer)": the biquad is not an EQ, it is a **harmonic-band
selector**, and the record is the only distortion-family member that **adds
its output to the dry signal**.

Per channel (ch0 `0x8401–0x8421`, ch1 `0x8423–0x8442` re-using every
coefficient after a `MODIFY(I0,−7)` rewind):

1. **Drive** (`0x8402–0x8403`): input × **c004** (float, template 1.0) — a
   host-set fixed drive, *no envelope follower* (unique in the family: an
   exciter's harmonic level should track program level, so the drive is
   static).
2. **Waveshaper** (`0x8404–0x840F`): the family's signal-indexed
   interpolated-LUT idiom (FIX, `<<8`, `ASHIFT −11` → ±16 index + 16-bit
   fraction via `FDEP R8 BY 15:16`, `I5 = I1+0x34` = c038 curve center,
   linear interpolation; fraction floated by **c005 = −31**). The template
   c028–c048 curve is **bit-identical to rec37's**: the odd-symmetric
   33-point PWL knee, slopes 7.5 (|x|<1/16), 1.5 (to 1/8), 0.5 (to ±1) —
   host-replaceable per preset.
3. **Presence bandpass** (`0x8410–0x8417`, 3-coefficient form; states PM
   `0x9800/1` ch0, `0x9802/3` ch1): `w[n] = u + a1·w1 + a2·w2`,
   `y = g·(w − w2)` — zeros at DC and Nyquist (rec74's resonator form), with
   **a1 = c007 = 1.32615, a2 = c008 = −0.57508, g = c009 = 0.21246**:

   | quantity | value |
   |---|---|
   | pole radius r | √0.57508 = **0.7583** |
   | center | **3556 Hz** |
   | −3 dB width | ≈ 3.4 kHz (broad presence band) |
   | peak gain | g·2sinθ/((1−r)·\|1−re^(−2jθ)\|) = **0.97 ≈ unity** |

   g is chosen to make the selector **unity-gain at center** — the wet path
   neither boosts nor pads the harmonics it keeps; c006 (template 1.0) trims
   the shaper output into the filter.
4. **Parallel mix** (`0x8418–0x8421`): `out = (0.5·bp + dry) × c00b`, with
   **wet = c00a = 0.5** and **c00b the master output level (template 0 —
   silent until the host writes it**, the rec14 idiom). Dry is re-read from
   the I/O slot at full level, `<<8` to Q31; the product is `>>8` to 24-bit.
   No CLIP stage.

```
 in ──┬──────────────────────────────────────────────(+)──×c00b──→ out
      └─×c004─→ PWL LUT (c028..c048) ─→ BP 3.56 kHz ──×0.5┘
        drive    adds harmonics          unity-peak    wet
```

So the Technics **EXCITER** = distort, bandpass the distortion around
3.5 kHz, add a little back — real new spectral content, where the GUI
**ENHANCER** (rec08, `phaser-enhancer-gate.md` §2) is a purely linear
phase/tilt/width trick. The two GUI names split exactly along the
classic aural-exciter vs psychoacoustic-enhancer line. The three
Exciter1–3 presets are DM edits (drive, band, wet, level, and the curve
itself). records.tsv conf → high.

## 2. rec21 = rec25 — the COMPRESSOR / LIMITER (0x24 / 0x29)

45 PM words, byte-identical PM (`rec21_effect_0x486C2092.asm`); the GUI's
**Comp.1–4** (rec21) and **Limiter1–4** (rec25) are the same program with
different DM banks written at select time. One state word (env, PM `0x9800`).

### 2.1 Detector (`0x8401–0x840A`)

`env += k·(|(L+R)<<9| − env)` — rectified stereo sum, asymmetric one-pole:
**attack k = c004 = 2²⁶/2³¹ = 1/32** (τ = 0.73 ms), **release k = c005 =
2²⁰/2³¹ = 1/2048** (τ = 46.4 ms), selected by the `IF LT` reload at `0x8407`.
A *peak-style* detector (fast-attack/slow-release), 8× faster on attack than
the 1/256 distortion-AGC standard — this gain rides the output directly, so
transients must be caught, not just estimated. (The `<<9` headroom idiom
wraps for |L+R| > 2²², as in rec47's follower — harmless for a level
detector, noted for completeness. Input-referred: detector full scale ≈ the
stereo sum at 1/8th of channel rail; thresholds below are in detector units.)

### 2.2 Gain computer (`0x840B–0x841B`) — float, full precision

The envelope is floated and inverted by **`RECIPS` + three Newton–Raphson
iterations** (`0x8410–0x8417`: `x' = x·(2−d·x)`, R11 = 2.0, product
accumulated in F7 — the same recipe as rec46's bilinear engine). Then:

```
gain = c006 + c007/env = 1/3 + (2³¹/6)/env          (c006 = 0.333333,
                                                     c007 = 357913920 ≈ 2³¹/6)
IF env ≤ c008 = 0.1 (Q31):  gain = c009 = 2.0
```

The clamp meets the curve **exactly**: 1/3 + 1/(6·0.1) = 2.0 — the same
"reciprocal meets clamp at threshold" construction as the distortion AGC
(rec37/rec62: 0.111 + 8.35e8/env, clamp 4.0 at 0.1 FS), with continuous gain
across the threshold. With e = env/2³¹ the static law above threshold is

```
out = e·gain = e/3 + 1/6        — affine in the envelope
```

i.e. a **soft knee whose compression ratio glides with level** (slope in dB
= 2e/(2e+1)):

| e (detector) | gain | ratio |
|---|---|---|
| 0.10 (thr) | 2.00 (+6.0 dB) | 6.0:1 |
| 0.25 | 1.00 (0 dB) | 3.0:1 |
| 0.50 | 0.667 (−3.5 dB) | 2.0:1 |
| 1.00 | 0.500 (−6.0 dB) | 1.5:1 |

Below threshold the fixed 2.0 = **+6 dB makeup**; unity gain crosses at
e = 0.25. There is no ratio parameter *in the record* — the Limiter vs
Compressor banks reshape the curve by rewriting c006/c007/c008/c009 (and
c00a) at select time (bank values not statically recoverable, as with
rec12's presets).

### 2.3 Application (`0x841C–0x8429`)

One gain, both channels (stereo-linked — no image shift): input floated,
× gain (float), FIX, × **c00a makeup** (Q31, template ≈1.0), **CLIP
±0x7FFFFF** — the 24-bit rail is the limiter's final safety. Full-replace
insert semantics: no dry path, no wet level.

Note the division of labor on a chip with ALUSAT: the *detector* is
fixed-point MAC arithmetic (bounded by construction), the *gain math* is
floating-point (immune to saturation), and the only saturation used is the
explicit output CLIP.

## 3. rec22 — the SLOW ATTACKER (0x25, GUI Slow Attacker1–4)

28 PM words (`rec22_effect_0x486C229D.asm`) — the smallest real effect in
the pool. Same detector as rec21 (attack 1/32, release 1/2048, state PM
`0x9800`), then a **threshold-driven two-target gain integrator** (gain
state PM `0x9801`):

```
0x840d: COMP(env, c006)                  ; threshold c006 = 0.125 (Q31)
  loud  (env ≥ 0.125): target = c007 = 0x7FFFFFFF (≈1.0), step = c008 = 2⁻¹⁵
  quiet (env < 0.125): target = c009 = 0,            step = c00a = 2⁻⁷
0x8411: gain += step·(target − gain)     ; MRF one-pole slew
```

- **Note onset**: gain climbs 0 → 1 exponentially with τ = 2¹⁵ samples =
  **743 ms** — the attack transient of a piano/guitar note is swallowed and
  the sound swells in like a bowed string (the effect's whole point).
- **Note off**: gain falls with τ = 2⁷ = **2.9 ms** — a fast reset so the
  *next* onset starts from silence and gets the swell again (without this
  the effect would only work once).

Threshold 0.125 detector-FS ≈ −24 dBFS input-referred. Output = input × gain
× c00b (makeup, template ≈1.0), both channels from the one gain, no CLIP
(gain ≤ 1 can't overflow). The four GUI presets rewrite the two step rates
(= attack/reset speeds) and the threshold. records.tsv conf → high.

Contrast with rec12's gate (`phaser-enhancer-gate.md` §6.2), the only other
two-target gain machine in the pool: rec12 gates a *reverb tail* with
hold/debounce cleverness; rec22 is the same ±target idiom reduced to four
instructions and pointed at the *attack envelope*.

## 4. rec23 — the PARAMETRIC EQ (0x27)

81 PM words (`rec23_effect_0x486C2447.asm`). GUI presets (descriptor table):
Make Up / Middle Cut / Radio / Treble Boost / Treble Cut / No Hi Hat / Bass
Cut / Too Bright — 20 parameters each.

### 4.1 The cascade (`0x8403–0x8421` ch0; `0x842A–0x8448` ch1 after a
`MODIFY(I0,−22)` rewind — same coefficients, own states; 8 state words per
channel at PM `0x9800`/`0x9808`)

Five sections in series, all in float:

- **S1, S5 — first-order** (5-instruction body, e.g. `0x8403–0x8407`):
  `w = x + p·s; y = g·w + z·s` → H(z) = g·(1 + (z/g)z⁻¹)/(1 − p z⁻¹),
  coefficient cells (p, z, g).
- **S2–S4 — biquads** (the kernel-style 6-op body, e.g. `0x8408–0x840E`):
  `w = x + a1·w1 + a2·w2; y = g·w + b1·w1 + b2·w2`, cells (a1, a2, b1, g, b2)
  — the same direct-form-II idiom as rec37's tone stage.

Output: FIX, × c019 (Q31, template ≈1.0), CLIP ±0x7FFFFF.

### 4.2 The template is flat by pole/zero cancellation — with the bands
pre-placed

Every template numerator is the **bit-exact mirror** of its denominator
(S1: z = −p, g = 1; S2–S4: b1 = −a1, b2 = −a2, g = 1 — identical mantissas,
flipped sign bits), so each section's transfer function is exactly 1 and the
whole record passes signal through untouched (to float rounding). But the
*denominators are not trivial* — the poles sit at real frequencies:

| section | template pole(s) | center |
|---|---|---|
| S1 (1st-order) | p = 0.982347 | ~124 Hz |
| S2 | a1 = 1.977334, a2 = −0.982362 → r = 0.9911 | **496 Hz** |
| S3 | a1 = 1.945209, a2 = −0.965120 → r = 0.9824 | **992 Hz** |
| S4 | a1 = 1.854196, a2 = −0.932108 → r = 0.9655 | **1985 Hz** |
| S5 (1st-order) | p = 0.218894 | high band (corner ≈ 8 kHz region) |

— octave-spaced mids (496/992/1985!). A preset "boosts a band" by moving
that section's zeros off its poles; an untouched band stays *exactly* flat
rather than approximately flat. The 20 descriptor params ≈ 4 GUI knobs × 5
bands, mapped to coefficients host-side (**PROVISIONAL** as a mapping; the
cells and template are ROM fact).

## 5. rec34 — the unit-8 output EQUALIZER (0x4F) and kernel helper `0x831B`

13 PM words (`rec34_effect_0x486C45E2.asm`) — a wrapper:

```
8400: CALL 0x831B (DB)          ; delay slots: R0 = DM(0x20,I4), I0 = I1
8403: R0 = CLIP R0 BY R15       ; R15 loaded by the helper (c019)
8404: DM(I4,M2) = R0
8405: CALL 0x831B (DB)          ; delay slot: MODIFY(I0,−21) — rewind c019→c004
8408: CLIP, 8409: write         ; second channel, same coefficients
```

### 5.1 Helper `0x831B` is the 5-section EQ cascade

Kernel PM `0x831B–0x832B` (quoted from `rec04_kernel_0x486BD9A8.asm`):
`F10 = FLOAT R0` → the same S1 first-order body → `LCNTR = 3, DO 0x8325
UNTIL LCE` → **three biquads** (identical 6-op body, coefficient order
(a1, a2, b1, g, b2)) → S5 first-order folded into the `RTS (DB)` delay
slots → `R0 = FIX F10, R15 = DM(I0,M6)` (the clip bound, c019 =
`0x007FFFFF`). **This corrects `kernel-architecture.md` §7's "FLOAT →
3-tap-interpolation → FIX coefficient generator" label** — the "3" is the
biquad loop count, and the helper is exactly rec23's cascade with the FIX
and clip-bound load built in. rec23 is the inlined/unrolled twin of this
helper (its 6-op biquad bodies are word-identical); boot-init's one-time
`CALL 0x831B` (`0x8D57`) is the cache-warming pass.

### 5.2 The 5 bands

Same mirror-flat template structure as rec23, different pre-placed poles:

| section | template pole(s) | center |
|---|---|---|
| S1 (1st-order) | p = 0.982347 (= rec23 S1) | ~124 Hz (LOW) |
| S2 | a1 = 1.960049, a2 = −0.965033 → r = 0.9824 | **484 Hz** |
| S3 | a1 = 1.911866, a2 = −0.931437 → r = 0.9651 | **969 Hz** |
| S4 | a1 = 1.793320, a2 = −0.868674 → r = 0.9320 | **1940 Hz** |
| S5 (1st-order) | p = 0.546882 | ~4 kHz (HIGH) |

Low shelf + three octave-spaced mids + high shelf = **the GUI's 5-band
EQUALIZER**, with broader mid poles than rec23 (graphic-EQ bands vs
parametric resonances).

### 5.3 State/coefficient budget

16 PM state words (8/channel: 1+2+2+2+1), 22 coefficient cells
(c004–c019), one clip bound. No LFOs, no delay, no SDRAM — consistent with
u8 sharing its arenas and running *after* the BUSLK release
(`kernel-architecture.md` §5/§6).

### 5.4 What rec34's I/O convention says about the "u8 master insert"
question

(Ref: `kn7000_mame/notes/effect-multi-unit-routing.md` 2026-07-12, and
`dsp-effect-catalog.md` §7.5.) The record's structure answers the
feasibility question as far as statics can:

- **Full-replace, no mix**: rec34 has no wet/dry cells, no makeup level, no
  envelope — input → cascade → clip → output, 1:1. Together with the kernel
  fact that u8's *empty-slot* stub is the copy-through `0x80FB` (the only
  slots that default to unity rather than silence are u7/u8), unit 8 is
  built to sit **in-line**: whatever arrives on its RX pair leaves EQ'd on
  its TX pair at unit gain.
- **There is no DSP-side chain**: rec34 reads its own I/O slot
  (`0xC372/3` in, `0xC352/3` out on SPORT1-A), not unit 0's return — units
  cannot see each other's slots. If the shipped KN7000 uses u8 as the master
  EQ, the unit0→unit8→DAC chain must be closed **outside the DSP, by the
  tone generator's TDM routing** (master bus out on u8's pair, return into
  the DAC path). For the MAME bridge this endorses exactly the note's
  proposed model: feed u8's input with the final mix and take u8's return as
  the DAC feed.
- **Flat should be transparent**: the template is mathematically identity
  (§5.2), so inserting a *template* rec34 costs only float rounding + FIX.
  The live measurement of ~15%-of-peak per-sample difference at "flat"
  (2026-07-12 note) therefore implies the **host's real coefficient bank is
  not a mirror bank** even at 0 dB (or the GUI's flat isn't 0 dB
  internally) — worth one live DM dump of u8 c004–c019 to settle
  (**PROVISIONAL**; the conditional-insert guard design in the note stands
  either way).

## 6. The distortion variants — deltas against the documented engines

Byte-diff first (PM words, 8-byte slots): **no two of rec17/18/19/20/37–40
are identical**, but the family structure is tight:

| pair | differing PM words | nature |
|---|---|---|
| rec38 vs rec37 | **2** (`0x8429`, `0x844D`) | output-level immediates only |
| rec40 vs rec39 | **4** (`0x842E`, `0x8430`, `0x8433`, `0x8457`) | levels + Haas length |
| rec18 vs rec39 | 18 (+1 word length) | levels + coefficient-bank layout (§6.3) |
| rec17 vs rec19 | 48 of 73 | same engine, different output stages |
| rec17 vs rec37 | 53 of 73 | rec37 adds the tone biquad + moves the delay |

All six share rec37's engine skeleton (`insert-effects-algorithms.md` §4):
`|(L+R)<<9|` envelope → reciprocal drive gain → signal-indexed interpolated
LUT → per-channel output stage with a Haas offset and a **polarity-inverted
second channel**. Differences that matter:

### 6.1 The AGC: seed-only vs Newton

All of rec17/18/19/37/38/39/40 compute drive = c006 + c007·`RECIPS`(env)
with **no Newton iterations** — the 2106x `RECIPS` seed alone (≈8-bit
accurate; a drive gain doesn't need better). Only the *compressor*
(rec21/25, §2.2) refines to full precision, because there the gain **is**
the output. Constants c006/c007/c008 = 0.111 / 8.35e8 / 0.1 and the
attack/release pair 1/256–1/2048 are shared by the whole distortion family —
except rec19:

- **rec19** (bank 0x41 "Normal / Hard Compress"): release = c005 =
  2²⁴/2³¹ = **1/128** (τ = 2.9 ms — *faster than its 5.8 ms attack*: the
  drive re-opens almost instantly as a note decays = maximum sustain), and
  the below-threshold clamp c009 = **2.0**, not the curve-meeting 4.0 — so
  the drive *steps down* 6 dB when the envelope falls under 0.1: a built-in
  quiet-signal gate that keeps hiss out of the fuzz. The one bank that
  deliberately breaks the continuity construction.

### 6.2 Three transfer curves (all in the host-replaceable c028 window)

| curve | records | positive-half slopes (per 1/16 FS segment) | character |
|---|---|---|---|
| A (knee) | rec17, rec20, rec37, rec38, rec62-65* | 7.5, 1.5, then 0.5 ×14 | compressor-knee, mild odd harmonics |
| B (smooth) | rec18, rec39, rec40 | 8.0, 2.67, 1.67, 1.0, 0.67, 0.33×3, 0.17×2, 0.083×4, 0.17×2 | rounded saturation, tube-ish |
| C (rail) | rec19 | 10.67, 4.33, then ≈0.08×13, dead-flat last | near-hard clipper: fuzz |

(*rec62–65 use the cubic y = x−x³/3 in code, not the LUT — listed for the
knee-shape comparison only.) Curve B is a smooth concave knee (no slope
discontinuities beyond segment 2); curve C slams to 0.94 FS within 1/8 of
input range and rails — the "Hard Compress" GUI names sit on this record.

### 6.3 Group A (no mid-stage): rec17, rec19 — and rec37/38

- **rec17** (0x20, bank 0x40 grp A Normal/Mild/Hard/Hard Compress): AGC →
  LUT → ×0.5 (c00c) → levels **0.222/0.25**; **ch1 delayed 200 samples
  (4.5 ms)** through the I2 ring + inverted; ch0 dry-side undelayed. No tone
  filter at all.
- **rec19** (0x22, bank 0x41): same skeleton, §6.1 AGC bank, curve C;
  levels **0.21/0.198** (= rec37's exactly); **ch0 delayed 400 (9.1 ms)**,
  ch1 inverted, undelayed.
- **rec37** (0x82, grp A "Bright") = rec17's engine + the **unity-DC tone
  biquad** (c00d–c011: poles 0.9535/0.6473, zeros 0.9723/0.4674 → a broad
  **+4 dB presence hump centered ≈1 kHz**, 0 dB at the extremes) + ch0
  delay 400. Already documented; numbers refined here.
- **rec38** (0x83, grp A "Fat") = rec37 with levels **0.36/0.25** (the two
  PM words) and a different c00d–c011 bank: poles r = 0.868 @ **1744 Hz**,
  numerator 0.0177·(1+z⁻¹)² — a **unity-DC resonant lowpass** (−6 dB @3 kHz,
  −16 dB @5 kHz): darker and louder = "Fat".

### 6.4 Group B (smoother + LP biquad): rec18, rec39, rec40

Group B inserts two stages between LUT and output (`0x8420–0x842D`):

1. **A one-pole tone smoother with host-writable coefficients in PM state**:
   `y = k1·x + k2·y[n−1]` where k1/k2 live at PM `0x9801/0x9802` (ch0) and
   `0x9805/0x9806` (ch1) — template **0.10/0.40** (DC gain 1/6, −3 dB ≈
   5.7 kHz), the previous output parked in a DM scratch cell (c00c/c015).
   Like rec12's hold counter, a *parameter hidden in the state block*: the
   presets can re-voice the smoothing without touching the DM bank.
2. **A unity-DC 5-coefficient biquad** (the §4.1 body):
   - **rec18** (0x21, bank 0x40 grp B): double real pole 0.374, numerator
     g(1+z⁻¹)² → gentle lowpass, −3 dB ≈ 4 kHz (cab-sim rounding); **two
     coefficient banks** (c00e–c012 ch0, c016–c01a ch1, templates equal) —
     per-channel tone is possible; levels **0.625/0.5**, ch0 delay 400, ch1
     inverted.
   - **rec39** (0x84, grp B "Bright"): **one shared bank** — the extra PM
     word `0x844F: MODIFY(I0,−8)` rewinds ch1's cursor onto ch0's cells
     (c016–c01a zeroed); poles r = 0.919 @ 1032 Hz over zeros r = 0.931 @
     867 Hz → **+3 dB high shelf from ≈1.5 kHz up**; levels **0.29/0.22**,
     delay 400.
   - **rec40** (0x85, grp B "Fat") = rec39 except levels **0.40/0.31**,
     **delay 200**, and bank: poles r = 0.868 @ 1744 Hz (= rec38's poles)
     over zeros r = 0.797 @ 1241 Hz → **+3.8 dB mid bump at 1.7 kHz**,
     unity at both extremes.

So the six "waveshaper/distortion" mysteries resolve into **two engines ×
three voicing axes** (curve, tone filter, output stage), with the GUI's
bank-0x40 grp A/B and bank-0x41 preset groups mapping 1:1 onto engine A
(rec17/37/38), engine B (rec18/39/40) and the rail-curve variant (rec19).
records.tsv conf → high for all six.

## 7. Comparison — the tone-shaping design language

| | rec20 | rec21/25 | rec22 | rec23 | rec34 | rec17/19 | rec18/39/40 |
|---|---|---|---|---|---|---|---|
| identity | exciter | comp/limiter | slow attack | param EQ | 5-band EQ | AGC waveshaper | + smoother & LP |
| detector | — | peak 1/32–1/2048 | = rec21 | — | — | 1/256–1/2048 | 1/256–1/2048 |
| gain math | — | Newton recip | ±target slew | — | — | RECIPS seed | RECIPS seed |
| nonlinearity | PWL LUT (knee) | — | — | — | — | LUT A/C | LUT B |
| filters | unity-peak BP 3.56k | — | — | 5-sect mirror-flat | 5-sect mirror-flat | (rec37: tone biquad) | smoother + unity-DC biquad |
| dry path | **added** | replace | replace | replace | replace | shaped only | shaped only |
| stereo | dual mono | linked gain ×2 | linked gain ×2 | dual mono | dual mono | Haas 200/400 + invert | Haas 400/200 + invert |
| CLIP | none | ±0x7FFFFF | none | ±0x7FFFFF | c019 bound | none (>>8) | none (>>8) |

Recurring signatures, extending the family lists: the **curve-meets-clamp
reciprocal law** (compressor and distortion AGCs, one construction, two
precisions); **unity-gain-by-construction filters** (the exciter's
unity-peak bandpass; the EQs' mirror-cancelled sections — the strongest form
yet of the "unity-DC everywhere" habit); **parameters as PM-state data**
(rec18's smoother coefficients, after rec12's hold counter and rec10's LFO
increments); the **c028 table window** now confirmed across three distinct
curves and two engines; and the **±target one-pole gain slew** (rec12 gate,
rec22 slow-attack — same four-instruction machine, opposite musical ends).

## 8. What this pass corrects and what remains

Corrected in `records.tsv` (this commit): rec20 "waveshaper + biquad EQ
(enhancer)" → harmonic exciter with unity-peak 3.56 kHz product selector
(conf high); rec21/25 → full gain-law annotation (conf high); rec22 →
two-target slow-attack machine, exact time constants (conf high); rec23 /
rec34 → mirror-flat 5-section cascades with pre-placed bands (conf high);
rec17/18/19/38/39/40 → engine/curve/voicing identities (conf high).
`kernel-architecture.md` §7's `0x831B` description corrected (EQ cascade,
not interpolator); syms rewritten for all ten records + the kernel label.

Still undocumented at full depth: rec11 (0x06/0x0E chorus), rec27
(VIBRATO), rec28/29 (the bank-0x38 wahs — "dynamics + biquad" is now
suspicious given this family's shapes), rec32 (MIXUP), rec33 (SPREADER),
rec49/50 (choruses), rec57 (VOICE CHANGER), rec58–61 (mic reverbs),
rec67–69 (BRASS SIM), rec70/71/72 (combi back-ends), rec75/76
(COMP+DST/OVD+DELAY).

## 9. Cross-model

KN6000/KN6500 DM banks are byte-identical for all 80 records: every constant
above (the gain laws, thresholds, time constants, all three LUT curves, both
EQ template cascades, the biquad voicing banks) carries over. The PM builds
are older: the level immediates (`0x3E570A3D`…), the Haas M7 lengths
(400/200), rec39's bank-sharing rewind and the `0x831B` helper address must
be re-checked against the KN6xxx listings before porting labels.
