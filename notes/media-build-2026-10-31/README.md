# Media committed, conversion at build time (lane media-build, 2026-10-31)

The owner's decision, verbatim: *"Images and wav files must be commited and the conversion must happen as
a build step."*

So every picture and recording is a committed standalone file (PNG, JPEG, BMP, WAV, MID), and nothing a
converter derives from one is tracked: the bytes the assemblers read are written from the media files by
make rules into git-ignored files, and a changed PNG or WAV rebuilds them.  The reference images are needed
only for the final byte compare and for the maintenance targets that re-extract media from a dump.

## Outcome

| what                                                             | before (main at f4045a81c)                                  | now                                                                                     |
|------------------------------------------------------------------|-------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| KN5000 IC307 recordings, 1,413 WAVs                              | extracted into git-ignored `waveform/wav/` from the dump    | committed; `pcm_wav.py build` (no `--ref`) writes `waveform/build/pcm/`                 |
| KN7000 wave-ROM recordings, 3,682 WAVs                           | extracted into git-ignored `kn7000/wav/` from the dump      | committed; `pcm_wav.py build` writes `kn7000/build/wav_pcm/`                            |
| KN5000 `images/*.bin` beside a PNG (142)                         | tracked, rewritten in place by the converters               | git-ignored outputs of one grouped make rule (`KN5000_IMAGE_BINS`)                      |
| v9 / v7 copies of v10's pictures (68), HD-AE5000 extractions (5) | tracked raw copies nothing reads                            | deleted                                                                                 |
| Feature Demo `FTBMP01..06.BMP`                                   | tracked "build cache" written from PNG + JSON               | git-ignored output of `ftbmp_images.py build`; includes marked `census: generated`      |
| NAKA GUI C pictures (39 per revision, 195)                       | hex rows in the tracked C, rewritten from the PNGs          | each initializer `#include`s a git-ignored `.inc` that `c_bitmaps.py build` writes      |
| WSA1R bitmaps (208) and font faces (12)                          | `.byte` rows in the tracked source, rewritten from the PNGs | `.incbin "images/<name>.bin"`; `wsa1_bitmaps.py` / `wsa1_fonts.py build` write the bins |
| WSA1R drawbar sprites (2, 1,398 B)                               | `.byte` rows, REFUSED (no rectangle)                        | 24 x 233 PNGs, converted at build (section "WSA1R: the refused ranges")                 |
| WSA1R prom_a 0xFC48E4.. (1,860 B)                                | REFUSED as a picture of unknown geometry                    | not a picture: typed display lists and tables (same section)                            |
| WSA1R `CONTACT_*.png` browsing sheets (6)                        | tracked, derived from the PNGs                              | git-ignored, `make -C wsa1 images-sheet`                                                |
| floppy BMP / JPEG / MIDI files (131)                             | read from the reference's extraction in `floppy/build/`     | committed in `floppy/<model>/<disk>/media/`, on the include path ahead of `build/`      |
| SX-KN7000, siblings, HD-AE5000 v1.15i / v1.10i                   | already PNG -> `build/` (table_png.py, hdae5000_images.py)  | unchanged; checked: no output tracked                                                   |

`python3 notes/media-files-probes/media_inventory.py`: **8,136 items backed by a committed media file (630
read directly, 7,506 converted at build), 0 not backed; 0 untracked media files the build reads; 0 tracked
files a converter derives from media** (section "Inventory").

## The C pictures: a generated header, not a generated C file

The brief offered two ways: generate the initializer file from the PNG plus a committed template, or have
clang include a generated header.  The second is the one taken.  Each of the 195 initializer bodies in the 25
`v*/maincpu/ui_widgets/naka_*.c` files is now one line:

```c
    .Bitmap_FadeInPicture = {
#include "../includes/generated/pictures/Bitmap_FadeInPicture.inc"  /* pixels: images/BitmapFadeInPicture.png, written at build time by scripts/build/c_bitmaps.py */
    },
```

- The C stays an ordinary source that a reader and clang both read as it is: its struct declarations, the
  header comment above each picture (size, format, readers) and its layout are unchanged; only the pixel rows
  left (about 82,000 lines).  A template would have made the committed file something that is not C until a tool
  has run.
