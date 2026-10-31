# Media cleanup: the last tracked blobs, renders and build state (lane media-cleanup, 2026-10-31)

Lane media-build (`notes/media-build-2026-10-31/README.md`, "Open questions and items left") made every
picture and recording a committed file converted at build time, and left five items open.  This lane closes
them.  The policy is the repo-root CLAUDE.md section "Media Files Are Committed; Conversion Is a Build Step".

## Outcome

| #   | item                                                           | state      | what changed                                                                                                 |
|-----|----------------------------------------------------------------|------------|--------------------------------------------------------------------------------------------------------------|
| 1   | `table_data/images/icons/` and the raw blobs                   | **CLOSED** | 191 renders and 8 blobs deleted; their readers use the tracked reference images through `retired_blobs.py`   |
| 2   | 80 tracked `*/maincpu/includes/generated/*.bin.patched` stamps | **CLOSED** | untracked and ignored; a missing stamp makes `apply_c_divergence.py` recompile the bin, never patch it twice |
| 3   | the MN10300 trees' `src/constants.inc`                         | **CLOSED** | committed generated source; only the `constants` maintenance target rewrites it                              |
| 4   | `notes/proma-2026-09-25/gen_fc4000_pages.py`                   | **CLOSED** | `--apply` retired, with the commits that replaced each part of its output; the check mode still passes       |
| 5   | `clean_checkout_proof.sh` with no exceptions                   | **CLOSED** | the two "left writable" exceptions are gone; the proof passes (see "Clean-checkout proof")                   |

## 1. The icon renders and the eight verbatim blobs

**What they were.**  Every blob was a byte-for-byte slice of a reference image git already tracks:

| deleted file                                  | bytes   | slice of                              | CPU address |
|-----------------------------------------------|---------|---------------------------------------|-------------|
| `table_data/includes/icon_pixel_data.bin`     | 51,184  | `original_ROMs/kn5000_table_data.rom` | 0x938588    |
| `table_data/includes/icons_to_strings.bin`    | 742,024 | `original_ROMs/kn5000_table_data.rom` | 0x944D78    |
| `table_data/includes/wallpaper1_to_icons.bin` | 152,576 | `original_ROMs/kn5000_table_data.rom` | 0x912C00    |
| `hdae5000/includes/code_2803c2_28f542.bin`    | 61,825  | `original_ROMs/hd-ae5000_v2_06i.ic4`  | 0x2803C2    |
| `hdae5000/includes/code_28f90c_2953e1.bin`    | 23,254  | `original_ROMs/hd-ae5000_v2_06i.ic4`  | 0x28F90C    |
| `hdae5000/includes/code_295642_2971a2.bin`    | 7,009   | `original_ROMs/hd-ae5000_v2_06i.ic4`  | 0x295642    |
| `hdae5000/includes/code_2971b7_29ae9e.bin`    | 15,592  | `original_ROMs/hd-ae5000_v2_06i.ic4`  | 0x2971B7    |
| `hdae5000/includes/code_29af2d_2fffff.bin`    | 413,907 | `original_ROMs/hd-ae5000_v2_06i.ic4`  | 0x29AF2D    |

The four `code_*` siblings of `code_29af2d_2fffff.bin` are the same kind of file with the same readers, so
they went too.  Their SHA-256 values are in `scripts/build/retired_blobs.py`, which checks every range
against them (`python3 scripts/build/retired_blobs.py` prints all eight `ok`).

**What included them.**  No assembly source: `command grep -a` over every `.s` / `.inc` finds only
`; Was: .incbin "includes/code_29af2d_2fffff.bin", ...` comments, and `audit_icons_blob_coverage.py` printed
`LLVM slices: 0 directives, 0 bytes (0.0% of the file)` before the change.  Their readers were:

- the picture converters' `export` / `verify` (`icon_images.py`, `font_images.py`, `ui_bitmaps_images.py`,
  `hdae5000_images.py`) and `style_events.py`'s `EXTRA` bank, all maintenance commands that may read a
  reference; `icon_images.py build` also took the icon count from the blob's size, and the table-data image
  rule listed the blob as a prerequisite;
- `decompress_slide8k.py --all`, the `decompress-help-databases` one-shot, `audit_icons_blob_coverage.py`,
  `extract_ui_bitmaps.py`, `refine_hdae5000_strings.py` (one-shot tools);
- the archived ASL mirrors.  The table-data one could not build before this lane (35 of the 48 files its
  `.asm` bincludes were already gone).  The HD-AE5000 one still built byte-identical.

