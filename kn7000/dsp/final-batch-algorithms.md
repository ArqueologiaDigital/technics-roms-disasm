# The KN7000 SHARC final batch — mic reverbs, the brass simulators, and the combis

Static reverse-engineering of the last twelve undocumented effect
microprograms (2026-07-19), at the standard of `reverb-algorithm.md` /
`chorus-family-algorithms.md` / `dynamics-eq-exciter.md`: everything below is
read off the committed listings in `../disasm/dsp/` (PM addresses quoted),
with delay lengths, coefficient roles and topology pinned. Records covered:
**rec58–61** (types 0x58–0x5B, the unit-7 mic reverbs Room / Karaoke / Stage /
Cave), **rec67–69** (0x79–0x7B, GUI BRASS SIMULATOR1–3), **rec70/71/72**
(0x40/0x42/0x43, the Delay+Chorus / Delay+Flanger / Delay+Vibrato combis) and
**rec75/76** (0x50/0x51, COMP+DST+DELAY / COMP+OVD+DELAY). GUI names are ROM
fact via the preset-descriptor and group tables
(`tremolo-rotary-family.md` §1, `modulation-pitch-family.md` §1).

**This pass completes the pool: every effect record (rec05–rec76) is now
documented.**

**Headlines — three questions answered:**

1. **The mic reverbs are a third reverb architecture, and they run at half
   the sample rate.** rec58–61 are neither the rec51 Moorer hybrid nor the
   rec12 gate tank: they are a **series-allpass (Schroeder) reverberator**
   with no combs and no global loop — six big allpasses whose ringing *is*
   the tail — executed as a **two-phase multirate machine**: the kernel's
   FLAG3 pin (finally explained) is a **fs/2 frame-parity strobe**, the
   exclusive I3 SDRAM ring scrolls only on FLAG3-high frames, and the
   program runs three allpasses on high frames and three on low frames.
   One ring word = two sample periods: 18,000 words of I3 become **816 ms
   of reach**, and Room's modest 5,954-word footprint buys a 2.3 s tail.
   Audio-rate unity-DC lowpass biquads bracket the half-rate core as
   decimation/interpolation filters. "Karaoke" collapses the whole tank to
   a single 363 ms k=0.7 echo allpass — the classic karaoke slap.
2. **The BRASS SIMULATORs are a physical-modeling cluster** — unique in the
   pool: all three integrate a **2-state nonlinear "lip" ODE** per sample
   (cubic + quadratic stiffness, Euler steps, oversampled ×4/×2 in
   rec68/69), whose output is silent at equilibrium — a *dynamics-emphasizing*
   distortion (the brass "blat"). rec67 adds the pool's only **pitch
   tracker** (a once-per-cycle period detector) driving a period-locked
   ping-pong grain tap; rec69 couples the lip to a **512-sample bore delay
   in a Karplus-Strong-style negative-feedback loop** (odd-mode comb — a
   closed-tube resonator): lip drives bore, bore pressure re-excites lip.
3. **The combis are literal compositions of documented engines** — and the
   attributions are exact, not generic: rec70 = rec13's echo (in rec73's
   float form) → **one voice of rec06's chorus geometry**; rec71 = echo →
   **rec09's flanger** (same 300-sample center, same 0.70 float regen)
   with one mono LFO; rec72 = echo → **rec27's vibrato** (same 1.346 Hz
   quadrature pair, full-replace semantics, deeper ±112 swing); rec75/76 =
   the **family AGC as the "COMP"** → the rec37/rec18 transfer curves in a
   **float-stored LUT** → echo, with the DST/OVD split done *entirely in
   data*: rec76 swaps curve A for curve B and switches on a unity-DC tone
   smoother whose pole lives in PM state — the engine-A/engine-B taxonomy
   of `dynamics-eq-exciter.md` §6 reproduced inside one PM image.

Sample rate: nominal fs = 44100 Hz. Execution context = the kernel contract
(`kernel-architecture.md` §7): `I1` params (`0xC004+slot·0x4D`), `I8` state
(`0x9800+slot·0x50`, PM bus), `I4` I/O cursor (inputs at `+0x20/+0x21`),
`I2`/`I6` rings scrolling −1/sample (read at write+D = D samples ago),
`M1=+2, M2=+1, M3=−1, M5=0x4D, M6=0`. Addresses are record-local (unit-0
form); Q31 = fixed-point /2³¹.