- The `#include` path is relative to the C file, so no clang command line changed.
- `c_bitmaps.py build TREE` writes `<tree>/maincpu/includes/generated/pictures/<name>.inc` from the PNG (an
  unchanged PNG leaves the file untouched); the Makefile's per-revision stamp in that directory depends on
  the revision's PNGs, and the five affected C objects depend on the stamp.
- Byte-identical: the 25 compiled objects equal those of a baseline build at f4045a81c (`cmp`), and `make
  gate` passes.  `c_bitmaps.py verify` checks PNG == `.inc` == the built bytes at each label.

## Where the converter outputs go

They stay at the paths the sources already `.incbin`, now git-ignored, so no `.incbin` line, no `-I` and no
analysis tool that reads them changed.  The repository already kept build products beside their sources
this way (`table_data/includes/help_databases/*.bin` beside their `.txt` listings, `includes/generated/`).

## Build graph

Make targets are given relative to the directory of the Makefile that defines them.

| media (committed)                                                                                                                                                              | converter (committed)                                      | output (git-ignored)                                             | make target                                                      | read by                                      |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|----------------------------------------------|
| `v*/maincpu/images/{Bitmap_1bit_*,SeBitmap_*}.png`, `v10/maincpu/images/Bitmap[A-Z]*.png`, `table_data/images/Wallpaper_*.png`, `hdae5000/images/HDAE5000_Bitmap_Button01.png` | `scripts/build/{indexed_images,mono_images,se_bitmaps}.py` | the `.bin` beside each PNG (`kn5000_image_outputs.py` lists 142) | `$(KN5000_IMAGE_BINS)` (grouped), `indexed-images`, `media`      | v10..v5 maincpu, table_data, HD-AE5000       |
| `v*/maincpu/images/*.png` (39 per revision)                                                                                                                                    | `scripts/build/c_bitmaps.py build TREE`                    | `v*/maincpu/includes/generated/pictures/*.inc`                   | `<tree>/maincpu/includes/generated/pictures/.stamp`, `media`     | the five `naka_*.c` objects of each revision |
| `table_data/images/FTBMP0?.png` + `ftbmp_headers.json`                                                                                                                         | `scripts/build/ftbmp_images.py build`                      | `table_data/images/FTBMP0?.BMP`                                  | `$(FTBMP_BMPS)` (grouped), `media`                               | table_data                                   |
| `table_data/images/{ui_bitmaps,icons_png,fonts}/*.png`                                                                                                                         | `ui_bitmaps_images.py`, `icon_images.py`, `font_images.py` | `table_data/includes/generated/*.bin` (274)                      | `$(TABLEDATA_IMAGE_BINS)` (grouped), `tabledata-images`, `media` | table_data                                   |
| `hdae5000*/images/*.png`, `*.txt` palettes                                                                                                                                     | `scripts/build/hdae5000_images.py build`                   | `hdae5000*/includes/generated/HDAE5000_*.bin` (14)               | `$(HDAE_IMAGE_BINS)` (grouped), `hdae5000-images`, `media`       | the four HD-AE5000 trees                     |
| `table_data/includes/demo_presets/midi/*.mid` + sidecars                                                                                                                       | `midi_to_preset.py`, `compress_lzss.py`                    | `table_data/includes/demo_presets/*_compressed.bin`              | the demo-preset rules (unchanged)                                | table_data                                   |
| `waveform/wav/*.wav`                                                                                                                                                           | `scripts/build/pcm_wav.py build`                           | `waveform/build/pcm/*.pcm`                                       | `waveform/build/pcm/.built`, `media`                             | IC307                                        |
| `kn7000/wav/{main,sub}/*.wav`                                                                                                                                                  | `../scripts/build/pcm_wav.py build`                        | `build/wav_pcm/{main,sub}/*.pcm`                                 | `build/wav_pcm/{main,sub}.done`                                  | the four KN7000 wave ROMs                    |
| `kn7000/src/table/*/*.png`                                                                                                                                                     | `tools/table_png.py build`                                 | `build/table_png/`                                               | `build/table_png/.stamp` (unchanged)                             | table 84 / sp7001 table                      |
| `kn7000/src/**/program/data/media/*.png`                                                                                                                                       | `tools/table_png.py build`                                 | `build/bitmaps/<build>/`                                         | `build/bitmaps/<build>/.stamp` (unchanged)                       | programs 941, sp7001, 935, 893               |
| `kn7000/src/ic18/media/FontGlyphs8x16.png`                                                                                                                                     | `tools/table_png.py build`                                 | `build/ic18_png/`                                                | `build/ic18_png/.stamp` (unchanged)                              | IC18                                         |
| `kn2400`, `kn6000`, `kn6500`, `hdsx3` `src/program/data/media/*.png`                                                                                                           | `../kn7000/tools/table_png.py build`                       | `build/bitmaps/`                                                 | `build/bitmaps/.stamp` (unchanged)                               | the sibling programs                         |
| `wsa1/prom_{a,b}/images/*.png`, `prom_b/images/fonts/*.png`                                                                                                                    | `scripts/build/wsa1_bitmaps.py` / `wsa1_fonts.py build`    | the `.bin` beside each PNG (222)                                 | `$(WSA1_IMAGE_BINS)` (grouped), `all`                            | prom_a, prom_b                               |
| `floppy/<model>/<disk>/media/*` (BMP, JPEG, MID)                                                                                                                               | none: read directly                                        | -                                                                | `-I <model>/<disk>/media` ahead of `build/`                      | the disk images                              |
| JPEG / BMP of `kn7000/src/{table,picture}`, `*/program/data/media/`                                                                                                            | none: read directly                                        | -                                                                | -                                                                | as before                                    |

