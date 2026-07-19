# The KN7000 SHARC tremolo/pan family — and the rotary speaker, found

Static reverse-engineering (2026-07-19) of the amplitude-modulation records
**rec24 / rec26 / rec31**, the **rec30 PM-family (rec30 = 35 = 36 = 41–45)**,
**rec16**, and a structural pass over **rec66** — at the standard of
`reverb-algorithm.md` / `chorus-family-algorithms.md` /
`insert-effects-algorithms.md`: everything below is read off the committed
listings in `../disasm/dsp/` with PM addresses quoted. Execution context is
the kernel ABI of `reverb-algorithm.md` §1 / `kernel-architecture.md` §7.
fs = 44100 Hz nominal; addresses are record-local (unit-0 form).

**Two headlines.**

1. **The GUI ROTARY SPEAKER is real, and it was hiding in plain sight**: the
   eight-preset identical-PM family the manifest called "modulated-delay
   chorus (conf low)" — rec30/35/36/41–45 — plus rec16, is a **full Leslie
   simulator**: drive → saturation table → crossover → two independent
   rotor oscillators **with spin-up/down inertia** → Doppler-modulated
   delay taps (a quadrature stereo pair for the horn, an antiphase tap for
   the drum). Every signature the earlier passes looked for is present.
   `insert-effects-algorithms.md` §7's "no rotary speaker found" verdict is
   hereby corrected; neither of its structural candidates (the tremolo-pans,
   rec66) was it.
2. **The firmware contains a complete GUI-name → effect-type table**, and it
   is now decoded (§1): 600 preset descriptors in program flash pin the GUI
   name, DSP type number, and edit-parameter defaults for *every* effect on
   the four effect screens. This turns most of the tree's PROVISIONAL
   GUI-name readings into ROM fact — including Rotary Speaker → rec30-family,
   Tremolo → rec24, Auto Pan → rec26, Ring Modulator → rec31, and
   Vocal Harmonizer → rec66.

## 1. The preset-descriptor table (ROM fact, new)

The GUI effect screens are driven by a pool of ~600 preset descriptors in
program flash (region ≈ CPU `0x4858FB8C..0x48597200`, first entry = Reverb
"Room1"). Each descriptor is:

```
u16 params[n]     ; edit-screen defaults (0..127 GUI units)
char name[16]     ; the on-screen preset name, space-padded
u16 0             ; terminator
u16 type          ; the DspEffectSelect TYPE = index into the 0x487B7248 record map
u16 nparams       ; edit-parameter count (6..20)
u16 0
u32 ptr           ; -> params[] above
u32 id            ; preset id: low byte = bank, byte1 = program
```

Group tables (two copies: the SOUND DSP list at ≈`0x4870FE00`, the
REVERB & EFFECT MENU list at ≈`0x48714B00`) hold
`{u32 preset_list_ptr, u16 count, char name[16]}` per GUI group — e.g.
`" Rotary Speaker "` → list `0x4870F928`, count **7**; `"  Rock Rotary   "` →
`0x4870F9C4`, count **6**. Because the type field indexes the confirmed
type→record map (`dsp-effect-catalog.md` §4), this closes the loop
**GUI name → type → record** statically. Key results for this document:

| GUI group (screen) | presets | type(s) | record(s) |
|---|---|---|---|
| **Tremolo** (Sound DSP) | Tremolo1–8 | 0x28 | **rec24** |
| **Auto Pan** (Sound DSP) | Auto Pan1–7 | 0x30 | **rec26** |
| **Ring Modulator** (Sound DSP) | Ring Mod.1–4 | 0x36 | **rec31** |
| **Rotary Speaker** (Sound DSP) | Standard / Single Rotor / Distorted | 0x35 | **rec30** |
| | Bright Twin | 0x86 | **rec41** |
| | Normal Twin | 0x8A | **rec45** |
| | Mellow Twin | 0x87 | **rec42** |
| | Brilliant Twin | 0x88 | **rec43** |
| **Rock Rotary** (Sound DSP) | Standard / Single Rotor / Distorted | 0x0F | **rec16** |
| | Bright Twin | 0x80 | **rec35** |
| | Mellow Twin | 0x81 | **rec36** |
| | Brilliant Twin | 0x89 | **rec44** |
| Vibrato (Sound DSP) | Vibrato1–8 | 0x32 | rec27 |
| Mixup (Sound DSP) | Mixup1–4 | 0x38 | rec32 |
| Mic effects | **Vocal Harmonizer** | 0x7C | **rec66** |

