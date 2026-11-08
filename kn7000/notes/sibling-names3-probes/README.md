# Probes of lane open14/sibling-names3 (2026-11-07)

Scripts behind `../sibling-names3/README.md`.  Run them from the repository root; they read the
committed generated sources (`<model>/src/program.s`, `src/labels.inc`, `src/symbols.inc`, the data
region's `labels.sym`) and the symbol files, and write nothing tracked (rows go to stdout).  The
census itself is wave 11's `../sibling-names-probes/sibling_name_census.py`.

| probe                  | question it answers                                                                                                                                     | command                                                                                                                      |
|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| `routine_graph.py`     | per routine: what its body names (callees, strings, GUI ids, events, RAM / I/O numbers) and who calls it; where the func_ routines cluster              | `python3 -I kn7000/notes/sibling-names3-probes/routine_graph.py kn6000 --clusters` (`--evidence`, `--brief --dump NAME ...`) |
| `wrapper_bodies.py`    | which func_ routines are the whole work of a named trampoline (`[add -N, sp] / call X / ret`), so that they take `<name>_Impl`                          | `python3 -I kn7000/notes/sibling-names3-probes/wrapper_bodies.py kn6000 kn6500 kn2400 [--rows]`                              |
| `xapr_slot_callers.py` | which host routine calls which XAPR plug-in header slot (the slot names read from `hdsx3/src/program.s`)                                                | `python3 -I kn7000/notes/sibling-names3-probes/xapr_slot_callers.py kn6500 [--rows]`                                         |
| `file_type_bodies.py`  | which routines build a disk file's name with the extension table's builder for one file type and open it "rb" / "wb"                                    | `python3 -I kn7000/notes/sibling-names3-probes/file_type_bodies.py kn2400 0x486D0F12 [--rows]`                               |
| `port_hand_names.py`   | which routine / RAM address of sibling B is the one a hand row of sibling A names (same masked body, same place in the routine order); with its audit   | `python3 -I kn7000/notes/sibling-names3-probes/port_hand_names.py kn6000 kn6500 [--report]`                                  |
| `hand_names_check.py`  | does every hand row of this lane cite an evidence class, name a func_ routine (or a data / RAM address), and use a name no other file of the model uses | `python3 -I kn7000/notes/sibling-names3-probes/hand_names_check.py kn6000 kn6500 kn2400`                                     |

The signals.  A routine is a column-0 label that is not local (`<x>_entry`, `<x>_L<hex>`,
`loc_<ADDR>`, `.L*`) and is followed by an instruction; a placeholder is exactly
`^func_[0-9A-F]{8}$` (WAVE13.md's probe-hygiene rule).  `port_hand_names.py` masks every symbol
and every hex number of 5 or more digits, aligns the two routine lists with difflib, keeps pairs in
equal runs of 3 or more (or bodies of 12 or more instructions), refuses a body that repeats among the
8 routines around it, then pairs bodies of 12 or more instructions that are unique in both images.
A RAM pair needs the same operand place in every paired routine and one address on each side.

Outputs kept here (the commit that adds or changes each one is the tree it measures):

| file                   | what                                                                                              |
|------------------------|---------------------------------------------------------------------------------------------------|
| `clusters-base.txt`    | `routine_graph.py kn6000 / kn6500 / kn2400 --clusters` at the lane's base 92b5cc4a7               |
| `census-92b5cc4a7.txt` | `../sibling-names-probes/sibling_name_census.py` at the base                                      |
| `census-after.txt`     | the same after the lane's regeneration                                                            |
| `port-audit.txt`       | `port_hand_names.py kn6000 kn6500 --report` and `kn6000 kn2400 --report`, and the file-type audit |
