# Wave-ROM recordings: real rates, the 8-bit gain law, IC307's partner (lane open3/sound, 2026-10-31)

This lane takes the open sound items of `../media-files-2026-10-30/README.md`, `../waveform-ic307-2026-10-29/`
and `../../kn7000/notes/wave-roms-2026-10-29.md`, and tracker issue `kn5000-d38`. Probes: `../sound-probes/`
(README there).

| # | item                                     | outcome                                                                                                   |
|---|------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| 1 | real sample rates in the WAV headers     | **CLOSED** for the 3,681 KN7000 recordings with a pitch exponent and 1,339 of IC307's 1,413 items. **BLOCKED** for IC307's other 74: their pitch exponent is in the P word on the undumped IC306 |
| 2 | the 8-bit segment gain law               | **BLOCKED** on a hardware measurement (a line-out recording of an 8-bit sound) or a datasheet for the TG LSI. No CPU reads the code, and no 16-bit copy of an 8-bit recording exists to calibrate against. The fitted law is recorded below |
| 3 | IC307's partner chip                     | **Decided: IC306.** The pair's other half, and every P word, Q word and odd record word, are **BLOCKED** on a dump of IC306. Classes 0-3 are **BLOCKED** on dumps of IC304 and IC305 |
| 4 | issue `kn5000-d38`                       | **left open, with a comment**: everything that can be done from IC307 is done. It is **BLOCKED** on dumps of IC304, IC305 and IC306, and on the website sync (drafts below) |

## 1. Real sample rates

### The derivation

Neither ROM stores a rate, and the firmware never sends one. A recording's read rate at a key follows from
three things, all read from the reference images by `kn7000/tools/wave_root_rates.py`:

1. **The TG's pitch law** (kn7000_mame `notes/g13-waves-2026-10-20`, fitted in emulation: with it 478 of 556
   traced voices sound at the firmware's own note):
   `samples per second = 2093.0045 x 2^((pitch18 - 0x1E200) / 0x3000 + E - 9)`, where E is the directory entry's
   pitch exponent (P bits 11:4) and `pitch18 = (pitch16 + 0x1800) << 2`.
2. **The firmware's pitch16 for a key**, from program 941's library (`kn7000/src/program/library_01.s`):
   - `TgPitchInitCalc` (0x4C030FB4): `pitch16 = ((note16 - (centre << 8 | 0x80)) >> exp) + 0x4280`, where
     `note16 = note << 8 | 0x80`, plus part transpose and master tune. The centre is parameter record +0x0B (66
     in 851 of 864 records; when param+8 bit 1 is set, 66). With exp = 0 the result is folded by octaves into
     [param+9, param+0x0A].
   - `TgPitchNoteResolve` (0x4C02FB79) then adds the zone's s16 at +6 when param+8 bit 7 is set.
   With exp = 0, no tone coarse tune and no transpose, the law reduces to
   `rate(n) = 440 x 2^((n - 69)/12 + E - 9 + corr/3072)`. Put another way, a waveform period of
   `T = 2^(E - 9 + corr/3072)` samples sounds at key n's equal-tempered pitch, whatever the key.
