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

Measured 2026-10-24 with `table_source_share.py` (src/table.s against 0x3E94D4 bytes,
src/sp7001/table.s against 0x400000):

| source               | state                        | passthrough `.incbin_range` | `.incbin` files      | spelled out      |
|----------------------|------------------------------|-----------------------------|----------------------|------------------|
| `src/table.s`        | 483b64324 (before)           | 4,101,332 B (100.00%)       | 0 B (0.00%)          | 0 B (0.00%)      |
| `src/table.s`        | b1a500c81 (57 JPEG segments) | 3,159,476 B (77.04%)        | 941,144 B (22.95%)   | 712 B (0.02%)    |
| `src/table.s`        | + picture groups             | 2,783,152 B (67.86%)        | 1,316,309 B (32.09%) | 1,871 B (0.05%)  |
| `src/sp7001/table.s` | 483b64324 (before)           | 4,112,180 B (98.04%)        | 0 B (0.00%)          | 82,124 B (1.96%) |
| `src/sp7001/table.s` | b1a500c81 (57 JPEG segments) | 3,170,832 B (75.60%)        | 941,144 B (22.44%)   | 82,328 B (1.96%) |
| `src/sp7001/table.s` | + picture groups             | 2,794,508 B (66.63%)        | 1,316,309 B (31.38%) | 83,487 B (1.99%) |
