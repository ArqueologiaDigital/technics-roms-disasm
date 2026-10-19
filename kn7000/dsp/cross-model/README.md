# Cross-model effects-DSP comparison (KN6000 / KN6500 vs KN7000)

The KN6000, KN6500 and KN7000 all use the **same** effects DSP — an Analog
Devices ADSP-21065L (IC304 on the KN6xxx, IC306 on the KN7000, part
`S21065LKS240`) — and all host-boot it from an 80-record download pool embedded
in their MN10300 program flash. This directory holds the KN6000/KN6500 pool,
disassembled with the same [`../../tools/gen_dsp_records.py`](../../tools/gen_dsp_records.py)
used for the KN7000, so the three can be compared directly. See the main
[`../README.md`](../README.md) for the record/block format and
`kn7000_mame/notes/dsp-effect-catalog.md` for the effect analysis.

## Pool locations

| Model | program image | pool (file offset) | pool (CPU) |
|---|---|---|---|
| KN7000 | `baserom/kn7000_program.rom` | `0x2BCEC4..0x2CE68D` | `0x486BCEC4..` |
| KN6000 | `kn6000_program_full.bin` (from the update disks) | `0x387064..0x398809` | `0x48787064..` |
| KN6500 | interleaved even/odd program ROMs | `0x3128E8..0x32408D` | `0x487128E8..` |

## The three key findings (byte-verified)

1. **KN6000 and KN6500 ship byte-identical DSP firmware — 80/80 records match.**
   One effects program set serves both models. Only `kn6000/` is kept here; the
   KN6500 pool is identical.

2. **Versus the KN7000, every record's data is identical but the code was
   revised: DM = 80/80 identical, PM = only 3/80 identical.** The KN7000 kept
   each effect's DM (coefficients / parameter tables) byte-for-byte and rebuilt
   the SHARC PM (instruction code). So the KN7000 is a *code* revision over the
   same effect architecture and the same tuning.

3. **The kernel confirms the pattern**: all four of its DM blocks
   (`0x9800/0x9C40/0xC000/0xC302`) are identical to the KN7000's, while all four
   PM blocks (`0x8000/0x8300/0x8400/0x8D00`) differ.

Consequence: the KN7000 effect **catalogue and DM-level annotations transfer
directly** to the KN6000/KN6500 (same coefficients, same type→record structure);
only the disassembled PM code differs, and diffing `kn6000/recNN_*.asm` against
`../recNN_*.asm` isolates exactly what the KN7000 code revision changed.

## Regenerating

The KN6xxx program images live outside this (KN7000-only) repo, so there is no
Makefile rule; regenerate with an explicit `--rom`:

```
python3 tools/gen_dsp_records.py \
  --rom /path/to/kn6000_program_full.bin --pool 0x387064 0x398809 \
  --unidasm ../mame-sony-video/unidasm \
  --manifest /dev/null --symdir /nonexistent \
  --bindir build/dsp-kn6000 --out dsp/cross-model/kn6000
```

The listings are committed (like the KN7000 ones); the raw `build/dsp-kn6000/`
extracts are git-ignored.