3. **The tone database's key mapping.** `TgVoiceRoutePtrCalc` (0x4C02BE45) gives `group = keymap[pitch16 >> 8]`
   and the zone `zones + header[4 + group] x (8 or 6)`. The select is `page << 12 | entry`.
   `TgVoiceSideSelect` (0x4C02BECB) takes the TG side from the zone's halfword +0 & 0x0C00. **0x400 is MAIN
   and 0x800 is SUB**: of the zones whose entry exists on one TG only, 242 of 242 with 0x400 name a MAIN entry
   and 416 of 416 with 0x800 a SUB one (`kn7000_zone_side.py`; the library's comment above `TgVoiceSideSelect` still says "TG A / TG B").

**The root key** of a recording is the lower median of the keys whose zone selects it, over every parameter
record that selects it. It uses the (E, corr) that most keys use: 2,632 of the 2,662 recordings reached have
only one. In the other 30, the corrections differ by 1 or 2 units, or by deliberate transpositions such as 1024
(4 semitones) or 3072 (an octave). For the 13 records whose centre is not 66, the shift goes into corr
(`corr += (66 - centre) x 256`). A single-cycle wave read at f(key) x its length can exceed 192 kHz. In that
case the root moves down by whole octaves until the rate is at most 192 kHz (121 recordings, each flagged).
The law makes the new (root, rate) pair exactly equivalent.

### Measured and inferred

| statement                                                                                   | status                                                                                                                             |
|---------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| which keys select which recording; each zone's correction; each entry's E                    | **read from the bytes** (`wave_root_rates.py`, the routines above)                                                                 |
| the side bit names the TG (0x400 MAIN, 0x800 SUB)                                            | **measured**: 658 of 658 single-TG zones (`kn7000_zone_side.py`)                                                                   |
| T's pitch class is the recording's period                                                    | **measured from the audio**: loops whose corr is not whole semitones hold a whole number of T in 611 of 702 (a wrong pitch class gives 74). The autocorrelation is higher at T than at 2^(E - 9) in 682 of 702 (`loop_period_check.py`) |
| the octave, i.e. E's weight in the law, and the 0x1E200 = C7 anchor                           | **inferred**: the g13 emulation fit (478 of 556 voices). It has not been checked on hardware                                       |
| the tuning is equal temperament at A4 = 440 Hz, with no tone-level coarse tune or transpose  | **convention**: the rate is the one at which the key sounds in tune                                                                |
| the 1,020 recordings no parameter record selects (drum-kit zones, unused entries)             | **inferred**: corr is taken as 0 (1,352 of the 1,416 kit-zone corrections are 0) and the root as 66, the pitch16 0x4280 point      |
| the output clock does not enter the derivation                                              | the law is fitted against absolute pitch, so the rate is samples per second at the key, whatever the DAC rate                      |

The output clocks were checked anyway:
- **KN5000:** IC303's crystal X301 is a 33.8688 MHz part (QSXG1I3386A in the replacement parts list; the
  schematic prints "36.8688MHz"). That is 768 x 44,100 Hz, so IC303's output rate is 44.1 kHz. This is an
  inference from the ratio. The 48 kHz in `audio-subsystem.md` and in the MAME driver is very probably wrong.
- **KN7000:** the master TG's X1 is listed as "16.9944MHz", part H0J1693xxxxx, which is very probably
  16.9344 MHz = 384 x 44,100 Hz (taken from the PDF's text layer). The DSP frame rate was measured on the
  owner's unit at 44,087 Hz (technics-docs `kn7000-effects-dsp.md`).

### KN5000 IC307

An IC307 item that holds the even words of a KN7000 recording from its first sample gets **half** that
recording's rate, at the same root (1,339 items; the 8-bit ones hold sample pairs 4i, 4i+1, so for them the
rate is an average). The same recording read in tune has the same rate on either instrument, and the KN5000
tunes it like the KN7000. Its table data gives 355 of the 390 comparable IC307 selectors exactly the KN7000's
correction for the same recording (`kn5000_kn7000_correction.py`). The 35 others are 33 drum-kit selectors
(class 5, mostly 4-byte SET records without a correction) and 2 of page 0. The other 74 items keep 22,050 Hz,
nominal. Their E is on IC306, and their KN5000 correction alone does not fix the octave (BLOCKED, item 3).

### Outputs and the round trip

- `kn7000/src/wave/root_rates.tsv` (one row per recording: E, corr, root, exact rate, header rate, unity
  note, keys, basis), written by `kn7000/tools/wave_root_rates.py`.
- The manifests (`kn7000/src/wave/{main,sub}_wav.tsv`, `waveform/wav_manifest.tsv`) carry the header rate and
  the smpl unity note. The unity note is the root plus the rounding, `12 log2(rate / rate_hz)`. The ICMT
  comment names the exact rate, the root and the basis.
