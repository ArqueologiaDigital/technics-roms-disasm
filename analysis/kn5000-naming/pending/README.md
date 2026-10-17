# Pending naming proposals (2026-10-17): written, not applied

The 2026-10-17 session stopped before these proposals could be applied. The owner ended it to save
tokens. Each file comes from a read-only naming agent and uses the usual proposal format: `old`,
`verdict`, `new`, `header`, `basis`, `evidence`. Before applying one, validate it (old label exists,
new name unused in v10/v9/v7 `*.s *.c *.h *.ld`, no generic suffix, not proposed before), spot-check the
evidence and move it to `../proposals-<date>-<tag>.json`. Then follow the procedure in
`notes/NEXT-STEPS-2026-10-17.md`.

| file                            | input               | records                | notes                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|---------------------------------|---------------------|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `proposals_hbatch_h3.json`      | `hbatch_h3.json`    | 47: 30 name, 17 refuse | v10 `_Helper` routines with a named caller                                                                                                                                                                                                                                                                                                                                                                                            |
| `proposals_corrections_c2.json` | (prompt groups 1-4) | 98: 97 name, 1 refuse  | misleading names: the fade engine (`CompIface_*` -> `Fade_*`), `PanelAction_ModWheel` -> `PanelAction_ExpressionPedal`, `Timer7_DisableInterrupt` -> `Demo_ReleaseGlidePedal`, encoder RAM `.equ` names; `kind` is label / local / equ. **The agent did not finish its check that every new name is unused: do it first.** Docs that repeat the old names: technics-docs `control-panel-protocol.md` (encoder table), `memory-map.md` |
| `proposals_sebatch_se3.json`    | `sebatch_se3.json`  | see the file           | the 159 `SeScreenData_0x<offset>` sound-editor record lists; records marked "not reviewed" were not reached                                                                                                                                                                                                                                                                                                                           |

Evidence lines cite the tree the agent read, given in each file or in the agent's notes. h3 used HEAD
b85f1c533 and c2 used 98670dc62. Most later commits only renamed labels, so re-locate a cited line by
its label if the line number has moved.
