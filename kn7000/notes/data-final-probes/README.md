# data-final probes

Lane kn7000-final of the data-semantics effort (2026-10-30): the last generic bytes of the KN7000
program builds' typed data regions, the review of what they declare opaque, and the SP7001 table
plug-in's GUI.  The tools that do the typing are in `kn7000/tools/` (`data_readers.py`,
`gen_data_s.py`, `gen_table_s.py`); see `../data-final/README.md`.

| script                 | question it answers                                                                                                                                                                                                                                                | run (from `kn7000/`, after a build)                                                                                     |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `generic_readers.py`   | For every generic `.incbin_range` of a build's data region (or, with `--opaque`, every declared-opaque one): which label precedes it, its first bytes, and which instructions load, store, take as a base or pass to a call an address in it                       | `python3 notes/data-final-probes/generic_readers.py [--profile 941] [--opaque] [--top N]`                               |
| `reader_ext_stats.py`  | What the extended reader walk (`data_readers.Reader(ext=True)`: stack slots, joined address sets, return values) adds: distinct accesses with and without it, accesses through a T value, the functions that return one of a set of records                        | `python3 notes/data-final-probes/reader_ext_stats.py [--profile 941]`                                                   |
| `reader_rows_stats.py` | Lane generic-zero: per tree (the KN7000 builds and the four siblings), how many pieces and bytes gen_data_s.py's last fallback, reader_rows(), wrote as rows (read at a known width / address only taken / strings), i.e. what the generic `.incbin_range`s became | `python3 kn7000/notes/data-final-probes/reader_rows_stats.py` (from the repository root; reads the committed data_NN.s) |

The signal both read is `tools/data_readers.py`'s access list: an access is (key, field offset,
width, kind, instruction, CPU address); a key `("abs", A)` is the fixed address A, `("rec", B, S)`
field o of S-byte records at B, `("ptr", ("fld", K, o))` what the 32-bit field K+o points at, and
`("ptr", ("tgt", {A1, A2, ...}))` one of the records A1, A2, ... (the extended walk's T value).
