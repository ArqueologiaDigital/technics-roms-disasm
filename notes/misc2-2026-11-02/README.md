# Lane open6/misc2 (2026-11-02): floppy leftovers, SLIDE4K without a reference, name-carrying macros, notes errors

Wave 6 lane `misc2` (`~/compartilhado/tmp/open-items-wave6/WAVE6.md`).  Items: the non-KN5000 floppy rows of
`notes/open-items/REGISTER.md` (N-391cb1d1 / O-wsa1-floppy-unknown-dump-66b9a5, N-4c66be6c, N-e140c8dc /
O-kn6000-floppy-unknown-dump-397763 / O-kn7000-floppy-unknown-dump-397763), the tooling rows N-700df83b and
N-f67b155c, the documentation row N-3a365d90, and the 17 rows of `notes/open-items/notes-errors-2026-10-31.md`.
Probes: `probes/README.md`.

## N-700df83b: compress_lzss.py encodes SLIDE4K with lzss_j.encode, no reference

**CLOSED.**  `scripts/build/compress_lzss.py` without `--reference` now runs `floppy/tools/kd/lzss_j.py`'s
`encode()` with N = 4096, F = 18, a 4-bit length (`compress_slide4k`; the old greedy coder is kept as
`compress_slide4k_greedy`), and takes `--pad BYTE` like `compress_slide8k.py`.  `probes/slide4k_encode_exact.py`
checks it against all 22 factory SLIDE4K streams, byte for byte:

| result   | streams                                                                             |
|----------|-------------------------------------------------------------------------------------|
| EXACT    | 14: demo songs 00, 02-05, 09, 11, 13-16 and the v1.40 / v1.41 / v1.42 update images |
| PAD 0xNN | 6: demo songs 01 (0x00), 06 (0x7D), 07 (0x7D), 08 (0xC5), 10 (0x43), 12 (0x0B)      |
| TAIL n   | 2: demo songs 17 (15,957 B) and 18 (75 B)                                           |

**The pad byte.**  Demo songs 00-17 run end to end, and every block starts on an even address: after an
odd-length stream comes one byte the decoder never reads.  For song 00 it is 0xFF, which the source's `.org`
already writes; for the six above it is inside the factory slice.  The Makefile records it
(`DEMO_PRESET_PAD_NN`) and passes it as `--pad`, as it does for the help databases' SLIDE8K pads.  Nothing
derives the value.

**The two tails** (`probes/slide4k_stale_tails.py`).  Song 17's slice has 15,957 B after its 3,357-byte stream:
- its first 398 B repeat the stream's own last 398 B (ROM 0x9F54E8..0x9F5675, again at 0x9F5676..0x9F5803);
- the other 15,559 B ("the old part") parse as SLIDE4K items ending on the slice's last byte;
- the old part equals the current song-18 (Feature Demo) stream in nine runs of 16-199 B, the stream offset
  12,425-12,476 B ahead.  In the 199-byte run the parse hits all 144 of the song-18 stream's item boundaries;
- its last 75 B are song 18's 75-byte tail;
- no 16-byte piece of it occurs anywhere else in 58 images, except inside song 18's slice (the runs above).

So both tails are the end of one older SLIDE4K stream, close to the current Feature Demo's.  [INFERENCE] An
earlier Feature Demo; demo songs 16 and 17 and the current song 18 were written over it.  A SLIDE4K
reference reads the window of everything decoded before it, and that stream's start is gone, so its plain
bytes are unknown and no source can regenerate it.  `table_data/kn5000_table_data.s` now spells the slices as:

| label                              | bytes  | spelled as                                                                                       |
|------------------------------------|--------|--------------------------------------------------------------------------------------------------|
| `DemoSongPreset17` payload         | 3,357  | `demo_preset_17_compressed.bin`, generated (MIDI + sidecar, the factory encoder)                 |
| `DemoSongPreset17_StreamEndCopy`   | 398    | `.incbin` of that payload, 2959, 398: generated (a second copy of its last 398 B)                |
| `DemoSongPreset17_StaleStreamTail` | 15,559 | `.incbin "original_ROMs/kn5000_table_data.rom", 0x1f5804, 15559`, `census: opaque -- compressed` |
| `DemoSongPreset18` payload         | 27,881 | `demo_preset_18_compressed.bin`, generated                                                       |
| `DemoSongPreset18_StaleStreamTail` | 75     | `.incbin "original_ROMs/kn5000_table_data.rom", 0xe6cf4, 75`, `census: opaque -- compressed`     |

Until now those 15,634 opaque bytes rode inside the two payloads, which `compress_lzss.py --reference` copied
from the factory slices and the censuses counted as generated.  So two figures ROSE because the old ones
undercounted, not because anything regressed:
- `kn5000_source_coverage.py`'s table data verbatim debt: 0 B -> 15,634 B (99.3 % source). CLAUDE.md's
  Architecture table now says so.
- `data_incbin_census.py`'s `kn5000-tabledata` row (read-only run): generated 350 / 1,303,899 -> 351 /
  1,288,265 (the copy is a new entry; the payloads lost 16,032 B), opaque 0 / 0 -> 2 / 15,634, generic 0.  The
  "before" bytes are the base's payload sizes (with the tails); the census sizes whatever files are built.

**Build changes.**
- `Makefile`: the demo payloads and the three update images are encoded with no `--reference` or `--strict`.
  The update images keep their `cmp` against the factory file.
- `verify-demo-presets` now compares each payload with the first bytes of its factory slice, and exits 1 on a
  mismatch (it used to print MISMATCH and exit 0).
- `table_data`'s object depends on `original_ROMs/kn5000_table_data.rom` (tracked), for the two tails.
- The census marker text (`scripts/tools/mark_census_generated.py`, `scripts/converters/mark_tabledata_media_sources.py`)
  no longer says "replayed".
- `table_data/includes/demo_presets/README.md` and the module comments say what the build does now.

Checked: every payload's `make verify-demo-presets` line is OK, the three update images `cmp` equal, and the
rebuilt table data image is byte-identical (`cmp` with `original_ROMs/kn5000_table_data.rom`); `make gate`
below.

## N-3a365d90: CLAUDE.md v6 / v5 figures, Mines workarounds

**CLOSED.**
- The repo-root CLAUDE.md's v6 / v5 rows already read 13,756 B / 15,910 B on main (50ce7e5f2, lane
  kn5000-ports).  The table_data row is corrected here (above).
- `../Mines` commit 301557d: its CLAUDE.md "LLVM Backend Bugs (Active Workarounds)" section now says none
  is active (bugs 10 and 11 were resolved 2026-02-28, 8b1d85e).  Its "Assembler Limitations" list was stale
  too, so it was retired with a probe, `platforms/kn5000/probes/asm_limitations.sh`.  The pinned llvm-mc
  assembles `ei 7`, `di`, `ld xwa, (xiz+0x0168)` and `ld a, (0x200000:24)`, all four PASS.
- `LLVM_TLCS900_BUGS.md`'s limitations section gets the same status line.  It also gets a correction: the
  old workaround's "DI = EI 0" is wrong; DI is EI 7.
