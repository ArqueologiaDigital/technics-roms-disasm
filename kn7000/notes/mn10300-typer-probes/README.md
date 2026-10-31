# mn10300-typer probes

Lane `mn10300-typer` of the open-items effort (2026-10-31): the struct typer and the reader walk of
`kn7000/tools/gen_data_s.py`, `data_structs.py`, `data_readers.py` and the new
`kn7000/tools/mn10300_insn_len.py`, applied to every MN10300 tree (KN7000 941 / 942 / 935 / 893, KN6000,
KN6500, KN2400, HD-SX3).  The notes are `../mn10300-typer/README.md`.

| script                 | question it answers                                                                                                                                                                                                                                                                                                         | run (from the repository root)                                                                                     |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `insn_starts_check.py` | Does the instruction-start oracle gen_data_s.py asks before it types a word as a pointer into code (`mn10300_insn_len.oracle()`: the KN7000 MAME core's length decoder, run forward from the code's function headers and entry / branch labels) say "start" exactly where kn7asm assembled an instruction, in every tree? | `python3 kn7000/notes/mn10300-typer-probes/insn_starts_check.py [tree ...]` (trees as `code_in_data.py --list`)    |
| `typer_stats.py`       | For one gen_data_s.py profile, with the lane's rules off (the generator as before) and on (all, one alone with `--only R`, all but one with `--drop R`): typed bytes, reader-row pieces / bytes, opaque pieces / bytes, the generated sources' line churn, and the bytes typed in one run only (does a rule lose coverage?) | `python3 kn7000/notes/mn10300-typer-probes/typer_stats.py --profile 941 --scratch ~/compartilhado/tmp/<dir> [--only R]` |

The code-in-data flags are `../code-island-probes/code_in_data.py`'s `P` column (a `.long` landing inside
an instruction), run on the committed sources after the regeneration.

## What the signals are

- `insn_starts_check.py` assembles the tree with kn7asm (the `Recorder` of `code_in_data.py`) and asks the
  oracle about every CPU address of every byte an instruction line emits: a first byte must be a start,
  every other byte must not.  "Undecided" is a byte before the first anchor or further than 0x10000 past
  one; gen_data_s.py then keeps its old test (any code address may be a pointer).
- `typer_stats.py` sets the environment variable `GEN_DATA_S_OFF` (a comma list of
  `gen_data_s.FEATURES` names) for each generator run, writes the sources into the scratch directory and
  compares: typed bytes are the byte ranges of the generator's items; reader rows are the headers
  `# N bytes read by ...`, `# N bytes the code takes the address of: ...`, `# a string, N bytes with its
  pad, read by ...`; opaque pieces are a `# census: opaque -- <kind>` line and the `.incbin_range` after it;
  line churn is `diff` of the two runs' `data_NN.s`, `data_structs.inc` and `labels.sym`.  The "off" run
  reproduces the committed sources byte for byte (checked for 941 and the HD-SX3 at the lane's base).

The figures are in `../mn10300-typer/README.md`.
