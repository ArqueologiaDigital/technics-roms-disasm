# mn10300-data2 probes

Lane `mn10300-data2` of the open-items effort (wave 10, 2026-11-06). The notes are `../mn10300-data2/README.md`.
Run every probe from the repository root. The generator runs need the reference images in place (`baserom/` of
kn7000, kn6000, kn6500, kn2400, hdsx3) and, for the KN7000 profiles, `kn7000/build/*.labels` (one `make -C
kn7000 verify verify-sp7001 verify-935 verify-893`). They write only into the scratch directory they are given.

| script           | question it answers                                                                                                                                                                                                                                                        | run                                                                                               |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `item_origin.py` | For one gen_data_s.py profile: which generator pass (the Gen method that called Gen.add) made the item that holds CPU address A, of what kind and size? An address no item holds (an opaque piece's first byte) names the item that ends right before it.                  | `python3 kn7000/notes/mn10300-data2-probes/item_origin.py --profile 941 --scratch DIR 0x487399D2` |
| `opaque_rows.py` | For every O-kn7000-* / O-kn6000-* / O-kn6500-* / O-kn2400-* / O-hdsx3-* row of the open-items register: the pieces / bytes the register counted (BEFORE) and the ones `data_incbin_census.py --list opaque` counts in this checkout (AFTER), grouped as the collector does | `python3 -I kn7000/notes/mn10300-data2-probes/opaque_rows.py`                                     |

The other figures of the notes come from the previous data lane's probes, unchanged:
`../mn10300-data-probes/data_stats.py --dirs BEFORE AFTER --brief` (typed bytes, reader rows, opaque pieces,
offset-named fields, bytes typed in BEFORE only), `../mn10300-data-probes/opaque_left.py --tree T --dir D` (the
opaque pieces by group) and `../mn10300-formats-probes/field_names_census.py` (offset-named fields with a reader).
BEFORE is base a385de42f's committed data directories, extracted with

    git archive a385de42f kn7000/src/program/data kn7000/src/sp7001/program/data kn7000/src/b935/program/data \
        kn7000/src/b893/program/data kn6000/src/program/data kn6500/src/program/data kn2400/src/program/data \
        hdsx3/src/program/data | tar -x -C BEFORE

## What the signals are

- "opaque": a `# census: opaque -- unknown-dump: ...` line and the `.incbin_range` after it, pieces / bytes.
- `opaque_rows.py`'s ids are the collector's: `O-<tree>-<kind>-<sha1 of the reason head>[:6]`, the reason head
  being the census reason with its numbers taken out, up to its first `;` (`collect_open_items.py
  collect_opaque`, re-implemented so that nothing under `notes/open-items/` is written).
