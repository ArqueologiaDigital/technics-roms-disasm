# Media as standalone files (lane media-files, 2026-10-30)

The owner's request: *"'Media: pictures and PCM' <== I want these to be represented as standalone files that
could be opened by the user on normal media viewers / sound apps. Then included in the source listing (maybe
with a lossless conversion step if necessary)"*.

> **Superseded in part, 2026-10-31** (lane media-build, `../media-build-2026-10-31/README.md`). The owner
> decided: *"Images and wav files must be commited and the conversion must happen as a build step."* So the
> WAVs and the floppies' BMP / JPEG / MIDI files ARE committed now, and every file a converter writes from a
> media file is a git-ignored build product: the `images/*.bin` beside the KN5000 PNGs, the Feature Demo
> `.BMP`s, the NAKA GUI C's pixel rows (now a generated `.inc` the C `#include`s), and the WSA1R's `.byte`
> rows (now `.incbin`s of PNG-built bins).  The statements below that say otherwise ("not committed",
> "committed beside the PNGs", "c_bitmaps.py writes the initializers", "checked by wsa1_bitmaps.py check",
> the three REFUSED WSA1R ranges) describe 2026-10-30.

## Outcome

| what                                         | before                                                    | now                                                                                   |
|----------------------------------------------|-----------------------------------------------------------|---------------------------------------------------------------------------------------|
| KN5000 IC307 recordings (1,413, 4.17 MB)     | `.incbin` of the reference image, `census: opaque -- pcm` | one WAV each, `waveform/wav/` (git-ignored), built back by `scripts/build/pcm_wav.py` |
| KN7000 wave-ROM recordings (3,682, 66 MB)    | `.incbin_range` of the reference stream, opaque pcm       | one WAV each, `kn7000/wav/main/`, `kn7000/wav/sub/` (git-ignored), same converter     |
| KN5000 SOUND EDIT bitmaps (13 x 5 trees)     | `.byte 0b........` rows                                   | `v*/maincpu/images/SeBitmap_*.png` through `scripts/build/se_bitmaps.py`              |
| HD-AE5000 `BitmapButt01` (2 trees)           | `.byte` rows                                              | `hdae5000/images/HDAE5000_Bitmap_Button01.png` through `indexed_images.py`            |
| KN7000 IC18 boot ROM 8x16 font (224 glyphs)  | `.byte` rows                                              | `kn7000/src/ic18/media/FontGlyphs8x16.png` through `kn7000/tools/table_png.py`        |
| KN7000 `SjisMissingGlyph` (4 builds)         | `tab_u8` rows                                             | `<build>/program/data/media/SjisMissingGlyph.png` through `table_png.py`              |
| KN5000 NAKA GUI C pictures (39 x 5 trees)    | hex initializers in `ui_widgets/naka_*.c`                 | `v*/maincpu/images/*.png` through `scripts/build/c_bitmaps.py` (C written from PNG)   |
| WSA1R older-build value glyphs (4)           | `.byte` rows, no PNG                                      | `wsa1/prom_b/images/OldBuild_ValueGlyph_*.png`, checked by `wsa1_bitmaps.py check`    |
| table_data / HD-AE5000 PNG and MIDI includes | census read them as compiled C, or named no file          | markers name the PNG / MIDI file (313 includes; census "from media")                  |

Every image still rebuilds byte-identical (gates below). The opaque-pcm class is now empty in every tree:
both encodings are established (sections below), and the 5,095 recordings are `generated` from their WAVs.
The probe `../media-files-probes/media_inventory.py` lists every picture, sound and MIDI item of every census
tree and the file behind each; it reports 0 items without a standalone file, and lists the three WSA1R ranges
whose picture geometry wsa1_bitmaps.py refuses to guess (section "Inventory").

## The WAV files