(Sound-DSP groups are Rotary Speaker = the 7-preset list, Rock Rotary = the
6-preset list — count-matched against the GUI capture in
`effect-selection-recipes.json`; the DIGITAL DRAWBAR page's FAST/SLOW
TREMOLO button drives exactly these two groups, Jazz = Rotary Speaker,
Rock = Rock Rotary, per the service-manual GUI inventory.)

The wider sweep of the table (reverb preset names Room/Plate/Concert/…
→ rec51–56 presets; **GUI "Enhancer1–6" = type 0x03 = rec08**, resolving
the old unit-0 tension; Exciter1–3 = rec20; Comp.1–4 = rec21 vs
Limiter1–4 = rec25; Delay+Chorus/Flanger/Vibrato/Phaser = rec70–73;
Autowah+Delay = rec74 — confirming the touch-wah reading; Voice Changer =
rec57; Brass simulator1–3 = rec67–69; mic Room/Karaoke/Stage/Cave =
rec58–61; Spreader = rec33) is recorded in `records.tsv` per row and in
`../../kn7000_mame/notes/dsp-effect-catalog.md`.

> **UPGRADE (2026-07-19, group-table walk)**: the *group* tables' true entry
> layout is `{u16 count, char name[16], u16 0, u32 preset_list_ptr}` (24
> bytes) — the earlier bank-byte pairings put some names against the
> *neighboring* entry's list. The corrected full walk is in
> `modulation-pitch-family.md` §1; notable fixes: the two "bank-0x38 wah"
> records are **rec28 = Auto Wah (Wah1–5)** and **rec29 = Pedal Wah
> (Wah1–3)**; rec47 = **Reverse Wah**; rec50 = **Trio Chorus**; rec11 =
> **Ensemble**; rec33's Spreader sits in the menu group **Space**; the
> distortion GUI groups are **Distortion/Overdrive/Fuzz/Distorted Amp**.

Since **multiple GUI presets share one record and one DM bank** (e.g. all
eight Tremolos are rec24), preset character differences within a group are
host-written parameter updates over the template — the descriptor's
`params[]` are the GUI-unit defaults the host translates into DM/state
writes. The template values quoted below are therefore the *download*
state; per-preset live values differ (PROVISIONAL where it matters).

## 2. rec24 — Tremolo (type 0x28) and rec26 — Auto Pan (type 0x30)

Two builds of one small program (54 vs 53 PM words,
`rec24_effect_0x486C2775.asm` / `rec26_effect_0x486C2C89.asm`); byte-diff
shows **rec24 = rec26 plus one inserted instruction**, and that one word is
the whole difference between a tremolo and a panner.

**Engine (both)**: two LFOs of the standard family shape
(`chorus-family-algorithms.md` §1.2 — 31-bit phase wrap, 16-step
interpolated sine at `c029..c03f`, increments in state `0x9800/0x9801`,
phases in params `c004/c005`). Phase templates: `c004 = 0`,
**`c005 = 0x20000000` = +90°** — LFO B runs a quarter-cycle ahead of LFO A.
Per channel the gain is an offset sine:

```
gain = bias + trim·sin       bias = state 0x9802/3 = 0x66666666 = 0.8
out  = in · gain · level     trim = c006/c008 = 0x19999999 = 0.2
                             level = c007 = 1.0
```

so the template gain swings **0.6..1.0** (≈4.4 dB of AM), `CLIP ±0x7FFFFF`,
per channel. No delay line, no feedback — pure amplitude modulation.

