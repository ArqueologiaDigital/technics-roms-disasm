# Probes for the SX-KN6000 / SX-KN6500 data regions

Each script answers one question behind `../data-region.md`; run them from the repository root.
They need the reference images (`make -C kn6000 baserom`, `make -C kn6500 baserom`, and for
`sigmap.py` also `make -C kn7000 baserom`).

| script               | question                                                                     | run                                                                 |
|----------------------|------------------------------------------------------------------------------|---------------------------------------------------------------------|
| `sigmap.py`          | which KN7000 propdata type character is each KN6000 / KN6500 one?            | `python3 kn6000/notes/data-region-probes/sigmap.py kn6000`          |
| `generic_regions.py` | which stretches of the typed data region are still `.incbin_range`, how big? | `python3 kn6000/notes/data-region-probes/generic_regions.py kn6000` |

`sigmap.py`'s answer (2026-10-29, KN6000): 591 field pairs, one KN7000 character per KN6000
character, as `milk_model.SIGMAP_NAKA` says (the script exits 1 otherwise).

The other structures are checked by the generator itself as it writes them: `gen_data_s.py`
refuses a widget record whose padding is not zero, `program_rhythm.py` re-checks the rhythm
resource's checksum, offsets and streams, the `.zlib` blocks must re-compress to the image's
bytes (kn7asm), `table_png.py` asserts each bitmap's round trip, and `make verify` compares the
whole image.