## 1. rec58–61 — the mic reverbs: a half-rate series-allpass reverberator

98 PM words (`rec58_effect_0x486C9DD2.asm`); rec59/60/61 are **PM-identical
except the six M7 tap immediates** (the rec52/53 preset pattern), and
rec60/61's DM banks are byte-identical to rec58's (rec59 zeroes four gains —
§1.4). These are the unit-7 ("Chorus" whitelist) records — the **microphone
reverb** behind the GUI's Room/Karaoke/Stage/Cave mic presets. Mono source
(in_L of the u7 pair), wet-only output.

### 1.1 FLAG3 and the I3 ring: the multirate machinery (kernel questions closed)

Two kernel facts that had no explanation now have one:

- the mainloop polls the **FLAG3 input pin** in u7's *call delay slot*
  (`0x8098: IF FLAG3_IN, MODIFY(I3, M3)`) — the third delay ring **scrolls
  only on FLAG3-high frames**, immediately before u7's program runs;
- rec58–61 are the only records that test FLAG3: `0x8400: IF NOT FLAG3_IN,
  JUMP 0x8432 (DB)` — **phase A** (`0x8401–0x8431`) runs on high frames,
  **phase B** (`0x8432–0x8461`) on low frames. The two delayed-branch slots
  (input read + `I0 = I1`) execute on *both* paths.

