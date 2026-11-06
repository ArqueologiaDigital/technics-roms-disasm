# Probes of lane mn10300-data4 (wave 12, 2026-11-06)

Each script answers one question about the MN10300 data regions; run them from the repository root.  The
lane's notes are `../mn10300-data4/README.md`.

| script                   | question it answers                                                                                                                                                                                                                              | command                                                                                                        |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `fx_param_lists.py`      | the SX-KN6000 / KN6500 effect DSP's per-type parameter lists (the 208-pointer table in the initialised-RAM image): does every block parse as func_4C155072 / func_4C155C08 read it, how many bytes, and how many of them are still census-opaque | `python3 kn7000/notes/mn10300-data4-probes/fx_param_lists.py [kn6000 kn6500]`                                  |
| `tg_image_regs.py`       | which MAIN TG register class each field of the KN6000 / KN6500 160-byte voice register image (func_4C0948CB_ArgA0 / func_4C094795_ArgA0) is written to                                                                                           | `python3 kn7000/notes/mn10300-data4-probes/tg_image_regs.py [kn6000 kn6500]`                                   |
| `string_ptr_runs.py`     | how many census-opaque bytes of the siblings are runs of words that are each 0 or a pointer to a printable NUL-ended string (what `gen_data_s.string_ptr_runs` types)                                                                            | `python3 kn7000/notes/mn10300-data4-probes/string_ptr_runs.py`                                                 |
| `plugin_regs.py`         | which RegisterObjectTable calls `milk_model.parse_calls` sees in the SP7001 plug-in's code (the class table at slot 0x2F4 must be among them, or gen_data_s.py --profile sp7001plugin stops)                                                     | `python3 kn7000/notes/mn10300-data4-probes/plugin_regs.py` (from `kn7000/`)                                    |
| `opaque_classes_diff.py` | per tree and per census class (the register's O- rows), the opaque pieces / bytes of a BEFORE copy of the data directories (a `git archive` of the base) and of this checkout                                                                    | `python3 kn7000/notes/mn10300-data4-probes/opaque_classes_diff.py DIR` (the docstring has the archive command) |

Signals: `fx_param_lists.py` passes when it prints `0 that do not parse` and, after the regeneration, `census-opaque
ranges in that span: 0 pieces`; `plugin_regs.py` when its first RegisterObjectTable row is slot `0x2f4` with class
`262148` (0x00040004, 942's Class class).