- `scripts/build/pcm_wav.py retag` rewrote the header chunks of 5,094 WAVs and checked each file's samples.
  Main_P00_W0AF, whose P word reads as E 47, keeps 44,100 Hz. `pcm_wav.py verify` round-trips 1,413 / 2,251 /
  1,431 of 1,413 / 2,251 / 1,431. `main.s` and `sub.s` regenerate byte-identically, and the gates rebuild the
  images from the WAVs (section "Gates").
- KN7000 rates from the zones run from 3,977 Hz to 189,437 Hz, median 37,084 Hz. Examples:
  - the piano's C4 recording `Main_P0A_W00F` (and `Sub_P08_W023`) is 18,508 Hz at root 63;
  - the 512-sample test sine is 189,437 Hz at root 66.

Regeneration order (all committed; the build itself needs none of this):

| step | command                                                                                         | writes                                                    |
|------|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| 1    | `python3 kn7000/tools/wave_root_rates.py`                                                        | `kn7000/src/wave/root_rates.tsv`                          |
| 2    | `make -C kn7000 wave-src` (= `gen_wave_s.py` main / sub)                                         | `kn7000/src/wave/{main,sub}.s` (unchanged), `*_wav.tsv`   |
| 3    | `python3 scripts/generators/gen_ic307_wav_manifest.py`                                           | `waveform/wav_manifest.tsv`, `kn7000/src/wave/ic307_names.tsv` |
| 4    | `python3 scripts/build/pcm_wav.py retag <manifest> <wavdir>` for the three manifests             | the WAV headers (samples unchanged)                       |

## 2. The 8-bit segment gain law

The law, as fitted (kn7000_mame g13 `code8fit.py`): a segment whose record word carries code (a, b), with
a = bits 13:11 and b = bits 10:8, plays at gain **2^(-b/2)**, i.e. 3 dB per step of b. a has no effect in the
fit. Under this law the median boundary jump is 0.384 octave, against 0.348 inside segments, 0.629 with no
gain and 0.516 with 2^-b. A free fit leaves about 0.2 octave unexplained, correlated with a. The code on
`REC_END` words is unexplained. The same field sits in IC307's record words, in its "sequence word" code bits.

Why it stays BLOCKED:
- **Firmware.** Nothing reads it: no CPU reads the wave ROMs, apart from the KN7000's service checksum
  (`kn7000/notes/wave-rom-port.md`) and the KN5000 sub-CPU's selector copy (`v142/subcpu`, the THE SELECTOR
  block).
- **Hardware documents.** None is known for the TG LSIs, KN5000 IC303 TC183C230002 or KN7000 C1BB00000709.
  A patent search found only other makers' schemes; Kawai's US4876935 multiplies 8-bit data by an envelope.
- **Data.** None of the 548 searchable 8-bit KN7000 recordings (of 959) has a 16-bit copy in either stream
  (`gain_law_duplicates.py`). A copy would have let the law be measured per segment.
- **What would settle it:** a line-out recording, on the owner's KN7000, of a sound built from 8-bit
  segments with rising codes (e.g. STRINGS, whose attack runs through codes 5..0), compared with the
  segment levels, or a datasheet.

The WAVs stay a lossless round trip: they hold the stored bytes, and the segments play at their stored
level. No gained file was made. The fit is not established well enough to publish as a listening copy.

## 3. IC307's partner chip: IC306

**The service manual** (EMID971655, scanned; `sm_crops.sh` cuts the regions):
- **Page I-20, test 6, "Wave ROM (IC304-307) check".** It reads: "The key number indicates the Wave ROM number.
  (1: IC304/305, 2: IC306/307)". C keys sound pair 1 and C# to B pair 2. The KN7000 manual's SOUND SYSTEM test
  does the same with its two proven pairs: C keys IC203&204, C# keys IC207&208.
