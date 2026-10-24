# Table-flash probes

Scripts behind the segment names and comments in `src/table.s` and `src/sp7001/table.s`.
Run them from `kn7000/`; they read the git-ignored reference images in `baserom/`.

| script                  | question it answers                                                                                                    | command                                                                     |
|-------------------------|------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `dir_slot_readers.py`   | Which program code reads slot *i* of the table directory, and in which named function does it sit?                     | `python3 notes/table-rom-probes/dir_slot_readers.py`                        |
| `table_source_share.py` | How many bytes of a table source are still `.incbin_range` passthrough, `.incbin` of a committed file, or spelled out? | `python3 notes/table-rom-probes/table_source_share.py src/table.s 0x3E94D4` |

The signal `dir_slot_readers.py` looks for is the firmware's one way into the archive,
`mov (0x48000000 + 4*i), Rn` (bytes `FC A0..A7` + the 32-bit address) followed by
`add 0x48000000, Rn`. A slot with no hit has no reader in the two code regions of program
941 (file `0x80..0x186000` and `0x3B8D00..0x3F6F01`); slots 8, 68, 69, 70, 71 are like that,
in program 941 and in program 942 (SP7001; second command in the script header).

Measured 2026-10-24 with `table_source_share.py` (the "before" is the source at commit 483b64324):

| source               | passthrough before    | passthrough after     | `.incbin` JPEG files | spelled out      |
|----------------------|-----------------------|-----------------------|----------------------|------------------|
| `src/table.s`        | 4,101,332 B (100.00%) | 3,159,476 B (77.04%)  | 941,144 B (22.95%)   | 712 B (0.02%)    |
| `src/sp7001/table.s` | 4,112,180 B (98.04%)  | 3,170,832 B (75.60%)  | 941,144 B (22.44%)   | 82,328 B (1.96%) |
