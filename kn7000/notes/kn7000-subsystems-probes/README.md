# Probes of lane open14/kn7000-subsystems (2026-11-07)

Read-only scripts behind `../kn7000-subsystems/README.md`.  Run from the repository root.
`routine_graph.py` and `check_proposals.py` read `kn7000/build/kn7000_program.labels`, written by
`make -C kn7000 build/kn7000_program.rom`.

| probe                | question it answers                                                                                                                                                                                               | command                                                                                                                                          |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `routine_graph.py`   | where in program 941 do the func_ routines sit with the most evidence (named callers / callees, strings, named data), which siblings pair each one, what is one body                                              | `python3 -I kn7000/notes/kn7000-subsystems-probes/routine_graph.py --clusters` / `--rank --range LO:HI` / `--list --range LO:HI` / `--show ADDR` |
| `check_proposals.py` | is every proposed name well formed, new in every MN10300 tree, on a 941 func_ routine start, with an evidence class; prints the `.sym` rows                                                                       | `python3 -I kn7000/notes/kn7000-subsystems-probes/check_proposals.py FILE.tsv ... [--exclude FILE] [--rows]`                                     |
| `name_tally.py`      | how many routines the lane's section of `kn7000_manual.sym` names, per address range and evidence class                                                                                                           | `python3 -I kn7000/notes/kn7000-subsystems-probes/name_tally.py`                                                                                 |
| `match_ic18.py`      | which IC18 boot-ROM routine (kn7000_ic18.sym) each program-941 routine of a range is the same code as, by normalized instruction sequence (difflib ratio): the evidence of the 152 `FdcPrg*` / `FdcStrap3*` names | `python3 -I kn7000/notes/kn7000-subsystems-probes/match_ic18.py 48400000 48404D10`                                                               |
| `placeholders.py`    | how many routines of each MN10300 tree are still func_<ADDR> (the figure of `../uitron3-function-codes/function_codes.py --placeholders`, without the spec)                                                       | `python3 -I kn7000/notes/kn7000-subsystems-probes/placeholders.py [--rev REV]`                                                                   |

Outputs kept here:

| file                           | what                                                                                      |
|--------------------------------|-------------------------------------------------------------------------------------------|
| `clusters-92b5cc4a7.txt`       | `routine_graph.py --clusters` at the lane's base: func_ / named routines per 64 KB window |
| `name-tally.txt`               | `name_tally.py` on the committed section                                                  |
| `placeholders-92b5cc4a7.txt`   | `placeholders.py` at the base                                                             |
| `placeholders-after.txt`       | the same on the regenerated tree                                                          |
| `sibling-census-92b5cc4a7.txt` | `../sibling-names-probes/sibling_name_census.py` at the base                              |
| `sibling-census-after.txt`     | the same on the regenerated tree                                                          |

The signal `routine_graph.py` reads: in the generated `.s`, a routine starts at a `func_<8 hex>`
label or at a label a symbol file names (not `loc_<ADDR>`, `.L*`, `X_entry`); `call` / `calls` to
another routine's label or `_entry` is a call, `jmp` / `bra` to one is a tail call, any other operand
naming a routine hands it over as a pointer; `Str_*` labels are resolved to their `.asciz` text in the
data sources.  The sibling pairing (`sib=`) is the siblings' `notes/routine-map-kn7000.tsv`.
