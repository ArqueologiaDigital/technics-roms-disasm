# KN5000 ported trees: probes

Lane `open3/kn5000-ports`, 2026-10-31.  Notes: `../kn5000-ports-2026-10-31/README.md`.

| script                  | question it answers                                                                                   | run (repository root, trees built: `make all` or `make gate`)        |
|-------------------------|-------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| `ported_label_probe.py` | Does every label v6 / v5 inherited from v7 stand on the thing it names?                               | `python3 notes/kn5000-ports-probes/ported_label_probe.py [--tree v6]` |
| `link_script_names.py`  | Does every `Name = 0x...;` line of a main-program tree's C link scripts give the tree's ELF address? | `python3 notes/kn5000-ports-probes/link_script_names.py [v7 v6 v5]`   |

## ported_label_probe.py

Signals read, per tree T (v6, v5), each against v7:

- **registry**: every `RegObjTabl` registration (via `scripts/analysis/nakarest_objtab_map.py`, the
  table read from the ROM dump): Function / ApFunction / MainFunction tables with their name table at
  slot + 0x300, Viewable tables with their ResName table, Class tables (record and proc).  Key: (kind,
  slot, the firmware's own name string, occurrence).  Pass: one of v7's labels at the v7 address is
  among T's labels at T's address.
- **ptrtab**: every run of 32-bit words in the v7 ROM, from a v7 label to the next label, that are all
  v7 label addresses (registered tables left out).  Pass: entry k in T carries v7's name of entry k.
- **body**: the labels each label's body names in the sources; a T body that names one other label
  than v7's body votes "r_T should be r_7"; unanimous votes, decided by the bytes where T defines r_7
  too (`Content`, 32-byte windows with ROM pointers translated).
- Kinds: `MISMATCH` (a v7 name on another thing: a shift), `UNLABELLED` / `DROPPED` (a v7 name the port
  left out, the thing carries only a name of T's own), `UNDECIDED` (the bytes do not decide; listed for
  reading).  The goal is 0 MISMATCH rows; exit status 1 otherwise.

Result at the lane's last commit (`v6` / `v5`):

| check    | v6                                                    | v5                                                    |
|----------|-------------------------------------------------------|-------------------------------------------------------|
| registry | ok 4,829, MISMATCH 0                                  | ok 4,816, MISMATCH 0                                  |
| ptrtab   | ok 9,502, MISMATCH 0                                  | ok 9,498, MISMATCH 0                                  |
| body     | MISMATCH 0, UNDECIDED 4, DROPPED 212 (not by content) | MISMATCH 0, UNDECIDED 4, DROPPED 216 (not by content) |

At 43242446d (before the fixer) the registry check alone found 4 shifted entries in v6 and 16 in
v5 (the Bitmap and language-check ApFunctions of slots 0x121 / 0x122; v5's Kubo slot 0x128 run).

## link_script_names.py

Signal: `llvm-nm` of `rebuilt_ROMs/kn5000_<tree>_program.llvm.elf` against each `Name = 0xADDR;`
line whose name the ELF defines in ROM.  At 43242446d: v10 0, v9 2, v7 53, v6 4, v5 4 wrong lines.
After `port_symbolize_pointers.py relink`: v7 7 (refused: the image needs the old values), v6 0,
v5 0; v9 untouched (2).
