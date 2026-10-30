# callee-walk probes

Lane callee-walk of the open-items effort (2026-10-30): the reader walk (`kn7000/tools/data_readers.py`,
`Reader(callee=True)`) follows a block's address into the routine it is passed to, and
`kn7000/tools/gen_data_s.py` types the block as a record of what that routine reads through the argument.
See `../callee-walk/README.md`.

| script                 | question it answers                                                                                                                                                                                                                                                                                                                            | run (from the repository root)                                                                               |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| `callee_walk_stats.py` | Per tree (KN7000 941 / 942 / 935 / 893, KN6000, KN6500, KN2400, HD-SX3): how many pieces and bytes gen_data_s.py writes as reader rows (read / address only / string) at the lane's base and now; how many blocks are records of what a routine reads through its argument; and, with `--reasons`, why each address-only piece left stays rows | `python3 kn7000/notes/callee-walk-probes/callee_walk_stats.py [--base REV] [--head REV] [--reasons]`         |
| `callee_off_on.py`     | For one gen_data_s.py profile: how many data-region bytes are typed items with the callee walk off (`readers_callee` False) and on, and which bytes are typed in one run only, by item kind: does the walk lose typed coverage anywhere? It writes both runs' sources into the scratch directory, never into the tree                          | `python3 kn7000/notes/callee-walk-probes/callee_off_on.py --profile 941 --scratch ~/compartilhado/tmp/<dir>` |

The signal is the header comment gen_data_s.py writes above each piece: `# N bytes read by ...` /
`# N bytes the code takes the address of: ...` / `# a string, N bytes ...` for reader rows, and
`Label:\t# REC_X (N bytes): the layout F 0xADDR reads through its argument S ...` for a callee record (a
following `# then K x uW up to the next label` adds its tail).  The reasons are the text after the row
kinds in an address-only header, which `gen_data_s.arg_why()` writes from the walk's `arg_skip` /
`arg_kinds()` (a library routine, a byte loop, no fixed read, one field at +0, a stored argument) or
"not seen reaching a call".  The script reads the files with `git show` at `--base` (default `e611d4eaf`)
and from the working tree (or `--head`), as bytes.