- **rec26 (Auto Pan)**: L is modulated by **LFO B** (the +90° phase, used
  directly at `0x8420`), R by **LFO A** (`R8 = R5` at `0x8429`) — the two
  channel gains sit in quadrature and the image slews around at the LFO
  rate. Template rate `0x00010000` → **1.346 Hz**.
- **rec24 (Tremolo)**: the inserted `R8 = R5` at `0x841F` replaces the L
  channel's modulator with LFO A too — **both channels pump in phase**:
  amp-style tremolo. Template rate `0x00080000` → **10.77 Hz**. The +90°
  LFO B is still computed and its phase still advances every sample
  (`0x8410–0x841D`) but its value is clobbered before use — **dead code**,
  the vestige of the pan build it was forked from.

Both keep 4 state reads (`MODIFY(I8,0x4C)` rewind). Per-preset GUI rates
(Tremolo1–8, Auto Pan1–7) are host rewrites of the state increments
(PROVISIONAL as exact values; the sharing of one record per group is fact).

## 3. rec31 — Ring Modulator (type 0x36)

45 PM words (`rec31_effect_0x486C3B6C.asm`). Same two-LFO front end (same
90° template offset, `c005 = 0x20000000`), but the output stage has **no
bias term at all** (the DM bank holds only `c006 = level = 1.0`): the full
**bipolar** sine multiplies the signal —

```
L = in_L · sin(θ+90°) · level      R = in_R · sin(θ) · level
```

Gain sweeps through zero and inverts polarity: textbook **ring modulation**
(output = sum and difference frequencies, carrier suppressed). And here the
template increment — `0x01000000` → **344.5 Hz** — is *not* a placeholder:
it is an audio-rate carrier, exactly what a ring modulator wants, and the
descriptor table confirms the GUI name **Ring Mod.1–4**. The 90°
inter-channel carrier makes the sidebands' stereo image rotate at the
carrier rate (per-channel powers sum to `in²` — cos²+sin² — so the total
never pumps). 2 state reads (`MODIFY(I8,0x4E)`).

The tremolo-pan trio is thus one hardware idea — offset-sine AM — voiced
three ways: in-phase (tremolo), quadrature (pan), bipolar-at-audio-rate
(ring mod). None of them is a rotary speaker.

## 4. The rotary speaker — rec30/35/36/41–45 + rec16 (types 0x35, 0x80–0x8A ex 0x82–0x85, 0x0F)

74 PM words (`rec30_effect_0x486C37C3.asm`), byte-identical across the
eight family records; **rec16** (72 words, `rec16_effect_0x486C0E96.asm`)
is the same program built with `ASHIFT −8` instead of `LSHIFT −8` + `NOP`
in the two output scalings — bit-identical in the low 24 bits that reach
the output bus, i.e. a cleaner rebuild of the same algorithm. This is the
only insert family that calls **both** kernel helpers (`0x8300`, `0x830B`),
and decoding those calls is what cracked it.

### 4.1 Signal path overview

```
in L+R ──(L+R)/2──►  ×drive ──► PWL saturation table ──► 1.57 kHz smoother
                     (c004)      (c028..c048, signal-       (0.2/0.8 one-pole,
                                  indexed, ±1.0 rails)       state c007)
   ──► ×3 (c008) ──► CROSSOVER (helper 0x8300, float, parallel):
         ├── drum band: 2-pole resonator f0=500 Hz r=0.931, unity DC → F6
         └── horn band: 2-pole bandpass  f0=1985 Hz r=0.965 (preset-voiced) → F10
   ROTORS (helper 0x830B): two magic-circle sin/cos oscillators with rate glide
         rotor1 (drum) 5.512 Hz ─ sin → R13     rotor2 (horn) 6.431 Hz ─ sin,cos → R8,R5
   DOPPLER (internal I2 ring):
         horn → write @P, taps @P+320±29·sin / ±29·cos   (two mics, 90° apart)
         drum → write @P+520, tap @P+680 (160±40·sin)     (one mic)
   OUT:  L = 0.6·(hornBP + hornTap_sin) + 0.243·(drumLP + drumTap)
         R = 0.6·(hornBP + hornTap_cos) + 0.243·(drumLP − drumTap)
```

