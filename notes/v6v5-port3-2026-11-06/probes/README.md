# Probes of lane open12/v6v5-port3

Run from the repository root, with the tree built (`make all`).

| script                | question it answers                                                                                                                                      | run                                                                                                     |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `unplaced_members.py` | which top-level members of a tree's C blob, by a name pattern, reach the image? (offset range from the compiled C's DWARF, and the slices that place it) | `python3 notes/v6v5-port3-2026-11-06/probes/unplaced_members.py v6 naka_technichord_part.bin MPVersion` |

`unplaced_members.py` reuses `notes/v6v5-port2-2026-11-06/probes/rawsites.py`'s DWARF reader.  "placed by []" means no
`.incbin` of the tree places any byte of the member.  Used for RAM_MPVersion_Window (the MPVersion records of
naka_technichord_part.c) and the IvMPver class definition (`naka_sound_menu_drawbar.bin 'classdef_161_36|IvMPver'`):
placed by [] in v6 and v5, placed in v7.