Notes on the graph:

- The root Makefile and `wsa1/Makefile` declare `.SECONDARY:` with no prerequisites, which makes every target
  intermediate, and make does not remake a missing intermediate for an object that is otherwise up to date.
  So `all` names the outputs (root: the new phony `media`; WSA1: `all: $(WSA1_IMAGE_BINS)`): a deleted output
  is made again by `make all` / `make gate`.  Found when `make gate` failed in `assert_images_assemble.py`
  ("Could not find incbin file") after the bins had been deleted on an already-built tree.
- `KN5000_IMAGE_BINS` is defined at the top of the root Makefile: a prerequisite list is expanded when make
  reads the rule.  The old `$(INDEXED_IMAGE_SRC)` prerequisite of the maincpu objects was defined about 400
  lines below them and so was always empty there.
- Maintenance targets (they read a reference; a build never runs them): `make waveform-wav`, `make -C kn7000
  wave-wav` (write missing WAVs), `make -C floppy media-<model>` (rewrite `media/`), `make -C wsa1
  images-export`, and the generators (`*-src`, `gen_*`).

## Checking that no converter reads a reference

- `pcm_wav.py build` lost its `--ref` option: it reads the manifest and the WAVs; a missing WAV is an error
  that says to restore it from git.  The make rules depend on every WAV the manifest names, not on an
  extraction stamp of the reference.
- `indexed_images.py` read row padding back from its own output when a stride exceeded the width; no row has
  such a stride, and it now refuses one instead (a padded picture needs a committed pad sidecar, the way
  `hdae5000_images.py` keeps `row_padding.json`).
