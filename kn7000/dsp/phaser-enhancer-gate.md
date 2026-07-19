# The KN7000 SHARC Enhancer, the real phasers, and the gate reverb

Static reverse-engineering of five more effect microprograms (2026-07-19), at
the standard of `reverb-algorithm.md` / `insert-effects-algorithms.md`:
everything below is read off the committed listings in `../disasm/dsp/` (PM
addresses quoted), with delay lengths, coefficient roles and topology pinned.
Records covered: **rec08** (type 0x03, GUI ENHANCER1–6), **rec10** (0x05/0x0D,
GUI Phaser groups), **rec73** (0x44, GUI DELAY+PHASER), **rec47** (0x90, GUI
Wah1–8 bank 0x3A), **rec12** (0x08, the REVERB screen's Short/Medium/Long Gate
presets). GUI names are ROM fact via the preset-descriptor table
(`tremolo-rotary-family.md` §1). All five are on the units-1–6 insert
whitelist.

**Headline — three questions answered:**

1. **What a Technics "Enhancer" is** (rec08): *not* an exciter — there is no
   nonlinearity anywhere in the record. It is a **phase-rotation
   loudness/width processor**: a 4-stage first-order allpass *phase disperser*
   feeding complementary one-pole low/high band filters whose sum is added
   back to the dry signal (bass+treble emphasis with a mid scoop), one output
   channel delayed 800 samples (18.1 ms) against the other — a Haas-style
   widener. The harmonic "exciter" of this pool is elsewhere: rec20 (GUI
   EXCITER1–3) is a waveshaper+EQ.
2. **The pool does contain true phasers** — Part-41's finding that the
   "modulated-allpass phasers" rec46/48 are swept filters stands, but rec10
   is the real thing: **five first-order allpass stages per channel whose
   *coefficient* (not a delay) is LFO-modulated**, quadrature stereo, with a
   float feedback path. rec73 is the same cascade, three stages, bolted onto
   rec13's echo — the DELAY+PHASER combi. rec47, the third candidate, is
   **not a phaser after all**: it is a *fourth wah* (see 3).
3. **rec12 is the GATE REVERB engine**: a compact allpass-ring reverberator
   (three allpasses totaling 85.5 ms in a −0.5 damped feedback loop, RT60 ≈
   0.85 s) whose output is multiplied by a **gate with hold** — threshold,
   ~23 ms attack, a PM-set hold counter, ×0.999/sample release — including a
   four-instruction re-trigger debounce that only works because the kernel
   enables ALUSAT.

Sample rate: nominal fs = 44100 Hz. Execution context = the kernel contract
(`reverb-algorithm.md` §1, `kernel-architecture.md` §7): `I1` params
(`0xC004+slot·0x4D`), `I8` state (`0x9800+slot·0x50`, PM bus), `I4` I/O cursor
(inputs at `+0x20/+0x21`), `I6` SDRAM delay arena scrolling −1/sample (read at
write+D = D samples ago), `M1=+2, M2=+1, M3=−1, M4=−2, M6=0`. Addresses are
record-local (unit-0 form).

## 1. The shared first-order-allpass idiom

rec08, rec10 and rec73 are built from one four-instruction cell (quoting
rec08 `0x8404–0x8407`):

```
F12 = F3 * F7          ; k·s          (s = state, k = coeff in F7)
F1  = F10 + F12        ; w = x + k·s
F12 = F1 * F7,  DM(I0,M2) = R1   ; k·w; store w back to the state cell
F10 = F3 - F12         ; y = s − k·w
```

With s = w[n−1] this is the one-multiplier-form **first-order allpass
H(z) = (z⁻¹ − k)/(1 − k z⁻¹)** — pole at k on the real axis, |H| = 1 at all
frequencies, phase running 0° (DC) → −180° (Nyquist) with the −90° point at
`f₉₀ = fs/2π · arccos(2k/(1+k²))`. The delay element is **one sample, held in
the DM parameter block itself** (the cell is written this frame, read next
frame) — no delay line, no interpolation. Chaining N cells gives N·180° of
phase rotation; what the three records *do* with that rotation differs:

