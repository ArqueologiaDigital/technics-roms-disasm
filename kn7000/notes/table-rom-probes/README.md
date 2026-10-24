# Table-flash probes

Scripts behind the segment names and comments in `src/table.s` and `src/sp7001/table.s`.
Run them from `kn7000/`; they read the git-ignored reference images in `baserom/`.

| script                | question it answers                                                                                    | command                                              |
|-----------------------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| `dir_slot_readers.py` | Which program-941 code reads slot *i* of the table directory, and in which named function does it sit? | `python3 notes/table-rom-probes/dir_slot_readers.py` |

The signal `dir_slot_readers.py` looks for is the firmware's one way into the archive,
`mov (0x48000000 + 4*i), Rn` (bytes `FC A0..A7` + the 32-bit address) followed by
`add 0x48000000, Rn`. A slot with no hit has no reader in the two code regions of program
941 (file `0x80..0x186000` and `0x3B8D00..0x3F6F01`); slots 8, 68, 69, 70, 71 are like that.
