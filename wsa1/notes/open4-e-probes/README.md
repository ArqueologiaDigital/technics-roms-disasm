# open4-e-probes -- join/split phases A3, A4, B3 (lane open4/wsa1-e, 2026-10-31)

Register item N-8c52a3ed ("Join/split plan: phases A3, A4 (KN5000 half) and B3 after the shared
kernel", `notes/HANDOFF-join-split-kernel.md`).  What each phase came to is in that file's status
section; this directory holds the measurement that decided A3, and the table names the two tools
that did A4 and B3 (they live beside the code they rewrite, not here).

| script                                                   | question it answers                                                                                                   | run (exact command)                                                                                                         |
|----------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| `kernel_a3_shareability.py`                              | A3: could `.equ` alone (a third `kernel_*.inc`) make `kernel/kernel.s` emit the KN5000 sub-CPU's kernel byte for byte? | `UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open4-e-probes/kernel_a3_shareability.py --selftest` (in `wsa1/`) |
| `../../scripts/tools/join_maincpu_link.py`               | B3: are prom_b and prom_a one link, with no cross-image name held as a number, and did the rewrite move any value?    | `python3 scripts/tools/join_maincpu_link.py --selftest` and `--proof 130735749` (in `wsa1/`, after `make all`)                  |
| `../../../scripts/tools/split_v142_subcpu_core.py`       | A4: is the split v142 sub-CPU core the same text, moved, and does every cut fall between routines?                    | `python3 scripts/tools/split_v142_subcpu_core.py --check 130735749` (repo root)                                              |

## What the A3 measurement says (2026-10-31)

26 kernel routines of >= 8 instructions, prom_c against the KN5000 sub-CPU payload at A2's match
sites.  Instruction classes (definitions in the script's docstring):

| class     | instructions | meaning                                                                   |
|-----------|--------------|---------------------------------------------------------------------------|
| same      | 714          | identical bytes                                                           |
| operand   | 106          | same shape and length, a different address or count: an `.equ` covers it |
| length    | 10           | same shape, a different length (8-bit vs 16-bit direct address)           |
| wsa1-only | 93           | no KN5000 partner (a lower bound: LCS maximises the pairing)              |

**One routine of 26 is equate-shareable** (`Kernel_ResumeTask`, 9 instructions).  24 of the
other 25 have at least one WSA1 instruction with no KN5000 partner, and 7 of them also have an
instruction encoded at a different length (10 in all); `Kernel_Dispatch` alone has 8 unpaired WSA1
instructions (the tick-drain loop A2 named).  The 25th, `SoftTimer_Register`, fails only on one
unpaired KN5000 instruction inside its span, the class the script calls not robust, so it may be a
second shareable routine.  Either way, extending the shared source to the KN5000 needs `.if/.else`
round instructions or a second spelling per CPU, which the A1 design (`HANDOFF-join-split-kernel.md`, "symbolic `.equ` per CPU,
NOT `.if/.else`") excluded -- an owner decision, recorded as the blocker in the handoff.
