# gui-data-region probes

| script        | question it answers                                                              | run (from `kn7000/`, after a build)                                                         |
|---------------|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `gap_kinds.py` | what kinds of bytes a build's typed data region still leaves as `.incbin_range` | `python3 notes/gui-data-region-probes/gap_kinds.py src/program/data baserom/kn7000_program.rom` |

The tools that type the region and check it are in `kn7000/tools/` (see `../gui-data-region/README.md`).
