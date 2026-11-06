# Probes of lane open11/v6v5-port2

Run from the repository root, with the tree built (`make all`).

| script                | question it answers                                                                                                                                   | run                                                                                                    |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `rawsites.py`         | where are the raw bytes of a tree's C-divergence json: which top-level C member (DWARF), and what does the C compile there vs what the tree needs?    | `python3 notes/v6v5-port2-2026-11-06/probes/rawsites.py v6 DIR` (DIR from `ported_c_rebase.py --need`) |
| `bass_name_tables.py` | what do the 64 work-RAM pointers after Naka_DrawbarReg_Table and the four 13-entry blocks they point at hold (MainChordPre_AppendChordSuffix's read)? | `python3 notes/v6v5-port2-2026-11-06/probes/bass_name_tables.py v6` (also v10, v9, v7, v5)             |

`bass_name_tables.py` reads `original_ROMs/kn5000_<tree>_program.rom` (git-ignored, copied by `make`) and
the tree's symbols file; it prints, per chord type, the block its pointer names, and per block and root the
note-name table and its twelve names.  Its output for v10 and v6 is the same apart from the first line (the
RAM addresses: v6's table and pointer array sit 4 bytes lower, RAM 0x3F1E0 / 0x3F2F4 against 0x3F1E4 /
0x3F2F8).