### 4.2 Drive and the saturation table (`0x8400–0x8411`)

Mono sum `(L+R)/2` → float → × drive **c004** (0.1 in rec30/42/45; **1.0**
in rec16/35/36/41/43/44 — the hot presets) → `FIX`, `LSHIFT 9`, and the
standard table-index idiom (`ASHIFT −11/−16` + `FDEP 15:16` frac) — but
indexing the **c038-centred window `c028..c048`** with the *signal*, the
same signal-indexed-table trick as rec37's waveshaper. The table (float
entries, ±2³¹ scale) is an odd-symmetric compressive curve: ±0.5 at index
±1, ±0.667 at ±2, ±0.833 at ±4, ±0.9375 at ±8, rails ±1.0 at ±16 — initial
gain ≈8× (linearised), soft-knee to hard rails: an amp-overdrive front end,
linearly interpolated. At drive 0.1 a full-scale input reaches only ±3.2
index (the gentle knee); at drive 1.0 inputs beyond ~half scale run off the
table end (`LSHIFT 9` also wraps above half scale) — the hot presets rely
on realistic send levels, and "Distorted" presets are host-written drives
on top (PROVISIONAL which GUI param lands in c004).

The shaped sample then passes a **one-pole smoother**
`y = 0.2·x + 0.8·y[n−1]` (state coeffs `0x9800/0x9801`, previous value in
`c007`, `0x8412–0x8417`) — unity DC, −3 dB ≈ **1.57 kHz**: rounds off the
shaper edges before the crossover.

### 4.3 The crossover — helper `0x8300` decoded

`CALL 0x8300` (`0x8416`) enters with F8 = smoothed signal, F3 = **3.0**
(c008; 0.5 in the drive-1.0 presets — drive and makeup co-tuned). The
helper (kernel PM `0x8300–0x830A`) runs **two parallel float 2-pole
sections** on `x' = makeup·x`, streaming coefficients from `c009..c00e`
and keeping four state words in PM `0x9802–0x9805`:

- **Drum band** (`c009–c00b` = 1.857603 / −0.867075 / 0.0094716):
  `w1[n] = x' + a1·w1[n−1] + a2·w1[n−2]`, output **F6 = b·w1[n−1]** — an
  all-pole resonator, poles r = 0.9312 at **500.5 Hz**, DC gain exactly
  1.000: the bass path, flat to DC with a presence bump at 500 Hz.
- **Horn band** (`c00c–c00e`, preset-voiced, §4.6): same recursion,
  output **F10 = b'·(w2[n] − w2[n−2])** — zeros at DC *and* Nyquist: a
  **bandpass**. Standard voicing 1985 Hz, r = 0.9655.

A textbook two-way tone split — the Leslie crossover (real Leslies cross
at ≈800 Hz; this one overlaps a resonant low band with a 2 kHz bandpass).

### 4.4 The rotors — helper `0x830B` decoded (state `0x9806–0x980B`)

`CALL 0x830B` (`0x8419`). The record's 12-word state block ends in two
triplets the old sym read as "{inc, inc, phase}". The helper's actual use,
per triplet {**target**, **current**, **−1.0**}:

1. **Inertia**: `current += 2⁻¹²·(target − current)` — computed as
   `current' = k1·target + k2·current` with `c010/c011` (= `c014/c015`) =
   {0x00080000, 0x7FF80000}, k1+k2 = 1 exactly. The host writes only the
   *target* rate; the running rate **glides** with τ = **93 ms** (95 % in
   ≈0.28 s). This is the rotary's spin-up/spin-down — the DIGITAL DRAWBAR
   FAST/SLOW switch and the GUI slow/fast select never step the rate, they
   re-aim it. (A real Leslie takes seconds; if the GUI ramps the target on
   top of this DSP glide it is host-side — unverified, PROVISIONAL.)
