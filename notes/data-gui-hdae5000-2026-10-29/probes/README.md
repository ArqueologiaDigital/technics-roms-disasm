# Probes of the HD-AE5000 GUI lane (2026-10-29)

Each script reads the reference images in `original_ROMs/` (and, where it says so, the built ELF
for one label address). Run them from the repo root after `make`.

| script               | question it answers                                                                                                      | command                                                                |
|----------------------|--------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `tree_preorder.py`   | Is the object table the preorder walk of the tree its super / sub / next / prev links describe (so nesting is lossless)? | `python3 notes/data-gui-hdae5000-2026-10-29/probes/tree_preorder.py`   |
| `editsw_geometry.py` | Does every `editsw` value name the LCD switch next to the object (COL1-8, LEFT/RIGHT rows 1-5)?                          | `python3 notes/data-gui-hdae5000-2026-10-29/probes/editsw_geometry.py` |

Signals read: the object table and name table (located from `HDAE5000_Handler_Registration`'s
`RegisterObjectTable` operands for tables 0x7F / 0x37F), each record's words at +4 / +6 / +8 / +10
(links) and +14..+21 (rect x1, y1, x2, y2), and the `editsw` field at the class's propname offset.
`tree_preorder.py` passes when it prints `PASS`; `editsw_geometry.py` passes when each side-row value
has one side and one row band (y 42-49, 84-92, 126, 168, 204-211) and the column values sit on the
bottom row (y 227-230). Both passed for v2.06i and v2.01i on 2026-10-29.
