# Probes for custom-data-ic21.md

Each script reads the factory custom-style banks and answers one question. The banks are the
references `make -C kn7000 verify-customdata` makes in `kn7000/baserom/customdata/*.ic21` (and
`make -C kn6000 verify-customdata` in `kn6000/baserom/01ctmini.ic18`), or the same files in the
private romsets. Run from this directory:

    R=../../baserom/customdata; K6=../../../kn6000/baserom/01ctmini.ic18

| script                | question it answers                                                                                                                                                        | command                                                                                                                                |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `layout_check.py`     | does every bank follow the directory / record / container layout exactly; which free blocks hold data?                                                                     | `python3 -I layout_check.py $R/*.ic21 $K6`                                                                                             |
| `stream_census.py`    | do all TCMP and TPAD streams parse with the firmware's event lengths; which events, how many?                                                                              | `python3 -I stream_census.py $R/*.ic21 $K6`                                                                                            |
| `slack_origin.py`     | where do the bytes past a record's end come from (same bytes at the same offsets in another record)?                                                                       | `python3 -I slack_origin.py $R/*.ic21 $K6`                                                                                             |
| `panel_memory_map.py` | the writer's field-map tables; do the stored one-touch settings follow them (masks, 941 tails, KN6000 part 3)?                                                             | `python3 -I panel_memory_map.py ../../baserom/kn7000_program.rom $R/*.ic21 $K6`                                                        |
| `residue_cover.py`    | how much of the residue repeats a typed record, is a whole stream or record, parses as events, or is left opaque?                                                          | `python3 -I notes/custom-data-ic21-probes/residue_cover.py baserom/customdata/*.ic21` (from `kn7000/`)                                 |
| `tcmp_var_fields.py`  | which values do the TCMP variation bytes +0x00..+0x02, +0x18/+0x19, the part set-ups' bytes 15..23 and the style record's +0x70 take (their readers are in its docstring)? | `python3 -I notes/custom-data-ic21-probes/tcmp_var_fields.py build/customdata/*.ic21` (from `kn7000/`, after `make verify-customdata`) |
| `zlib104_drv.c`       | does zlib 1.0.4 itself reproduce an `.AST` payload (Python's zlib 1.3.1 does not)?                                                                                         | below                                                                                                                                  |

What each prints, as measured 2026-10-29 (`tcmp_var_fields.py` 2026-11-06):

- `tcmp_var_fields.py`: 3,600 variation records, 28,800 part set-ups; `+0x00` 0 in 2,553 (0x58 in
  465), `+0x01` 0 in 2,611, `+0x02` 0 in all; `+0x18/+0x19` `ffff` in 3,380 (then `ff04` 81, `ff02` 37,
  `02ff` 31, ...); part set-up bytes 15..23 all zero (28,800 differ from the default template);
  style unit bytes `10 00 23 00` in 132 of 180 records, `44 00 44 00` in 18, `11 91 44 00` (EFF4
  0x1111 "Shallow2", TOTAL MODE) in 3.

- `layout_check.py`: `OK` for all ten banks. The nine KN7000 banks list free blocks with data
  (01ctmini: 21, 26-29; ...); the KN6000 bank has none.
- `stream_census.py`: 5,200 streams, 2,979,536 event bytes, 806,516 events, 0 that do not end
  exactly, 0 events with a data byte >= 0x80, largest position byte 95; notes 398,918, positions
  261,177, beat markers 57,034, pitch bends 49,467, controllers 31,240, ends 5,200, SysEx 3,290,
  program changes 188, channel pressure 2.
- `panel_memory_map.py`: 0 part bytes outside their masks in the KN7000 banks; settings without
  the 941 part tails: 01ctmini 76, 02custm6 0 (live records); KN6000: 880 bytes outside, all 80
  settings with part 3 all 0xFF.
- `residue_cover.py` (all nine images): record copies 2,202,310 B, whole streams 195,442, event
  runs 185,705, variation and pad records 4,672, opaque 4,179 (per image: custom-data-ic21.md).
- `slack_origin.py`: 166 records with residue past their end, 122 of them with the same bytes at
  the same offsets in another record.

`zlib104_drv.c` deflates a file whole with `deflateInit(Z_DEFAULT_COMPRESSION)` and writes the
zlib stream; its bytes after the 2-byte header equal the `.AST` payload. Recipe (the zlib sources
are a download, kept out of git):

    curl -O https://zlib.net/fossils/zlib-1.0.4.tar.gz      # SHA-256 e5c260cd3db1370fb3e0c193e9cbd9f127a9bd055d622b3fb55b82747f6e5b24
    tar xzf zlib-1.0.4.tar.gz
    Z=zlib-1.0.4; gcc -O2 -w -I$Z -o drv zlib104_drv.c $Z/deflate.c $Z/trees.c $Z/adler32.c $Z/zutil.c
    ./drv 01custm1.ic21 out.z     # out.z[2:] == 01CUSTM1.AST[16:]  (checked for 01CUSTM1)

The Python port (`kn7000/tools/zlib10_deflate.py`) is what the Makefiles use:
`make -C kn7000 verify-customdata-ast` rebuilds all nine KN7000 files identical, and
`make -C kn6000 verify-customdata-ast` the KN6000's.