2. **Oscillator**: with ε = current (Q31, rad/sample) and the constant
   −1.0 (`0x9808/0x980B`) used as a negator, the helper advances a
   **magic-circle (coupled-form) sine/cosine pair** held in the *param*
   block: `sin' = sin + ε·cos; cos' = cos − ε·sin'` — rotor 1 in
   `c012/c013`, rotor 2 in `c016/c017`, amplitude = template 0.95.

Template rates: rotor 1 (drum) inc `0x19BC65` → ε = 7.854e−4 →
**5.512 Hz = 331 RPM**; rotor 2 (horn) inc `0x1E0676` → **6.431 Hz =
386 RPM**. The ratio is **exactly 7:6**, horn faster than drum — these are
the *fast* (tremolo) speeds of a Leslie (horn ≈ 400 RPM, drum ≈ 340 RPM on
a 122). The slow (chorale) targets are host writes (PROVISIONAL values).
Returns: R13 = sin(rotor 1), R8/R5 = sin/cos(rotor 2), consuming 6 state
words (total 12 with §4.2's — `MODIFY(I8,0x44)` ✓).

### 4.5 Doppler taps and the stereo matrix (`0x841A–0x8446`)

All delay is the kernel's internal DM ring (I2, 1024-word slot grant,
scrolls −1/sample; float bit patterns stored, float lerp reads — the rec09
technique). Tap offsets are 16.16 products `modulator × depth`:

- **Horn** (`0x841C–0x842D`): F10 written at P (advance +0x140);
  **two taps** at `P+320 + 29·sin(rotor2)` and `P+320 + 29·cos(rotor2)`
  (depth c00f = `0x001D0000` = 29.0) — the horn heard by **two virtual
  microphones 90° apart around the rotation**, one per output channel.
  Center delay 7.26 ms, swing ±0.63 ms (±27.6 samples at the 0.95
  oscillator amplitude) → peak Doppler **±2.5 % ≈ ±43 cents** at the fast
  rate.
- **Drum** (`0x842E–0x8436`): F6 written at P+520 (advance +0xA0), **one
  tap** at `P+680 + 40·sin(rotor1)` (depth c01a = `0x00280000` = 40.0) =
  delay 160±38 samples → **±3.0 % ≈ ±51 cents** at fast.
- **Mix** (`0x8437–0x843D`, gains c01c = horn = 0.60, c01d = drum = 0.243):

  `L = 0.6·hornBP + 0.243·drumLP + 0.6·hornTap_sin + 0.243·drumTap`
  `R = 0.6·hornBP + 0.243·drumLP + 0.6·hornTap_cos − 0.243·drumTap`

  Direct band signal and its moving tap at **equal gain**: as the tap
  sweeps, direct+delayed interference comb-sweeps each band — that is
  where the amplitude throb comes from (no explicit AM multiplier). The
  drum tap is **antiphase** between channels; the horn pair is quadrature.
  × level (c01e = 1.0), scale to 24-bit (`LSHIFT/ASHIFT −8`), out. No dry
  path — like every insert, the record *is* the signal.

Deepest read P+720 → fits the 1024-word grant; the two write heads and all
five reads are collision-free by layout (horn reads ≤ P+349 < 520; drum
reads ≥ P+640).

### 4.6 The presets (DM diffs — everything else is byte-identical)

