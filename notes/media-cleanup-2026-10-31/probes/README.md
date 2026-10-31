# media-cleanup probes

| script                    | question it answers                                                                                                                                                  | run (repository root)                                                   |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `compare_icon_renders.py` | do the 191 deleted `table_data/images/icons/` renders hold anything the committed `icons_png/` does not?  PASS = every `Icon_NNN.png` and the sprite sheet reproduce | `python3 notes/media-cleanup-2026-10-31/probes/compare_icon_renders.py` |