- `icon_images.py` and `font_images.py` take their counts and kern widths from the committed blob size and
  `table_data/fonts.s`; they read no reference image.  `hdae5000_images.py build` reads only the PNGs and the
  palette text files.  `table_png.py build` reads only the PNGs (the format is in each PNG's tEXt chunk).
- The proof is phase A of the clean-checkout run (below): every converter output was built with
  `PROJECTS_ROOT`, `ROMSET_DIR`, `CA_MIRROR`, `SOFTLIST_DIR`, `EXTRACT_DIR`, `WAVE_ROMSET` ... pointed at an
  empty directory.

## WSA1R: the refused ranges

`notes/media-files-2026-10-30/README.md` left three WSA1R ranges as byte rows because their picture
geometry was not established.  Established from the code that draws them:

- **`Bitmap_DrawbarA` (prom_b 0xF54808) and `Bitmap_DrawbarB` (0xF54AC3), 699 B each.**  `Drawbar_DrawColumn`
  (0xF538B6) builds an op-03 record on its stack (BC = 1, HL = 0x7B, XIY = base + `DrawbarRowOffsets[value]`)
  and issues it three times through `Blit_FromStackRecord`, adding 1 to the destination column IX (one byte,
  8 pixels) and 233 (`ld XBC,0x000000e9`) to XIY each time.  That is `LCD_Svc_03_BlitColumns`' column-major
  layout with BC = 3, HL = 233: a **24 x 233** picture, of which the screen shows the 123-row window that
  starts at the row offset (0x7B + the largest offset 0x6E = 0xE9 = 233).  The window is the caller's; the
  stored rectangle is the sprite's.  Rendered that way, `Bitmap_DrawbarA.png` is a drawbar shaft numbered 8
  down to 1 above its handle, then the 110 blank rows the window never reaches at offset 0
  (`wsa1_bitmaps.py verify`: 210 images, 47,838 B, 0 failures).  DrawbarA serves the integer footages, B the
  fractional ones (the source headers).
- **prom_a 0xFC48E4-0xFC52F7 beyond the eight widgets (1,860 B): not a picture.**  0xFC48E4-0xFC4BA6 is
  widgets 1-7 of `Widget_FC48D7..` (already PNGs); from 0xFC4BA7 on the module
  `prom_a/modules/fc4000_fc53ff_digital_effect_screen_data.s` already types it as the SOUND EDIT COPY page's
  display lists (`dl_*`, `dlb_*` records), `.short` rectangles and `.ascii` names, each named by its prom_b
  reader (`SoundEditCopy_Paint` 0xF09B9B and friends).  No `.byte` row remains there; the REFUSED entry was
  stale.
- The third entry ("no fifth cell at 0xF17AE0") is not a picture and stays as the one REFUSED note.

## The WSA1R respell

`wsa1_bitmaps.py respell` / `wsa1_fonts.py respell` (run once) replaced the `.byte` slots of every range with
`.incbin "images/<name>.bin", skip, count`, found through the script's own ROM-confirmed address map: a line
shared with a neighbour is split, ASCII-art preview rows inside a picture are dropped (the PNG is the
picture), and labels and other comments stay where they were, splitting the include there.  210 bitmap
ranges and 12 faces became 225 include lines (three ranges are split by an inner label or comment, for
example `Bitmap_F01992` at its inner label `Bitmap_F0199E`).  `_line_size()` now sizes an `.incbin` with an
explicit count, so the map still propagates addresses across the respelled ranges.  `check` asserts that
every range is covered exactly once by include pieces of its own bin; `rewrite` is gone.

## Floppy media

A unit's `.incbin` of a `.bmp`, `.jpg` or `.mid` name (census class `media`) now finds the committed copy in
`floppy/<model>/<disk>/media/`, which comes before `build/<model>/<disk>/` on the disk's include path.  The
KD_CUT byte ranges (the BMP inside a `.HMP`, the SMF inside a WSA1R song file) are no longer build
prerequisites.  131 files, 5,062,376 B: KN5000 29, WSA1R 16, KN6000 85, KN7000 1; the largest 79,810 B.
`tools/fat12_media.py check` runs in every `gate-<model>`.

## Clean-checkout proof

`notes/media-build-2026-10-31/clean_checkout_proof.sh SCRATCH open2/media-build`, run 2026-10-31 on a fresh
clone of cd758fe62 (main d24411d2e and 88c9ab319 merged in) under `~/compartilhado/tmp/`; its output is
committed as `clean_checkout_proof-2026-10-31.txt`.  It printed `PASS: clean checkout of open2/media-build`:

| phase | what                                                                                                                                                                             | result                                                                   |
|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| A     | every converter output built with `PROJECTS_ROOT`, every romset / dump / mirror override and `UNIDASM` pointed at an empty directory                                             | 7,033 outputs built; no reference image present after it                 |
| B     | `make gate gate-wsa1 gate-floppy gate-kn7000 gate-kn6000 gate-kn6500 gate-kn2400 gate-hdsx3`, `make -C kn7000 symbols-check`, references copied by the Makefiles (SHA-1 checked) | all exit 0; "PASS: every rebuilt ROM is byte-identical." (KN5000, WSA1R) |
| C     | `git status --porcelain`                                                                                                                                                         | empty: no tracked file changed, nothing untracked and unignored          |
| D     | every converter output deleted, every tracked file read-only (two pre-existing exceptions below), the same gates                                                                 | all exit 0; the 7,033 outputs rebuilt SHA-256-identical to phase A       |
| E     | the 93 extracted copies of committed floppy media deleted from `floppy/build/`, disks rebuilt                                                                                    | "4 models reproduced byte-for-byte"                                      |

- Phase A answers "does a clean checkout build every media conversion from the committed media alone": yes.
  Phase D answers "does deleting every derived output and rebuilding reproduce it byte for byte": yes, and,
  with the tracked files read-only, no converter writes a tracked file.  The SHA-256 list of the 7,033
  outputs is committed as `converter_outputs.sha256.gz` (the list itself hashes to
  `81927db84c5734446474fc68a6b8b0d50411c0bdc83c958e68a9bb12fbc09b89`).
- Of those 7,033, the 6,616 that a baseline build of main at f4045a81c also has (the formerly tracked `.bin`
  and `.BMP` files, `includes/generated/`, the raw PCM items, kn7000 `build/`) are SHA-256-identical to it;
  the other 417 are new kinds of file (the 195 C-picture `.inc` files and the 222 WSA1R bins, which
  `wsa1_bitmaps.py verify` / `wsa1_fonts.py verify` check against the ROM).
- Phase E: the 38 KD_CUT media (22 home-page BMPs, 16 SMF files) never exist in a fresh clone's `build/`,
  so the disks can only have read them from `media/`; for the other 93 the extracted copy was deleted.
- Earlier runs found two Makefile gaps, fixed before this run: under `.SECONDARY:` a deleted output was not
  rebuilt for an up-to-date object (the `media` target, a2e768e3a), and `hdae5000-images` /
  `tabledata-images` were output-less rules (e1eda9247).  They also found two kinds of tracked build state
  that the read-only phase must leave writable (open items): the `*.bin.patched` stamps and the MN10300
  `src/constants.inc`.  Both were closed by lane media-cleanup, whose rerun of this script with no exception
  is recorded in `notes/media-cleanup-2026-10-31/` (`clean_checkout_proof-2026-10-31.txt` there).

## Gates in the lane worktree

On the merged branch (a07054fc3: all nine; then `make gate` again on e1eda9247), after deleting
`kn7000/build/*.labels`, all exit 0: `make gate` ("PASS: every rebuilt ROM is byte-identical.", 21 KN5000
images), `make gate-wsa1` (prom_a..d byte-identical; `images-check`: 210 of 210 bitmaps and 12 of 12 faces
are .incbin of their PNG-built bins, verify 0 failures), `make gate-floppy` (14 + 9 + 21 + 6 disks
reproduced), `make gate-kn7000` (35 OK lines, 0 FAIL, including "src/ic21own/ic21.s rebuilds the 2 MB IC21
read byte-for-byte"), `make gate-kn6000` / `gate-kn6500` / `gate-kn2400` / `gate-hdsx3` (5 / 4 / 5 / 4 OK, 0
FAIL), `make -C kn7000 symbols-check` (17 OK).  The proof above repeats all of them on a fresh clone of
cd758fe62, whose only later change is to the proof script.

## Inventory

`python3 notes/media-files-probes/media_inventory.py`, 2026-10-31, on this branch after merging main
d24411d2e (lane ic21-own, whose home page is the committed BMP `kn7000/src/b893/program/data/media/Bmp_48743E5C.bmp`,
read directly), every tree built.  It exits 0:

| tree             | pictures: direct / converted / NOT backed | sounds: direct / converted / NOT backed | midis: direct / converted / NOT backed |
|------------------|-------------------------------------------|-----------------------------------------|----------------------------------------|
| kn5000-v10       | 0 / 60 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-v9        | 0 / 60 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-v7        | 0 / 60 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-v6        | 0 / 60 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-v5        | 0 / 60 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-tabledata | 0 / 323 / 0                               | 0 / 0 / 0                               | 0 / 19 / 0                             |
| kn5000-hdae5000  | 0 / 6 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-hdae201   | 0 / 6 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-hdae115   | 0 / 4 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-hdae110   | 0 / 4 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn5000-waveform  | 0 / 0 / 0                                 | 0 / 1413 / 0                            | 0 / 0 / 0                              |
| kn5000-floppy    | 58 / 0 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| wsa1             | 0 / 225 / 0                               | 0 / 0 / 0                               | 0 / 0 / 0                              |
| wsa1-floppy      | 0 / 0 / 0                                 | 0 / 0 / 0                               | 16 / 0 / 0                             |
| kn7000-program   | 10 / 88 / 0                               | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-table     | 159 / 439 / 0                             | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-sp7001    | 169 / 527 / 0                             | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-b893      | 10 / 88 / 0                               | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-b935      | 10 / 88 / 0                               | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-ic18      | 0 / 1 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-picture   | 100 / 0 / 0                               | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-wave      | 0 / 0 / 0                                 | 0 / 3682 / 0                            | 0 / 0 / 0                              |
| kn7000-ic21own   | 1 / 0 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn7000-floppy    | 1 / 0 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn6000-floppy    | 85 / 0 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn2400           | 5 / 127 / 0                               | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn6000           | 3 / 80 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| kn6500           | 3 / 83 / 0                                | 0 / 0 / 0                               | 0 / 0 / 0                              |
| hdsx3            | 0 / 3 / 0                                 | 0 / 0 / 0                               | 0 / 0 / 0                              |

- **8,136 items backed by a committed media file (630 read directly, 7,506 converted at build), 0 not backed;
  0 untracked media files the build reads; 0 tracked files a converter derives from media.**  168 typed-row
  candidates, all with a verdict.
- WSA1R: 225 include lines for 210 bitmaps and 12 faces (three split by an inner label or comment).
- Negative test (2026-10-31, before the merge): with `waveform/wav/P0_W0000_Sine.wav` untracked and
  `wsa1/prom_b/images/Bitmap_DrawbarA.bin` force-added, the probe reported 1 untracked media file and 1 tracked
  derived output (found three ways: its include, wsa1_bitmaps.py's output list, the stem twin of its PNG) and
  exited 1.

## Repository size

`git count-objects -vH` of the shared object store (every worktree of this repository writes into it, so the
"after" figure also holds other lanes' objects created meanwhile):

| when                                   | loose objects | loose size | packed size |
|----------------------------------------|---------------|------------|-------------|
| before (lane start, main at f4045a81c) | 2,912         | 229.10 MiB | 411.55 MiB  |
| after (this lane's commits, pre-merge) | 8,586         | 314.76 MiB | 411.55 MiB  |

What this branch itself adds (`git rev-list --objects f4045a81c..` before the merge, through `git cat-file
--batch-check`): 5,288 blobs, 87,128,381 B uncompressed, 71,611,725 B zlib-compressed on disk; 123 trees
(257,989 B) and 11 commits.  The WAVs are almost all of it (72,121,566 B of PCM, which zlib barely shrinks);
the floppy media add 5,062,376 B (identical files, such as the ten `BITMAP.bmp`, are one blob each).  The 221
tracked files this lane removed stay in history.

## Read-only censuses

Run on the merged branch, nothing written:

- `data_incbin_census.py --compare data-incbin-2026-10-30-04.json`: exit 0, generic 0 in every tree.  Moved, as
  expected: `wsa1` generated 0 -> 225 / 95,342 B, all from media (the respell); `kn5000-tabledata` media 6 -> 0
  and from media 336 -> 342 (the six Feature Demo BMPs are now generated from their PNGs); the new
  `kn7000-ic21own` row (main) has its BMP as media.
- `doc_quality_census.py --compare` (before the merge): "compared with docs/coverage/doc-quality-2026-10-30-03.json:
  nothing rose"; fell: prom_a `.byte` runs after a terminator 64 -> 63 (bytes 4,763 -> 4,382), prom_b 78 -> 76
  (2,311 -> 2,204).
- dispatch census (`build_maps.py` into `$DISPATCH_CENSUS_DIR` in scratch, then `census.py --compare`, before the
  merge): "compared with docs/coverage/dispatch-census-2026-10-30-03.json: nothing rose".

## Make targets, in the order that regenerates the outputs

| step | command                                                                                   | writes                                                                  |
|------|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| 1    | `python3 scripts/build/c_bitmaps.py respell` (once; idempotent)                           | the 25 `naka_*.c` files' `#include` lines                               |
| 2    | `python3 wsa1/scripts/build/wsa1_bitmaps.py respell`, then `wsa1_fonts.py respell` (once) | the WSA1R `.incbin` lines (refuses to run twice: no `.byte` slots left) |
| 3    | `make media` / `make all` (root), `make -C wsa1 all`, `make -C kn7000 ...`                | every converter output (git-ignored)                                    |
| 4    | `make -C floppy media-<model>` (maintenance, needs the references)                        | `floppy/<model>/<disk>/media/`                                          |
| 5    | `make waveform-wav`, `make -C kn7000 wave-wav` (maintenance, needs the references)        | missing WAVs                                                            |

## Open questions and items left

- **Closed 2026-10-31 by lane media-cleanup** (`notes/media-cleanup-2026-10-31/README.md`), the four items
  this lane left:
  - *Tracked one-way renders and raw blobs.*  `table_data/images/icons/` (191 renders) and the eight verbatim
    blobs (`table_data/includes/icon_pixel_data.bin`, `icons_to_strings.bin`, `wallpaper1_to_icons.bin`,
    `hdae5000/includes/code_*.bin`, all byte-exact slices of tracked reference images) are deleted; their
    maintenance readers use `scripts/build/retired_blobs.py`; `extract_icons.py` paints `icons_png/`.
  - *The `.bin.patched` stamps* are untracked and ignored; a missing stamp makes `apply_c_divergence.py`
    recompile the bin before patching it.
  - *`src/constants.inc`* stays committed (generated source) and only `make constants` rewrites it.
  - *`gen_fc4000_pages.py --apply`* is retired.
  `clean_checkout_proof.sh` now makes every tracked file read-only in phase D, with no exceptions.
- **Comments in the HD-AE5000 sources** (`hdae5000*/hdae5000_data_tables.s`) named the five extraction copies
  this lane deleted; corrected after lane hdae-ledgers was merged (comment-only; the Palette `.bin` mentions stay,
  those files are kept).  `notes/hdae5000-versions-2026-10-24/port-edits/00_filepanel_picture.py`, a dated port
  edit, still quotes the old comment.
- The palettes in `v*/maincpu/images/` (`Palette_8bit_RGBA*.bin`) and `hdae5000/images/HDAE5000_Palette*.bin`
  are data, not converter output, and stay tracked.

## Website page draft

For `media-files.md` (replacing the draft in `../media-files-2026-10-30/README.md`):

> ### Pictures and recordings as ordinary files
>
> Every picture in the disassembly is a PNG, JPEG or BMP file, and every wave-ROM recording is a WAV file.
> They are committed, and the build turns them back into the ROM's bytes, so you can open them in any image
> viewer or sound program, edit them, and rebuild.  Nothing the build derives from them is committed: the
> raw bytes it writes go into git-ignored files next to the sources or under `build/`.
>
> **Pictures**: KN5000 `v10/maincpu/images/` (and the other revisions'), `table_data/images/`,
> `hdae5000/images/`; SX-KN7000 `kn7000/src/table/`, `kn7000/src/picture/`, `kn7000/src/*/program/data/media/`;
> SX-WSA1R `wsa1/prom_*/images/`; the floppy disks' pictures under `floppy/<model>/<disk>/media/`.  Indexed
> PNGs store the ROM's palette indices, so a pixel's value is the ROM's byte.  One-bit pictures are one-bit
> PNGs.  The SX-WSA1R's two drawbar sprites are 24 x 233 pictures of which the screen shows a 123-row window.
>
> **Recordings**: `waveform/wav/` (KN5000 IC307, 1,413 files) and `kn7000/wav/main/`, `kn7000/wav/sub/`
> (SX-KN7000, 3,682 files), about 72 MB.  They are mono WAV files: 16-bit recordings as 16-bit signed PCM,
> 8-bit ones as 8-bit PCM.  The sample rates in the headers are nominal (44.1 kHz for the SX-KN7000, 22.05
> kHz for IC307), because the ROMs store none.  The SX-KN7000 files carry a `smpl` chunk with the loop the
> tone generator uses (837 recordings) and an approximate root note.
>
> **MIDI**: the demo songs of the KN5000 table data and the SX-WSA1R floppies' songs are `.mid` files.
>
> **KN5000 IC307 is half of a pair.** (unchanged from the 2026-10-30 draft)
