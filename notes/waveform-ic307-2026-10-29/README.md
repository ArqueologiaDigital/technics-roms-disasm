# KN5000 waveform ROM IC307 as source (lane kn5000-waveform, 2026-10-29)

IC307 (QS6GX3C32008, 4,194,304 B) is the only dumped one of the KN5000's four wave ROMs. The tone generator
IC303 reads it on its own bus. **No CPU reads it**, so no field here can be tied to a firmware reader. Every
statement below is either measured from the bytes (probe named) or reached through the Sub CPU's
wave-selection chain over the table-data ROM (routine named). Inferences are marked.

## What was built

| file                                         | content                                                                                 |
|----------------------------------------------|-----------------------------------------------------------------------------------------|
| `waveform/kn5000_waveform_ic307.s`           | root: the format header, the macro include, the four page includes                      |
| `waveform/waveform_macros.inc`               | `WaveDirEntry`, `WaveRecHead`, `WaveSplit`, `WaveSeq`                                   |
| `waveform/ic307_page0.s` .. `page3.s`        | per page: directory, parameter records, 16-byte alignment, the PCM waves, the 0xFF tail |
| `waveform/waveform.ld`                       | links at 0 (no CPU address exists; a label's value is its file offset)                  |
| `scripts/generators/gen_waveform_ic307_s.py` | the one-shot generator that wrote the tree (refuses to overwrite it without `--force`)  |

The `.s` files are the authoritative source from now on, as with kn7000's `gen_picture_s.py`.

Build and gate:

    make rebuilt_ROMs/kn5000_waveform_ic307.llvm.rom     # copies the reference first, SHA-1 checked
    make gate                                           # includes verify-ic307-reference and the byte gate

The reference image is not committed. `make` copies `original_ROMs/kn5000_waveform_rom.ic307` (git-ignored) from
`KN5000_IC307_REF`, default `$(PROJECTS_ROOT)/technics_romsets/kn5000/kn5000_waveform_rom.ic307`, and refuses a
copy whose SHA-1 is not `4b511bff6625f4655cabd96a263bf548d2ef4bf7`. The 1,413 PCM bodies, 4,170,480 B, are
`.incbin`s of that copy, each marked `census: opaque -- pcm`. The other 23,824 B are typed source: directories,
records, alignment and tails. `data_incbin_census.py`: `kn5000-waveform` opaque 1413 / 4,170,480, generic 0.

## The format, as measured

`probes/ic307_layout.py` prints every figure in this section.

| page | file offset | N     | directory     | records       | empty records | zero alignment | PCM             | distinct waves | 0xFF tail |
|------|-------------|-------|---------------|---------------|---------------|----------------|-----------------|----------------|-----------|
| 0    | 0x000000    | 198   | 0x0000-0x0317 | 0x0318-0x1a2d | 1             | 2 B            | 0x01a30-0xfff7f | 186            | 128 B     |
| 1    | 0x100000    | 168   | 0x0000-0x029f | 0x02a0-0x1831 | 3             | 14 B           | 0x01840-0xfff7f | 151            | 128 B     |
| 2    | 0x200000    | 1,072 | 0x0000-0x10bf | 0x10c0-0x2695 | 961           | 10 B           | 0x026a0-0xfff7f | 1,034          | 128 B     |
| 3    | 0x300000    | 57    | 0x0000-0x00e3 | 0x00e4-0x0233 | 0             | 12 B           | 0x00240-0xfffbf | 42             | 64 B      |

- **Directory.** Entry `i` at page offset `4 i` is `{u16 record offset, u16 wave start in 16-byte granules}`, both
  relative to the page base. Entry 0's record offset is `4 N`, so the table sizes itself. Record offsets ascend
  strictly in all four pages. Wave starts ascend except in page 1, at entries 79, 82 and 85. Those three
  entries point back at earlier waves: 79 at the "ReverseCym.1" wave, stored among the snares, 82 at a
  "ReverseCym.2" wave, and 85 at a wave nothing selects. Source:
  `WaveDirEntry base, rec, wave` = `.short rec - base, (wave - base) / 16`.
- **Records.** Each record runs to the next one, and the last one to its last non-zero word. Its head word
  repeats its entry's wave start in all 1,495 records (`WaveRecHead`; also `analysis/wave7-probes/verify.py`). It
  is followed by 0 or more `[flags:8][value:8]` words: 7,184 words in 530 non-empty records. 965 records are
  head-only, 961 of them in page 2.
- **Alignment.** The zero bytes after the last record exactly reach the next 16-byte boundary in every page
  (`.balign 16, 0`). A wave start counts 16-byte granules, so the first wave has to start on one.
- **PCM.** Signed 16-bit little-endian words. A wave's length is taken as the distance to the next distinct
  wave start, or to the 0xFF tail. Lengths run from 32 B to 75,040 B. 30 records suggest that an entry can play
  past that length (below). **Corrected 2026-10-30** (`../media-files-2026-10-30/README.md`): IC307 is the Y
  chip of a word-interleaved pair like the KN7000's, so each item is every other word of a recording, and
  169 + 31 of the items are two signed 8-bit samples per word, not 16-bit samples. 1,342 of the 1,413 items
  occur verbatim in the KN7000's Y chips (`../media-files-probes/ic307_kn7000_match.py`).
- **Tails.** Pages 0-2 end with 128 B of 0xFF and page 3 with 64 B (`.fill`). `.org` pins each page end at
  `(p + 1) * 0x100000`.
- **Test sines.** The first wave of page 0 and the first wave of page 2 are the same 256-word sine: peak 32,767,
  mean deviation 0.26 LSB from `32767 sin(2 pi k / 256)`. No SET or drawbar record selects either one (labels
  `P0_W0000_Sine`, `P2_W0000_Sine`). Since 2026-10-30: it is exactly the even samples of the KN7000's
  512-sample sine `Main_P00_W000`, the first proof that this chip holds every other word.

### Parameter words: two kinds

| kind      | macro                              | rule (measured)                                                         | count |
|-----------|------------------------------------|-------------------------------------------------------------------------|-------|
| key split | `WaveSplit value, mark=, end=`     | flag bits 5..0 clear and value a multiple of 8, at most 0x80            | 658   |
| sequence  | `WaveSeq value, a, b, mark=, end=` | everything else; `value` s8, `a` = flag bits 5..3, `b` = flag bits 2..0 | 6,526 |

The two kinds share these bits:

- **`end`, flag bit 7.** Set on 286 words, and every one of them is the last word of its record. Not every
  record has one.
- **`mark`, flag bit 6.** Set on 258 words. Not decoded.

Record shapes, with K for a key-split word and S for a sequence word:

| shape       | records |
|-------------|---------|
| empty       | 965     |
| S*          | 277     |
| K*          | 212     |
| S* K*       | 29      |
| K* S*       | 9       |
| S* K* S*    | 2       |
| K* S* K* S* | 1       |

- **Key splits.** In the multisample groups the values descend within a record and shift by 8 from one entry to
  the next (page 0 entries 185-190, all on one wave). An earlier lane measured key = 1.5 x (value - 0x28) against
  the zone tables, that is one unit = 1/8 octave (`../technics-docs/waveform-rom-format.md`). That relation was
  **not** re-derived here, and the macro comment says so. The rule above is a byte rule: in mixed records a word
  with bits 5..0 clear and a value that is not a multiple of 8 (for example `0x98`) is spelled `WaveSeq v, 0, 0`.
- **Sequence words: new findings, not decoded.**
  - The value is negative in 6,494 of 6,526 words; 5,957 of them are -1 to -8.
  - `a` and `b` never exceed 5, and |a - b| <= 1 in 6,128 of 6,526 words (a - b = -1: 2,829, 0: 337, +1: 2,962).
  - Sequences run up to 424 words (page 0 entry 173).
  - 30 sequence records repeat the tail of an earlier record of the same page. Page 0 entry 158 is entry 157
    without its first 4 words, and its wave starts 44 granules after 157's. Entry 159 is 157 without 23 words,
    296 granules later. 174 is 173 without 74 words, 400 granules later. 176 is 175 without 104 words, 479
    granules later. Page 2 has 26 more cases, among them entries 42-46 inside entry 40.
  - **[INFERENCE]** A sequence record is a time-ordered description of the audio from the entry's start: one word
    per segment, with segments of variable length (the words-to-granules ratio is not constant). If so, an entry
    plays on past the end of its own item into the next ones. Entry 157 then plays through 158's and 159's
    audio.
  - This retires the reading "flags 0x01-0x2F = per-zone fine tune" from `waveform-rom-format.md`. The values do
    sit in 0xEA-0xFF, but a record of hundreds of such words on a single wave has no zones to tune.

## Selectors: which tones play which entry

A zone record's +0 word is the recording selector `(class << 12) + entry`, which `WaveSel_StageB_Build_Reg040`
(0x023849) copies to tone-generator register +0x040. `probes/tonedb_selector_users.py` walks the whole chain
backwards over the table-data ROM, with the routines named in its docstring:

- tone partial blocks: `WaveSel_StageA1_FromPatchBlock` 0x0325FC;
- drum-instrument layers: `WaveSel_StageA1_FromToneSlot` 0x032682;
- `WaveSel_StageA1_IndexLookup` 0x032469;
- velocity bands: `Velocity_Select_Split_Zone` 0x022824;
- `WaveSel_StageA2_FromVelZone` 0x0328B5 and `_FindSetDesc` 0x032750;
- SET zone records;
- the drawbar zone blocks that `WaveSel_StageB_Build_Reg040_Footage` 0x0238F8 reads, indexed through
  `Voice_KeyIndex_Pack3Nibbles` 0x02B2C2.

It also names each StageA1 pair through the firmware's own catalogue maps: catalogue A (dir +0x50) through
+0x44 / +0x48, and the percussion catalogue (+0x8C) through +0x4C.

| class | distinct entries used | largest entry | IC307 page with N entries | users                                                               |
|-------|-----------------------|---------------|---------------------------|---------------------------------------------------------------------|
| 0     | 212                   | 213           | (page 0 has 198)          | SETs                                                                |
| 1     | 168                   | 176           | (page 1 has 168)          | SETs                                                                |
| 2     | 184                   | 184           | (page 2 has 1,072)        | SETs                                                                |
| 3     | 415                   | 435           | (page 3 has 57)           | SETs                                                                |
| 4     | 195                   | 197           | page 0, N = 198           | SETs (organs, accordions, effects, basses)                          |
| 5     | 164                   | 167           | page 1, N = 168           | SETs (flutes, drums and cymbals)                                    |
| 6     | 1,007                 | 1,071         | page 2, N = 1,072         | 49 entries (up to 150) from SETs; 960 from the drawbar zone records |
| 7     | 57                    | 56            | page 3, N = 57            | SETs (piano, slap and dance bass)                                   |

What is proven and what is inferred:

- **Proven: the entry counts fit.** For classes 4, 5, 6 and 7 the largest entry used is exactly N - 1 of IC307's
  pages 0, 1, 2 and 3. Class 6 is new here. Through the SETs alone it reaches only entry 150, so the earlier work
  matched only classes 4, 5 and 7. The 2 x 729 + 4 drawbar zone records reach 960 distinct page-2 entries up to
  1,071. Page 2 is the drawbar organ's page: 958 of its 1,034 waves are selected only by drawbar records.
- **Proven: classes 0, 1 and 3 are not pages 0, 1 and 3 of this chip.** Their largest entries (213, 176, 435)
  exceed those pages' directories.
- **Inferred: page = class & 3, and classes 4-7 are IC307.** The chip-select is IC303's. It is consistent with the
  sources and tones the walk finds, for example page 3 = "Piano L/R" and page 1 = the drum kit sounds. Which
  socket holds classes 0-3 waits on dumps of IC304-IC306. **2026-10-31:** class bit 2 is IC303's chip set, so
  classes 0-3 are IC304 + IC305 and 4-7 IC306 + IC307 (`../sound-2026-10-31/README.md`, section 3).
- **Not walked:**
  - the alternate StageA2 maps (+0x9C / +0xA0 / +0xA4), which alias the standard ones in the factory data;
  - the RAM user-tone banks;
  - `Voice_Init_Type1`'s `(tick & 7)` offset;
  - `WaveSel_StageB_Store_Reg040`'s class doubling under mode bit 2 (0x02399D).
- **Entries nothing selects:**
  - page 0: entries 0 (the sine), 152 and 159;
  - page 1: entries 77, 80 and 83 (three 32-sample waves just before the ride cymbals) and 85;
  - page 2: 65 entries: 0 (the sine), 24, and 63 of entries 41-111. Many of these are the entries that start
    inside another entry's audio (42-46, 54-55, 62-63 ...);
  - page 3: none.

**Naming.** Each record's comment lists its selector's users: catalogue sources, tones, drum instruments, SETs
and drawbar records. A wave label carries the source name when all its entries' users agree on one catalogue
source (`P0_W0184_ElectricBass`), `_Drawbar` when only drawbar records select it, and only its page/index
otherwise. The page-3 piano waves, for example, are reached by "Piano L", "BrightPiano L" and "Piano (Mono)"
alike. Two page-first waves are named `_Sine` from their measured shape. That gives 1,261 named and 152 index-only
waves, 958 of the named ones `_Drawbar`.

## Prior work reused or superseded

- `../technics-docs/waveform-rom-format.md`: the page / directory / record / PCM framing, confirmed. It needs
  these corrections:
  - Pages 0-2 also end in 0xFF (128 B each), not only the chip's last 64 B.
  - Page 0's wave 185 (0xFEF6) is 2,064 samples long. It ends at the tail at 0xFFF80, not at the page boundary
    (2,128).
  - The flags 0x01-0x2F "fine tune" reading is retired (above).
  - Class 6 is page 2, through the drawbar records.
  - Page 2's first wave is the same sine as page 0's.
- `analysis/wave7-probes/verify.py`, `ic307_directory_backref_and_monotonicity.py`,
  `ic307_directory_record_fields.py`, `ic307_record_flag0_ordering.py`: back-references 1495/1495 and page 1's
  back-steps, reproduced. Their hardcoded path `~/compartilhado/kn5000_original_roms/` no longer exists, so they
  do not run as they stand. `probes/ic307_layout.py` supersedes them.
- `~/compartilhado/kn7000_mame/tools/kn5000-rom-structure/` (`waverec.py`, `flagcensus.py`, `loopprobe.py`): the
  record-size census and the finding that no record holds loop points. Both agree with the sequence-word reading:
  every field is one byte.
- `~/compartilhado/kn7000_mame/tools/kn5000_class_usage.py` concluded that page 2 has "exactly ONE named user". That
  is superseded: it did not walk the drawbar zone records, which select 960 page-2 entries.
- `~/compartilhado/kn5000_wave_samples/INDEX.txt` gives an older class-to-chunk mapping, for example "class 7 =
  PIANO is mapped to chunks 39-54". It used page-0 chunk numbers for every class and is superseded by the walk.

## Open questions

- What the sequence words encode: the value, the two 3-bit fields, the marker bit, and how a word maps to a stretch
  of samples.
- Where loops are. No field is wide enough to hold a loop point, so loops may be implied by the sequence end, or
  be IC303's own business. Since 2026-10-30, the likelier answer: on the X chip. In the KN7000 the loop marks
  are in the records' odd words and the format flag in the directory's P word, which are X-chip words; IC307's
  "sequence words" would be the even words of such records.
- ~~The base sample rate, and which socket holds classes 0-3 (and the X chip of each pair).~~ **Answered
  2026-10-31** (`../sound-2026-10-31/README.md`): IC307's partner is **IC306** and classes 0-3 are IC304 + IC305
  (service manual I-20 and II-15/16: two chip sets, one chip on each of IC303's address buses). 1,339 items carry
  a real rate (half the KN7000 counterpart's); the other 74, the P/Q words and the loops are **BLOCKED** on a dump
  of IC306, classes 0-3 on dumps of IC304 and IC305.
- Why page 1 entries 77, 80, 83 and 85, page 0 entries 152 and 159, and 65 page-2 entries have no selector.
  Possibly older-build leftovers, or users reached only through the RAM user-tone banks.

## Website page draft (for `waveform-rom-format.md`)

> **IC307 is now source.** `waveform/` in the disassembly rebuilds the 4 MB image byte-for-byte, through `make
> gate`. Per page, the directory and the 1,495 parameter records are typed rows. Each of the 1,413 PCM waves is a
> labelled item named after the wave source that selects it ("Electric Bass", "Ride Cymbal 1", "Jazz Drawbars").
>
> **Page tails.** Pages 0-2 end in 128 bytes of 0xFF, page 3 in 64 bytes. Page 0's last wave (0xFEF6) is 2,064
> samples long.
>
> **Two kinds of parameter word.** A key-split word has flag bits 5..0 clear and a value that is a multiple of 8
> (658 words). A sequence word carries a small negative value and two 3-bit fields that differ by at most 1 in 94%
> of the 6,526 words. A sequence record can repeat the tail of an earlier entry's record exactly, and that entry
> starts later in the same audio (30 cases). This suggests a time-ordered per-segment description; it is an
> inference. Bit 7 ends a record (286 of 286 on a last word). Bit 6 is a marker (258 words), not decoded. The
> earlier "per-zone fine tune" reading of flags 0x01-0x2F does not fit records of up to 424 such words.
>
> **Class 6 is page 2.** The drawbar organ's zone records (2 x 729 + 4, read by
> `WaveSel_StageB_Build_Reg040_Footage`) select page-2 entries up to 1,071, which is that page's N - 1. With
> classes 4, 5 and 7, all four pages of IC307 now match a selector class by entry count. Classes 0, 1 and 3 use
> entries beyond IC307's pages 0, 1 and 3, so they live on another chip. Page 2's first wave is the same
> 256-sample sine as page 0's.
>
> Probes: `notes/waveform-ic307-2026-10-29/probes/` in the disassembly repository.
