# Probes of lane siblings-final (2026-10-30)

The probes behind `../siblings-data-final/README.md`. Each answers one question about the typed data
regions of the four MN10300 siblings (`kn6000`, `kn6500`, `kn2400`, `hdsx3`). Run them from the
repository root; they read the committed sources and the git-ignored reference images (`make -C <model>
baserom`).

| script                | question it answers                                                                                     | run                                                                                                            |
|-----------------------|---------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `untyped_regions.py`  | where the largest runs of `.incbin_range` pieces (generic or declared opaque) are, and what they hold   | `python3 kn6000/notes/siblings-data-final-probes/untyped_regions.py kn6000 40 [--kind opaque]`                  |
| `reader_accesses.py`  | which instructions read, write, index or pass the data at one address (the evidence behind a field name) | `python3 kn6000/notes/siblings-data-final-probes/reader_accesses.py kn6000 0x4C3DF8EC`                          |
| `hash_chains.py`      | whether a `{u16 mult, u16 nbuckets}` + buckets block is a hash table whose keys sit in their buckets      | `python3 kn6000/notes/siblings-data-final-probes/hash_chains.py kn6000/baserom/kn6000_program.rom 0x4C000000 0x4C3E8680 4` |

What the signals mean:

- `untyped_regions.py`: per run its size, file range, CPU address, piece count, how much of it is declared
  opaque, the label before it and its first 20 bytes. A run is consecutive `.incbin_range` pieces with only
  labels and comments between them.
- `reader_accesses.py`: one line per distinct access: the key (`('abs', A)` a fixed address, `('rec', B, S)`
  field of the S-byte records at B, `('ptr', ...)` through a pointer field), the field offset, the width
  (0 = an address passed or loaded as a base), the kind (`ld`, `st`, `arg a0`, `base`, `step`), the routine
  label and its address, and the instruction.
- `hash_chains.py`: pass means "keys in the wrong bucket 0" and one entry spacing. Measured 2026-10-30 on
  KN6000 v7.1: ToneKeyHash 1,139 buckets / 1,896 entries of 20 bytes, ShortKeyHash 1,907 / 2,898 of 12,
  BankKeyHash 1,139 / 1,375 of 12, every key in its bucket (mult 1).
