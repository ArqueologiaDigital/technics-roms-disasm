# The KN7000 SHARC modulation/pitch cluster — and the GUI group table, fully decoded

Static reverse-engineering (2026-07-19) of the remaining modulation and pitch
records — **rec11**, **rec27**, **rec28/rec29**, **rec32**, **rec33**,
**rec49/rec50**, **rec57** — at the standard of `reverb-algorithm.md` /
`chorus-family-algorithms.md` / `tremolo-rotary-family.md`: everything below is
read off the committed listings in `../disasm/dsp/` with PM addresses quoted,
plus a direct walk of the firmware's GUI tables in `baserom/kn7000_program.rom`.
Execution context = the kernel ABI (`kernel-architecture.md` §7): `I1` params
(`0xC004+slot·0x4D`), `I8` state (`0x9800+slot·0x50`, PM bus), `I4` I/O cursor
(inputs at `+0x20/+0x21`), `I2` internal delay ring scrolling −1/sample (read
at write+D = D samples ago), `M1=+2, M2=+1, M3=−1, M4=−2, M5=0x4D, M6=0` (DM);
`M8=+1, M9=+2, M11=−1, M13=+0x50, M14=0` (PM). fs = 44100 Hz nominal; addresses
record-local (unit-0 form); Q31 = fixed-point /2³¹; ê = envelope/2³¹.

**Headlines.**

1. **The GUI group table is now fully decoded** (§1) — the true entry layout is
   `{u16 count, char name[16], u16 0, u32 preset_list_ptr}`, and walking every
   group's preset list closes name → type → record for the *whole* effect
   inventory with zero ambiguity. This upgrades and in several places
   **corrects** the §1 "descriptor bank" readings of
   `tremolo-rotary-family.md`: the two "bank-0x38 wah" records split into
   **rec28 = AUTO WAH** and **rec29 = PEDAL WAH**; rec47 is the GUI
   **Reverse Wah**; rec50 is the GUI **TRIO CHORUS**; rec11 is the GUI
   **Ensemble**; rec33's Spreader lives in a menu group named **Space**; and
   the distortion family's GUI groups are **Distortion / Overdrive / Fuzz /
   Distorted Amp** (not "bank 0x40/0x41").
2. **The rec28/29 suspicion resolves beautifully** (§4): both are the *same*
   envelope-swept resonator as rec74's touch wah (identical polynomial
   constants), but **rec29's audio detector is dead code** — it computes the
   mono sum and throws it away, tracking a **host-written pedal position**
   instead. One record listens, one record obeys the pedal; the ROM group
   names (Auto Wah / Pedal Wah) say exactly that.
3. **rec49/rec50 introduce a third LFO idiom** (§7): overflow-reflected
   **triangle oscillators** (`IF AV, R3 = −R3` — the increment's sign lives in
   PM state and flips at each rail) plus a **magic-circle sine** — the rotary's
   oscillator — driving three taps per channel: two contrary-motion triangle
   detunes and a fast shallow sine shimmer. rec50 = the GUI **Trio Chorus**,
   named for precisely this trio of taps.
4. **MIXUP is a burst vibrato** (§5): its two tap modulators are Q31
   **products** sin(slow)·sin(fast) with the fast pair in quadrature — a deep
   ~21 Hz pitch wobble whose depth swells and nulls at ~1.3 Hz, 90° apart
   between the channels. **SPREADER is a stereo widener** (§6): scattered
   16-tap micro-FIRs (≤8 samples) decorrelate the channels, a +8 dB 349 Hz
   bell warms them, and two **antiphase unity echoes of the mono sum** (12.3 /
   18.1 ms) do the Haas work.