- rec08 keeps k **fixed** (phase disperser),
- rec10/rec73 **sweep k from an LFO** (phaser),

and all three share the constant k-center **0.876** (rec08 float `c004
0x3F604188`; rec10/73 Q31 `0x7020C49B`) with f₉₀ = **926 Hz** per stage.

## 2. rec08 — the ENHANCER (type 0x03, GUI Enhancer1–6)

90 PM words (`rec08_effect_0x486BF364.asm`), two symmetric channel halves
(ch0 `0x8401–0x842C`, ch1 `0x842D–0x8456`). Corrects the old "comb+allpass
reverb" identification: there is **no feedback anywhere** — nothing
recirculates, no tail is possible.

### 2.1 Phase disperser (`0x8404–0x8413`)

Four chained allpass cells, all with **k = c004 = 0.876** (loaded once at
`0x8402`, parked in R15 at `0x8404` for the second channel), states in
c005–c008 (ch1: c012–c015 at `0x8430–0x843F`). Four stages of k = 0.876:

| f | phase (4 stages) | group delay |
|---|---|---|
| DC | 0° | 60.5 samples (1.37 ms) |
| 100 Hz | −49° | |
| 400 Hz | −187° | |
| 926 Hz | −360° | |
| 2 kHz | −522° | |
| Nyquist | −720° | 0.26 samples |

Magnitude is untouched; the network concentrates ~1.4 ms of group delay in
the bass — a classic **phase rotator** (the broadcast-processor trick for
making asymmetric waveforms symmetric).

### 2.2 Complementary band split (`0x8414–0x841D`)

The dispersed signal feeds two one-pole+zero filters whose single-sample
states live in the **PM state block** (`0x9800/1` ch0, `0x9802/3` ch1 — the
`R3 = PM(I8,M14)` load / `PM(I8,M8) = R3` write-back pair at
`0x8414/0x8417`):

- **Lowpass** (c009–c00b = 0.9446 / 0.0277 / 0.0277):
  `H = 0.0277(1+z⁻¹)/(1−0.9446z⁻¹)` — **unity DC gain** (1.0000), zero at
  Nyquist, −3 dB at **400 Hz**.
- **Highpass** (c00c–c00e = 0.7491 / −0.8745 / +0.8745):
  `H = 0.8745(1−z⁻¹)/(1−0.7491z⁻¹)` — zero at DC, **unity Nyquist gain**
  (1.0000), −3 dB at **2.04 kHz**.

The band between 400 Hz and 2 kHz belongs to neither filter — and that is
exactly the octave band where the disperser rotates through −360° (§2.1).

### 2.3 Recombination + the 800-sample stereo offset (`0x841E–0x842C`)

Both band outputs are FIXed and mixed in the MAC with **independent Q31
gains** — `MRF = c00f·low; out = MRF + c010·high` (`0x8420–0x8421`; ch1
gains c01c/c01d; templates all `0x7FFFFFFF` ≈ 1.0) — then **added to the
dry input re-read from the I/O slot** (`0x8422–0x8423`):

```
sum = dry + gLO·LP(disp(x)) + gHI·HP(disp(x))
```

Where the wet phase aligns with dry (the extremes of the spectrum), lows and
highs reinforce toward **+6 dB**; the 400 Hz–2 kHz midband keeps only the
dry term (a scoop), and through the crossover skirts the −360°-rotating wet
term sweeps in and out of phase with dry — a gentle comb coloration instead
of a shelf's hard edge. A "smile-curve" loudness tilt built from phase, not
from EQ gain.

The sum is then written to the SDRAM arena and read back (`0x8424–0x8428`):
**ch0 writes at the entry cursor and taps at +0x320 = 800 samples = 18.1 ms**
(`M7 = 0x320` write post-modify, tap at the moved cursor, cursor restored
from R1, then `MODIFY(I6, 0x3C8C)` hops to the ch1 sub-arena); **ch1 writes
and immediately reads back the same word — delay 0** (`M7 = 0` at `0x8450`).
One channel lags the other by 18 ms: the **Haas precedence trick** (cf.
rec37's 400-sample variant), decorrelating the channels into width. (Which
physical side is the delayed one depends on the unresolved SDIE/SDOE channel
order — the 800-sample *offset* is the fact.) Output: ×wet (c011, Q31,
shared by both channels), CLIP ±0x7FFFFF, write.