The delay bookkeeping only closes if FLAG3 **alternates every frame**: phase
A walks the I3 cursor down 3,753 words and leaves it there, saving its entry
cursor in **MSGR2** (`DM(0x0A)` — a host-visible 21065L message register;
notably the one message register the kernel's boot init does *not* zero);
phase B walks further down from where A stopped, then **restores the cursor
from MSGR2**. Net ring motion per two-frame cycle = exactly the kernel's one
FLAG3-gated `M3` scroll — the ring ages **one word per two samples**. If
FLAG3 ever failed to alternate, phase B would re-read cells it had just
written (delay 0) or the ring would never age at all: the *design* pins
FLAG3 as a fs/2 parity strobe (what physically drives the pin on the board
remains untraced — the function is now fact, the source PROVISIONAL).

Consequences: **1 I3 tick = 2 samples**, so the 18,000-word ring holds
**816 ms**, and every delay below is quoted in ticks. And since rec58–61
touch **no I6 and no I2** at all, the kernel's `{u6,u7}` shared-SDRAM-window
concurrency corner (`kernel-architecture.md` §6/§9) dissolves: with a mic
reverb loaded, u7's delay state lives entirely in its private I3 ring.

### 1.2 The audio-rate shell: three identical unity-DC lowpasses

The DM bank carries **three byte-identical 5-coefficient biquads**
(c004–c008 = c009–c00d = c00e–c012, the rec51 DF2 idiom, order
a1,a2,b1,b0,b2): `H(z) = 0.2002(1+z⁻¹)²/(1 − 0.5745z⁻¹ + 0.3752z⁻²)` —
**unity DC gain, double zero at Nyquist**, poles r = 0.61 at ≈7.6 kHz
(−6.5 dB @11 kHz, −23 dB @16.5 kHz). Their shared state (PM `0x9800–0x9805`)
is advanced by **both phases every frame** — they are the audio-rate shell
around the half-rate core:

- **bq3** filters the *input* each frame (the anti-alias **decimation
  filter**); its output is consumed only on phase-A frames (the tank input
  sample), so phase B computes it and **discards the result** — five
  pipelined instructions spent purely on keeping the filter state correct.
- **bq1/bq2** filter the two tank *outputs* (held cells updated once per
  two frames) — zero-order-hold **interpolation smoothers** whose Nyquist
  zero kills the 22.05 kHz image. bq1(c002) → out ch1, bq2(c001) → out
  ch2, each `FIX`, `CLIP ±0x7FFFFF`, written every frame.

### 1.3 The half-rate core: six series allpasses, no loop

All tank state lives in the I3 walk; each allpass is the four-instruction
Schroeder cell in the `w = x − k·d, y = d + k·w` sign convention, with the
line storing float bits. Phase A: input → bq3 → ×c003 (tank gain, ≈1.0) →
**AP_a1 → AP_a2 → AP_a3** (series) → scratch **c000**. Phase B: c000 →
**AP_b1** → then a **parallel terminal pair**: AP_b2 → **c002** (→ ch1) and
AP_b3 → **c001** (→ ch2) — two different last allpasses decorrelate the
stereo pair (the rec12 AP4 trick, doubled). There is **no comb, no global
feedback loop**: the tail is the convolved ringing of the six allpasses
themselves — Schroeder's series-allpass reverberator, the textbook
"colorless" cascade, scaled up by the half-rate trick. Per-section RT60 =
delay · 60/(−20·log₁₀k):

| preset | phase-A ticks (ms) | phase-B ticks (ms) | k (A / B) | total AP delay | RT60 |
|---|---|---|---|---|---|
| **rec58 Room** (0x58) | 1650/1100/1000 (74.8/49.9/45.4) | 935/549/720 (42.4/24.9/32.7) | .80,.86,.86 / .82,.70,.62 | 270 ms | **≈2.3 s** |
| **rec60 Stage** (0x5A) | 2250/1500/1400 (102.0/68.0/63.5) | 1235/799/920 (56.0/36.2/41.7) | same | 322 ms | **≈3.2 s** |
| **rec61 Cave** (0x5B) | 2600/1800/1680 (117.9/81.6/76.2) | 1480/960/1104 (67.1/43.5/50.1) | same | 436 ms | **≈3.7 s** |
| **rec59 Karaoke** (0x59) | **8000** (362.8) + 1 + 1 | 1 + 2002 + 1 | **.70** / all 0 | — | ≈7 s of repeats |

Footprints: Room 5,960 → Cave 9,630 words, comfortably inside the
18,000-word ring. In the two long sections' gains (0.86 at ~50 ms) the
per-section RT60s are deliberately matched (2.1–2.3 s in Room) — the tail
decays as one voice, not as a staircase.

```
              (audio rate, 44.1 kHz)          (half rate, 22.05 kHz — I3, FLAG3-paced)
 in_L ──► bq3 LP ──►(sampled on A-frames)──► AP_a1 ─ AP_a2 ─ AP_a3 ──c000──► AP_b1 ─┬─ AP_b2 ──c002
                                                                                    └─ AP_b3 ──c001
 out1 ◄── CLIP ◄── bq1 LP ◄──────────────────────────────────────────────────────────────┘c002
 out2 ◄── CLIP ◄── bq2 LP ◄───────────────────────────────────────────────────────────────c001
```

### 1.4 Karaoke: the degenerate preset

rec59 zeroes **c014–c017** and re-times the taps: the four zero-gain
"allpasses" degenerate to pure delays (w = x, y = d), leaving **one** real
allpass — 8,000 ticks = **362.8 ms** at k = 0.70 = a regenerating slap echo
losing 3.1 dB per repeat (≈7 s of audible discrete repeats), exactly the
karaoke-machine mic sound. The phase-B pure delays split the outputs: ch1 =
tank + 2,003 ticks (**90.8 ms**), ch2 = tank + 2 ticks — a wide stereo echo
offset for free. One record family covers a true reverb *and* a tape-echo
character purely through its data.

### 1.5 Why half-rate (a reading)

u7's I6 window is shared with u6 and its I2 window with u6+u8
(`kernel-architecture.md` §6) — a mic reverb there could collide with a
MULTI insert. The I3 ring is u7's alone, and clocking it at fs/2 doubles
both the reach *and* the effective per-word cost of the longest tails in
the pool outside u0. A voice-band effect (the mic path) is exactly where a
11 kHz-bandwidth tank is inaudible as a compromise. (Interpretation;
the mechanism itself is opcode fact.)

## 2. rec67 / rec68 / rec69 — the BRASS SIMULATORs: a physical-modeling cluster

Three distinct programs (108/57/90 PM words), one shared heart, three
escalating configurations. All mono (in_L), dual-mono out, all ending in the
**cubic soft clipper** y = x − x³/3 with rails ±2/3 — rec62's clipper
verbatim (constants ±1.0, 1/3, ±2/3 in each DM bank).

### 2.1 The shared "lip" ODE

Each record normalizes its drive signal by **1.0e-8** (float) into ODE units
and Euler-integrates a 2-state nonlinear system per sample:

```
u' = x − v − 0.0667·u³ − 0.7·u²         (u: the "lip" state)
v' = u³ − x − 2·v                        (rec67/68; rec69: v' = u³ + u − v + tube)
```

- rec67: 1 step of ε = 0.04 per sample; **rec68: 4 steps of ε = 0.01**
  (LCNTR=4 — the same net rate, 4×-oversampled integration); rec69: 2 steps
  of ε = 0.01.
- The u equation is a driven nonlinearity with **cubic + quadratic
  stiffness** — the u² term makes it asymmetric (even harmonics, the brassy
  "cuivré" edge that grows with amplitude).
- v is a leaky integrator of (u³ − x): the output pick **u³ − 2v** (rec67)
  / **u³ − x − 2v** (rec68) is therefore the distortion products
  *highpassed* (leak 2ε → ≈560 Hz) with the drive removed — **at
  equilibrium the output is exactly zero**. The effect passes nothing in
  steady state and speaks on *change*: a transient-emphasizing distortion,
  the attack "blat" of a brass note.
- Output conditioning: ×0.0025/0.0005/0.001 → cubic clip → ×4e9/8e9/4e9
  renormalize → Q31 level → `>>9/>>6/>>8`.

### 2.2 rec67 — BRASS SIMULATOR1: the pitch-tracked front end

The most elaborate record in the batch, and the pool's only pitch tracker:

1. **Detector conditioning** (`0x8403–0x8407`): a one-pole bass-emphasis
   filter (s' = x + 0.9935·s, y = 0.033(s'+s): DC gain ≈×10, −17 dB @5 kHz)
   — the envelope tracks the *fundamental*, not the harmonics.
