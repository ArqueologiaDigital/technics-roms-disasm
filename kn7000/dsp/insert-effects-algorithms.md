# The KN7000 SHARC insert effects — wah / distortion / delay family annotation

Static reverse-engineering of six-plus Multi/Sound-DSP insert microprograms
(2026-07-19), at the standard of `reverb-algorithm.md` /
`chorus-family-algorithms.md`: everything below is read off the committed
listings in `../disasm/dsp/` (PM addresses quoted), with delay lengths,
coefficient roles and topology pinned. Records covered: **rec74** (type 0x46),
**rec46/rec48** (0x8C/0x91), **rec62–65** (0x64–0x67), **rec37** (0x82, with
family notes on rec38–40), **rec13/rec14/rec15** (0x09/0x0A/0x0C). All are on
the units-1–6 (Multi / Sound-DSP insert) whitelist.

**Headline: three of these records are wah pedals, and none of them is what
records.tsv said.** rec74 ("tremolo-rotary") is an **envelope-follower touch
wah** — the polynomial that looked like a computed-LFO sine is a quadratic
map from the input envelope to resonator coefficients. rec46 and rec48
("modulated-allpass phasers") contain no allpass at all: they are **LFO-swept
filters computed by an on-the-fly bilinear transform**, complete with a
3-iteration Newton–Raphson reciprocal *per sample* — rec46 a 10-pole lowpass
sweep, rec48 a single resonant bandpass with Q = 8 (the classic crying-wah
voicing). rec62–65 are four tone-bank presets of a textbook **cubic
soft-clipper** (y = x − x³/3, rails ±2/3); rec37 is a **table-lookup
waveshaper** with a live auto-gain. rec13/14/15 are the **echo family** —
dual-mono, multi-tap, and a cross-feedback ping-pong that matches the GUI
MULTI unit's default "Cross Delay" name.