```
        in ch0 ──┬────────────────────────────────────────────┐ dry
                 └→ AP.876 ×4 ──┬→ LP 400 Hz ──×gLO──┐        ▼
                 (disperser)    └→ HP 2.04 kHz ─×gHI─┴──(+)──(+)──→ delay 800 ──×wet→ out0
        in ch1 ── (same, own states/gains) ······················→ delay 0  ──×wet→ out1
```

### 2.4 What "Enhancer" means here

No rectifier, no waveshaper, no envelope — rec08 cannot add harmonics. The
Technics Enhancer is a **psychoacoustic spectral-tilt + stereo-width
processor**: phase-dispersed bass/treble reinforcement with a mid scoop, plus
interchannel delay. The six GUI presets (Enhancer1–6) differ only in the DM
bank (band gains gLO/gHI per channel, wet, and the filter poles if rewritten);
the 800/0-sample PM immediates are fixed for all presets. records.tsv
conf → high.

## 3. rec10 — the true PHASER (types 0x05/0x0D, GUI Phaser groups)

106 PM words (`rec10_effect_0x486BFAFE.asm`). The record the manifest always
called "modulated-allpass phaser" — and for once the label was right.

### 3.1 Quadrature LFO pair → coefficient sweep (`0x8403–0x8424`)

Two instances of the family LFO idiom (`chorus-family-algorithms.md` §1.2):
phase accumulators in **c006/c007** (31-bit wrap, 16-step sine table at
c030±8, linear interpolation), increments in **PM `0x9800/0x9801`** (both
template `0x800000` — the audio-rate placeholder the host rewrites at select
time, as throughout the chorus family). c007's template phase is
`0x20000000` = **+90°**: the two LFOs run in quadrature forever (equal
increments). Each sine is scaled by **depth c005 = 0.12** (Q31) and added to
**center c004 = 0.876** (`0x8411–0x8412`, `0x8421–0x8422`); the result is
floated with exponent −31 (`F7 = FLOAT R8 BY R15`, R15 = −31, `0x8424` /
`0x8446`). So per channel:

```
k(t) = 0.876 + 0.12·sin(θ)  ∈  [0.756, 0.996]     (θ_ch0 = θ_ch1 + 90°)
```

Unlike rec46/48 (which must grind a bilinear transform per sample to sweep a
*second-order* section), a first-order allpass is parameterized by its one
coefficient — **the LFO output IS the filter coefficient**, no Newton
iterations needed. Per-stage 90°-points across the sweep:

| k | f₉₀ |
|---|---|
| 0.756 | 1.94 kHz |
| 0.876 | 926 Hz |
| 0.996 | 28 Hz |

— a wide, tangent-warped (musically spaced) sweep over ~6 octaves.

### 3.2 Five allpass stages per channel + feedback (`0x8425–0x8466`)