2. **Slow envelope + the family AGC** (`0x8409–0x8413`): attack 1/256,
   release **1/32768 (τ = 743 ms — the slowest release in the pool)**;
   drive = 0.111 + 8.35e8/env clamped at 4.0 below 0.1 — rec37's law,
   eighth appearance.
3. **Period detector** (`0x841a–0x842c`): a running integral c000 +=
   (drivenLP − env)/4, and a trigger that fires once per fundamental cycle
   (drivenLP ≥ env AND driven-raw < env AND integral < 0 — a debounced
   phase point). Between triggers a **period ramp** c00f += 0x100000/sample
   (capped at 1,008 samples = 43.75 Hz); each trigger **latches the ramp
   into c012** — the measured period T — and resets integral and ramp.
4. **Pitch-synchronous ping-pong tap** (`0x842d–0x843d`): the driven input
   is written to a fixed-point I2 line (write P, read base P+510); a tap
   accumulator (increment = PM state `0x9802` = −0x200000, host preset)
   **reflects at ±c012** — rec66's ping-pong grain idiom, but with the
   grain span slaved to the *detected period*: offset sweeps ±T/2 samples
   at ±1 sample/sample. Delay slope −1 reads at 2× (an octave up); slope +1
   holds one absolute cell (readout frozen): period-locked grains
   alternating octave-up and hold, re-synchronized every cycle. (Mechanism
   is opcode fact; the perceptual reading — a period-locked
   thickening/octave layer feeding the nonlinearity — is PROVISIONAL.)
5. Tap → unity-DC LP biquad (r = 0.628 @3.46 kHz, c014–c018) → ×1e-8 → the
   §2.1 ODE → cubic clip → out.

### 2.3 rec68 — BRASS SIMULATOR2: the naked blow model

No AGC, no envelope, no delay line, one state word: input ×1e-8 → the ODE,
4×-oversampled → out = u³ − x − 2v → a **+6 dB-at-Nyquist one-pole shelf**
(unity DC: pole 0.769, zeros/num 1.8802/−1.6489 — brightening the rasp) →
×0.0005 → cubic clip → renorm → CLIP. The minimal, always-on brass edge.

