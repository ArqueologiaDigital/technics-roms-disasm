# The KN7000 SHARC chorus family — rec06 / rec07 / rec09 algorithm annotation

Static reverse-engineering of the three modulation-effect microprograms on the
unit-9 "Reverb" whitelist (2026-07-19). Everything below is read off the
committed listings in `../disasm/dsp/` (PM addresses quoted throughout).
These are the records the reverb annotation (`reverb-algorithm.md` §6) exposed
as *not* reverbs — this document gives them the same full treatment the
rec51–56 reverb engine received.

**Headline: rec06, rec07 and rec09 are three modulated-delay effects built
from one shared design language** — a table-interpolated sine LFO, fractional
delay-line taps with linear interpolation, wet-only output, and the kernel's
small *internal* DM delay ring (never the SDRAM reverb arena):

- **rec06** (types 0x01, 0x2C): single-LFO **quadrature two-voice ensemble
  chorus** — each channel averages two taps modulated 90° apart; right channel
  antiphase. No feedback.
- **rec07** (types 0x02, 0x07, 0x2D): the same engine plus a **second LFO
  cross-mixed at 0.15** into both modulators — a dual-rate ensemble chorus.
  No feedback.
- **rec09** (types 0x04, 0x0B): one tap per channel with **0.70 floating-point
  regeneration** and independent per-channel LFOs 90° apart — a stereo
  resonant **flanger**.

Sample rate: nominal fs = 44100 Hz (one kernel IRQ0 = one sample frame), as
established for the reverb. Record DM/PM blocks are stored in unit-0 form
(PM `0x8400`, params `0xC004`, state `0x9800`); the host rebases per slot.

Two corrections to previously committed annotation fall out of this pass:

1. **rec09's two LFO phase templates are 90° apart, not 45°** — `c005 =
   0x20000000` is 4 of the 16 table steps under the 2^31 phase wrap
   (`0x20000000 >> 27 = 4`, and 16 steps/cycle), i.e. quadrature.
2. **The kernel enables ALU saturation**: the reset write `BIT SET MODE1
   0x3000` (kernel PM `0x8074`) is IRPTEN (bit 12) + **ALUSAT** (bit 13,
   `0x2000` per the ADSP-2106x TRM), previously misread as NESTM (bit 11 =
   `0x800`). This matters below: rec07's modulator *sum* saturates cleanly at
   ±1.0 instead of wrapping.

## 1. The shared design language

Execution context is the kernel contract documented in `reverb-algorithm.md`
§1: per-frame CALL; `I1` = param block (`0xC004 + slot*0x4D`), `I8` = state
block (`0x9800 + slot*0x50`, PM bus), `I4` = I/O cursor with input at
`DM(I4+0x20)`/`DM(I4+0x21)` and output = two `DM(I4,M2)` writes leaving I4
advanced by 2. What is specific to this family:

### 1.1 The internal delay ring and its per-slot arenas

None of the three records touches the SDRAM `I6` arena. All delay state lives
in the kernel's **internal DM ring `B2=0xC3A0, L2=0x1C60`** (7,264 words).
The mainloop's CALL delay slots partition it: the first call slot enters with
the ring base, the second after `MODIFY(I2, 0x45F)` (kernel PM `0x8085`), and
each subsequent delay-capable slot after `MODIFY(I2, 0x400)` (`0x8088`,
`0x808B`, `0x808E`, `0x8091`, `0x8095`, `0x80A1`). The advances sum to
`0x1C5F = L2−1 ≡ −1 (mod L2)`, so the ring **scrolls one word per sample**
and a read at (write address + D) returns the value written D samples
earlier. Practical grant: **0x400 = 1024 words = 23.2 ms** per slot (1119 for
the first). Unlike the reverb (which parks the cursor at the arena *top* and
walks down with negative offsets), this family walks *up* from the entry
cursor P with positive offsets — the delay convention is the same either way.

### 1.2 The LFO idiom

All LFOs in the family are one code shape (quoting rec06):

- **Accumulate** (`0x8403–0x8406`): `phase(c004) += incr` where the increment
  is a **host-writable state word** (`PM(I8)` = `0x9800+`); then
  `R8 = FDEP R8 BY 0:31 (SE)` (`0x8405`) wraps the phase to 31 bits →
  **one LFO cycle = 2^31 counts**, so `f = fs · incr / 2^31`.
- **Index** (`0x8408–0x840B`): `ASHIFT −11` then `ASHIFT −16` → table index =
  phase >> 27, i.e. **16 steps per cycle**, signed −8..+7 about the table
  center `c030`.
- **Interpolate** (`0x840C–0x8410`): frac = `FDEP (phase>>11) BY 15:16`
  (the 16 bits below the index); a dummy `DM(I5,M7)` walks I5 to `c030+i`;
  then `MR1F = s[i]`, `MRF += s[i+1]·frac`, `result = MRF − frac·s[i]`
  = `s[i] + frac·(s[i+1]−s[i])` — fixed-point linear interpolation.
- **Quadrature read**: `MODIFY(I5, 4)` (rec06 `0x8412`) re-reads the table 4
  steps = **+90°** ahead for a second modulator from the same phase.

The phase accumulator lives in the *param* block (c004/c005/c006 — the same
`I1` region the host edits), the increment in the *state* block. Neither the
31-bit wrap nor ALUSAT collide: |phase| ≤ 2^30 plus a ≤2^23 increment never
overflows 32 bits, so saturation never fires on the accumulate.

### 1.3 The waveform slot — host-swappable LFO shapes

The sine table is baked into each record's DM block at `c029..c03f`: a
16-entry cycle (`c029..c038`, peaks ±1.0 at `c02c`/`c034`) plus a
positive-half guard (`c039..c03f`) so the +4 quadrature read and the `i+1`
interpolation read never need wrap logic (maximum reach = `c03C`; the i=−8
read lands on `c028`, whose template 0 equals sin(±180°)). The table is
stored **angle-negated** (entry i of the cycle = sin(−i·22.5°), so the LFO
output is −sin(phase) — immaterial for a symmetric LFO).

Crucially, this span is exactly the target of the pool's three **DM-only data
records**: rec77/78/79 download 25 words to `DM 0xC028` = **sine / triangle /
square** (rec77 is bit-identical to the baked table). The host can therefore
**reshape every LFO in this family live**, without reloading the effect.

### 1.4 The fractional-tap idiom

Every delay read is the same five-step shape (quoting rec06's first voice,
`0x841C–0x8423`):

1. `R8 = mod × depth` — Q31 fractional multiply; the product is then treated
   as a **16.16 sample offset**, so the swing in samples = `depth >> 16`
   (template depth `0x00400000` → **±64 samples**).
2. int part: `ASHIFT −16` → `M7` → `MODIFY(I2, M7)` (floor semantics for
   negative offsets — frac stays in [0,1), so the interpolation is seamless
   through zero).
3. frac part: `FDEP R8 BY 15:16` → Q31 fraction.
4. read `d[i] = DM(I2,M2)` (advance +1), `d[i+1] = DM(I2,M3)` (back −1).
5. lerp `d[i] + frac·(d[i+1]−d[i])`: rec06/07 via the MAC (`R7 = R4 − R7`
   then `MRF + frac·R7`, e.g. `0x8422–0x8423`); rec09 does the same in
   **floating point** (`0x842E–0x8430`).

### 1.5 Output convention

All three are **wet-only**: no dry term ever reaches the output sum (dry is
mixed outside the DSP by the send/return architecture). Net wet gain is
unity by construction: rec06/07 average the two voices (`(R8+R9)/2`,
`0x842F`), multiply by wet (template `0x7FFFFFFF` ≈ 1.0), then ×2 makeup
(`0x8431`); rec09 multiplies the single tap by Q31 0.5 (`c009 = 0x40000000`)
then ×2. Every channel ends in `CLIP ±0x7FFFFF` (24-bit rails) before the
`DM(I4,M2)` write — first write = the L-input-derived channel at I4+0, second
= R at I4+1. The epilogue is the standard `RTS(DB)` + `DM(I1,M5)` (I1 +=
0x4D) + `MODIFY(I8, 0x50−n)` where n = the record's PM(I8) increment reads.

## 2. rec06 — quadrature two-voice ensemble chorus (types 0x01, 0x2C)

82 PM words at `0x8400–0x8451` (`rec06_effect_0x486BEBE5.asm`).

- **LFO**: one phase (c004, incr state `0x9800`); modulator A = sine(phase)
  (`0x8410`), modulator B = sine(phase+90°) via the table +4 read
  (`0x8412–0x8417`).
- **Left channel**: write in_L at P (`0x841A`, post-modify `M7=0xFA` → read
  base **P+250**); voice 1 = fractional tap at **P+250+64·B**
  (`0x841C–0x8423`), voice 2 at **P+250+64·A** (`0x8424–0x842C`); output =
  (v1+v2)/2 × wet × 2 (`0x842F–0x8431`), CLIP, write (`0x8434`).
- **Right channel**: `MODIFY(I2, 0xF0)` (`0x842E`) sets the R write base
  **P+490**; write in_R there (`0x8436`, again +0xFA → read base **P+740**);
  voices at **P+740−64·B / −64·A** — the `MRF −(R6*R10)` / `MRF −(R5*R10)`
  forms (`0x8438`, `0x8441`) **negate both modulators**. Mix as L
  (`0x8449–0x844B`), restore I2 (`0x844A`), write (`0x844E`).

**Delay arithmetic**: R's read base P+740 minus its write P+490 = the same
**250-sample center** as L. Both channels sweep 186..314 samples =
**4.22–7.12 ms about a 5.67 ms center** (±64 samples = ±1.45 ms). Deepest
read = P+805 → 806-word footprint, comfortably inside the 1024-word grant.
The two write heads never collide with the other channel's reads (L reads ≤
P+315 < 490; R reads ≥ P+676 > any aged L-write alias).

**Character**: the two voices per channel sit in quadrature, so when one
voice's pitch deviation is maximal the other's is zero — averaging them gives
the constant-shimmer, beat-free doubling of a classic **ensemble/celeste**
circuit (the two-phase analog BBD ensemble topology, digitized). The R
channel's negated modulators make the image wide: L sharpens while R
flattens. No feedback, no dry, no tail-capable loop anywhere.

## 3. rec07 — dual-LFO ensemble chorus (types 0x02, 0x07, 0x2D)

91 PM words at `0x8400–0x845A` (`rec07_effect_0x486BEF87.asm`).

Identical delay engine to rec06 (same 250-sample centers at the same PM
shapes: L write `0x8422`, R base `MODIFY(I2,0xF0)` at `0x8436`, R write
`0x843F`, negated R modulators `0x8441`/`0x844A`) — the difference is the
modulator source:

- **LFO A** (phase c004, incr `0x9800`, template `0x00055000` = **7.15 Hz**):
  computed first (`0x8401–0x840C`), then scaled: `R9 = sineA × c005`
  (`0x840D`) with **c005 = 0x13333333 = 0.15**.
- **LFO B** (phase c006, incr `0x9801`, template fs/256): quadrature pair
  read as in rec06 (`0x8410–0x841D`).
- **Modulators** (`0x841A`, `0x841E`): `modA = sineB + 0.15·sineA`,
  `modB = sineB(+90°) + 0.15·sineA` — the second LFO **wobbles both
  quadrature taps together**.

**Correction (already in the syms, restated here)**: c005 is the slow-LFO
**cross-mix gain, not feedback** — the only DM writes in the whole program
are the two delay-line writes and the two phase stores; nothing recirculates.

**ALUSAT refinement (new)**: the modulator adds can reach ±1.15, but with
MODE1 ALUSAT set (kernel `0x8074`) the ALU **saturates at ±1.0**, so the tap
swing stays **±64 samples** with the modulation waveform's peaks flattened
(brief dwell at the extremes) rather than the ±73.6-sample swing a wrap-free
read of the math would suggest. The earlier "±73" note is corrected in
`sym/rec07.sym`.

**Character**: a two-rate modulator makes the voice trajectories
quasi-periodic instead of cyclic — a richer, less "rotary" ensemble. With
the template rates (slow 7.15 Hz at 0.15 depth ≈ ±9.6 samples ≈ 17-cent
vibrato shimmer) the slow component is exactly a vibrato-rate detune riding
on the main chorus sweep.

## 4. rec09 — stereo resonant flanger (types 0x04, 0x0B)

85 PM words at `0x8400–0x8454` (`rec09_effect_0x486BF745.asm`).

- **Two independent LFOs**, one per channel: LFO0 (phase c004, incr `0x9800`)
  → sine0 = the **right** modulator (`0x840F`, used at `0x8442`); LFO1
  (phase c005, incr `0x9801`) → sine1 = the **left** modulator (`0x8419+`,
  used at `0x8428`). Template increments are equal and the phase templates
  sit **90° apart** (`c005 = 0x20000000` = 4 table steps — corrected from
  the earlier 45° reading).
- **Left channel** (`0x841E–0x8439`): input is **converted to float**
  (`0x841F`); feedback state = previous L tap, kept as float bits in param
  `c003` read via `DM(I1−1)` (`0x8420`); `F4 = F4 × 0.70` (**c006 =
  0x3F333333, IEEE 0.70**) and `F0 = in + F4` (`0x8422–0x8423`); the sum's
  **float bit pattern is written to the delay line** (`0x8424–0x8425`,
  post-modify `M7=0x12C` → read base **P+300**); one fractional tap at
  **P+300+64·sine1** (depth c007, `0x8428–0x842C`) with the frac converted
  by `FLOAT R3 BY −31` (c008, `0x842D`) and a **float lerp**
  (`0x842E–0x8430`); the tap is simultaneously **saved as next frame's
  feedback** (`DM(I1−1)`, `0x8431`) and sent to the output: `FIX`, × c009
  (Q31 0.5), ×2, CLIP, write (`0x8434–0x8439`).
- **Right channel** (`0x843A–0x8451`): the same engine with base **P+500**
  (`MODIFY(I2, 0xC8)` at `0x8433`), write at P+500 → read base **P+800** (=
  300-sample center again), feedback state `c002` via `DM(I1−2)`
  (`0x843C`/`0x844B`), gain `c00A`, modulated by sine0 (`0x8442`) — **not
  negated**; stereo decorrelation comes from the 90° LFO offset instead.

**The loop**: `w[n] = in[n] + 0.70·y[n−1]`, `y[n] = lerp-tap of w at
D(n) = 300 + 64·sine`, so the recirculation period is **D+1 samples**
(the feedback uses the *previous* frame's tap). Template numbers: comb
resonances spaced fs/301 ≈ **146 Hz**, sweeping ≈ 121–187 Hz as D sweeps
236..364 samples (5.35–8.25 ms); regeneration 0.70 → peak resonance
1/(1−0.7) = ×3.33 ≈ **+10.5 dB**. Longest loop ≈ 8 ms — tail-incapable,
as reported in `reverb-algorithm.md` §6.

**Why float?** The delay line stores raw float bit patterns and the entire
recirculating path (inject, lerp, feedback save) is floating-point —
sidestepping fixed-point limit cycles and quantization buildup in a 0.7-regen
loop. (The freshly zeroed ring is benign: 0x00000000 bits = +0.0.) The wet
scale is applied only after `FIX`, outside the loop. Deepest read = P+865 →
866-word footprint, inside the 1024-word grant.

**Character**: a 6.8 ms center is deep for a textbook flanger (0.1–5 ms) —
with 0.70 regeneration this reads as a **resonant flanger voiced toward
chorus depth**, matching its whitelist adjacency to the two ensembles.

## 5. Comparison table

| | rec06 | rec07 | rec09 |
|---|---|---|---|
| types (→record map) | 0x01, 0x2C | 0x02, 0x07, 0x2D | 0x04, 0x0B |
| PM words | 82 (`0x8400–0x8451`) | 91 (`–0x845A`) | 85 (`–0x8454`) |
| LFOs | 1 sine + quadrature read | 2 sines; 0.15 cross-mix + quadrature read | 2 independent sines, 90° apart (template) |
| voices per channel | 2, averaged | 2, averaged | 1 |
| delay center | 250 smp = 5.67 ms | 250 smp | 300 smp = 6.80 ms |
| tap swing (template) | ±64 smp | ±64 smp (sum ALUSAT-clipped) | ±64 smp |
| feedback | none | none | 0.70 float, per channel |
| stereo strategy | negated modulators (antiphase) | negated modulators | independent LFOs, 90° offset |
| tap arithmetic | fixed-point MAC lerp | fixed-point MAC lerp | float lerp, float line |
| wet path | (v1+v2)/2 ×1.0 ×2 | same | tap ×0.5 ×2 |
| ring footprint | 806 words | 806 words | 866 words |
| identity | quadrature ensemble/celeste chorus | dual-rate ensemble chorus | stereo resonant flanger |

Shared by all three: internal-DM I2 ring only (no SDRAM), the c028–c040
host-swappable LFO waveform slot, 16-step interpolated sine, 16.16 fractional
taps, wet-only unity output, CLIP ±0x7FFFFF, no tail-capable structure.

## 6. LFO rates, depths, and the fs/256 template question

Rate derivation (from §1.2, exact): **f = fs · incr / 2^31**. Template
increments:

| word | value | f @44.1 kHz | comment |
|---|---|---|---|
| rec06 `0x9800` | 0x00800000 | 172.3 Hz (= fs/256) | audio-rate — see below |
| rec07 `0x9800` | 0x00055000 | 7.15 Hz | plausible as-shipped (vibrato-rate) |
| rec07 `0x9801` | 0x00800000 | 172.3 Hz | audio-rate |
| rec09 `0x9800/1` | 0x00800000 | 172.3 Hz | audio-rate |

Depth in musical terms: peak pitch deviation of a swept tap =
2π·f·A/fs (A = swing in samples). At A = 64 and a typical chorus rate of
0.5–1 Hz that is **8–16 cents** — textbook chorus depth. At the fs/256
template rate the same formula gives **±157%** — an audio-rate FM well past
any usable chorus. So either the `0x800000` templates are placeholders the
host rewrites at select time, or the shipped defaults would ring-modulate.
Since (a) the increments live in the per-unit state block the host is known
to rewrite on effect select (live upload captures, `reverb-algorithm.md`
§6), and (b) rec07 ships one *sensible* rate (7.15 Hz) in the same block,
the placeholder reading is near-certain — but the actual per-preset rates
are **not statically pinned; PROVISIONAL** until a live capture of a chorus
select logs the rewritten state words.

Waveform: sine by default; host-swappable to triangle or square for the
whole family via data records rec78/rec79 targeting `DM 0xC028` (§1.3).

## 7. Which GUI effects are these? (provisional)

Hard facts first: unit 9's whitelist (`0x486CE9CD`) admits types
0x00/0x01/0x02/0x04/0x40/0x52; the ROM type→record master table maps
0x01→rec06, 0x02→rec07, 0x04→rec09 **and** the alias types 0x2C→rec06,
0x2D→rec07, 0x07→rec07, 0x0B→rec09, which sit in the **units-1–6
(Multi/Sound-DSP insert) whitelist**. The GUI's Sound-DSP list (recipes
capture) contains, among others: *Celeste 1–8*, *Mod. Cel. 1–8*, *Flanger
Deep 1–8*, *Flanger Wet 1–8*; the GUI CHORUS unit (unit 7) is a different
engine entirely (rec58–61, allpass diffusion).

Provisional readings (structure + naming + type adjacency, no dynamic
confirmation):

- **rec06 ↔ the Celeste class**: a wet-only quadrature two-voice ensemble is
  precisely the classic "celeste" topology, and its insert alias 0x2C sits
  next to…
- **rec07 ↔ the Mod. Celeste class**: alias 0x2D — the adjacent GUI group
  whose name ("modulated celeste") describes exactly rec06-plus-an-extra-LFO.
- **rec09 ↔ the Flanger class** (alias 0x0B): the only regenerative
  modulated delay of the three; whether it serves *Flanger* (Deep) or
  *FlangerDryWet* (Wet) presets — or both via DM banks — is not pinned.
- **The unit-9 role**: with 4–5 usable types (rec06/07/09 + rec70 ensemble +
  rec49 chorus) and no tail-capable program, unit 9 looks like a
  **chorus/ensemble send unit** (plausibly the GM two-bus send chorus — GM
  Chorus 1–4 in the GUI — or an APC "space" unit), not the audible REVERB
  screen, which lives on the rec51–56 family. The decisive experiment is
  unchanged from `reverb-algorithm.md` §7: breakpoint `DspEffectSelect`
  (`0x48405815`) while switching these GUI groups and log (unit, type).

All four bullets are **PROVISIONAL**; the whitelist membership and the
type→record map are the facts.

> **UPGRADE (2026-07-19)**: the firmware's GUI preset-descriptor table
> (`tremolo-rotary-family.md` §1) settles the names as ROM fact:
> **Celeste1–13 = type 0x2C = rec06** and **Mod. Cel.1–13 = 0x2D = rec07**
> (bullets 1–2 confirmed); the Sound-DSP **Flanger** groups
> (Deep/Normal/Shallow 1–13 = 0x04, Dry/Wet 1–13 = 0x0B) are **rec09**
> (bullet 3 confirmed, both preset families on one record); and on the
> CHORUS screen **GM Chorus1/3 = 0x01 = rec06, GM Chorus2/4 = 0x02 =
> rec07, Chorus1–4 = 0x52 = rec49, Feedback Chorus = 0x40 = rec70,
> Flanger = 0x04 = rec09** — supporting bullet 4's chorus/ensemble-send
> reading of unit 9.

> **UPGRADE 2 (2026-07-19, group-table walk)**: the GUI *group* table is now
> fully decoded (`modulation-pitch-family.md` §1). It adds: the Sound-DSP
> **Chorus** group (Deep/Normal/Shallow 1–13, type 0x01) is **rec06** as well
> — rec06 serves both Chorus and Celeste; the **Modulated Chorus** group
> (0x02) + its D/W list (0x07) are **rec07**; the Flanger D/W list (0x0B) is
> **rec09**. The §6 rate question is unchanged (0x01's 39 presets are host
> rewrites over the same record).

## 8. Cross-model note

Per the pool diff (`cross-model/`), the KN6000/KN6500 DM blocks are
byte-identical for all 80 records — every template coefficient above
(rates, 0.15 cross-mix, 0.70 regen, depths, wet levels, the waveform tables)
carries over. Their PM is an older build: re-derive the delay immediates
(0xFA/0xF0/0x12C/0xC8) from the KN6xxx listings before porting these labels.