Per channel: input floated, plus **feedback = c008 × (last frame's cascade
output)** (`0x8426–0x8429`; the output is saved as raw float bits in the
param scratch — c003 for ch0 at `0x843F`, c002 for ch1 at `0x8460` — the
same one-frame-late idiom as rec09's flanger). Then **five §1 allpass cells**
(states c009–c00d ch0, c00f–c013 ch1; the old "5 ch0 / 6 ch1" sym note was a
miscount — both cascades are five stages), all sharing the channel's swept k.
Output: FIX, × wet (c00e, Q31 ≈ 1.0), **×2 makeup** (`R0 = R0+R0`,
`0x8442`), CLIP, write.

### 3.3 Where the notches come from

The record is **wet-only** — five allpasses have flat magnitude, so the
record's own output is (near-)transparent until it meets the dry path. These
are send-bus units: the TG mixer sums the dry channel with the DSP return at
the GUI depth (`kernel-architecture.md` §8), and the notch comb forms **at
that sum**: 5 stages sweep 0–900° of phase, giving up to **2–3 notches**
gliding over the 28 Hz–1.9 kHz range, quadrature between the channels (the
stereo "swirl"). Feedback c008 (template 0; a float written by the host)
sharpens the notches into notch+peak pairs — the classic resonant phaser.
(Notch placement at the external mix is architectural interpretation —
PROVISIONAL only in that the TG-side depth mix is modeled, not traced;
the phase math is ROM fact.) The GUI's Phaser **Deep/Normal/Shallow 1–13**
and **Dry/Wet 1–13** preset banks are DM/state edits over this one program:
depth, center, feedback, wet, LFO rates.

## 4. rec73 — DELAY+PHASER (type 0x44)

79 PM words (`rec73_effect_0x486CD6C3.asm`). The third "phaser/diffuser"
candidate resolves as the combi effect its GUI name says: **rec13's echo in
front of a 3-stage rec10-style phaser**, per channel.

- **Echo** (`0x8404–0x840C` ch0, `0x8432–0x8438` ch1): line input =
  `in + 0.6·fb` (c004/c012 = 0.6 float), delays **8000 samples (181.4 ms)**
  ch0 / **10000 (226.8 ms)** ch1 — exactly rec13's lengths and feedback, but
  run **in floating point with no damping filter** (the tap itself is saved
  to c003/c002 as next frame's feedback; `0x3C64` channel-arena stride as
  in rec13/15/74).
- **Phaser input mix** (`0x840D–0x8410`): `mix = 0.5·in + 0.5·tap`
  (c006/c007; ch1 c013/c014).
- **One mono LFO** (`0x8411–0x841E`): family idiom, phase c00a, increment PM
  `0x9800` (`0x800000` placeholder), depth c009 = 0.12, center c008 = 0.876
  — the same numbers as rec10 but a **single LFO shared by both channels**
  (no quadrature; the k control R5 is floated once per channel at
  `0x841F`/`0x843A` with exponent from c00b/c015 = −31, stored as DM
  constants).
- **Three §1 allpass cells** per channel (states c00d–c00f / c016–c018)
  with **cascade feedback 0.6** (c00c/… — `F12 = F3·F4` at `0x8420/0x843B`
  mixes 0.6 × last frame's cascade output, saved to c001/c000).
- **Internal dry/wet sum** (`0x842D–0x842F` / `0x8448–0x844A`): unlike
  rec10, rec73 mixes **inside the record**: `out = 0.5·mix + 0.5·phased`
  (c010/c011; c019/c01a) — the phaser input mix is parked in F6 (`R6 = R11`
  at `0x841C`/`0x843D`) and recombined, so real notches (up to 540° → 1–2)
  ride on the echo repeats regardless of the external depth. Output × wet
  (c005, Q31), **no CLIP stage** (unusual for the pool; float headroom +
  0.5/0.5 mix keep it bounded). The kernel epilogue cursor chores are folded
  inline (`MODIFY(I8,M13)` `0x8444`, `MODIFY(I12,M8)` `0x8445`,
  `MODIFY(I1,M5)` `0x844A`) instead of the standard RTS-delay-slot idiom.

Siblings rec71 (DELAY+FLANGER) and rec72 (DELAY+VIBRATO) are the same
recipe with different modulation back-ends (structural family; their detail
pass is still open).

## 5. rec47 — not a phaser: the fourth wah (type 0x90, GUI Wah1–8)

64 PM words (`rec47_effect_0x486C751B.asm`). The last "modulated-allpass
phaser" label falls: rec47 is the **rec46/48 computed-bilinear engine**
(shared `0x8417–0x842A`: coefficient construction from g and g², `RECIPS` +
three Newton–Raphson iterations, q = c00c = **0.125** → Q = 8, output tap
`w − w[n−2]` = bandpass) — but the sweep source is **not an LFO**. The
front-end (`0x8401–0x8413`, previously labeled "LFO_TriGen") is an
**envelope follower**:

- `env += k·(|(L+R)<<11| − env)` with attack **c004 = 1/256** (τ ≈ 5.8 ms)
  and release **c005 = 1/2048** (τ ≈ 46 ms) — the float twins of
  rec74/rec37's fixed-point constants; state in PM `0x9800`; the `IF LT`
  reload at `0x8408` selects the release rate.
- Envelope → tangent-domain control (`0x840C–0x8413`): e = env·2⁻³¹·**0.3**
  (c006), then `g = c007 + (c008 − e) = 0.014 + (0.3 − e)` while e ≤ 0.3,
  **floored at g = c007 = 0.014** when the envelope saturates (the `IF LT`
  branch). With f = (fs/π)·atan(g):

| level | g | resonance |
|---|---|---|
| silence | 0.314 | **4.27 kHz** |
| loud (env ≥ full) | 0.014 | **197 Hz** |

**The sweep runs downward**: playing harder *closes* the filter, and the
resonance re-opens toward 4.3 kHz as the note decays — the opposite law to
rec74's up-sweeping touch wah (the `<<11` input scaling makes the envelope
reach full scale around −18 dBFS, so the down-sweep uses most of the playing
range; the shift wraps for the loudest transient sums, which only pins the
envelope high — harmless in a level detector, but worth noting). Output:
mono `(L+R)/2` through the single Q=8 section, **×4 makeup** (c011), × wet
(c012, Q31), CLIP, same sample to both outputs. g is parked in two scratch
cells (c009/c00a, `0x8414–0x8415`) and re-read from the second — the write
to c009 is never read back (left-over symmetry or host telemetry;
PROVISIONAL).

So the pool's wah census reaches **four**: rec74 (envelope, up, resonator +
echo), rec48 (LFO, bilinear BP Q=8), rec46 (LFO, 10-pole LP sweep), rec47
(envelope, **down**, bilinear BP Q=8). The GUI's two wah banks split as
0x38 = rec28/29 (still undocumented) and 0x3A = this record.

