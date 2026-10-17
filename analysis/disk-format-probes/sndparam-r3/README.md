# Sound-parameter descriptors, round 3 (2026-10-17)

The research records behind `scripts/renaming/gen_sndparam_desc_names_r3.py`: firmware evidence for 204 of the 259
descriptors that rounds 1 and 2 left positional, two round-2 corrections, five better names for descriptors outside
the 259, and what is still unknown about the other 55.  Read-only research by an agent; every file:line citation is
against a `git archive` of commit **429a926d2** (the tree was being edited while it ran), and `build_proposals.py`
refuses to write the JSON if a cited line does not contain the text it quotes.  Section 9 of
`../README-lsw-param-namespace-map.md` has the tables.

| file                        | what it holds                                                                       |
|-----------------------------|-------------------------------------------------------------------------------------|
| `proposals.json`            | 78 firm proposals: 7 per-part fields and 71 global keys, with meaning and evidence  |
| `inferred.json`             | 2 probable names that are NOT applied, each with what would confirm it              |
| `unresolved.json`           | the keys still without a meaning, and what is known about each                      |
| `observations.json`         | findings beyond the 259: two round-2 names corrected, misleading code labels        |
| `proposals_weak_names.json` | 5 descriptors outside the 259 whose names restated an index                         |
| `sndparam_unnamed_v10.txt`  | the input: the 259 descriptors (key, alias, record, byte, mask, range) at 2748ddff2 |

| script                | question it answers                                                          | command (repository root)                                                                  |
|-----------------------|------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `build_proposals.py`  | which unnamed keys does the firmware identify, and how (writes all JSON)     | `python3 analysis/disk-format-probes/sndparam-r3/build_proposals.py` (needs `snap/`)       |
| `crosscheck_trees.py` | do v9 and v7 hold the same descriptor shape and alias for every proposed key | `python3 analysis/disk-format-probes/sndparam-r3/crosscheck_trees.py`                      |
| `desc_dump.py`        | the full 18-byte descriptors of given keys                                   | `python3 analysis/disk-format-probes/sndparam-r3/desc_dump.py v10 18003 4140`              |
| `blockptrs.py`        | record -> RAM payload base (`SndParam_BlockRamPtrs`)                         | `python3 analysis/disk-format-probes/sndparam-r3/blockptrs.py v10`                         |
| `recaccess.py`        | every absolute access to record REC byte OFF (in `snap/`)                    | `python3 analysis/disk-format-probes/sndparam-r3/recaccess.py 0x98:7,0x98:8`               |
| `romsym.py`           | ROM bytes / strings / u32 at an ELF symbol                                   | `python3 analysis/disk-format-probes/sndparam-r3/romsym.py CtlMsgGridCheck_Table 0x48 u32` |
| `widget_keys.py`      | the pman_adr / pman_ad key fields of naka widget instances (in `snap/`)      | `python3 analysis/disk-format-probes/sndparam-r3/widget_keys.py`                           |
| `lsw_answers.py`      | every routine answering EVT_GET_LSW_DATA_NO / _ADDRESS, and its constant     | `python3 analysis/disk-format-probes/sndparam-r3/lsw_answers.py v10`                       |
| `lsw_const_keys.py`   | constant keys loaded into XWA before an accessor call                        | `python3 analysis/disk-format-probes/sndparam-r3/lsw_const_keys.py v10`                    |
| `s.py`, `cite.py`     | byte-safe regex search / first citation line in `snap/`                      | `python3 .../s.py REGEX [tree]`, `python3 .../cite.py FILE REGEX`                          |

`snap/` is not committed (`.gitignore`).  Recreate it with
`mkdir -p analysis/disk-format-probes/sndparam-r3/snap && git archive 429a926d2 v7 v9 v10 v142 | tar -x -C analysis/disk-format-probes/sndparam-r3/snap && echo 429a926d2 > analysis/disk-format-probes/sndparam-r3/snap/COMMIT`.
The ROM / ELF readers (`crosscheck_trees.py`, `desc_dump.py`, `blockptrs.py`, `romsym.py`) read the built tree.

Checked when the names were applied: `crosscheck_trees.py` printed "206 keys checked against v9 and v7: 0
mismatches"; the namer asserts every rule's record, byte and mask against each tree's ROM.