- **Not committed.** The repository is public and the recordings are dump bytes. `make` extracts any
  missing WAV from the git-ignored reference image, and never overwrites one that is there, so an edited WAV
  survives. The build then reads the WAVs, not the reference: `pcm_wav.py build` writes each recording's raw
  item (`waveform/build/pcm/<label>.pcm`, `kn7000/build/wav_pcm/<tg>/<label>.pcm`), and the source
  `.incbin`s it.
- **The mapping is exact both ways.** A 16-bit recording is signed little-endian, so its WAV `data` chunk
  holds the ROM bytes unchanged. An 8-bit recording is two signed samples per word, low byte first; WAV
  8-bit PCM is unsigned, so each WAV byte is the ROM byte XOR 0x80. `pcm_wav.py verify` checks the round
  trip in memory (1,413 / 2,251 / 1,431 of 1,413 / 2,251 / 1,431). `build` refuses a WAV that is not mono
  integer PCM of the recording's bit depth or whose length differs, because the page layout fixes where
  every recording starts.
- **Manifests** (committed, no sample data): `waveform/wav_manifest.tsv`, `kn7000/src/wave/main_wav.tsv`,
  `kn7000/src/wave/sub_wav.tsv`. One row per recording: label, offset in the reference, end, bit depth,
  sample rate, WAV file name, smpl unity note, smpl loops, and the INFO comment.
- **Names.** A WAV is named after its source label. The KN5000 labels already carry the instrument
  (`P1_W0003_JazzFlute.wav`). A KN7000 recording whose audio IC307 also holds gets the IC307 name too
  (`Main_P00_W000_Sine.wav`; 1,118 of 3,682), from `kn7000/src/wave/ic307_names.tsv`. Each WAV's LIST/INFO
  chunk carries the label (INAM) and a comment (ICMT): tone generator, page, entries, select, format, and
  the IC307 or KN7000 counterpart.
- **Total size** (apparent bytes, 2026-10-30): `waveform/wav/` 4,650,396 B (1,413 files), `kn7000/wav/`
  67,471,170 B (3,682 files); 72,121,566 B in all.

### How to open them

Any sound program plays them: they are plain mono RIFF WAVE files, `pcm_s16le` or `pcm_u8`. For example
`ffplay kn7000/wav/main/Main_P0A_W00F.wav`, or open the folder in Audacity. `ffprobe` read all 5,095 without
an error (2026-10-30). The KN7000 files carry a `smpl` chunk that samplers read: the unity note always, and
the loop where the record marks one (837 recordings).

```
make waveform-wav                 # KN5000: extract the missing WAVs into waveform/wav/
make -C kn7000 wave-wav           # KN7000: extract the missing WAVs into kn7000/wav/{main,sub}/
make rebuilt_ROMs/kn5000_waveform_ic307.llvm.rom    # builds from the WAVs (extracts them first if absent)
make -C kn7000 verify-wave        # the same for the four KN7000 chips
```

The reverse direction was checked on 2026-10-30: with `waveform/wav/` and `kn7000/wav/` deleted, `make gate`
and `make gate-kn7000` regenerated them from the references and the images were byte-identical again
(section "Gates").

## KN7000 wave ROMs: encoding

The stream format is in `../../kn7000/notes/wave-roms-2026-10-29.md`: the Y and X chips of a tone generator
are one stream of 16-bit words, word i of Y then word i of X; a directory entry's P bit 3 marks a recording
of two 8-bit samples per word.

| field       | value                                                        | evidence                                                                                                       |
|-------------|--------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| 16-bit      | two's complement, little-endian (the stream's words)         | `pcm_encoding_probe.py`: s16le has the fewest full-scale jumps in 2,632 of 2,723; the other 91 tie (silence)   |
| 8-bit       | two's complement, low byte first, two per word               | the same probe: s8 wins in 925 of 959, the rest tie; byte correlation > 0.5 in 917 of 959 (16-bit: 0 of 2,720) |
| companding  | none found; samples are written as stored (linear)           | not proven: the 8-bit segments have a gain code (below) that the WAV does not apply                            |
| sample rate | the TG's read rate at the root key (since 2026-10-31)        | `../sound-2026-10-31/README.md`: pitch law, E, zone correction, key map; until then 44,100 Hz nominal          |
| unity note  | the root key from the tone database (since 2026-10-31)       | `../sound-2026-10-31/README.md`; until then `96 + 12 (log2(44100 / 2093.0045) - (E - 9))`, the g13 pitch law   |
| loops       | `smpl` loop = the record's LOOP_START..LOOP_END segment ends | `wave-roms-probes/loop_probe.py`: 945 of 954 marked loops repeat; end written inclusive (end sample - 1)       |