## 6. rec12 — the GATE REVERB (type 0x08, REVERB-screen Gate presets)

69 PM words (`rec12_effect_0x486C035B.asm`). Corrects "dynamics/compressor +
delay/filter composite, conf low": rec12 is a **reverberator and a gate**,
and the Short/Medium/Long Gate presets on the REVERB screen are its DM/state
banks.

### 6.1 The reverb: a damped allpass ring (`0x8404–0x8421`)

Mono sum `(L+R)/2`, floated. The SDRAM cursor is parked at the top of the
insert arena (`MODIFY(I6, 0x7918)`, the rec51 idiom) and all lines walk down
with negative M7 taps; delay = write depth − read depth:

- **Loop feedback conditioning** (`0x8408–0x840C`): last frame's loop output
  (param scratch c003, saved at `0x8424`) passes a **unity-DC damping
  filter** `H = (0.5344 − 0.4012z⁻¹)/(1 − 0.8668z⁻¹)` (c004–c006; DC gain
  1.0000, Nyquist 0.50; state PM `0x9800`), is scaled by **c007 = −0.5**
  (the loop gain) and added to the input.
- **Three Schroeder allpasses in the loop**: AP1 delay **849** samples
  (19.3 ms; write depth 0x351, read depth 0 at `0x840E–0x8411`), AP2
  **1422** (32.2 ms; 0x8E0/0x352), AP3 **1498** (34.0 ms; 0xEBB/0x8E1).
  k₁ = k₂ = **0.6** — read from **PM state `0x9801`** (a coefficient in the
  state block, host-rewritable per preset); k₃ = **0.4** = c008, which also
  serves as a **mid-loop dry re-injection gain**: `0.4·in` is added between
  AP2 and AP3 (`0x8419–0x841A`), densifying the early build-up.
- The AP3 output **is the loop output** (saved to c003) → total loop length
  849+1422+1498+1 = **3770 samples = 85.5 ms**; per-pass gain 0.5 → **RT60 ≈
  0.85 s at DC**, ~0.43 s at Nyquist through the damp — a small, dense,
  darkening tail.