**What replaced them.**  Each reader calls `retired_blobs.read(name)`, which returns the same bytes from the
reference image.  No `build` step reads a reference: `icon_images.py` knows its 177 icons, and the rule no
longer depends on the blob.  The legacy HD-AE5000 ASL mirror gets its five slices written into
`rebuilt_ROMs/asl-hdae5000/includes/` by a make rule (`ASL_HDAE_SLICES`), so `make asl-all`'s HD-AE5000 image
is still byte-identical to the reference (checked with `ASL_PATH=$HOME/compartilhado/tools/asl`).  That
mirror copies those ranges of the reference, as it always did; now it says so.  `decompress-help-databases`
reads the factory streams at ROM-minus-0x800000 offsets; its six outputs equal the committed databases.

**The renders.**  `table_data/images/icons/` held 176 RGB renders (`Icon_000..175.png`), the sprite sheet
and 14 format-exploration renders (`test_*.png`, deliberately wrong decodings), all written from the ROM by
the old `scripts/analysis/extract_icons.py`.  They duplicated `table_data/images/icons_png/`, the 177
palette-indexed PNGs the build converts.  `extract_icons.py` now paints `icons_png/` with the firmware's
16 colours, writes outside the tree, and `make gallery` writes the sheet into the website's gallery.
`probes/compare_icon_renders.py` reads all 191 files back from git at 43242446d: **177 of 177 reproduced
pixel-exactly** (176 icons + the sheet), 14 not compared.  The sheet it paints is pixel-identical to the
website's `assets/images/gallery/IconSpriteSheet.png`.

Byte-identity: table data and HD-AE5000 v2.06i rebuild equal to their references; `media_inventory.py`
reports 0 untracked media files and 0 tracked derived outputs.

## 2. The C-divergence stamps

`apply_c_divergence.py` (and `apply_v7_c_divergence.py`, now the same code run on v7) patches the compiled C
bins of the ported trees in place, with relocations that are relative (`v += delta`).  Patching a bin make
did not recompile would apply them twice.  The stamp `X.bin.patched` is what prevented that, and 80 of them
had been committed by ab4e0f268.  Untracking them as they were would have been unsafe: a checkout that
pulled the removal loses its stamps while its bins stay patched.

The stamp now holds two SHA-256 values, of the bin the script wrote and of the json entry it applied:

| stamp                                     | bin          | the script                                                 |
|-------------------------------------------|--------------|------------------------------------------------------------|
| valid, entry unchanged                    | hash = stamp | skips it (already patched)                                 |
| valid, entry unchanged                    | hash differs | patches it (make recompiled it)                            |
| missing, old one-line form, entry changed | anything     | deletes it, runs make on it (same MAKEFLAGS), then patches |

So a missing stamp costs one recompile and never a second patch.  `.gitignore` gains
`*/maincpu/includes/generated/*.bin.patched`; `regenerate_v7_c_divergence.py` reads the first field.

Proof, `probes/c_divergence_stamp_proof.sh` (output: `c_divergence_stamp_proof-2026-10-31.txt`), on a fresh
clone of this branch: no stamp tracked; first build v7, v6, v5 byte-identical; second build `make -q` up to
date and every patch step skips every bin; the stamps of the three bins with the most relocations deleted
(v7 `gui_display_struct_data.bin` 533, v6 and v5 `naka_style_bitmaps.bin` 1,196): exactly those recompiled,
ROMs byte-identical; every stamp deleted (an older checkout after the pull): all recompiled, ROMs
byte-identical; negative control: the patcher as it was at 43242446d, run on `naka_style_bitmaps.bin` with its
stamp missing, changes the bin (patched twice), and the current one restores it; `git status` clean.  `PASS`,
on a clone of 02319af1d.

## 3. `src/constants.inc` (kn7000, kn2400, kn6000, kn6500; hdsx3 reads kn6000's)

It holds the firmware's own `{name, value}` enumeration tables (`BD_*`, `CL_*`, `VF_*`, ...) as `.equ`
lines, which the assembly uses by name.  That is readable source of the same kind as the committed
`src/program.s`, not a media conversion and not a byte the assembler copies, so it stays committed.  What was
wrong was the rule: `constants src/constants.inc: ... baserom/$(ROM)` made it a file target, rewritten from the
reference whenever the reference copy was newer (always, in a fresh clone).  Now `constants` alone is a phony
maintenance target, beside `program-src` / `data-src`, and the build reads the committed file.  Run on the four
reference images in this worktree, `make constants` rewrote all four files byte-identically.

## 4. `gen_fc4000_pages.py`