- A recording's sample rate is not stored: the firmware folds each zone's tuning into the pitch it writes.
  The header rate is the one at which the WAV, played at its unity note, sounds as the tone generator plays
  that recording at that note. The unity note leaves out the per-zone tuning, so it is only near.
- One recording, `Main_P00_W0AF`, has no unity note: its P word reads as E = 47 (the odd entry in the wave
  notes).
- 90 loops end past their item (an entry can play into the next recording's bytes); the WAV leaves them out
  and its comment says how many.
- The 8-bit segments carry a 6-bit code that, in emulation, scales the segment by 2^(-b/2) (fitted, not
  derived). The WAV holds the raw samples, so 8-bit recordings play with their segments at the stored level.

## KN5000 IC307: encoding, and what the chip is

IC307 turned out to be **the Y chip of a word-interleaved pair, like the KN7000's**: it holds every other word
of each recording, of each directory entry and of each record. The KN7000 notes had inferred it (kn7000_mame
g13); the probes prove it:

- 1,342 of IC307's 1,413 waves occur verbatim in the KN7000's Y chips (1,162 in IC203, 180 in IC207; none in
  an X chip); 1,339 of them at a KN7000 recording's first sample, 1,327 over their whole length
  (`ic307_kn7000_match.py`).
- IC307's 256-word test sine is exactly the even samples of the KN7000's 512-sample sine `Main_P00_W000`
  (`pcm_encoding_probe.py`).
- 456 IC307 records equal the words p1, p3, p5, ... of a KN7000 record that plays the same recording, and
  the 965 head-only IC307 records pair with KN7000 records of at most one parameter word; 9 match no
  partner, none matches the control p0, p2, ... (`ic307_records_vs_kn7000.py`).

So the IC307 "sequence words" (`../waveform-ic307-2026-10-29/README.md`) are KN7000 record words seen from one
chip: [flags:2][code:6][value:8], a value of 0x80 or more a segment of (256 - value) granules, flag bit 7 the
KN7000 LOOP_END / REC_END bit and bit 6 its LOOP_START bit, the code the 8-bit gain. The directory's P word
(pitch exponent, 8-bit flag, loop granule), its Q word and every other record word are on the undumped
partner chip. The MAME driver maps IC304-IC307 as one linear 16 MB region; this says the four chips are two
word-interleaved pairs instead. Which socket is IC307's partner is not known. **Answered 2026-10-31: IC306**
(`../sound-2026-10-31/README.md`, section 3).

| field              | value                                                                         | evidence                                                                                           |
|--------------------|-------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| word               | two's complement, little-endian                                               | `pcm_encoding_probe.py`: s16le has the fewest jumps in 1,165 of 1,391 IC307 items, ties 169        |
| what an item holds | every other word of a recording (the Y half)                                  | the three matches above                                                                            |
| 8-bit or 16-bit    | from the KN7000 recording with the same audio: 1,173 16-bit, 169 8-bit        | `ic307_kn7000_match.py`; the P word with the flag is on the partner chip                           |
| the 71 others      | byte correlation > 0.5: 8-bit (31); else 16-bit (40)                          | calibrated on the matched items: > 0.5 in 0 of 1,170 16-bit ones, 152 of 169 8-bit ones; inference |
| sample rate        | half the KN7000 counterpart's read rate (1,339 items); else 22,050 Hz nominal | `../sound-2026-10-31/README.md` (since 2026-10-31; until then 22,050 Hz for all)                   |
| loops              | none in the WAV: the loop marks are on the partner chip                       | the record finding above                                                                           |

An IC307 WAV is therefore the Y half of a recording: a 16-bit one sounds like the recording at half the
rate, without anti-alias filtering; an 8-bit one holds the sample pairs (4i, 4i+1). For the 1,327 waves
whose whole length matches, the KN7000's X chip holds the other half of what is very probably the same
recording; this lane does not combine them (a KN7000 dump is not a KN5000 one).

## The pictures this lane converted

The inventory found these pictures still spelled as rows. Each is now a PNG that a build step turns back
into the bytes, following the tree's own precedent.

| item                                       | format (evidence)                                                                                                           | converter                         |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| `SeBitmap_*` x 13, v10 v9 v7 v6 v5         | 1 bpp, column-major, bit 7 leftmost; drawn by static op 03 via ColorBlit2_LargeCodeBlock (the header above each)            | `scripts/build/se_bitmaps.py`     |
| `HDAE5000_Bitmap_Button01`, both trees     | 42 x 15, 8 bpp, no row pad; HDAE5000_BitmapButt01 answers EVT_GET_BITMAP_DATA / _WIDTH / _HEIGHT with it                    | `scripts/build/indexed_images.py` |
| `FontGlyphs8x16`, KN7000 IC18              | 224 glyphs from 0x20, 16 bytes each, MSB leftmost; FontTable points at it (`table_png.py` `font 1 16 224`)                  | `kn7000/tools/table_png.py`       |
| `SjisMissingGlyph`, KN7000 941/935/893/942 | 16 x 16, 1 bpp, column-major; DrawString_Impl 0x48425467 draws it for an absent Shift-JIS code (`annotations/gfx_draw.ann`) | `kn7000/tools/table_png.py`       |

- The KN5000 PNGs are mode '1' (SOUND EDIT) or indexed with the main palette `Palette_8bit_RGBA.bin`
  (BitmapButt01, which the HD-AE5000 hands to the main CPU's bitmap protocol). The `.bin` files are
  committed beside the PNGs, as everywhere in `images/`.
- `SjisMissingGlyph` comes from `gen_data_s.py`'s new pass `named_glyphs()`; the data sources were
  regenerated with `tools/regen_data_and_code.sh`.
- **The NAKA GUI C's pictures.** Each KN5000 maincpu revision's compiled C holds 39 pictures as initializers:
  the 33 8-bpp bitmaps that v10's `images/` already had as PNGs for table_data (logos, split-point keyboards,
  MIDI diagrams, fade buttons ...), `UserBitmapCheck_Bitmap24x24` (a 24 x 24 worm), and the welcome screen's
  letters (`WelcomeGlyph_C`, `Bitmap_Digit1` 'I', `Bitmap_DigitR`, `Bitmap_DigitD`, `Bitmap_DigitL` 'L N O':
  16 x 17, 1 bpp, one big-endian word per row, rows bottom-up, drawn by DrawBitmapSP2_Impl). Until now the C
  held the bytes and v10's PNGs fed only table_data. `scripts/build/c_bitmaps.py build` now writes every
  initializer's values from its PNG (and redraws the letters' ASCII-art comments) before clang runs; an
  unchanged PNG leaves the C file byte-identical. For v10 the PNG is the same file table_data uses; v9, v7, v6
  and v5 got their own 39 (162 new PNGs, 167 KB). `c_bitmaps.py verify`: 195 of 195 pictures, PNG == C ==
  the built `includes/generated/*.bin` at the label. The census still counts these includes as compiled C.
