# Lane open4/misc (2026-10-31): tooling, media and documentation items

Wave 4 lane `misc`: the unowned ACTIONABLE N-* rows of the register's media, tooling and documentation
sections, the BLOCKED rows whose blocker was in this repository's own notes, the stale website text the
register lane found, the two LLVM bugs `../Mines/LLVM_TLCS900_BUGS.md` listed as active, and the KN5000 tone
generator's crystal.  Probes are in `probes/` (see `probes/README.md`).

## N-64f1f64d: 'J KD' LZSS is the KN5000's SLIDE8K, encoder included

**CLOSED.**  `probes/slide8k_vs_lzss_j.py` decodes each of the table data's six SLIDE8K help streams
(`original_ROMs/help_db_<lang>_compressed.original.bin`) with `floppy/tools/kd/lzss_j.py` and with
`scripts/build/decompress_slide8k.py` (same output), then re-encodes the decoded 0x9000 bytes with
`lzss_j.encode` (H. Okumura's LZSS.C, N = 8192, F = 10) and compares the decisions:

| stream       | factory stream | read by the decoder | encode() | decisions                                   |
|--------------|----------------|---------------------|----------|---------------------------------------------|
| english      | 13,471 B       | 13,470 B            | 13,470 B | all 7,366 the same, every byte the same     |
| german       | 13,717 B       | 13,716 B            | 13,716 B | all 7,539 the same                          |
| french       | 14,631 B       | 14,630 B            | 14,630 B | all 8,120 the same                          |
| spanish      | 14,819 B       | 14,818 B            | 14,818 B | all 8,148 the same                          |
| indonesian   | 13,767 B       | 13,766 B            | 13,766 B | all 7,589 the same                          |
| german_stale | 16,111 B       | 16,110 B            | 9,402 B  | the 5,339 up to output 0x55E0 the same      |

The byte each live stream has past what the decoder reads is the alignment pad (0x20, 0x7F, 0xCF, 0xCD,
0xCE).  german_stale parts at output 0x55E0, exactly where `table_data/help_databases.s` says the block was
cut (the Music Stylist pointer tables overwrote its tail): encoding only those first 0x55E0 bytes gives its
5,339 decisions exactly (encoding all 0x9000 decoded bytes parts at item 5,339).  So the factory SLIDE8K encoder is Okumura's, and the help databases need no
reference stream:

- `scripts/build/compress_slide8k.py`: without `--reference` it now runs `lzss_j.encode` (the old greedy
  coder is kept as `compress_slide8k_greedy`); `--pad BYTE` appends the alignment byte.
- `Makefile`: the five live payloads are built with `--pad $(HELP_DB_PAD_<lang>)`; the pad values are
  recorded there.  Only german_stale (verification only, not a ROM input) is still replayed.
- `table_data/help_databases.s` and `scripts/tools/mark_census_generated.py`: the census markers and the
  module header no longer say "replayed"; the header's claim that the last flag byte's unused bits are
  NONZERO "in these blocks" was wrong for the five live blocks (they are zero; only the cut stale stream
  ends in 0xA0) and is corrected.

Also measured (a finding, no build change): **SLIDE4K is the same encoder with N = 4096, F = 18.**
`probes/slide4k_vs_okumura.py` re-encodes the 19 demo presets and the three Sub-CPU update images
(v1.40/v1.41/v1.42) with `lzss_j.encode` re-parameterised, and all 22 make the factory decisions.  Two preset
slices carry bytes past the end of their stream: `demo_preset_17_compressed.original.bin` is 19,314 B but its
stream (header size 0x1700) is 3,357 B, and preset 18's is 27,956 B for a 27,881-byte stream.
`scripts/build/compress_lzss.py` could therefore also drop its reference for the stream part; the slices'
tails would still need a source of their own.  Not done here: listed as a follow-up below.
