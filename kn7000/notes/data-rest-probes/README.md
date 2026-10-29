# data-rest probes

Lane kn7000-data-rest (2026-10-29): what the typed data regions of the KN7000 program builds still
leave as `.incbin_range`, and where.  The tools that type the region are in `kn7000/tools/`
(`data_readers.py`, `data_structs.py`, `gen_data_s.py`); see `../data-rest/README.md`.

| script        | question it answers                                                       | run (from `kn7000/`, after a build)                                                              |
|---------------|---------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `pieces.py`   | which generic pieces are biggest, under which label, what their bytes are | `python3 notes/data-rest-probes/pieces.py src/program/data baserom/kn7000_program.rom 60`        |
| `bands.py`    | in which 16 KB bands the generic bytes are                                | `python3 notes/data-rest-probes/bands.py src/program/data`                                       |
| `kindlist.py` | which pieces gap_kinds.py puts in one kind (text, pointers, small, other) | `python3 notes/data-rest-probes/kindlist.py src/program/data baserom/kn7000_program.rom text 40` |

The kind table in the lane README is `../gui-data-region-probes/gap_kinds.py`.