- **WSA1R.** `OldBuild_ValueGlyph_Bitmaps` (0xF0EEE0, 288 B, unread) is byte-identical to the first four
  value glyphs, as its header says; `wsa1_bitmaps.py` now lists it like the 0xF17AE0 copies (208 images).

## Census convention

`scripts/analysis/data_incbin_census.py` keeps an include made from a standalone media file through a
committed lossless converter in class **`generated`**, with the converter and the media file named in its
marker (`census: generated -- <tool>, from <file>.wav`; "from the .png beside it" for the KN5000 picture
scripts). That was already the picture convention; the class says how the bytes the assembler reads are
made. A new column, **from media**, counts these entries per tree (`from_media` in the json), so the table
shows how much of `generated` an ordinary viewer or player opens. The docstring documents it.

## Inventory

`python3 notes/media-files-probes/media_inventory.py` (2026-10-30, at the end of this lane, every tree built)
lists every picture, PCM recording and MIDI stream of every census tree, and the file behind it. It exits 0:
**8,122 items backed by a standalone file, 0 not**; 159 typed-row candidates (labels that read like a picture)
all carry a verdict (palettes, display lists, memory images, pointer and lookup tables, GUI state fields,
name strings). Items / bytes:

| tree             | pictures backed | sounds backed     | midis backed | pictures NOT backed | sounds NOT backed | midis NOT backed |
|------------------|-----------------|-------------------|--------------|---------------------|-------------------|------------------|
| kn5000-v10       | 60 / 287,104    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-v9        | 60 / 287,104    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-v7        | 60 / 287,104    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-v6        | 60 / 287,104    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-v5        | 60 / 287,104    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-tabledata | 323 / 904,396   | 0 / 0             | 19 / 245,992 | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-hdae5000  | 6 / 308,586     | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-hdae201   | 6 / 308,586     | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-waveform  | 0 / 0           | 1413 / 4,170,480  | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn5000-floppy    | 58 / 2,303,264  | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| wsa1             | 220 / 93,944    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| wsa1-floppy      | 0 / 0           | 0 / 0             | 16 / 613,706 | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-program   | 98 / 221,934    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-table     | 598 / 1,615,821 | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-sp7001    | 696 / 1,837,755 | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-b893      | 98 / 221,934    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-b935      | 98 / 221,934    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-ic18      | 1 / 3,584       | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-picture   | 100 / 2,093,050 | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-wave      | 0 / 0           | 3682 / 66,319,584 | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn7000-floppy    | 1 / 17,078      | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn6000-floppy    | 85 / 2,126,762  | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn2400           | 132 / 177,931   | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn6000           | 83 / 165,680    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| kn6500           | 86 / 166,064    | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |
| hdsx3            | 3 / 309,200     | 0 / 0             | 0 / 0        | 0 / 0               | 0 / 0             | 0 / 0            |