5. **VOICE CHANGER is a second, independent granular pitch engine** (§8):
   dual wrapped-saw taps with exact **equal-gain triangular crossfade**
   (windows = |phase|, antiphase, sum ≡ 0.5, each window nulling precisely at
   the other tap's wrap) — a stereo ±12.7-cent detune at template, L down /
   R up. It shares only the fractional-tap idiom with rec66's harmonizer
   (reflected ramps, 3 voices, gate/AGC/telemetry — none of which rec57 has).

## 1. The GUI group table — true layout and full decode (ROM fact)

`tremolo-rotary-family.md` §1 decoded the *preset descriptors*; this pass
decodes the *group tables* that index them. Two copies exist (SOUND DSP list
at `0x4870FDF6`-region, REVERB & EFFECT MENU list at `0x48714A56`-region);
each entry is **24 bytes**:

```
u16  count            ; number of presets in this group
char name[16]         ; the on-screen group name, space-padded
u16  0
u32  preset_list_ptr  ; -> array of count u32 pointers, each -> a preset
                      ;    descriptor (pointer lands on its name[16]; the
                      ;    {0, type, nparams, 0, params_ptr, id} tail follows)
```

(The earlier bank-byte readings paired names with the *neighboring* entry's
list — every "descriptor bank 0xNN" attribution below is superseded by this
walk.) The decoded map, with each group's DSP type(s) → record:

| GUI group | presets | type(s) | record |
|---|---|---|---|
| Reverb (Sound-DSP screen) | Medium/Short/Long Gate | 0x08 | rec12 (gate reverb) |
| **Chorus** | Deep/Normal/Shallow 1–13 | 0x01 | **rec06** |
| **Trio Chorus** | Deep/Normal/Shallow 1–8 | 0x53 | **rec50** (§7) |
| **Ensemble** | Deep/Normal/Shallow 1–13 | 0x06 | **rec11** (§2) |
| Ensemble D/W (menu) | Dry/Wet 1–13 | 0x0E | **rec11** |
| Modulated Chorus | Deep/Normal/Shallow 1–13 | 0x02 | rec07 |
| Mod.Chorus D/W (menu) | Dry/Wet 1–13 | 0x07 | rec07 |
| Celeste | Celeste1–13 | 0x2C | rec06 |
| Mod. Celeste | Mod. Cel.1–13 | 0x2D | rec07 |
| Phaser | Deep/Normal/Shallow 1–13 | 0x05 | rec10 |
| Phaser D/W (menu) | Dry/Wet 1–13 | 0x0D | rec10 |
| Flanger | Deep/Normal/Shallow 1–13 | 0x04 | rec09 |
| Flanger D/W (menu) | Dry/Wet 1–13 | 0x0B | rec09 |
| Rotary Speaker | Standard/Single Rotor/Distorted + 4 Twins | 0x35, 0x86–0x88, 0x8A | rec30/41/42/43/45 |
| Rock Rotary | Standard/Single Rotor/Distorted + 3 Twins | 0x0F, 0x80/0x81/0x89 | rec16/35/36/44 |
| Tremolo | Tremolo1–8 | 0x28 | rec24 |
| Auto Pan | Auto Pan1–7 | 0x30 | rec26 |
| **Vibrato** | Vibrato1–8 | 0x32 | **rec27** (§3) |
| Ring Modulator | Ring Mod.1–4 | 0x36 | rec31 |
| **Mixup** | Mixup1–4 | 0x38 | **rec32** (§5) |
| Parametric EQ | Make Up … Too Bright (8) | 0x27 | rec23 |
| Enhancer | Enhancer1–6 | 0x03 | rec08 |
| Exciter | Exciter1–3 | 0x23 | rec20 |
| **Auto Wah** | Wah1–5 | 0x34 | **rec28** (§4) |
| **Pedal Wah** | Wah1–3 | 0x33 | **rec29** (§4) |
| LFO Wah | For 2/3/4Beat 1–2 | 0x91 | rec48 |
| **Reverse Wah** | Wah1–8 | 0x90 | rec47 |
| LFO Filter | For 2/3/4Beat 1–2 | 0x8C | rec46 |
| **Distortion** | Normal/Mild/Hard/Hard Compress + Bright + Fat | 0x20, 0x82, 0x83 | rec17/37/38 |
| **Overdrive** | Normal/Mild/Hard/Hard Compress + Bright + Fat | 0x21, 0x84, 0x85 | rec18/39/40 |
| **Fuzz** | Normal/Hard Compress | 0x22 | rec19 |
| **Distorted Amp** | Loud/Normal/Soft 1–4 | 0x64–0x67 | rec62–65 |
| Limiter | Limiter1–4 | 0x29 | rec25 |
| Compressor | Comp.1–4 | 0x24 | rec21 |
| Slow Attacker | Slow Attacker1–4 | 0x25 | rec22 |
| **Dual Delay** | Deep/Normal/Shallow 1–20 | 0x09 | rec13 |
| Cross Delay | Deep/Normal/Shallow 1–20 | 0x0C | rec15 |
| Multi Tap Delay | Multi1–8 | 0x0A | rec14 |
| Delay Complex | Delay+Chorus/Flanger/Vibrato/Phaser, Autowah+Delay, Comp+Dst/Ovd+Delay | 0x40/0x42/0x43/0x44/0x46/0x50/0x51 | rec70–76 |
| **Vocal Effect** | Voice Changer1/2, Brass simulator1–3, Vocal Harmonizer | 0x78, 0x79–0x7B, 0x7C | **rec57** (§8), rec67–69, rec66 |
| **Space** (menu only) | Spreader | 0x39 | **rec33** (§6) |

Notable identity upgrades beyond this document's records: **rec13 = the GUI
Dual Delay** (not a generic "Delay" group), **rec47 = Reverse Wah** (its
down-sweep law now has its GUI name), **rec62–65 = Distorted Amp**, and the
engine-A/engine-B distortion split of `dynamics-eq-exciter.md` §6 maps 1:1
onto the GUI's **Distortion** (A) and **Overdrive** (B) groups, with the
rail-curve rec19 = **Fuzz** — the GUI taxonomy matches the engine taxonomy the
byte-diff found. On the Sound-DSP screen rec06 serves both **Chorus** (0x01)
and **Celeste** (0x2C); the D/W ("Dry/Wet") menu groups are the same records
under their insert-alias types.

## 2. rec11 — the GUI ENSEMBLE (types 0x06, 0x0E): hexaphase 3-voice chorus

104 PM words (`rec11_effect_0x486BFF35.asm`). One sine LFO of the standard
family shape (`chorus-family-algorithms.md` §1.2; phase c004, increment = PM
state `0x9800`, template `0x800000` = the family's fs/256 placeholder — GUI
rates are host rewrites, as established there). The single state read uses
**M13 = +0x50** (`0x8401`), auto-advancing I8 the whole per-unit stride — the
only record so far with no epilogue `MODIFY(I8)`.

The novelty is the table walk (`0x8409–0x8416`): after interpolating
sine(φ) for **voice 0** (R5), the code does `MODIFY(I5,3)` and re-interpolates
at the same fraction for **voice 1** = sine(φ+3 steps) = **+67.5°** (R6), then
again for **voice 2** = sine(φ+6 steps) = **+135°** (R15) — three modulators
67.5° apart from one phase (the +4-step read of rec06 gave 90°; the guard rows
`c039..c03f` make the +7 reach safe, exactly as designed).

Per channel, the rec06 delay geometry: write at P (stride `M7=0xFA`), read
base P+250 (5.67 ms), three fractional taps at 250 ± 64·mod (depths
c005/c006/c007 = `0x00400000`); right channel writes at P+500, reads at
P+750, and its three depths c00b/c00c/c00d = **`0xFFC00000` = −64** — the
antiphase trick of rec06's R channel done in *data* instead of negated MAC
opcodes. Voice sum = `0.4·(v0+v1+v2)` (c008/c00e = 0x33333333), × wet (c009,
1.0) × 2 makeup, CLIP ±0x7FFFFF (c00a). Footprint: deepest read P+815 < 1024.

So the six taps sit at **0°, 67.5°, 135° (L) and 180°, 247.5°, 315° (R)** —
near-uniform coverage of the whole modulation cycle. At any instant some
voice is at maximum detune while another crosses zero, in both channels, in
opposite senses: the multiphase BBD **ensemble** (string-machine) topology,
which is exactly what the GUI calls it. records.tsv conf → high (identity).

## 3. rec27 — the GUI VIBRATO (type 0x32): modulated delay with no dry, no disguise

68 PM words (`rec27_effect_0x486C2F8C.asm`). Two standard sine LFOs
(increments `0x9800/0x9801`, template `0x00010000` = **1.346 Hz** — a real
vibrato rate, not the placeholder; phases c004 = 0, c005 = `0x20000000` =
**+90°**). **Mono source**: both channels read the *left* input slot
(`DM(0x20,I4)` at `0x841f` *and* `0x8432`). Each channel writes its copy into
the ring (L at P, R at P+500, stride 0xFA) and reads **one** fractional tap at
center 250 samples (5.67 ms), swing ±64 (c006), L modulated by the +90° LFO,
R by the 0° LFO — the rec26 auto-pan channel assignment, applied to FM.

Output = tap × wet (c007, template 1.0), CLIP `0x007FFFFF` (immediate), out.
**No dry term, no makeup, no feedback, one voice**: a modulated delay used
*undiluted*. That is the entire definition of vibrato — chorus is this plus
dry — and with the 90° channel offset the two ears get the same depth with a
quarter-cycle skew (a gentle widening; at template numbers the peak deviation
is 2π·1.346·64/44100 ≈ **1.2 % ≈ 21 cents**). The 2-word state epilogue
(`MODIFY(I8,0x4E)`) and the c029 host-swappable waveform slot are family
standard. conf → high.

## 4. rec28 / rec29 — AUTO WAH and PEDAL WAH (types 0x34 / 0x33)

The pair the manifest carried as "dynamics + biquad (envelope filter), conf
low", flagged suspicious after the dynamics pass. Both are 56/60-word
**mono** programs (both channels read `DM(0x20,I4)`; dual-mono outputs) built
around one swept resonator; the difference is *what does the sweeping*.

### 4.1 The shared resonator and its sweep law

Both records derive, per sample, a 3-coefficient bank from a control value ê
(Q31, floated) via the polynomial block (`0x840e–0x8415` / `0x8412–0x8419` —
float constants stored against the 2³¹-scaled envelope, the rec21 convention):

```
a1 = 1.99594 − 1.28·ê²          (c009/c00b = 0x3FFF7CED = 1.99594, the "resonance" cell)
a2 = −(1 − 0.1·ê + 0.02·ê²)
g  = 0.05·ê − 0.01·ê²
```

written to the DM bank and applied by the kernel-style body
`w = x + a1·w1 + a2·w2; y = 4·g·(w − w2)` (×4 = the `0x40800000` immediate;
zeros at DC and Nyquist — rec74/rec20's resonator form; separate state pairs
per channel, shared coefficients). **These are exactly rec74's touch-wah
constants** (`insert-effects-algorithms.md` §1): rec28 is the standalone build
of the Autowah+Delay's front half. The template sweep:

| ê | center | pole r | 4g (peak ≈ ×4·g-compensated) |
|---|---|---|---|
| 0 | 447 Hz | 1.0000 | 0 (silent) |
| 0.2 | 1.34 kHz | 0.9904 | 0.038 |
| 0.4 | 2.96 kHz | 0.9814 | 0.074 (peak gain ≈ 4.0 = +12 dB) |
| 0.8 (cap) | 6.43 kHz | 0.9658 | 0.134 |

At silence the poles sit *on* the unit circle at 447 Hz with zero input gain —
the filter is parked, armed, and inaudible; as ê rises the resonance climbs
through the spectrum with r backing off and g compensating. (rec74's doc
quotes 8.3 kHz — that is the ê = 1.0 extrapolation; both records' detectors
scale by 0.8, capping ê at 0.8 → 6.4 kHz.) Output × level (c00e/c010,
template 1.0), CLIP ±0x7FFFFF.

### 4.2 rec28 — AUTO WAH: the audio drives it

Detector (`0x8403–0x840d`): `|0.8·(L+R)<<9|` in float, asymmetric one-pole
with **attack c004 = 2⁻⁸ (1/256, τ = 5.8 ms)** and **release c005 = 2⁻¹¹
(1/2048, 46 ms)** — the distortion-family float pair, selected by the
pre-modify `IF LT, R4 = DM(M3,I0)` reload. Envelope in PM state, 5 state
words total (`MODIFY(I8,0x4B)`). Play softly → 450 Hz murmur; dig in → the
resonance sweeps up past 6 kHz: the **up-sweeping touch wah**, complementing
rec47 (= GUI *Reverse* Wah, the down-sweeper — the group names now confirm
both directions).

### 4.3 rec29 — PEDAL WAH: the host drives it, and the detector is a fossil

rec29 = rec28 plus one block — and minus its own premise. The program still
computes `(L+R)<<9` (`0x8403–0x8404`)… **and never uses it**: the "PreFilter"
at `0x8405–0x8408` overwrites R8 with a *fixed-point* one-pole that has
nothing to do with audio —

```
c005' = k0·c004 + k1·c005     k0 = 0x9800 = 0.4789 (Q31), k1 = 0x9801 = 0.4966
```

i.e. c005 slews toward 0.95·**c004, a host-written control cell** (template
`0x3E3851EB` ≈ 0.486 ≈ mid-travel), settling in ~10 samples. *That* value —
not the signal — is floated, ×0.8, and fed to the same attack/release slew
(now = **pedal glide**: 5.8 ms up, 46 ms down) and the same polynomial. The
dead mono sum is a fossil of the rec28 codebase this was forked from, the
same style of evidence as rec24's dead quadrature LFO. 7 state words
(`MODIFY(I8,0x49)`).

So the GUI's three-preset **Pedal Wah** is this record with the panel/pedal
(EXPRESSION pedal via the host) writing c004 in real time — a manual wah
whose DSP-side glide keeps it click-free. Which physical controller feeds
c004 in performance is host-side and not statically pinned (PROVISIONAL);
the c004-driven data flow is opcode fact. records.tsv conf → high, both.

## 5. rec32 — MIXUP (type 0x38): slow-gated fast vibrato (burst FM)

90 PM words (`rec32_effect_0x486C3E35.asm`). **Three** standard sine LFOs:
LFO1 (phase c004, inc `0x9800` = `0x10000` → **1.346 Hz**), LFO2 (c005, inc
`0x9801` = `0x100000` → **21.5 Hz**), LFO3 (c006, inc `0x9802` = 21.5 Hz,
phase template `0x20000000` = **+90°**) — a slow sine and a fast quadrature
pair. The modulators are Q31 **products** (`0x841e`, `0x842d`):

```
modR = sin(θslow)·sin(θfast)        modL = sin(θslow)·sin(θfast+90°)
```

**Mono source** (both channels read `DM(0x20,I4)`), float delay line (input
floated before the write, rec09/rec30 technique): L writes at P, taps at
**250 + 64·modL**; R writes at P+500, taps at **750 + 64·modR** (depth c007 =
`0x00400000`, float-lerp reads with the `FLOAT R3 BY −31` fraction, c008/c00a
= −31). Wet (c009 = 1.0) × 2 makeup, CLIP, out; 3 state words
(`MODIFY(I8,0x4D)`).

What the product does: sin(a)·sin(b) = ½[cos(a−b) − cos(a+b)] — the tap
modulator is a beating pair at 20.2/22.9 Hz whose envelope is |sin(θslow)|.
Perceptually: **bursts of deep, fast vibrato** that swell in and null out
**2.7 times a second**, the L and R wobbles 90° apart so each burst swirls
across the image. At template depth the instantaneous pitch deviation peaks
at 2π·21.5·64/44100 ≈ **±19.6 % ≈ ±3.1 semitones** — a deliberate, seasick
pitch scramble. The GUI name is honest: it mixes your pitch up. The four
presets rewrite the two rates and depth (host, PROVISIONAL values). conf →
high (identity).

## 6. rec33 — SPREADER (type 0x39, menu group "Space"): a three-trick stereo widener

74 PM words (`rec33_effect_0x486C4211.asm`), 2 GUI params. The only effect
whose *FIR kernel lives in PM state*: `0x9800–0x980f` hold **16 float
coefficients** (+0.0363, +0.0054, +0.0555, +0.0290, +0.1221, +0.0387,
+0.0112, +0.0015, −0.0350, −0.0239, −0.0310, +0.0253, +0.0034, +0.0085,
−0.0647, −0.0161 — a scattered, mixed-sign spray, host-rewritable), rewound
mid-frame by `MODIFY(I8,−16)` (`0x841b`) so both channels share them.

**Trick 1 — decorrelation micro-FIRs.** The entry parks the ring cursor at
P+1023 (`MODIFY(I2,0x3FF)`) and walks *down* (M3 reads), interleaving 4 write
heads (in_L at walk offsets 1016 and 991, in_R at 1007 and 999) with 30 reads.
Resolving each read against the nearest write head below it (ring scroll −1
per sample):

```
outL = Σk h[k]·L[n−7+k] (k=0..6) + h[7]·L[n] + Σk h[k]·R[n−8+(k−8)] (k=8..14) + h[15]·R[n]
outR = Σk h[k]·R[n−7+k] (k=0..6) + h[7]·R[n] + Σk h[k]·L[n−7+(k−8)] (k=8..14) + h[15]·L[n]
```

— each output a 16-tap FIR over the last **8 samples (0.18 ms)** of *both*
inputs, with the tap groups channel-swapped between L and R. Same-channel
kernel (h0–h7) all-positive (Σ ≈ +0.30), cross-channel kernel (h8–h15) mostly
negative (Σ ≈ −0.13): the direct sound is replaced by two *differently*
comb-scrambled copies — phase decorrelation above ~3 kHz, where interaural
phase stops being useful and coloration reads as "air".

**Trick 2 — a warmth bell.** Each FIR output runs one float biquad (banks
c006–c00a and c00b–c00f, byte-identical): a1 = 1.89840, a2 = −0.90320
(poles r = 0.9504 at **349 Hz**), numerator 1.0880 − 1.89840z⁻¹ + 0.8153z⁻²
(real zeros 0.981, 0.764): **+8.2 dB at 349 Hz, unity at DC and Nyquist** (to
0.03 dB) — the low-mid body the micro-FIRs' scramble would otherwise thin.

**Trick 3 — antiphase Haas echoes.** The mono average `(L+R)/2` (computed at
`0x8407`, float) is written deep in the walk (offset 190); two pre-modify M7
taps read it back at walk offsets 990 and 734 = **800 and 544 samples ago**,
and the mix (`0x843d–0x843e`) is:

```
outL += mono[n−544]  (12.3 ms)         outR −= mono[n−800]  (18.1 ms)
```

**at unity gain** — the dominant components of the output. Opposite-polarity,
unequal-lag copies of the mono content: the classic Haas widener, the same
family as rec08's 18.1 ms Enhancer offset (same 800-sample constant!), here
doubled and antiphase. Output × level (c010, 1.0), CLIP. 20 state words
(`MODIFY(I8,0x3C)` = 16 FIR + 4 biquad states at `0x9810–0x9813`).

Verdict: not a "FIR convolution + EQ" mystery — a purpose-built **stereo
spreader**: decorrelate, re-warm, Haas-spread. Mono-compatibility is the
cost (antiphase echoes cancel in a mono sum), which is presumably why the
GUI files it under "Space" with two parameters and no siblings.

## 7. rec49 / rec50 — Chorus1–4 (unit 9) and the TRIO CHORUS: the triangle-LFO engine

101/94 PM words (`rec49_effect_0x486C7AF2.asm`, `rec50_effect_0x486C7E4D.asm`)
— one engine, two builds, and a **new modulator idiom** (neither the sine
table nor the rotors):

- **Reflect-triangle oscillators** (3 per record, `0x8401–0x840f` in rec49):
  `phase += inc; IF AV, inc = −inc` — the 32-bit accumulator ping-pongs
  between the rails, the *signed increment lives in PM state*
  (`0x9800/0x9801/0x9802`, template ±`0x12599`) and flips at each overflow.
  Triangle frequency = inc·fs/2³³ = **0.386 Hz**; the raw accumulator is
  scaled by c005 into a 16.16 tap offset. Triangle FM = **constant-slope
  detune**: the tap's pitch offset is a square wave (±4·A·f/fs), not a sine's
  swell-and-stall — the "always moving" chorus character.
- **A magic-circle sine pair** (`0x8410–0x8414`): the rotary's coupled-form
  oscillator (state c008/c009 in the *param* block, ε = `0x9803` =
  `0x2407C1` → **7.717 Hz**), amplitude = the c009 seed.

Template state makes tri2 ≡ tri1 and tri3 ≡ −tri1 (equal |inc|, zero phases,
`0x9802` negative): the **host-written initial phases** (c004/c006/c007) are
what decorrelate the presets — osc2 exists solely to give R its own triangle.

**Taps** (both records, float ring, float lerp): per channel one write
(stride 0xFA; L at P read base 250, R at P+494 read base 744 — center 250),
three fractional taps: L ← {tri1, tri3, sine}, R ← {tri2, −tri1, sine}.

| | rec49 (0x52, **unit 9**, GUI CHORUS-screen Chorus1–4) | rec50 (0x53, insert, GUI **Trio Chorus** Deep/Normal/Shallow 1–8) |
|---|---|---|
| triangle swing (c005 scale) | `0x00800000` → ±128 smp → **±7.8 cents** | `0x00F00000` → ±240 smp → **±14.5 cents** |
| sine tap (c009 seed) | ±2 smp @ 7.72 Hz → 3.8 cents | ±4 smp @ 7.72 Hz → 7.6 cents |
| tap mix | sine/2 + (tri_a+tri_b)/4 | sine + (tri_a+tri_b)/2 |
| makeup | ×2 at the **input** (`R0+R0`, `0x8402/8404`) | ×2 at the **output** (`R8+R8`) |
| input conditioning | 2 first-order float sections per channel | none |
| state words | 9 (`MODIFY(I8,0x47)`) | 5 (`0x4B`) |

rec49's conditioning cascade (`0x8415–0x841e`, banks c00a–c00f / c015–c01a):
section 1 is **mirror-flat** (pole = zero = 0.9311, g = 1 — the rec23 trick:
a host-voicable tone slot shipped as identity), section 2 a fixed shelf
`(1.15364 − 0.34015z⁻¹)/(1 − 0.18654z⁻¹)`: **unity DC, +2.0 dB at Nyquist**
— a slight pre-brightening into the delay line. rec50 drops both.

Identity: two contrary-motion constant-detune voices plus a fast shallow
shimmer voice per channel = a **three-voice chorus**, which the GUI names
outright — *Trio* Chorus — with rec49 the unit-9 (chorus-send) build behind
the CHORUS screen's generic Chorus1–4. Deepest reads: rec49 L 379/R 873;
rec50 L 491 (one word shy of the R write head at 494)/R 985 < 1024. conf →
high, both.

## 8. rec57 — VOICE CHANGER (type 0x78, group Vocal Effect): the dual-saw detune

87 PM words (`rec57_effect_0x486C9A0D.asm`), 4 GUI params. Per channel:

- **Two phase accumulators** in the 31-bit-wrap domain (`FDEP 0:31 (SE)` —
  values live in [−2³⁰, 2³⁰), one cycle = 2³¹): phase A (c004/c008, template
  0) and phase B (c005/c009, template `0x40000000` = **exactly half a
  cycle**), both advanced by the *same* increment — the channel's PM state
  word (`0x9800` = +`0x10000` for L, `0x9801` = −`0x10000` for R).
- **Windows by rectification**: R6 = |phaseA|, R13 = |phaseB| — antiphase
  triangles.
- **Two moving taps**: offset = phase·depth (c006/c00a = `0x00F00000` →
  **±120 samples** about the 250-sample base), 16.16 fractional lerp reads.
- **The crossfade** (`0x8424–0x8425`): `out = tapA·|phaseB| + tapB·|phaseA|`.

The windowing is exact: when a phase wraps (its tap's read address jumps
half the sweep), the *other* phase crosses zero — so **each tap is weighted
precisely zero at the instant it jumps**, and since antiphase triangles sum
to a constant (2³⁰ = 0.5 in Q31), the crossfade is equal-gain with no level
ripple. This is the textbook two-tap rotating-tape pitch shifter, built from
four instructions of window math.

Numbers at template: phase cycle = 2³¹/0x10000 = 32768 samples = **0.743 s**
(two grain hand-offs per cycle); tap slope = inc·depth/2⁴⁷ = 0.7324 % →
**L = −12.7 cents, R = +12.7 cents** (L's delay grows, R's shrinks — a
stereo detune pair). Gain: ×2 in, ×0.5 crossfade sum, × level (c007 = 1.0),
×2 out → net ×2. Presets rewrite the increments/depths (a "voice changer"
preset = a large increment; grain span is fixed at 240 samples). The DM sine
table at c029 is the family template, **unused by this PM** — no LFO here.

**One anomaly, now a cross-build fact**: the right channel's input read is
`DM(0x1F, I4)` (`0x8436`) — not its own R slot (+0x21) but the slot two
below, i.e. the *previous unit's* R input; the left channel reads its own
+0x20. The KN6000's older PM build has the **same 0x1F** (`cross-model/
kn6000/rec57_effect_0x48793BA1.asm` line `8436`), so it is not a KN7000
typo — either a long-carried copy bug (harmless if the neighboring slot
carries the same mic feed) or a deliberate cross-slot mono tap. Which unit
slot the Voice Changer actually runs in decides what audio that is —
host-side routing, not statically pinned (the read offset is fact; its
meaning PROVISIONAL).

**vs rec66 (Vocal Harmonizer)**: different engines, one design language.
rec66 schedules **reflected** (ping-pong) ramp taps — grains that reverse
instead of jumping, three voices at host-set cent-exact slopes, with input
conditioning, an auto-gain, a gate, and host telemetry. rec57 schedules
**wrapped** saw taps — grains that jump under a zero of the window — two
voices, symmetric ±detune, and nothing else. The harmonizer sings chords;
the voice changer transposes the singer. conf → high (identity).

## 9. Comparison

| | rec11 | rec27 | rec28 | rec29 | rec32 | rec33 | rec49/50 | rec57 |
|---|---|---|---|---|---|---|---|---|
| GUI (ROM fact) | Ensemble | Vibrato1–8 | Auto Wah | Pedal Wah | Mixup1–4 | Spreader (Space) | Chorus1–4 / Trio Chorus | Voice Changer1/2 |
| modulator | 1 sine, taps +0/67.5/135° | 2 sines 90° | audio envelope | host cell c004 | sin·sin products | none (static FIR) | 3 reflect-triangles + magic-circle sine | dual wrapped saws |
| template rate | (host) | 1.35 Hz | atk 5.8 ms/rel 46 ms | glide 5.8/46 ms | 1.35 + 21.5 Hz | — | 0.386 Hz + 7.72 Hz | 0.743 s/cycle |
| voices/channel | 3 | 1 | — | — | 1 | 16-tap FIR + 1 echo | 3 | 2 (crossfaded) |
| delay center | 250 smp | 250 | — | — | 250 | 544/800 mono echoes | 250 | 250 |
| swing | ±64 | ±64 | 447 Hz–6.4 kHz | same, by pedal | ±64 (burst) | — | ±128 / ±240 | ±120 |
| stereo strategy | negated depths | 90° LFOs | dual mono | dual mono | quadrature fast pair | swapped FIRs + antiphase echoes | per-channel triangles | L down / R up |
| source | stereo | **mono (in_L)** | **mono** | **mono** | **mono** | stereo + mono echo | stereo | in_L + slot 0x1F |
| dry path | none | **none** | replace | replace | none | replaced by FIR cloud | none | none |
| identity | hexaphase ensemble | true vibrato | touch wah | manual wah | burst vibrato | stereo widener | triangle trio chorus | granular detune |

Design language, extended: **dead code as fork evidence** (rec29's orphaned
detector after rec24's orphaned LFO); **parameters in PM state** (rec49/50's
signed triangle increments and rec33's FIR kernel join rec18's smoother and
rec12's hold counter); **unity-by-construction** (rec49's flat tone slot and
exact-unity-DC shelf; rec57's constant-sum crossfade windows); the **float
ring** for every line that stores conditioned audio (rec32/49/50, after
rec09/30); and mono-sourcing from the L slot across the insert modulators
(rec27/28/29/32) — the TG evidently feeds inserts a mono send.

## 10. Corrections this pass makes

- `records.tsv`: all nine records re-identified (conf high throughout);
  GUI groups restamped from §1 across the manifest — notably rec13 "Delay
  Deep/Normal/Shallow" → **Dual Delay**, rec47 "Wah1–8 bank 0x3A" →
  **Reverse Wah**, rec48 → **LFO Wah**, rec46 → **LFO Filter**, rec62–65
  "Overdrive/Fuzz bank 0x41" → **Distorted Amp**, rec17/37/38 → GUI
  **Distortion**, rec18/39/40 → GUI **Overdrive**, rec19 → GUI **Fuzz**,
  rec12 → the Sound-DSP **Reverb** group (Medium/Short/Long Gate).
- `tremolo-rotary-family.md` §1's "descriptor bank 0xNN" attributions for
  the wah pair ("Wah1–5 / Wah1–3, bank 0x38") — superseded by the group-table
  walk (§1 above): the two groups are **Auto Wah** and **Pedal Wah**.
- `chorus-family-algorithms.md` §7: rec06 additionally serves the Sound-DSP
  **Chorus** group (0x01×39) — the "GM Chorus1/3" CHORUS-screen reading
  stands, but the main Chorus Deep/Normal/Shallow presets are rec06 too.
- `dsp-effect-catalog.md`'s per-type GUI column (kn7000_mame notes): updated
  from the same walk.
- Old sym guesses corrected: rec11's "PM(I8,M13) increment" note (M13 =
  +0x50, explaining the missing epilogue rewind), rec27's generic
  "chorus/flanger" (it is the GUI Vibrato, and mono), rec28/29
  "dynamics + biquad" (envelope wah vs pedal wah; rec29's detector dead),
  rec32's "modulated-delay chorus" (product-modulated burst vibrato),
  rec33's "FIR + biquad EQ" (spreader: decorrelators + bell + antiphase
  Haas), rec49/50 "modulated-delay chorus" (triangle-trio engine; the
  "LFO reflect scale (x2)" comment on c006 was the AV-negate idiom),
  rec57 "pitch-shifter (detune)" (confirmed, now with the full window
  math and the 0x1F cross-slot fact).

## 11. Cross-model note

KN6000/KN6500 DM banks are byte-identical for all 80 records: the wah
polynomial, the triangle increments and scales, the spreader FIR kernel and
biquad, the detune increments/depths and window seeds all carry over. Their
PM is the older build — rec57's `0x1F` read is already verified present
(§8); the other records' delay immediates and the rec49 filter banks should
be re-checked against the KN6xxx listings before porting labels. Their GUI
group tables presumably use the same 24-byte layout; not yet walked.
