# mn10300-data probes

Lane `mn10300-data` of the open-items effort (wave 6, 2026-11-02). The notes are `../mn10300-data/README.md`.
Run every probe from the repository root, with the reference images in place (`baserom/` of kn7000, kn6000,
kn6500, kn2400, hdsx3) and, for the KN7000 profiles, `kn7000/build/*.labels` (one `make -C kn7000 verify
verify-sp7001 verify-935 verify-893`). They write only into the scratch directory they are given.

| script            | question it answers                                                                                                                                                                                                                                                                                                                                         | run                                                                                                       |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| `data_stats.py`   | For one gen_data_s.py profile (or, with `--dirs BEFORE AFTER`, two committed data directories: typed bytes from labels.sym), with the lane's rules off (main c240d1c0b) and on (all, `--only R`, `--drop R`): typed bytes, reader-row pieces / bytes, opaque pieces / bytes, offset-named fields with a reader, line churn, bytes typed in the off run only | `python3 kn7000/notes/mn10300-data-probes/data_stats.py --profile 941 --scratch DIR [--only R] [--brief]` |
| `opaque_left.py`  | ../mn10300-rest-probes/opaque_groups.py pointed at a generator run's output: the opaque pieces left, by group and by the table above them; `--classes DIR`: by the census line's own class (the register's O- rows)                                                                                                                                         | `python3 -I kn7000/notes/mn10300-data-probes/opaque_left.py --tree 941 --dir DIR/941_on --by-table`       |
| `array_counts.py` | Where each struct array's record count comes from (a loop's end compare, a bounded index, a capped index, an inference): counts per class, `--list inferred` (N-92b0bf4c)                                                                                                                                                                                   | `python3 -I kn7000/notes/mn10300-data-probes/array_counts.py kn7000/src/program/data`                     |
| `split_tables.py` | Which tables a routine indexes with a bounded index past another label (a table the sources may still split in two, N-44fb32d4); `fixed` = the code names that label                                                                                                                                                                                        | `python3 kn7000/notes/mn10300-data-probes/split_tables.py --profile kn6000`                               |

## What the signals are

- "typed bytes": the bytes of the data region a generator item claims (`gen_data_s.Gen.items`, pickled by
  `../mn10300-typer-probes/typer_stats.run_one`); gap fill (`.space`, `.align`), reader rows and opaque
  pieces are not items.
- "opaque": a `# census: opaque -- unknown-dump: ...` line and the `.incbin_range` after it, pieces / bytes.
- "reader rows": the reader-row headers `typer_stats.ROWS` matches (the generic-zero fallback).
- "offset-named fields with a reader": `../mn10300-formats-probes/field_names_census.py` on the run's
  `data_structs.inc`.
- "typed in the off run only": bytes an off-run item holds that no on-run item holds; 0 means the rules
  lose no typed coverage.
- The off run must reproduce the committed sources: `diff -r <scratch>/<profile>_off <tree data dir>`
  differs only in data.s's include paths (checked for every profile, see the notes).