Its `--apply` wrote prom_a 0xFC4000-0xFC52F7 into `wsa1_prom_a.s` in the 2026-09-25 form.  Since then the
span moved to `wsa1/prom_a/modules/fc4000_fc53ff_digital_effect_screen_data.s` (98cabf6d5), its records became
macros (6e9ea3b49), its numbers names (6f6138c09) and the Widget pictograms `.incbin`s of bins built from
`images/Widget_*.png` (cfb2e8ab1).  Emitting "the current form" would mean regenerating hand-edited source, so
`--apply` is retired: it refuses and says what replaced each part, and `emit()` is gone (git history keeps
it).  The check mode reads only the reference ROMs and still prints `tiling 0xFC4000-0xFC52F8: OK, 68
objects`.  The other `--apply` generators in `notes/proma-2026-09-25/` predate the same module split; they
write no pixels, and their anchors are no longer in `wsa1_prom_a.s`.

## 5. Clean-checkout proof

`notes/media-build-2026-10-31/clean_checkout_proof.sh` no longer leaves anything writable in phase D:
`git ls-files -z | xargs -0 chmod a-w`.  Run on a fresh clone of 898af4ead (output:
`clean_checkout_proof-2026-10-31.txt`), it printed `PASS: clean checkout of open3/media-cleanup`: phase A built
7,033 converter outputs with no reference reachable; phase B all nine gates exit 0; phase C `git status
--porcelain` empty; phase D, every tracked file read-only, all nine gates exit 0 again and the 7,033 outputs
SHA-256-identical to phase A; phase E 93 extracted floppy media deleted, 4 models reproduced byte-for-byte.

## Gates and censuses in the lane worktree

At 898af4ead, after deleting `kn7000/build/*.labels`, with the absolute romset overrides of the brief: `make gate`
("PASS: every rebuilt ROM is byte-identical."), `make gate-wsa1` (the same), `make gate-floppy` ("All 6 kn7000
floppies reproduced byte-for-byte."), `make gate-kn7000` ("All 9 factory custom-style banks reproduced
byte-for-byte."), `make gate-kn6000`, `gate-kn6500`, `gate-kn2400`, `gate-hdsx3` and `make -C kn7000
symbols-check`: all exit 0.  Read-only censuses: `data_incbin_census.py` prints a table identical to
`docs/coverage/data-incbin-2026-10-31-02.txt`, and `doc_quality_census.py` figures identical to
`doc-quality-2026-10-31-02.txt`: nothing rose.  The dispatch census was not rerun: no change here touches a
table, a label or an instruction (the source edits are comment-only).

## Regeneration order (for the integrator)

Nothing here is a generated output that has to be regenerated after merging.  `make gallery` now also writes
`IconSpriteSheet.png` (pixel-identical to the website's copy).

## Shared files touched

- root `Makefile`: the table-data image rule's prerequisites (one line), `decompress-help-databases`, the
  blob-audit comment, `gallery` (one line), the legacy HD-AE5000 ASL rule (`ASL_HDAE_SLICES`).
- `.gitignore`: one rule (the stamps).
- `kn7000/`, `kn2400/`, `kn6000/`, `kn6500/` `Makefile`: the `constants` rule.
- `notes/media-build-2026-10-31/clean_checkout_proof.sh` and `README.md`; repo-root `CLAUDE.md` (the media
  section and the MN10300 siblings paragraph).

## Website page draft

For `media-files.md`, replacing the section "What is left":

> ### What is left
>
> Nothing in this list.  On 2026-10-31 (lane media-cleanup):
>
> - the 191 colour renders that used to sit in `table_data/images/icons/` were deleted.  They duplicated
>   `table_data/images/icons_png/`, the indexed PNGs the build converts, and `scripts/analysis/extract_icons.py`
>   now paints those (`make gallery` writes the sprite sheet).  The eight raw blobs that were byte-for-byte
>   slices of the table-data and HD-AE5000 reference images (`table_data/includes/icon_pixel_data.bin`,
>   `icons_to_strings.bin`, `wallpaper1_to_icons.bin`, `hdae5000/includes/code_*.bin`) were deleted too.  No
>   build read them; the maintenance commands that did read the same bytes from the reference image.
> - the C-divergence patcher's stamps are build state, no longer committed.  A missing stamp makes the
>   patcher recompile that bin first, so it can never patch a bin twice.
> - the MN10300 trees' `src/constants.inc` is committed source, rewritten only by `make constants`.
> - the one-shot generator that wrote the SX-WSA1R widget pages as pixel rows no longer writes anything.
>
> The probe's limit stays: a picture under a label that names no picture class, held as typed rows, is not
> seen.
