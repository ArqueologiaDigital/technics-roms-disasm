# KN7000 effects-DSP (IC306, ADSP-21065L "SHARC") program tree

This directory holds the reverse-engineered programs that run on the KN7000's
**effects DSP** — IC306, an Analog Devices **ADSP-21065L** (part marking
`S21065LKS240`), a 2106x-family SHARC. The DSP has no boot ROM on its own bus:
the MN10300 main CPU **host-boots** it by streaming programs through the host
port (index register `0x98000000`, data register `0x9C000000`).

Those programs are **embedded in the dumped MN10300 program flash**, as a pool
of 80 download records at CPU `0x486BCEC4..0x486CE68D` (file offset
`0x2BCEC4..0x2CE68D`, 71,625 bytes). This tree extracts, disassembles, and
documents them. Nothing here needs the physical DSP or any undumped ROM — the
whole effects program set was recovered from firmware.

## What's here

| Path | Committed? | Contents |
|---|---|---|
| `README.md` | yes | this file |
| `records.tsv` | yes | hand-curated manifest: role + name + one-line note per record |
| `kernel-architecture.md` | yes | the definitive doc of the resident kernel (rec04): host-boot protocol (= 21065L IOP registers), vector table, the 10-slot per-sample dispatch chain, the eight self-chaining SPORT DMA rings, the scrolling delay-arena windows, BUSLK coefficient-update window, scrub stubs |
| `reverb-algorithm.md` | yes | full algorithm annotation of the reverb engine (rec51–56 family) + the unit-9 records |
| `chorus-family-algorithms.md` | yes | full algorithm annotation of the unit-9 chorus family: rec06 (quadrature ensemble), rec07 (dual-LFO ensemble), rec09 (stereo flanger) |
| `insert-effects-algorithms.md` | yes | full algorithm annotation of the Multi/Sound-DSP insert families: rec74 (touch wah), rec46/48 (computed-bilinear swept filters / LFO wah), rec62–65 (cubic overdrive, 4 tone banks), rec37 (table waveshaper + AGC), rec13/14/15 (echo family incl. the cross-feedback ping-pong) |
| `tremolo-rotary-family.md` | yes | the AM family (rec24 tremolo / rec26 auto-pan / rec31 ring modulator), the **ROTARY SPEAKER simulator** (rec30 = 35 = 36 = 41–45 + rec16: crossover, dual magic-circle rotors with 93 ms rate glide, Doppler taps), rec66 vocal harmonizer — plus the decoded **GUI preset-descriptor table** (600 ROM descriptors pinning GUI name → effect type for every effect screen) |
| `phaser-enhancer-gate.md` | yes | rec08 = the GUI **ENHANCER** (phase rotator + low/high emphasis + Haas offset — no exciter nonlinearity), the **true phasers** rec10 (5+5 swept allpasses, quadrature LFOs) and rec73 (DELAY+PHASER combi), rec47 re-identified as a fourth **touch wah** (down-sweeping bilinear bandpass), and rec12 = the **GATE REVERB** (damped allpass-ring tank + hold-gate with ALUSAT-dependent debounce) |
| `modulation-pitch-family.md` | yes | the modulation/pitch cluster **and the fully decoded GUI group table** (24-byte `{count, name, ptr}` entries — closes GUI name → type → record for the whole inventory): rec11 = the GUI **ENSEMBLE** (hexaphase 3-voice chorus, taps 67.5° apart), rec27 = **VIBRATO** (wet-only, no dry, mono), rec28 = **AUTO WAH** / rec29 = **PEDAL WAH** (same swept resonator; rec29's audio detector is dead code — it tracks a host-written pedal cell), rec32 = **MIXUP** (burst vibrato: sin·sin product modulators), rec33 = **SPREADER** (decorrelation micro-FIRs + 349 Hz bell + antiphase mono Haas echoes; menu group "Space"), rec49/rec50 = the **triangle-trio chorus** engine (overflow-reflect triangle LFOs + magic-circle sine; rec50 = GUI **Trio Chorus**), rec57 = **VOICE CHANGER** (dual-saw granular detune with exact equal-gain crossfade) |
| `dynamics-eq-exciter.md` | yes | the tone-shaping cluster: rec20 = the real **HARMONIC EXCITER** (waveshaper → unity-peak 3.56 kHz product selector → added to dry), rec21/25 = the **COMPRESSOR/LIMITER** (closed-form reciprocal gain law 1/3+1/(6e), Newton-refined, curve-meets-clamp continuity), rec22 = the **SLOW ATTACKER** (two-target gain machine, 743 ms swell / 2.9 ms reset), rec23 + rec34 = the **EQs** (mirror-flat 5-section cascades with pre-placed bands; rec34 wraps kernel helper `0x831B` = the EQ cascade, and its I/O convention settles the u8 master-insert question), and the **distortion-variant map** (rec17/18/19/38/39/40 diffed against rec37: two engines, three transfer curves, per-preset level/Haas/biquad voicings) |
| `final-batch-algorithms.md` | yes | the closing pass — **completes the pool**: rec58–61 = the **unit-7 MIC REVERBS** (Room/Karaoke/Stage/Cave — a third reverb architecture: series-allpass tank run at **half sample rate**, phase-split across the FLAG3 fs/2 parity strobe on the exclusive I3 ring; resolves the kernel's FLAG3 + {u6,u7}-window questions), rec67–69 = the **BRASS SIMULATORs** (a physical-modeling cluster: nonlinear "lip" ODE, rec67's pitch tracker + period-locked grains, rec69's 512-sample bore waveguide), rec70/71/72 = the **delay+modulation combis** (float echo → rec06-chorus / rec09-flanger / rec27-vibrato back ends), rec75/76 = **COMP+DST/OVD+DELAY** (family AGC as the "COMP" → float-LUT curves A/B → echo; the engine-A/B distortion split done purely in data) |
| `sym/recNN.sym` | yes | hand-curated SHARC labels/comments per record (`pm:`/`dm:` addrs) |
| `../disasm/dsp/*.asm` | yes | generated **and tracked** listings (index + one per record) |
| `../build/dsp/*.bin` | no (git-ignored) | raw per-block extracts, regenerable |

Generated by [`../tools/gen_dsp_records.py`](../tools/gen_dsp_records.py); rebuild
with `make disasm-dsp` from the repo root. The generator is deterministic, so
`make disasm-dsp && git diff --exit-code disasm/dsp` is a drift check. It reads
`records.tsv` and `sym/*.sym` and merges them into the listings, so regenerating
never loses annotation — put analysis in those two places, never in the `.asm`.

## Record / block format

Each record is a run of blocks ended by a 12-byte zero terminator. A block is:

```
u16 id = 0x2004 (big-endian)   u8 mode (0x80=PM, 0x00=DM)   u8 flag (0xFF on last block)
u16 A(=0)   u16 target (word address in DSP memory)   u16 C(=0)   u16 len (bytes)   payload[len]
```

- **PM** (program memory) payload = 6 bytes per 48-bit SHARC instruction word:
  three big-endian u16, most-significant first. Repacked as `w0<<32|w1<<16|w2`
  into little-endian 8-byte slots for `unidasm -arch sharc`. This MSW-first
  packing is verified — it reproduces the ADSP-2106x reset/interrupt vector
  table (`IDLE` at 0x8004, `JUMP` at 0x8005, RTI-filled vectors).
- **DM** (data memory) payload = 5 bytes per entry (a 40-bit SHARC data word).
  Emitted as an annotated data table.

## Record roles (see `records.tsv` / `../disasm/dsp/index.asm` for the full list)

- **kernel** (rec 04): the resident SHARC kernel — reset/IRQ vectors at PM
  `0x8000`, plus PM `0x8300`/`0x8400`/`0x8D00` and the DM tables. Downloaded
  once at boot; all effect microprograms load *on top of it* at PM
  `0x8400+unit*0x100` (slot 9 recycles the boot-init block at `0x8D00`).
  Fully documented in [`kernel-architecture.md`](kernel-architecture.md).
- **probe** (rec 00–03): four near-identical board-variant probe records tried
  in turn at boot (host reg `0x0B` ID readback) until one matches.
- **effect** (rec 05–76): the per-effect microprograms — reverb, chorus, multi,
  and Sound-DSP algorithms. Structurally grouped into families (records with the
  same block signature are variants of one effect group).
- **data** (rec 77–79): DM-only records (parameter/coefficient updates, no code).

## Full coverage: the complete effect inventory (2026-07-19)

With `final-batch-algorithms.md` the documentation pass over the pool is
**complete: every record — kernel, probes, all 72 effect programs, and the
data records — has a full algorithm identification.** The map (doc column =
the deep annotation; `records.tsv` carries the one-line summaries):

| rec | GUI / role (ROM fact unless noted) | engine | doc |
|---|---|---|---|
| 00–03 | boot probes | SDRAM POST self-tests | `kernel-architecture.md` §1 |
| 04 | resident kernel | 10-slot dispatcher, 8 SPORT DMA rings, 3 delay arenas, BUSLK window | `kernel-architecture.md` |
| 05 | effect-off stub | mute (two zero writes) | `kernel-architecture.md` §5 |
| 06 | Chorus / Celeste / GM Chorus1/3 | quadrature 2-voice ensemble chorus | `chorus-family-algorithms.md` §2 |
| 07 | Modulated Chorus / Mod. Celeste / GM Chorus2/4 | dual-rate ensemble chorus | `chorus-family-algorithms.md` §3 |
| 08 | Enhancer1–6 | phase rotator + low/high emphasis + Haas offset (linear) | `phaser-enhancer-gate.md` §2 |
| 09 | Flanger (+ D/W) | stereo resonant flanger, 0.70 float regen | `chorus-family-algorithms.md` §4 |
| 10 | Phaser (+ D/W) | true phaser: 5+5 swept allpasses, quadrature LFOs | `phaser-enhancer-gate.md` §3 |
| 11 | Ensemble (+ D/W) | hexaphase 3-voice chorus (taps 67.5° apart) | `modulation-pitch-family.md` §2 |
| 12 | Reverb group: Medium/Short/Long Gate | GATE REVERB: damped allpass ring + hold-gate | `phaser-enhancer-gate.md` §6 |
| 13 | Dual Delay | dual-mono damped echo 181/227 ms | `insert-effects-algorithms.md` §5 |
| 14 | Multi Tap Delay | 4-tap panning echo | `insert-effects-algorithms.md` §5 |
| 15 | Cross Delay | cross-feedback ping-pong echo | `insert-effects-algorithms.md` §5 |
| 16 | Rock Rotary (Standard trio) | rotary speaker (rec30 engine, 1-word variant) | `tremolo-rotary-family.md` §4 |
| 17 | Distortion (Normal/Mild/Hard/H.C.) | AGC waveshaper, curve A, no tone filter | `dynamics-eq-exciter.md` §6.3 |
| 18 | Overdrive (Normal/Mild/Hard/H.C.) | AGC waveshaper, curve B + smoother + LP | `dynamics-eq-exciter.md` §6.4 |
| 19 | Fuzz | AGC waveshaper, rail curve C, quiet-gate | `dynamics-eq-exciter.md` §6.1 |
| 20 | Exciter1–3 | harmonic exciter: LUT → unity-peak 3.56 kHz BP → +dry | `dynamics-eq-exciter.md` §1 |
| 21 | Compressor (Comp.1–4) | closed-form reciprocal gain law (Newton) | `dynamics-eq-exciter.md` §2 |
| 22 | Slow Attacker1–4 | two-target gain machine, 743 ms swell | `dynamics-eq-exciter.md` §3 |
| 23 | Parametric EQ (8 presets) | mirror-flat 5-section cascade | `dynamics-eq-exciter.md` §4 |
| 24 | Tremolo1–8 | in-phase LFO AM (rec26 + 1 word) | `tremolo-rotary-family.md` §2 |
| 25 | Limiter1–4 | = rec21 PM, Limiter banks | `dynamics-eq-exciter.md` §2 |
| 26 | Auto Pan1–7 | quadrature LFO AM panner | `tremolo-rotary-family.md` §2 |
| 27 | Vibrato1–8 | wet-only modulated delay (no dry) | `modulation-pitch-family.md` §3 |
| 28 | Auto Wah (Wah1–5) | envelope-swept resonator (rec74's law) | `modulation-pitch-family.md` §4 |
| 29 | Pedal Wah (Wah1–3) | host-cell-swept resonator (dead detector) | `modulation-pitch-family.md` §4.3 |
| 30, 35, 36, 41–45 | Rotary Speaker / Rock Rotary Twins | full Leslie sim: crossover + 2 gliding rotors + Doppler taps | `tremolo-rotary-family.md` §4 |
| 31 | Ring Mod.1–4 | bipolar quadrature AM, audio-rate carrier | `tremolo-rotary-family.md` §3 |
| 32 | Mixup1–4 | burst vibrato (sin·sin product modulators) | `modulation-pitch-family.md` §5 |
| 33 | Spreader (group "Space") | decorrelation FIRs + 349 Hz bell + antiphase Haas | `modulation-pitch-family.md` §6 |
| 34 | unit-8 EQUALIZER | 5-band wrapper around kernel helper `0x831B` | `dynamics-eq-exciter.md` §5 |
| 37 | Distortion "Bright" | curve-A LUT + AGC + presence biquad + Haas | `insert-effects-algorithms.md` §4 |
| 38–40 | Distortion/Overdrive "Fat"/"Bright" | voicing deltas over rec37/rec18 | `dynamics-eq-exciter.md` §6 |
| 46 | LFO Filter | 10-pole computed-bilinear LP sweep | `insert-effects-algorithms.md` §2 |
| 47 | Reverse Wah (Wah1–8) | envelope-swept bilinear BP, down-sweep | `phaser-enhancer-gate.md` §5 |
| 48 | LFO Wah | swept bilinear BP Q=8 | `insert-effects-algorithms.md` §2 |
| 49 | Chorus1–4 (CHORUS screen, unit 9) | triangle-trio chorus + conditioning | `modulation-pitch-family.md` §7 |
| 50 | Trio Chorus | triangle-trio chorus, deeper insert build | `modulation-pitch-family.md` §7 |
| 51–56 | REVERB screen (Room/Plate/Concert/Dark/Bright/Stage…) | Moorer/Dattorro hybrid: ER + 4-AP diffuser + absorbing AP + 2 damped combs | `reverb-algorithm.md` |
| 57 | Voice Changer1/2 | dual-saw granular detune, equal-gain crossfade | `modulation-pitch-family.md` §8 |
| **58–61** | **mic reverbs Room/Karaoke/Stage/Cave (unit 7)** | **half-rate series-allpass tank (FLAG3 phase-split, I3 ring)** | `final-batch-algorithms.md` §1 |
| 62–65 | Distorted Amp (Loud/Normal/Soft 1–4) | cubic soft-clip overdrive, 4 tone banks | `insert-effects-algorithms.md` §3 |
| 66 | Vocal Harmonizer | 3-voice reflected-ramp granular pitch shifter | `tremolo-rotary-family.md` §5 |
| **67–69** | **Brass Simulator1–3** | **nonlinear lip ODE (+ pitch-locked grains / + bore waveguide)** | `final-batch-algorithms.md` §2 |
| **70–72** | **Delay+Chorus (Feedback Chorus) / +Flanger / +Vibrato** | **float echo → rec06/rec09/rec27 back ends** | `final-batch-algorithms.md` §3 |
| 73 | Delay+Phaser | float echo → 3-stage swept-allpass phaser | `phaser-enhancer-gate.md` §4 |
| 74 | Autowah+Delay | touch wah + stereo echo | `insert-effects-algorithms.md` §1 |
| **75–76** | **Comp+Dst+Delay / Comp+Ovd+Delay** | **AGC compressor → float-LUT curve A/B (+smoother) → echo** | `final-batch-algorithms.md` §4 |
| 77–79 | data records | LFO waveform tables (sine/triangle/square → the c028 window) | `chorus-family-algorithms.md` §1.3 |

**State of the documentation.** Everything structural is **ROM fact**: every
PM instruction of every record is disassembled and accounted for, every
delay length, filter coefficient, LFO rate and gain quoted above is read off
the listings, and all GUI names come from the firmware's own
preset-descriptor and group tables. What remains **provisional** is
host-runtime behavior that statics cannot pin: the per-preset DM/state banks
the CPU writes at select time (templates are known, live values are not),
the handful of host-fed cells (rec29's pedal, rec75/76's `PM 0x9801`,
rec14's regen), the bank↔SPORT-line identity order behind the MULTI-unit
verdict, FLAG3's physical driver, and perceptual readings flagged as such
(rec67's grain character). The two standing **live experiments**: (1) a
**u8 DM dump** of the running EQ coefficient bank (settles the "flat isn't
mirror-flat" measurement, `dynamics-eq-exciter.md` §5.4), and (2) the
**unit-role capture** — breakpoint `DspEffectSelect` (`0x48405815`) while
switching GUI effects and log (unit, type, slot rewrite), which would close
the unit-numbering question of `reverb-algorithm.md` §7 and the send-bank
order of `kernel-architecture.md` §8 in one session.

## Host-side driver (MN10300)

The CPU-side downloader/driver lives at program-flash `0x48404D10..0x48408000`;
its functions and the effect-type → record-index mapping (runtime table
`0x500066E0`) are named in `../kn7000_manual.sym` and documented in
`../../kn7000_mame/notes/dsp-host-interface.md` and
`../../kn7000_mame/notes/dsp-effect-catalog.md`.

## Same DSP in the KN6000 / KN6500

The KN6000 and KN6500 carry the *same* ADSP-21065L and a **byte-identical**
record pool (their pool matches each other; vs the KN7000 the kernel's DM tables
match while the PM code is an older build). `gen_dsp_records.py` takes the pool
bounds as CLI arguments so the same tool serves those models when their
disassembly repos exist. See
`../../kn7000_mame/notes/sound-cross-model-kn6000-kn6500.md`.