- **TONE GENERATOR SECTION (A), page II-15/16.** IC303 has two wave address buses:
  - ADY (AY0-AY20) feeds IC304 and IC306;
  - ADX (AX0-AX20) feeds IC305 and IC307.
  All four chips share the data lines RD0-RD15, CE is tied low, and each chip has its own output enable:
  - NOEY0 (pin 172) via R316 to IC304;
  - NOEY1 (pin 173) via R315 to IC306;
  - NOEX0 (pin 141) via R319 to IC305;
  - NOEX1 (pin 143) via R318 to IC307.
  NOEY2/3 and NOEX2/3 are open. So the board has two chip sets, select 0 = IC304 + IC305 and select 1 =
  IC306 + IC307. Each set has one chip per address bus, which is exactly a word-interleaved pair with an
  independent address for each half.
- **Part numbers.** IC304 is QSIGU3C32375 and IC305 QSIGU3C32374, consecutive numbers. IC306 is QSIGT3C32A01
  and IC307 QSIGX3C32008.

**The firmware** (v1.42 sub-CPU): the selector's class is `word >> 12`, and classes 4-7 are IC307's pages 0-3
(proven by entry counts, `../waveform-ic307-2026-10-29/`). Read as `class = select << 2 | page`, class bit 2 is
the chip set. Classes 4-7 are therefore set 1, the OE line that drives IC307 (NOEX1), and its address-bus
partner is IC306 (NOEY1). Classes 0-3 are set 0, IC304 + IC305. For example, selector 0x0000 is the "Sine
Wave" source, the counterpart of IC307's unselected test sine at 0x4000. No firmware routine distinguishes
the chips: IC303 decodes the selector. The KN5000's Wave ROM check (main CPU `TEST3FUNC`, title 0xF6) only
posts key events. How the sub-CPU picks the test sines was not traced.

**A naming clash, not a contradiction.** The notes call IC307 "the Y chip" because it holds the even words,
like the KN7000's IC203 / IC207. On the KN7000 those chips sit on the AWAY / BWAY buses (read from the
schematic's text layer by position, weak). On the KN5000, IC307 is wired to IC303's **X** bus (ADX/NOEX1).
Read "Y chip" in the notes as "the even-word chip".

**BLOCKED:** a dump of **IC306** (QSIGT3C32A01) for the other half of every IC307 recording, the P / Q words
and the loops; dumps of **IC304 and IC305** for classes 0-3.

## 4. Issue kn5000-d38

| asked                            | where it is answered                                                                                                  |
|----------------------------------|------------------------------------------------------------------------------------------------------------------------|
| total size                       | four 32 Mbit (4 MB) mask ROMs, 16-bit, 21 address lines each; IC307 dumped                                              |
| data format                      | 4 pages of 1 MB per chip: directory, parameter records, PCM, 0xFF tail (`../waveform-ic307-2026-10-29/`)               |
| sample encoding                  | 16-bit two's complement LE, or two signed 8-bit per word with a per-segment gain code; no compression beyond that (`../media-files-2026-10-30/`) |
| how samples are indexed          | selector `class << 12 | entry`. Class bit 2 picks the chip set (IC304/305 or IC306/307), bits 1:0 the page, the entry the directory slot; the two chips of a set are word-interleaved |
| instrument mapping               | classes 4-7: every IC307 entry named after its sources (the walk in `../waveform-ic307-2026-10-29/`); classes 0-3: selectors known, audio undumped |
| rates                            | this note, section 1                                                                                                    |

Closure needs the website updated (the drafts below; another process syncs it) and the three undumped chips.
The issue gets a comment and stays open.

## Gates

Run in the worktree at efa438902 (2026-10-31), with `kn7000/build/*.labels` deleted first and the absolute
overrides (`ROMSET_DIR`, `CA_MIRROR`, `SOFTLIST_DIR`, `SP7001_UPDATES`): `make gate gate-kn7000` exit 0.
- `assert_byte_identical.py`: "PASS: every rebuilt ROM is byte-identical", 21 images, `kn5000_waveform_ic307`
  among them, built from the retagged WAVs.