### 2.4 rec69 — BRASS SIMULATOR3: lip + bore, coupled

rec69 completes the model with a resonator: the family AGC (release 1/2048
this time) → the ODE (2×, with the modified v' = u³ + u − v + tube) coupled
to a **512-sample delay line in a Karplus-Strong-style loop**:

```
line_in = 0.12·v − 0.8·[ (tap[n] + tap[n−1])/2 ]        (I2, 512 samples = 11.6 ms)
v'     += … + (tap[n] + tap[n−1])/2                      (one frame late, via c013)
```

The two-tap averager is the classic KS loop-damping filter (zero at
Nyquist); the **negative** 0.8 feedback makes the comb resonate at **odd
multiples of ≈43 Hz** — a closed-tube (bore) mode series. The lip state v
injects into the bore; the bore's averaged output pressure re-enters the
lip's v equation: a genuine, if stylized, **coupled lip–bore waveguide**.
Output = the v' expression → the same +6 dB shelf (pole 0.751) → ×0.001 →
cubic clip → out.

So "what makes a brass simulator" (the task's question): **not formant
filters** — an asymmetric nonlinear oscillator with a zero-at-equilibrium
output (dynamics-only distortion), optionally pitch-locked grain excitation
(rec67), optionally a physical bore resonator (rec69), always the cubic
clipper and (67/69) the family AGC in front.

## 3. rec70 / rec71 / rec72 — the delay+modulation combis

Three siblings of rec73 (`phaser-enhancer-gate.md` §4), one recipe: **the
echo family front end run in float** (undamped, feedback via the
one-frame-late param-scratch idiom, `0x3C64` channel stride in I6), a
**0.5·in + 0.5·tap mix**, then a documented modulation engine on the I2
ring. All three: no CLIP stage (the combi-family trait), family sine table
at c029–c03f (hot-swappable via data records rec77–79), real (non-placeholder)
LFO rates shipped in PM state.

| | rec70 DELAY+CHORUS (0x40) | rec71 DELAY+FLANGER (0x42) | rec72 DELAY+VIBRATO (0x43) | (rec73 DELAY+PHASER, 0x44) |
|---|---|---|---|---|
| GUI (ROM fact) | **Feedback Chorus** (CHORUS screen, unit-9 whitelist) *and* Delay+Chorus (Multi) | Delay+Flanger | Delay+Vibrato | Delay+Phaser |
| echo (smp) | 8000 / 10000 | **8000 / 8000** | 8000 / 10000 | 8000 / 10000 |
| echo fb | 0.6 float | 0.6 float | 0.6 float | 0.6 float |
| back-end engine | **rec06's chorus geometry**, 1 voice/ch (write P / P+490, read base 250/740, ±64) | **rec09's flanger** (write P / P+500, base 300/800, ±64, **0.70 float regen**) | **rec27's vibrato** (write P / P+500, base 250/750, **±112**) | 3× §1-allpass cells, k=.876±.12, 0.6 cascade fb |
| LFOs | 1 sine, 0.673 Hz (`PM9800 = 0x8000`); L=+sin, R=−sin(+90°) | **1 mono sine**, 0.673 Hz; R negated (rec09 had 2 LFOs 90° apart) | 2 sines **1.346 Hz** (`0x10000` = rec27's rate), phases 0/+90°, rec27's L/R assignment | 1 mono, placeholder inc |
| output | 0.5·mix + 0.5·voice, ×wet ×2 | 0.5·(line-in incl regen) + 0.5·tap, ×wet | **tap only, full-replace** ×wet (vibrato semantics) | 0.5·mix + 0.5·phased, ×wet |
| I2 footprint | 805 w | 865 w | 863 w | — |

Notes with teeth in them:

- **rec70** is the record behind two GUI names at once — *Feedback Chorus*
  on the CHORUS screen (through its unit-9 whitelist membership) and
  *Delay+Chorus* in the Multi group: the name "Feedback Chorus" describes
  precisely a chorus with a 0.6-regeneration echo behind it. Its chorus
  half is rec06's exact delay geometry (250-sample centers, P+490 R base,
  antiphase quadrature R modulator) reduced to one voice per channel.
- **rec71** is the only combi with *equal* echo delays (8000/8000) — the
  stereo motion comes entirely from the antiphase flanger modulators. Its
  flanger half reproduces rec09 to the number (300-sample center, ±64
  swing, 0.70 float regeneration, float ring, float lerp) with the two
  independent LFOs economized to one mono LFO + negation.
- **rec72** keeps rec27's *semantics* — the vibrato tap fully replaces the
  signal (no dry term, no makeup) — but deepens the swing to ±112 samples
  (≈37 cents at the shipped 1.346 Hz) and takes a stereo source where
  rec27 was mono. Echo repeats *inside* a vibrato: the wobble applies to
  the repeats too.
- The shipped LFO increments here are **real rates** (0.673/1.346 Hz), not
  the chorus family's fs/256 placeholder — more evidence that the
  placeholder records expect host rewrites while the combis were shipped
  performance-ready.

## 4. rec75 / rec76 — COMP+DST+DELAY / COMP+OVD+DELAY: one PM, two engines

76 PM words, **byte-identical PM** (`rec75_effect_0x486CDD14.asm`); the
GUI's DST/OVD split is done entirely in the DM/state banks.

### 4.1 The chain (both records)

1. **"COMP" = the family AGC made load-bearing**: stereo-linked detector
   `|(L+R)<<9|`, attack 1/256 / release 1/2048, drive = 0.111 + 8.35e8/env
   clamped at 4.0 (RECIPS seed), ×c004 master trim (1.0f). What the
   distortion records use as drive conditioning is here the *advertised*
   compressor: the gain law rides both channels' inputs directly.
2. **Waveshaper**: per channel, x·drive indexes the c028 window — but the
   33-point curve is **stored as IEEE floats** and interpolated with the
   float lerp (`FLOAT R3 BY −31`) — a third variant of the family LUT
   idiom (rec37: fixed table; chorus family: waveform table; here: float
   table).
3. **A one-pole** y = k1·x + k2·y[n−1], with k1 in DM (c00e) and **k2 in PM
   state `0x9801`** — the parameter-in-state idiom (rec18's smoother,
   rec12's hold counter).
4. **Echo**: line_in = 0.125·y + 0.6·fb, **5000/5000 samples (113.4 ms both
   channels)**, float, undamped, `0x3C64` stride (the family echo, at
   rec74's R length).
5. **Output**: out = 0.0625·y + 0.5·tap, ×wet, `>>8` (net ×2 makeup against
   the `<<9` input). The scaling is exact: the first repeat
   (0.5 × 0.125·y) lands at **precisely the direct level** (0.0625·y), then
   decays ×0.6 — slap-echo distortion with a calibrated first bounce.

### 4.2 The data-only DST/OVD split

| | rec75 (DST) | rec76 (OVD) |
|---|---|---|
| c028 float LUT | **curve A** — the 7.5/1.5/0.5 hard-knee (rec37/rec17's, GUI *Distortion*) | **curve B** — the smooth concave knee 8/2.67/1.67/1/0.67/0.33×3/0.17×2/0.083×4/0.17×2 (rec18's, GUI *Overdrive*) |
| one-pole k1 (c00e) | ≈1.0 (Q31) | **0.2** |
| one-pole k2 (PM `0x9801`) | **0** → stage bypassed | **0.8** → H = 0.2/(1−0.8z⁻¹): **unity DC**, −3 dB ≈1.6 kHz |

That is `dynamics-eq-exciter.md` §6's engine taxonomy reproduced in data:
engine A (no mid-stage) vs engine B (tone smoother with its coefficient in
PM state), selected by a curve swap and two cells. The 33-point curves match
the documented tables **point for point**.

## 5. Comparison — the batch against the pool's design language

| | rec58–61 | rec67 | rec68 | rec69 | rec70/71/72 | rec75/76 |
|---|---|---|---|---|---|---|
| identity | half-rate series-AP mic reverb | pitch-tracked lip ODE | naked lip ODE | lip + bore waveguide | echo→chorus/flanger/vibrato | AGC comp→LUT→echo |
| source | mono (in_L) | mono | mono | mono | stereo | stereo (linked detector) |
| rate trick | **fs/2 phase split** | per-cycle trigger | 4× oversampled ODE | 2× oversampled ODE | — | — |
| family AGC | — | ✓ (rel 1/32768) | — | ✓ | — | ✓ (the "COMP") |
| unity-DC filters | 3 (the multirate shell) | tap LP | +6 dB shelf | shelf + KS damp | echo (undamped) | rec76 smoother |
| nonlinearity | — | ODE + cubic clip | ODE + cubic clip | ODE + cubic clip | — | float LUT A/B |
| delay rings | **I3 only** | I2 | none | I2 | I6 + I2 | I6 |
| params in PM state | AP k's would be DM; taps are **PM immediates** | ping-pong inc | — | — | LFO incs (real rates) | smoother pole |
| CLIP | ±0x7FFFFF | none (>>9) | ±0x7FFFFF | ±0x7FFFFF | none | none (>>8) |

Signatures extended a final time: the **1/256–1/2048 attack/release pair**
(rec69, rec75/76 — and rec67 stretching the release to 1/32768); the
**0.111 + 8.35e8/env clamp-4.0 drive law** (rec67/69/75/76 — now ten
records); **unity-DC-by-construction filters** (the mic shell, both brass
shelves, rec76's smoother); **parameters as PM-state data** (rec75/76's
smoother pole, rec67's grain increment, the combis' LFO rates);
**dead-computation-as-structure** (rec58's phase-B bq3, run purely for its
state — cousin of rec29's fossil detector, but *deliberate*); the **cubic
±2/3 clipper** (rec62's, all three brass sims); the **c028 window** in its
third role (float curve LUT); and the **one-frame-late float feedback**
idiom carrying every combi echo.

## 6. What this pass corrects

- `records.tsv`: all twelve records re-identified, conf medium → high
  (rec58–61 "comb+allpass reverb" → half-rate series-allpass mic reverbs;
  rec67–69 "waveshaper/nonlinear" → the brass physical-modeling cluster;
  rec70/71/72 "modulated-delay chorus" → the exact engine-composition
  combis; rec75/76 "modulated-delay chorus/flanger" → AGC-compressor →
  LUT-distortion → echo combis).
- `kernel-architecture.md`: FLAG3's function (§5) and the {u6,u7}
  shared-window corner (§6/§9) are resolved by rec58–61's design; MSGR2's
  exemption from the boot-init zeroing is explained.
- Syms rewritten for all twelve (the old rec58 "biquad damping b0/b1/b2"
  cell order corrected to the a1,a2,b1,b0,b2 idiom; rec67's "sine-polynomial
  waveshaper" reading replaced by the period detector + ODE; rec70–72/75/76
  placeholder labels replaced by the full dataflow).

## 7. Remaining unknowns (honest list)

- FLAG3's physical driver (function pinned, net untraced) and the exact
  perceptual character of rec67's alternating octave/hold grains — both
  need the real board or a faithful TG model.
- rec75/76's `PM 0x9801`/host interplay beyond the shipped banks, and all
  preset-time host rewrites throughout (the standing `DspEffectSelect`
  live-capture experiment).
- The u7 empty-slot copy-through vs rec58–61's wet-only output: whether
  the mic dry path re-enters TG-side on the same pair (send/return) or the
  reverb is meant to fully replace the mic feed is host/TG routing, not
  statically decidable.

## 8. Cross-model

KN6000/KN6500 DM banks are byte-identical for all 80 records: the mic
biquad/gain banks, the brass ODE constants and both float LUT curves carry
over. The PM builds are older — before porting: re-check the six M7 tap
immediates per mic preset, rec67's 0x1FE/±T/2 grain constants, rec69's
0x3FF/−512 bore geometry, and the combi delay immediates
(0x1F40/0x2710/0x1388, 0xFA/0xF0/0x12C/0xC8) against the KN6xxx listings.
The FLAG3/I3 half-rate machinery lives partly in the kernel (the §1.1 poll)
— the KN6xxx kernel's older PM should be checked for the same delay-slot
scroll before assuming the mic path works identically there.