Sample rate: nominal fs = 44100 Hz (one kernel IRQ0 = one sample frame).
Execution context is the kernel contract of `reverb-algorithm.md` §1
(`I1` = params `0xC004+slot·0x4D`, `I8` = state `0x9800+slot·0x50` on the PM
bus, `I4` I/O cursor with inputs at `+0x20/+0x21`; `M1=+2, M2=+1, M3=−1,
M4=−2, M5=0x4D, M6=0` — M4's value matters below). Delay reads follow the
scrolling-arena rule: a read at (write address + D) returns the value written
D samples earlier. Addresses are record-local (unit-0 form).

## 1. rec74 — touch wah (envelope-swept resonator) + stereo echo (type 0x46)

72 PM words at `0x8400–0x8447` (`rec74_effect_0x486CDA53.asm`). Corrects the
old "modulated-delay / tremolo-rotary (computed LFO)" identification: there
is **no LFO** — the sweep source is the input envelope.

### 1.1 Envelope follower (`0x8401–0x840c`)

`|0.8·((L+R)<<9)|` as float (`0x8404–0x8408`) drives an asymmetric one-pole:
`env += k·(|x| − env)` with **attack k = c004 = 1/256** (τ ≈ 5.8 ms) and
**release k = c005 = 1/2048** (τ ≈ 46 ms), selected by the `IF LT` reload at
`0x840a` (release when |x| < env). State: PM `0x9800` (write `0x840d`).

### 1.2 The quadratic coefficient map (`0x840d–0x8415`)

Three multiplies and two adds turn env into biquad coefficients. With
e = env/2³¹ (0..1) and the constants c006 = 0.05/2³¹, c007 = 0.01/2⁶²,
c008 = 1.28/2⁶², c009 = 1.996, c00a = 1.0:

- `g  = 0.05·e − 0.01·e²` (bandwidth & output gain), stored to scratch c00d;
- `a1 = 1.996 − 1.28·e²` stored to c00b;
- `a2 = 2g − 1` stored to c00c (i.e. pole radius r = √(1−2g)).

Each channel then runs the two-pole two-zero section (L `0x8414–0x841b`,
state PM `0x9801/2`; R `0x842d–0x8435`, state `0x9803/4` — the same scratch
coefficients re-read after `MODIFY(I0,−7)` at `0x842e`):
`w[n] = x + a1·w[n−1] + a2·w[n−2]`, `y = g·(w[n] − w[n−2])` — a **bandpass**
(zeros at DC and Nyquist) whose center rides the envelope:

| envelope e | center f₀ | r | note |
|---|---|---|---|
| 0 (silence) | 443 Hz | 1.000 | undamped but **g = 0 → silent** (elegant quiescence) |
| 0.4 | ≈ 2.6 kHz | 0.992 | |
| 0.8 | ≈ 6.4 kHz | 0.966 | |
| 1.0 | ≈ 8.3 kHz | 0.959 | |

Louder playing sweeps the resonance up — the classic **touch-wah / auto-wah
law**, with the resonator kept stable by the same polynomial that widens its
bandwidth as it rises.

### 1.3 The echo tail (`0x841c–0x8446`)

The wah'd signal feeds a per-channel regenerative delay in the SDRAM `I6`
arena: line input = `4.0·y + 0.6·fb` (immediate 4.0 at `0x841c/0x8437`,
feedback gain **c00e/c012 = 0.6**), L delay = **4000 samples (90.7 ms)**
(`M7=0xFA0`, write `0x8421`, tap `0x8422`), R delay = **5000 samples
(113.4 ms)** (`M7=0x1388` after a `MODIFY(I6, 0x3C64)` channel-arena hop).
The tap is saved to param scratch (`DM(I1−1)`=c003 L, `DM(I1−2)`=c002 R) and
used as next frame's feedback — the same one-frame-late idiom as rec09's
flanger. Output (wet-only): `out = 2.0·y + 0.5·tap` (c00f/c010 = 0.5, wet
c011 = Q31 ≈ 1.0), `FIX`, write. Footprint 2×15,460 words (`0x3C64` = the
insert-slot per-channel arena stride, also in rec13/15).

## 2. rec46 / rec48 — the computed-bilinear swept-filter engine (0x8C, 0x91)

One engine, two voicings; the records labeled "modulated-allpass phaser"
are **swept filters with no allpass**. rec46 = 99 PM words
(`rec46_effect_0x486C7113.asm`), rec48 = 70 (`rec48_effect_0x486C7798.asm`);
`0x8400–0x8434` is near-identical in both.

### 2.1 LFO and control (`0x8401–0x841b`)

The standard family LFO (16-step sine table at c030±8, 31-bit phase wrap,
linear interpolation — `chorus-family-algorithms.md` §1.2), but with the
**phase in param c004 and the increment in PM state `0x9800`** — and unlike
the chorus family the shipped increments are *musical*: rec46 `0x10000` →
**1.35 Hz**, rec48 `0x4000` → **0.34 Hz**. The bipolar sine is folded to
unipolar m ∈ [0,1] (`0x840f–0x8414`), then mapped to the control

- rec46: `g = 0.2·m + 0.0014` (c005, c006), clipped to ≤ 1;
- rec48: `g = 0.5·m + 0.004`.

`g` is exactly the **bilinear-transform frequency variable g = tan(π·f₀/fs)**
(see §2.2), so the LFO sweeps the *tangent domain* linearly:

- rec46: f₀ = 19.6 Hz … **2.79 kHz**;
- rec48: f₀ = 56 Hz … **6.56 kHz**.

### 2.2 Coefficients by construction, not lookup (`0x841c–0x8430`)

Per sample the code builds, from g and g²: `1+g²−q·g`, `1+g²+q·g`,
`2(g²−1)` — where **q = the c00a scale** (1.0 in rec46; **0.125 in rec48**)
— then computes `1/(1+g²+q·g)` with `RECIPS` plus **three Newton–Raphson
iterations** (`0x8427–0x842e`, x' = x·(2−d·x), R11 = 2.0). Substituting
s = (1/g)·(1−z⁻¹)/(1+z⁻¹) into H(s) = N(s)/(s² + q·s + 1) reproduces these
exactly — each stage is the **bilinear transform of a second-order analog
prototype with Q = 1/q**, cutoff swept by the LFO:

`w[n] = [num·x − 2(g²−1)·w1 − (1+g²−q·g)·w2] / (1+g²+q·g)`

- **rec46**: numerator g²·(1+z⁻¹)² (output tap `w + 2w1 + w2`, `0x843a/b`) =
  **lowpass**, Q = 1, and the stage is instantiated **five times**
  (`0x8435/843c/8443/844a/8451`, states c00d–c016) → a **10-pole swept
  lowpass** (~60 dB/oct) with a ~6 dB resonant crest — a deep synth-style
  filter sweep at 1.35 Hz. (The "AllpassStage6" label was a miscount: `0x8458`
  is the output-scale load.) Output ×0.5 (c017), wet c018, mono to both
  channels.
- **rec48**: numerator 0.125·g·(1−z⁻²) (output tap `w − w2`, `0x843a`) =
  **bandpass with Q = 8**, one stage — a narrow +18 dB resonant peak
  sweeping 56 Hz–6.6 kHz at 0.34 Hz: the **wah-wah voicing**. Mono, wet
  ≈ unity.

Both are mono-summed in (`(L+R)/2`, `0x8431–0x8434`) and write the same
sample to L and R. Nothing here can produce a phaser's notch comb — the
numerators are lowpass/bandpass, not allpass. (The remaining true-phaser
candidates in the pool are rec10/rec47/rec73, still undocumented.)

> **Follow-up (2026-07-19, next pass)**: resolved — rec10 and rec73 ARE
> true modulated-allpass phasers (the LFO sweeps the first-order allpass
> *coefficient* directly, no bilinear machinery needed), while rec47 turned
> out to be **another wah on this very engine**: the same coefficient
> construction + `RECIPS`/Newton reciprocal and q = 0.125, but driven by an
> envelope follower and sweeping *downward* (4.27 kHz → 197 Hz with playing
> level) — the pool's fourth wah. See
> [`phaser-enhancer-gate.md`](phaser-enhancer-gate.md).

## 3. rec62–65 — cubic soft-clip overdrive, four tone banks (0x64–0x67)

One byte-identical program (109 PM words, `rec62_effect_0x486CAB5A.asm`),
four DM banks. Signal path per channel (L `0x8412–0x843e`, R mirrored
`0x843f–0x8469`; inputs `<<8`):

1. **DC-block highpass** (c00d–c00f = 0.9858/−0.9929/0.9929): one-pole
   `H(z) = 0.9929(1−z⁻¹)/(1−0.9858z⁻¹)`, ~100 Hz — keeps bias out of the
   clipper. State PM `0x9800`.
2. **Drive**: × c00b·c00c·gain (c00b = 2⁻³¹-scale normalizer, c00c = 10.0)
   — the float signal lands in ±~1 clipper units.
3. **The clipper** (`0x8419–0x8424`): if x ≥ +1 → y = +2/3 (`0x3F2AAAAB`);
   if x ≤ −1 → y = −2/3; else **y = x − x³/3** (c014 = 0.333…) — the
   textbook smooth cubic: slope 1 at 0, slope 0 at ±1, meeting the rails
   exactly (1 − 1/3 = 2/3). Odd symmetry → odd harmonics.
4. **Post filter** (`0x8425–0x8428`): y is rescaled to fixed range (c010 =
   2³¹) and passed through `lp[n] = c013·y + c015·lp[n−1]` (c013 = 0.06,
   c015 = 0.99 → fc ≈ 70 Hz, DC gain 6) with a sign-consistency guard
   (`0x8429–0x842d`: if sign(lp) ≠ sign(y), add y once, then zero if still
   opposed) — a smoothing/integrating stage that rounds the clipped square
   toward a triangle, with the guard keeping its zero crossings locked to
   the clipper's. State in param scratch c016 (`0x842e` via `DM(−3, I0)`).
5. **Tone bank** (the preset voice; injection gain c018, biquad c019–c01d,
   one-pole c01e–c020): `w = c018·lp + c019·w1 + c01a·w2` (poles), output
   `c01c·w + c01b·w1 + c01d·w2` (zeros), then `u = y1 + c01e·u1`,
   `out = c01f·u + c020·u1` (≈ 5 kHz rolloff, zero at Nyquist). **All four
   banks are unity-DC-gain** — the family signature seen in the reverb's
   damping filters:

| rec | type | inject | poles | tone character |
|---|---|---|---|---|
| 62 | 0x64 | 0.05 | r=0.901 @ 2.91 kHz | resonant presence peak ~2.9 kHz |
| 63 | 0x65 | 0.20 | r=0.645 @ 322 Hz | broad low-mid; **complex zeros r=0.901 @ 2.91 kHz = a notch exactly where rec62 peaks** |
| 64 | 0x66 | 0.17 | r=0.858 @ 1.05 kHz | mid honk ~1 kHz, real zeros (mid dip) |
| 65 | 0x67 | 0.10 | r=0.901 @ 2.91 kHz | rec62's poles, softened zeros (0.89/0.11) |

   c00d–c00f, c013–c015, the clipper and the drive chain are identical in
   all four banks — **pure "cabinet" voicings of one overdrive**.
6. Output: `FIX`, × c021 (Q31 ≈ 1.0), `>>8`, write.

### 3.1 The dormant AGC (an honest finding)

`0x8405–0x8411` is an envelope/auto-gain prologue shared with rec37 (§4):
rectified L+R, attack/release MAC, then gain = c008 + c007/env
(0.111 + 8.35e8/env) with a comparison against c009 (0.1 FS) that clamps the
gain to c00a = 4.0 — the constants are chosen so the reciprocal curve meets
the clamp *exactly* at the threshold (0.111 + 8.35e8/2.147e8 = 4.00). But in
this record the wiring is inert: the follower reads its "previous envelope"
from **c004, which nothing ever writes** (the smoother's output goes to c005
via the kernel's `M4 = −2` pre-modify at `0x840b`, and c005 is only read
back as a MAC coefficient). With c004 stuck at its template 0, the clamp
comparison always takes the ≤-threshold branch and **the drive gain is the
constant 4.0**. Either the host live-writes c004 as the GUI drive parameter
(unverified — PROVISIONAL), or the AGC is vestigial here; its *working* form
is rec37, where the same math keeps its envelope in PM state.

## 4. rec37 — table-lookup waveshaper with live AGC + Haas stereo (0x82)

88 PM words (`rec37_effect_0x486C4ECA.asm`); rec38/39/40 (0x83/0x84/0x85)
are structural siblings with their own PM (undocumented in detail — the
family's remaining work).

> **Follow-up (2026-07-19, tone-shaping pass)**: the family detail is done —
> rec38 = rec37 ± 2 level immediates (tone bank → resonant LP 1744 Hz =
> "Fat"); rec39/40 = the *group-B* engine (rec18's: + PM-state tone smoother
> + unity-DC biquad, its own smoother transfer curve) with per-preset
> levels/Haas/voicings; rec17/rec19 = the filterless group-A variants (rec19
> with a near-hard-clip curve, fast release and a deliberate below-threshold
> drive gate). Full delta map:
> [`dynamics-eq-exciter.md`](dynamics-eq-exciter.md) §6 — which also
> documents rec20 (the real EXCITER built on this same LUT engine), the
> rec21/25 compressor, rec22, and the two EQs.

- **AGC, working form** (`0x8405–0x8410`): envelope of |L+R| in PM `0x9800`
  (attack c004 = 1/256, release c005 = 1/2048 — the same constants as
  rec74's follower); gain = c006 + c007/env = 0.111 + 8.35e8/env, clamped
  at c009 = 4.0 below c008 = 0.1 FS. Result: the waveshaper input is held
  near half scale regardless of playing level — **constant distortion
  timbre across velocity**, gain riding −6…+12 dB.
- **Waveshaper** (`0x8415–0x841f`): the drive-scaled sample itself indexes
  the c028–c048 table (`FIX`, `>>27` signed → ±16 with 16-bit fraction,
  `I5 = c038 + idx`, linear interpolation) — the **same table-window
  mechanism the chorus family uses for LFO waveforms, indexed by signal**.
  The baked curve is a 33-point odd-symmetric piecewise-linear knee:
  slope 7.5 for |x| < 1/16, 1.5 to 1/8, then 0.5 out to ±1.0 —
  a hard-knee compressor/limiter curve (soft distortion). Being a table, the
  transfer curve is **host-replaceable without reloading the effect**.
- **Tone biquad** (`0x8422–0x8428`, c00d–c011): unity-DC again — poles
  0.954/0.647, zeros 0.972/0.467 (input ×0.5, c00c) — a gentle mid tilt.
- **Stereo trick**: L output is the channel's own processed signal delayed
  **400 samples (9.1 ms)** through the internal `I2` ring (`0x842b–0x842e`,
  write+tap+rewind −400); R is undelayed, **polarity-inverted**
  (`0x8451`), at a slightly different level (L 0.21 `0x3E570A3D`, R 0.198
  `0x3E4AC083`) — a Haas-effect widener baked into a distortion.

## 5. rec13 / rec14 / rec15 — the echo family (0x09, 0x0A, 0x0C)

Three small programs (63/72/64 PM words) around one kit: SDRAM `I6` delay
lines with the `0x3C64` channel stride, a **unity-DC damping filter** in the
regeneration path, and a **parameter smoother** for click-free levels.

Shared pieces:

- **Damping** (rec13/15 c004–c006 = 0.749/−0.313/0.564): `u = fb + 0.749·u1`,
  `y = 0.564·u − 0.313·u1` → H(z) = (0.564−0.313z⁻¹)/(1−0.749z⁻¹): DC gain
  1.000, Nyquist 0.50 — each repeat gets darker, tape-style, without losing
  level. rec14's variant (0.7446/−0.4937) damps less (0.71 @ Nyquist).
  State PM `0x9800+`.
- **Level smoother** (the `CrossMixTaps`-labeled epilogue, e.g. rec13
  `0x8437–0x843b`): `actual = 0.004·target + 0.996·actual` (coefficients in
  the *state* block, `0x9802/3`) — the output level glides with τ ≈ 5.7 ms.
  Since the smoothed cell's template is 0 and the target's is 1.0, a freshly
  loaded echo **fades in** over ~30 ms instead of clicking.
- Output: `tap × level × wet ×2` (makeup), `CLIP ±0x7FFFFF`.

The three topologies:

- **rec13 (0x09) — stereo echo, dual mono**: L = 8000 samples (**181.4 ms**),
  R = 10000 (**226.8 ms**) — a 4:5 polyrhythmic bounce; feedback 0.6 (c007/
  c009) each channel from its own tap (states c003/c002), through the damp.
- **rec14 (0x0A) — panning multi-tap echo**: mono sum into one line, **four
  taps at 5997/11995/17992/23990 samples = 136/272/408/544 ms** (equal
  ~136 ms spacing — a rhythmic 4-repeat). Three gain banks: c008–c00b
  (0.25×4) mix the taps into the **regeneration** signal (fed back through
  the damp at gain c007 — template 0, i.e. regen off until the host writes
  the feedback parameter); the **output banks pan the repeats across the
  stereo field**: one channel's tap gains ascend (c00c–c00f = 0, 0.30,
  0.60, 0.90) while the other's descend (c011–c014 = 0.90, 0.60, 0.30, 0)
  — each successive repeat walks from one side to the other. Master level
  = c015 (1.0) through the smoother state c016.
- **rec15 (0x0C) — cross-feedback ping-pong**: L = 4000 (**90.7 ms**),
  R = 4400 (**99.8 ms**), feedback 0.6 — but the feedback sources are
  **swapped**: L regenerates from R's tap (`DM(I1−2)`) and R from L's
  (`DM(I1−1)`), so each repeat crosses the stereo field. This matches the
  GUI MULTI unit's default type name "Cross Delay"
  (`kn7000_mame/notes/effect-multi-unit-routing.md`) — PROVISIONAL as a
  name, structural as a fact.

## 6. Comparison — the insert design language

| | rec74 | rec46 | rec48 | rec62–65 | rec37 | rec13/14/15 |
|---|---|---|---|---|---|---|
| identity | touch wah + echo | 10-pole LP sweep | Q=8 wah | cubic overdrive | table waveshaper | echo family |
| sweep source | input envelope | 1.35 Hz sine | 0.34 Hz sine | — | — | — |
| nonlinearity | — | — | — | x − x³/3, ±2/3 | 33-pt PWL knee | — |
| filter math | quadratic env→coeff map | bilinear + Newton recip | same, q=0.125 | unity-DC tone banks | unity-DC biquad | unity-DC damp |
| delay | 4000/5000 SDRAM | — | — | — | 400 internal (Haas) | 8000/10000 · 4×5997 · 4000/4400 |
| feedback | 0.6/channel | — | — | — | — | 0.6 (13/15: damped; 15: crossed) |
| stereo | per-channel wah+echo | mono | mono | dual mono | Haas + invert | dual / mono-in / ping-pong |
| dry path | wet-only | wet-only | wet-only | shaped only | shaped only | wet-only |

Recurring signatures worth naming: **unity-DC-gain filters everywhere**
(damping, tone banks, DC-block — level never drifts with a parameter edit);
the **1/256–1/2048 attack/release pair** (rec74, rec62, rec37); **parameter
smoothing and fade-in by one-pole** (echo family); **per-sample coefficient
computation** rather than host-side tables (rec74's quadratic map, rec46/48's
full bilinear transform with Newton reciprocal — the CPU only ever writes
*musical* parameters, the DSP does the DSP math); and the **c028 table
window** doing double duty as LFO waveform (choruses) and transfer curve
(rec37).

## 7. What this pass corrects and what remains

Corrected in `records.tsv` (this commit): rec74 tremolo-rotary → touch wah;
rec46/rec48 modulated-allpass phaser → swept LP / swept BP wah; rec13/14/15
"comb+allpass reverb / delay" → the specific echo topologies; rec62–65 and
rec37 identities sharpened with preset voicings.

**No rotary speaker has been found in the pool so far.** The remaining
candidates are the tremolo-pan LFO records (rec24/26/31) and the larger
undocumented modulation composites (rec66, rec30-family, rec71–73);
a rotary would need a crossover + two rates + Doppler-ish modulated delay —
rec66 ("multi-stage chorus/pitch-shift", 1207 bytes, the pool's biggest
insert) is the best structural candidate. Still undocumented after this
pass: rec08/12/16–33 (dynamics, EQs, tremolo-pans, choruses), rec38–40
detail, rec47/57/66–69/70–73/75/76, and the unit-7/unit-0 open questions of
`reverb-algorithm.md` §7. GUI names per type remain PROVISIONAL throughout
(the `DspEffectSelect` breakpoint experiment is unchanged).

> **SUPERSEDED (2026-07-19, next pass)**: the rotary speaker **was found** —
> it is the rec30 PM-family (rec30/35/36/41–45) plus rec16, previously
> filed as "modulated-delay chorus, conf low": crossover + dual
> magic-circle rotors with rate glide + Doppler taps. Neither structural
> candidate above was it (rec24/26/31 = tremolo / auto-pan / ring
> modulator; rec66 = the vocal harmonizer). And the GUI names are no
> longer provisional: the firmware's preset-descriptor table (600 entries)
> pins GUI name → type for every effect. See
> [`tremolo-rotary-family.md`](tremolo-rotary-family.md) — including
> §1's table, which upgrades this document's own naming: "Cross Delay"
> (rec15) and "Autowah+Delay" (rec74) are ROM fact now.

## 8. Cross-model

KN6000/KN6500 DM banks are byte-identical for all 80 records: every constant
above (envelope pairs, 0.6 feedbacks, tone banks, tap gains, the PWL curve)
carries over; their older PM builds must be re-checked for the delay
immediates (0xFA0/0x1388/0x1F40/0x2710/0x176D…/0xFA0/0x1130/0x190) before
porting labels.