| rec | GUI preset | drive c004 | makeup c008 | horn BP (c00c–e) | horn lvl c01c | drum lvl c01d |
|---|---|---|---|---|---|---|
| 30 | RS Standard / Single Rotor / Distorted | 0.1 | 3.0 | 1985 Hz r=.965 | 0.60 | 0.243 |
| 45 | RS Normal Twin | 0.1 | 3.0 | 1985 Hz | 0.60 | 0.485 |
| 42 | RS Mellow Twin | 0.1 | 3.0 | 1985 Hz | **0.30** | **1.0** |
| 41 | RS Bright Twin | **1.0** | 0.5 | **2979 Hz** r=.949 | 0.60 | 0.30 |
| 43 | RS Brilliant Twin | **1.0** | 0.5 | **3975 Hz** r=.935 | 0.60 | 0.30 |
| 16 | RR Standard / Single Rotor / Distorted | **1.0** | 0.5 | **2369 Hz** r=.946 | **0.125** | 0.245 |
| 35 | RR Bright Twin | **1.0** | 0.5 | 2369 Hz | 0.60 | 0.492 |
| 36 | RR Mellow Twin | **1.0** | 0.5 | 2369 Hz | 0.60 | 0.30 |
| 44 | RR Brilliant Twin | **1.0** | 0.5 | **4888 Hz** r=.848 | 0.60 | 0.26 |

Rotor rates, depths, glide constant, drum resonator and the saturation
curve are identical in all nine records. "Rock" = drive 1.0 everywhere +
brighter horn; the three same-type presets per group (Standard / Single
Rotor / Distorted) differ only in host-written parameters ("Single Rotor"
plausibly zeroes one rotor's depth — its descriptor defaults duplicate the
two rotor param pairs; PROVISIONAL).

### 4.7 Verdict

**The KN7000's GUI ROTARY SPEAKER is a genuine rotary-speaker simulation,
not a renamed tremolo-pan** — dual rotors at distinct rates (7:6), rate
inertia, a spectral crossover, per-band Doppler FM via modulated fractional
delays, interference AM, quadrature horn mics and an antiphase drum mic,
with an overdrive front end. The record map (fact) plus this annotation
(read off the opcodes) settles the question the insert pass left open.

## 5. rec66 — Vocal Harmonizer (type 0x7C), structural annotation

141 PM words (`rec66_effect_0x486CBCA6.asm`) — the pool's biggest insert,
now GUI-named **Vocal Harmonizer** (mic section) by the descriptor table.
Confirmed structure (full constant-level annotation remains open):

- **Mono in, mono out** (input `<<10`; the same sample is written to both
  outputs) — a microphone path.
- **Conditioning**: input biquad (`c005–c007`), rectifier + envelope
  smoother, **`RECIPS`-based auto-gain** (gain ∝ 1/envelope — vocal
  levelling), a **level gate** (`0x8426–0x842A`: below threshold, zero the
  contribution and skip six coefficients), and a peak-hold section
  (`0x842B–0x843D`) that tracks a running peak/period.
