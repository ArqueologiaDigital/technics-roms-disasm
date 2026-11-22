## Z3: routines of the hand source holding a `djnz`

| image    | class            | routines | djnz sites |
|----------|------------------|----------|------------|
| hdae5000 | no frame         | 8        | 10         |
| v10      | compiled-looking | 4        | 4          |
| v10      | hand             | 84       | 120        |
| v10      | no frame         | 34       | 45         |
| v142     | hand             | 4        | 4          |
| v142     | no frame         | 10       | 10         |

## The compiled-looking routines (no other hand mark, a cc900 frame or a parameter spill)

| image | routine                | file                                        | djnz | frame | spill | calls | insns |
|-------|------------------------|---------------------------------------------|------|-------|-------|-------|-------|
| v10   | Fat_ReadFile           | v10/maincpu/sequencer/smf_event_processor.s | 1    | 1     | 1     | 5     | 222   |
| v10   | Sprintf_StringLength   | v10/maincpu/audio/sprintf_core.s            | 1    | 1     | 0     | 1     | 17    |
| v10   | FDC_CMD_ENABLE         | v10/maincpu/storage/fdc_routines.s          | 1    | 1     | 0     | 3     | 17    |
| v10   | SeqStep_SearchBackward | v10/maincpu/sequencer/seq_step_routines.s   | 1    | 1     | 0     | 1     | 10    |
