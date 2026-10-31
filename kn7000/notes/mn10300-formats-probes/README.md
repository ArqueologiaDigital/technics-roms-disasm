# mn10300-formats probes

Lane mn10300-formats (2026-10-31), notes in `../mn10300-formats/README.md`. Every script runs from
`kn7000/` and reads only the git-ignored reference images (`baserom/`, `../kn6000/baserom/`, ...) and
the committed sources; none writes anything.

| script                  | question it answers                                                                                                                                                        | run                                                                         |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `zlib_tables.py`        | where each build (KN7000 941 / 942 / 935 / 893, KN6000, KN6500, KN2400, HD-SX3) holds zlib 1.0.4's static tables, found by their contents, and which name its symbols give | `python3 notes/mn10300-formats-probes/zlib_tables.py [--sym] [profile ...]` |
| `hash_payloads.py`      | which payload bytes of the KN6000's ToneKeyHash / ShortKeyHash / BankKeyHash carry values, the range of each, and that the bytes no routine reads are always 0             | `python3 notes/mn10300-formats-probes/hash_payloads.py`                     |
| `kn2400_fx_desc.py`     | whether the KN2400's effect descriptors and 36-byte parameter records tile 0x48439000..0x48440898 and the field meanings hold in every record                              | `python3 notes/mn10300-formats-probes/kn2400_fx_desc.py`                    |
| `kss_bgscreen_ids.py`   | whether the SP7001 plug-in's KssBgScreen `image_id` (0x8068) and `icon` (1) are ids of 942's resource-id trie, what icon 1 is, and whether the plug-in reads +0x28 as u16  | `python3 notes/mn10300-formats-probes/kss_bgscreen_ids.py`                  |
| `field_names_census.py` | per tree, how many record fields of `data_structs.inc` have a name that says what they are and how many only an offset name (`--list`: the offset-named ones; `--md`)      | `python3 notes/mn10300-formats-probes/field_names_census.py --md`           |

What each one reads, and what a value means:

- `zlib_tables.py`: the byte patterns are zlib 1.0.4's own tables (deflate.c `configuration_table`,
  trees.c `extra_lbits` / `extra_dbits` / `extra_blbits` / `bl_order` / `static_*_desc`, infblock.c
  `border`, inftrees.c `cplens` / `cplext` / `cpdist` / `cpdext`, infutil.c `inflate_mask`, zutil.c
  `z_errmsg`); `cpdext` and `extra_dbits` have the same 30 values and are told apart by the table each
  follows. A table in the initialised-RAM image is given at its RAM address (crt0's copy, from
  `gen_data_s.configure`). Expected: 19 tables in each KN7000 build and each sibling, none in the HD-SX3
  plug-in.
- `hash_payloads.py`: expected `always 0x00` for ToneKeyHash +9..+11, ShortKeyHash +3..+5, BankKeyHash
  +2..+3 (the trailing `.space` of `TONE_KEY_PAYLOAD` / `SHORT_KEY_PAYLOAD` / `BANK_KEY_PAYLOAD`), and
  ToneKeyHash +0 (u16) 0..1099.
- `kn2400_fx_desc.py`: expected 107 distinct descriptors in 260 entries, region 0x48439000..0x48440898
  (30,872 bytes) with 0 gaps, all 809 names NUL-padded, `+12` = REVERB SEND's number in 106 of 106
  descriptors with records; the `+9` and `nparams` lines are counts, not checks.
- `kss_bgscreen_ids.py`: expected "id 0x008068: no such id", icon 1 = ResIconTable entry 1 (24 x 24),
  and 0 16-bit accesses at (0x28, aN) in the plug-in's code.
- `field_names_census.py`: reads the generated `data_structs.inc` of each tree; run it before and after
  a regeneration to compare.