- **`DM(0x0C) = R2`** (`0x843C`): an absolute write into the IOP register
  window — the pool's *only* effect that reports state back toward the
  host (the boot probes use IOP `0x0B` the same way). Reading: the
  harmonizer publishes a detected level/pitch-period word for the CPU
  (which needs the singer's pitch to steer harmonies). Interpretation
  PROVISIONAL; the write itself is fact.
- **Three resampling taps** (voices, `0x843E–0x847A`): per voice a phase
  accumulator in the param block advances by a host-set slope, is
  **reflected** on exceeding a bound (`IF GE, Rn = −Rn` — ping-pong grain
  reads, click-avoidance), `FDEP`-wrapped, `>>5`, and read from the I2
  ring with 16.16 fractional lerp and a per-voice gain (`c029/c02b/c02d`,
  template 1.0). A moving-tap slope ≠ 0 is a **pitch shift**; the template
  slopes are `c021/c023/c025` = −0.8747 / −0.5000 / −0.2498 samples/sample
  → ratios 1.8747 / 1.5000 / 1.2498 = **+1088.0 / +702.0 / +386.0 cents**
  — *integer-cent* renderings of the just major seventh (15/8), perfect
  fifth (3/2) and major third (5/4): the template harmony is a just
  **major-seventh chord** over the singer. (Host rewrites these per the
  harmony/key setting — the firmware evidently computes slopes from cents.)
- The three voices are averaged (`(v0+v1)/2` with v2 folded in at
  `0x8479–0x847A`), passed through **two post biquads** (`c031–c033`,
  `c034–c036`), gain, `CLIP ±0x7FFFFF`, out.

So: a gated, auto-levelled, three-voice granular (reflected-tap) pitch
shifter with host-facing pitch/level telemetry — a vocal harmonizer by
construction, not just by name. Not a rotary; never was a candidate worth
the name once opened.

## 6. Comparison

| | rec24 | rec26 | rec31 | rec30-family + rec16 | rec66 |
|---|---|---|---|---|---|
| GUI (ROM fact) | Tremolo1–8 | Auto Pan1–7 | Ring Mod.1–4 | Rotary Speaker / Rock Rotary | Vocal Harmonizer |
| modulators | 1 sine used (+1 dead) | 2 sines, 90° | 2 sines, 90°, audio rate | 2 magic-circle rotors, 7:6, glide τ=93 ms | 3 reflected ramp taps |
| template rate | 10.77 Hz | 1.35 Hz | 344.5 Hz | 5.51 / 6.43 Hz | +386/+702/+1088 cents |
| AM law | 0.8+0.2·sin, in-phase | same, quadrature | bipolar ×sin | comb interference (direct+swept tap) | — |
| delay | none | none | none | horn 320±29, drum 160±40 (float ring) | 3 fractional taps, ring |
| filters | — | — | — | PWL shaper, 1.57 kHz smoother, 500 Hz + ~2 kHz crossover | pre/post biquads, gate, AGC |
| stereo | L=R gain | gains 90° apart | carriers 90° apart | quad horn mics + antiphase drum | mono→both |
| state math | 31-bit phase wrap | same | same | coupled-form osc in param block | phase reflect |

Design-language notes: the rotary is the only program that treats the
*param block* as oscillator state (c012/c013/c016/c017) and the only
effect family calling both kernel helpers; the increment-glide (one-pole
on a *rate*, k+k' = 1 exactly) is the same unity-DC discipline the tree
keeps finding in signal filters, applied to a control signal.

## 7. Corrections this pass makes

- `records.tsv`: rec30/35/36/41–45 "modulated-delay + filter (multi-tap,
  crossfaded) / chorus, conf low-high" → **rotary speaker simulator**
  (per-preset GUI names, conf high); rec16 "modulated-delay chorus" →
  **rotary speaker (Rock Rotary build)**; rec24/26 named Tremolo / Auto
  Pan (the generic "tremolo-pan LFO" split into the two real identities,
  including rec24's dead quadrature LFO); rec31 "tremolo-pan" → **ring
  modulator** (audio-rate template is intentional); rec66
  "chorus/pitch-shift (conf low)" → **vocal harmonizer, 3-voice granular
  pitch shifter** (conf high structural); GUI names from §1 stamped on
  every descriptor-covered row.
- `insert-effects-algorithms.md` §7's closing "no rotary speaker found;
  candidates rec24/26/31 tremolo-pans, rec66" — superseded by §4 above
  (correction note added there).
- `chorus-family-algorithms.md` §7's provisional Celeste/Mod.Cel./Flanger
  readings — now ROM fact via the descriptor table (addendum added there).
- Old sym guesses corrected: rec30's "CallBiquad/CallAllpass" (it is a
  crossover + dual-rotor call pair), the "{inc,inc,phase}" state reading
  (it is {target, current, −1} with glide), rec24/26's "LFO_Depth"
  (0x66666666 is the *bias*; the depth is c006/c008), rec16's
  "0.10/0.40" smoother comment (0.2/0.8).

## 8. Cross-model note

KN6000/KN6500 DM banks are byte-identical for all 80 records: rotor rates,
the 7:6 ratio, glide constant, crossover voicings, tremolo/pan/ring
templates and the harmonizer's just-chord slopes all carry over. Their PM
is the older build — re-derive the delay immediates (0x140/0xA0/0xC8) and
the rec16-vs-rec30 shift variant from the KN6xxx listings before porting
labels. Their GUI descriptor tables (if present in the same layout) have
not yet been walked.