- *Backed* means the build reads the item from that file, directly (JPEG, BMP, MID) or through a committed
  converter (PNG, WAV), or holds rows that a converter checks against the file in the gate (the WSA1R's
  `wsa1_bitmaps.py` / `wsa1_fonts.py check`; the KN5000 NAKA GUI C, which `c_bitmaps.py` writes from PNGs).
- Files not committed by design: the WAVs, and the floppies' BMP / JPEG / MID files, which the floppy
  framework extracts from the git-ignored disk images. Every other backing file is committed.
- Not counted as pictures: palettes (their pictures' PNGs carry them), the KN5000 `Palette_8bit_RGBA.bin`
  and the HD-AE5000 `.txt` palettes.
- **Left as rows, by the WSA1R's own choice** (`wsa1_bitmaps.py` REFUSED, geometry not established):
  prom_a 0xFC48E4-0xFC52F7 beyond its eight 90-byte widgets (1,860 B), prom_b `Bitmap_DrawbarA` /
  `Bitmap_DrawbarB` (699 B each: three 233-byte slices, drawn as 123-row windows at an offset the caller
  computes), and no fifth cell at 0xF17AE0. A PNG needs a rectangle; these have none yet.
- The probe's limit: a picture under a label that names no picture class, held as typed rows, is not seen.

## Gates

Run on branch `open/media-files` at the end of the lane (2026-10-30), all exit 0:

| command                                                                  | first deleted                                                   | result                                                                       |
|--------------------------------------------------------------------------|-----------------------------------------------------------------|------------------------------------------------------------------------------|
| `make gate`                                                              | `waveform/wav/`, `waveform/build/`                              | 1,413 WAVs re-extracted; `PASS: every rebuilt ROM is byte-identical.`        |
| `make gate-wsa1 gate-floppy`                                             | -                                                               | every image and disk byte-identical; `images-check` (now in the gate) passes |
| `make gate-kn7000 gate-kn6000 gate-kn6500 gate-kn2400 gate-hdsx3`        | `kn7000/wav/`, `kn7000/build/wav_pcm/`, `kn7000/build/*.labels` | 3,682 WAVs re-extracted; 69 `OK` lines, 0 `FAIL`                             |
| `make -C kn7000 symbols-check`                                           | -                                                               | every symbol file is what its generator writes                               |
| `python3 scripts/build/pcm_wav.py verify` (three manifests)              | -                                                               | 1,413 / 2,251 / 1,431 recordings round-trip exactly                          |
| `python3 scripts/build/c_bitmaps.py verify`                              | -                                                               | 195 of 195 pictures: PNG == C == built bytes                                 |
| `python3 scripts/build/se_bitmaps.py verify`, `indexed_images.py verify` | -                                                               | 65 of 65; ROUND TRIP EXACT                                                   |
| `python3 notes/media-files-probes/media_inventory.py`                    | -                                                               | 8,122 items backed, 0 not                                                    |

The first two rows are the reverse-direction check the brief asked for: with the WAVs gone, the build makes
them again from the reference images and the images come out byte-identical.

Read-only censuses (no snapshot written):

- `data_incbin_census.py`: generic 0 in every tree, as before; **opaque pcm 0** (was 5,095 items,
  70,490,064 B); `kn5000-waveform` and `kn7000-wave` are now `generated` 1,413 / 4,170,480 and
  3,682 / 66,319,584, all "from media". "From media" also rose in kn5000-tabledata (43 -> 336, the markers),
  the HD-AE5000 trees (0 -> 6), the KN5000 maincpu trees (8 -> 21: the SOUND EDIT bitmaps), kn7000-ic18
  (0 -> 1) and the four KN7000 program builds (+1, SjisMissingGlyph). `--compare` against
  `data-incbin-2026-10-30-02`: nothing rose.
- `doc_quality_census.py --compare`: "compared with docs/coverage/doc-quality-2026-10-30-02.json: nothing rose".
- dispatch census (`build_maps.py` into a lane scratch dir, then `census.py --compare`): "compared with
  docs/coverage/dispatch-census-2026-10-30-02.json: nothing rose".

## Make targets, in the order that regenerates the outputs

| step | command                                                                | writes                                                              |
|------|------------------------------------------------------------------------|---------------------------------------------------------------------|
| 1    | `python3 scripts/generators/gen_ic307_wav_manifest.py`                 | `waveform/wav_manifest.tsv`, `kn7000/src/wave/ic307_names.tsv`      |
| 2    | `python3 scripts/converters/respell_ic307_pcm_as_wav.py`               | `waveform/ic307_page*.s` (idempotent)                               |
| 3    | `make -C kn7000 wave-src`                                              | `kn7000/src/wave/{main,sub}.s` and `{main,sub}_wav.tsv`             |
| 4    | `make -C kn7000 ic18-src`                                              | `kn7000/src/ic18/boot.s`, `src/ic18/media/FontGlyphs8x16.png`       |
| 5    | `UNIDASM=... kn7000/tools/regen_data_and_code.sh`                      | the four KN7000 builds' `program/data/` (SjisMissingGlyph)          |
| 6    | `python3 scripts/build/se_bitmaps.py build`, `indexed_images.py build` | the committed `.bin` beside each PNG (also run by `make`)           |
| 7    | `python3 scripts/build/c_bitmaps.py build`                             | the NAKA GUI C initializers from the PNGs (also run by `make`)      |
| 8    | `python3 scripts/converters/mark_tabledata_media_sources.py`           | census markers of table_data / HD-AE5000 includes (idempotent)      |
| 9    | `python3 wsa1/scripts/build/wsa1_bitmaps.py check`                     | nothing: asserts the WSA1R rows equal their PNGs (`make gate-wsa1`) |

The WAVs and raw items need no step of their own: `make` makes them (`waveform-wav`, `wave-wav` to refill by
hand).

## Open questions

- ~~**Sample rates.**~~ **CLOSED 2026-10-31** (`../sound-2026-10-31/README.md`): every KN7000 WAV but one
  and 1,339 IC307 WAVs carry the TG's read rate at a root key; IC307's other 74 are BLOCKED on IC306.
- **The 8-bit gain law**: **BLOCKED** on a hardware measurement or a TG datasheet (`../sound-2026-10-31/README.md`,
  section 2: no firmware reader, no 16-bit copy to calibrate against). The fit 2^(-b/2) is recorded there.
- ~~**IC307's partner chip.**~~ **Decided 2026-10-31: IC306** (service manual I-20 and II-15/16: IC306 and IC307
  share output-enable index 1 on IC303's two address buses). The other half of each recording is **BLOCKED** on
  a dump of IC306; classes 0-3 on dumps of IC304 and IC305.
- **The 71 IC307 waves with no KN7000 counterpart**: their format is the byte-correlation inference.
- **WSA1R ranges that wsa1_bitmaps.py refuses** (section "Inventory"): pictures whose geometry is not
  established, so they stay rows.

## Website page draft

For a new page `media-files.md` (sidebar: under ROM reconstruction), and short notes on
`waveform-rom-format.md` and `kn7000-wave-rom-format.md`:

> ### Pictures and recordings as ordinary files
>
> Every picture in the disassembly is a PNG, JPEG or BMP file, and every wave-ROM recording is a WAV
> file, which the build turns back into the ROM's bytes. You can open them in any image viewer or sound
> program, edit them, and rebuild. (Three SX-WSA1R ranges stay byte rows until their picture geometry is
> established.)
>
> **Pictures** are committed: KN5000 `v10/maincpu/images/` (and the other revisions' `images/`),
> `table_data/images/`, `hdae5000/images/`;
> SX-KN7000 `kn7000/src/table/`, `kn7000/src/picture/`, `kn7000/src/*/program/data/media/`; SX-WSA1R
> `wsa1/prom_*/images/`. Indexed PNGs store the ROM's palette indices, so a pixel's value is the ROM's
> byte. One-bit pictures are one-bit PNGs.
>
> **Recordings** are not committed: they are the dumps' own bytes. `make waveform-wav` (KN5000 IC307) and
> `make -C kn7000 wave-wav` (KN7000) write them from your copy of the ROM images into `waveform/wav/` and
> `kn7000/wav/`, about 72 MB for 5,095 files. They are mono WAV files: 16-bit recordings as 16-bit signed
> PCM, 8-bit ones as 8-bit PCM. The sample rates in the headers are nominal (44.1 kHz for the KN7000,
> 22.05 kHz for IC307), because the ROMs store none. The KN7000 files carry a `smpl` chunk with the loop
> the tone generator uses (837 recordings) and an approximate root note.
>
> **KN5000 IC307 is half of a pair.** IC307 holds every other 16-bit word of each recording, directory
> entry and parameter record: it is the "Y" chip of a word-interleaved pair, like the SX-KN7000's wave
> ROMs, so the KN5000's tone generator must read its wave ROMs in pairs too (an inference from the chip's
> contents; the MAME driver maps the four chips as one linear region). 1,342 of its 1,413 waves occur verbatim in the KN7000's Y chips
> (IC203, IC207), and its 256-word test sine is the even half of the KN7000's 512-sample one. The partner
> chip, which holds the other half and each entry's format, pitch and loop word, is not dumped. An IC307
> WAV therefore sounds like its recording at half the sample rate. 200 of the waves are 8-bit (two
> samples per word), 169 of them known from the KN7000 recording with the same audio.