- `verify-wave`: IC203, IC204, IC207 and IC208 are each 100% byte-identical to the instrument's wave ROM.
- `pcm_wav.py verify` (round trip): 1,413 / 2,251 / 1,431 of 1,413 / 2,251 / 1,431.
- `data_incbin_census.py`, read-only: kn7000-wave 3682 generated / 66,319,584 B and generic 0, unchanged. No
  `.s` file changed, so the census and doc-quality figures cannot move.

## Website page drafts

### `waveform-rom-format.md`

> **IC307's partner is IC306.** The service manual's Wave ROM check (page I-20) groups the chips as IC304/305
> and IC306/307. The tone generator section (II-15/16) shows why. IC303 has two wave address buses: ADY,
> with IC304 and IC306, and ADX, with IC305 and IC307. All four chips share one 16-bit data bus, and IC303
> enables one chip on each bus at a time (NOEY0 for IC304, NOEY1 for IC306, NOEX0 for IC305, NOEX1 for IC307).
> Each set of two is a word-interleaved pair with its own address per half. Selector classes 4-7 are set 1
> (IC306 + IC307) and classes 0-3 set 0 (IC304 + IC305). IC307 holds the even words: on the KN5000 it is the
> chip on the X bus, although the KN7000-derived notes call it "the Y chip". Until IC306 is dumped, every
> IC307 recording is half a recording, and the directory's pitch, format and loop word are missing.
>
> **IC303's clock** is the 33.8688 MHz crystal X301 (parts list; the schematic prints 36.8688), 768 x 44.1 kHz.
> The output rate is therefore 44.1 kHz, not 48 kHz.
>
> **Real rates.** 1,339 of IC307's WAV files now carry a real sample rate and root key in their header. Each is
> half the rate of the SX-KN7000 recording whose even words they hold (see the KN7000 page). The KN5000's own
> table data gives 355 of 390 comparable selectors the same pitch correction as the KN7000 does. The other 74
> keep 22,050 Hz, nominal: their octave is in the undumped P word.

### `kn7000-wave-rom-format.md`

> **Sample rates.** No rate is stored. Each recording's WAV header now carries the tone generator's read rate
> at a root key: `rate(n) = 440 x 2^((n - 69)/12 + E - 9 + corr/3072)`. E is the entry's pitch exponent and
> corr the zone correction the firmware adds (`TgPitchNoteResolve`). The root is the median key that selects
> the recording in the tone database (`TgVoiceRoutePtrCalc`'s key maps). The `smpl` chunk carries the root.
> - The pitch class is checked against the audio. In 682 of 702 loops, the derived period fits better than
>   the uncorrected one.
> - The octave rests on the emulation fit of the pitch law.
> - 1,020 recordings that no zone selects get their exponent's rate at key 66.
>
> Examples: the piano's C4 recording 18,508 Hz at root 63, the 512-sample sine 189,437 Hz at root 66. A zone's
> side bit 0x400 means the MAIN tone generator and 0x800 the SUB one.
>
> **8-bit gain.** The segment code's law is still a fit, 2^(-b/2) for b = bits 10:8. Nothing in the firmware
> reads it, no datasheet is known, and no 8-bit recording has a 16-bit copy to measure against. The WAVs keep
> the stored levels.

### `media-files.md`

> **Recordings are committed WAV files** (corrects the 2026-10-30 text: they are no longer extracted at
> build time). Their headers carry a real sample rate and root note:
> - the SX-KN7000: the tone generator's read rate at the recording's root key, from the tone database;
> - KN5000 IC307: half that rate where the KN7000 holds the same recording (1,339 of 1,413); the other 74
>   stay at 22,050 Hz, nominal.
>
> The samples are the ROM's bytes, so a WAV still rebuilds the ROM exactly. 8-bit recordings play at their
> stored segment levels: the segment gain law is not established.