- **Output pair**: ch_a = the loop output itself; ch_b = the loop output
  through a fourth, out-of-loop allpass **AP4 = 2002 samples (45.4 ms),
  k = 0.4** (`0x841D–0x8421`, completed at `0x8428`) — cheap stereo
  decorrelation of a mono tank (cf. rec51's line-J trick).

### 6.2 The gate: threshold, attack, hold, release (`0x8422–0x8441`)

A fixed-point side-chain runs interleaved with the float tail math:

- **Detector**: `env += r·(|mono<<11⁺⁴| − env)` — rectified `(L+R)/2 << 15`,
  rates c009/c00a ≈ **0.48/0.49 per sample** (the MAC at `0x8427` is
  fixed-point, so the Q31 reading governs; the cells' bit patterns also
  decode as tidy floats 0.082/0.162, flagged PROVISIONAL as possible
  dual-use). τ ≈ 2 samples — the "envelope" is essentially the rectified
  signal; the gate's timing comes from the counter below. Threshold
  **c00c = 0.2** (Q31), ≈ **−56 dBFS** input-referred through the <<15
  scaling: the gate hears any signal at all. State PM `0x9802`.
- **The state machine** (`0x8429–0x843B`) is driven by a frame counter in
  **c00b** whose increment overflow (`R3 = R3+1` from `0x7FFFFFFF`, `IF AV`)
  selects between *counting* and *decide* paths — a data-driven branch:
  - **decide + loud** (env > thr): gain target cell **c00d ← −1.0**
    (0x80000000) and counter ← **PM `0x9804`** (template `0x7FFFFE00` →
    hold = **511 samples ≈ 11.6 ms**; the Short/Medium/Long presets rewrite
    this state word — the gate time is `0x7FFFFFFF − PM9804` samples).
  - **decide + quiet**: target c00d ← 0, and the counter is reloaded from
    **PM `0x9803`** (template gap 63) *unless* the target was already 0 —
    the `R7 = R4+R4; IF EQ` pair at `0x8433/0x8437`: doubling the −1.0
    target **saturates** (ALUSAT, kernel MODE1) to nonzero on the first
    quiet frame → 63-frame (1.4 ms) re-check lockout, then per-frame
    checks once fully releasing. Four instructions of chatter debounce
    that only work because the kernel turned saturation on.
  - **counting** (hold window): counter++ and the gain keeps slewing toward
    whatever c00d last was, ignoring the detector.
- **Gain slew** (`0x843A–0x843B`): `gain = target·PM9805 + gain·PM9806` =
  `0.001·target + 0.999·gain` — open: τ = 1000 samples = **22.7 ms attack**
  toward full scale (the target is −1.0, so the "open" gain settles at
  −1.0 — a polarity inversion, inaudible on a mono reverb tail; both outputs
  get the same sign); closed: ×0.999/sample = **−60 dB in 157 ms release**.
  Gain state c00e.
- **Application** (`0x843C–0x8444`): `R2 = gain × wet` (c00f, Q31);
  out₀ = AP4-output × R2, out₁ = loop-output × R2. No CLIP (like rec73).

The crucial gate-reverb property falls out of the topology: the gate sits
**outside the loop** — the tank keeps ringing while the output is shut, so a
re-trigger opens onto a still-decaying tail, and the hold counter (not the
80s-drum-sound envelope cliché of chopping the *input*) is what carves the
"gated" shape. Template numbers (hold 11.6 ms) are placeholders; the presets
rewrite PM `0x9803–0x9806` + the DM bank at select time (not recoverable
statically — the preset-descriptor parameter fields are the lead).

```
 (L+R)/2 ─┬──────────────0.4────────────┐
          ▼                             ▼
   in ──(+)── AP849 ── AP1422 ──(+)── AP1498 ──┬────────────→ ×gain·wet → out₁
          ▲   k=.6      k=.6           k=.4    │
          └── ×(−0.5) ── damp(DC1/Nyq.5) ──────┘   AP2002 ──→ ×gain·wet → out₀
                                                    k=.4
   |mono|→ env → [thr 0.2 → target ±: attack τ23ms / hold cnt / release ×.999] → gain
```

## 7. Comparison — five records, one design language

| | rec08 | rec10 | rec73 | rec47 | rec12 |
|---|---|---|---|---|---|
| identity | enhancer (phase tilt + Haas) | phaser | delay+phaser | touch wah (down) | gate reverb |
| §1 allpass cells | 4+4, k fixed .876 | 5+5, k swept | 3+3, k swept | — (bilinear BP) | — (Schroeder APs) |
| sweep source | — | 2 LFOs, 90° | 1 mono LFO | input envelope | — |
| sweep law | — | k=.876±.12 | k=.876±.12 | g=.314→.014 | — |
| feedback | none | c008 (templ. 0) | 0.6 echo + 0.6 cascade | — | −0.5 loop |
| delay | 800/0 (Haas) | — | 8000/10000 | — | APs 849/1422/1498/2002 |
| dry mix | internal (+dry) | at the TG send | internal 0.5/0.5 | wet-only | wet-only |
| stereo | Haas offset | quadrature LFOs | dual-mono echo | mono×2 | AP4 decorrelation |
| dynamics | — | — | — | env → filter | env → gate |

Recurring signatures: the **0.876 constant** shared by all three allpass
records (float in rec08, Q31 in rec10/73); the **1/256–1/2048
attack/release pair** appearing a fourth time (rec47, now in float); the
**unity-DC damping filter** (rec12's loop, same form as rec13/rec51); delay
state as raw float bits in DM/SDRAM (rec73's whole echo, rec10's feedback
scratch — the rec09 idiom); the **placeholder `0x800000` LFO increments**
rewritten by the host (rec10/73); and parameters that are *code* to the
host but *data* to the DSP (rec12's hold time hidden in a PM state word,
rec10's phaser feedback as a float the host writes into a "coefficient"
cell).

## 8. What this pass corrects and what remains

Corrected in `records.tsv` (this commit): rec08 "comb+allpass reverb" →
stereo enhancer (conf high); rec12 "dynamics/compressor + delay/filter
composite, conf low" → gate reverb (conf high); rec47 "modulated-allpass
phaser" → envelope-swept bandpass touch wah (conf high); rec10/rec73
confirmed as the pool's true phasers with full detail (conf high). Syms
rewritten for all five (rec10's "5/6 stages" → 5/5; rec47's "LFO_TriGen" →
envelope follower; rec08's "reverb tail" → no feedback exists).

Still undocumented at full depth after this pass: rec11 (0x06/0x0E
chorus), rec17–19 (waveshaper+distortion variants), rec20 (EXCITER),
rec21/25 + rec22 (compressor/limiter/slow attacker), rec23 (parametric EQ),
rec27 (VIBRATO), rec28/29 (the bank-0x38 wahs), rec32 (MIXUP), rec33
(SPREADER), rec34 (5-band EQ), rec38–40 (distortion detail), rec49/50
(choruses), rec57 (VOICE CHANGER), rec58–61 (mic reverbs), rec67–69 (BRASS
SIM), rec70/71/72 (chorus combis), rec75/76 (COMP+DST/OVD+DELAY).

> **Follow-up (2026-07-19, next pass)**: rec17–23, rec25, rec34 and
> rec38–40 are done — including rec20, which completes this document's §2
> story: the GUI **EXCITER** really does generate harmonics (waveshaper →
> unity-peak 3.56 kHz bandpass → added to dry), the exact nonlinear
> counterpart to the linear Enhancer decoded here. See
> [`dynamics-eq-exciter.md`](dynamics-eq-exciter.md).

## 9. Cross-model

KN6000/KN6500 DM banks are byte-identical for all 80 records: every constant
above (0.876 center, 0.12 depth, 0.6 feedbacks, the rec12 gate constants and
allpass k's, rec47's sweep law) carries over. The PM builds are older: the
delay immediates quoted here (0x320/0x3C8C, 0x1F40/0x2710, and rec12's four
M7 tap offsets 0x351/0x58E/0x5DA/0x7D2 + the 0x7918 arena park) must be
re-checked against the KN6xxx listings before porting labels.
