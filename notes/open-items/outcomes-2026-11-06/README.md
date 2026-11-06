# Outcomes, 2026-11-06 (wave 9: the owner's answers to the three open decisions)

The owner answered the three BLOCKED owner decisions on 2026-11-06:

| item                      | question                                                         | answer                                                                                                  | done by                 |
|---------------------------|------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------|
| N-8c52a3ed                | may the shared kernel carry per-CPU `.if/.else` blocks?          | "Yes: one kernel source for three CPUs, with conditional blocks through most routines."                 | lane open9/kernel-a3    |
| L-mn10300-names-ncr-names | empty `NCR_NAMES` to cut the IC18 rhythm source by about 5.6 MB? | "My recommendation: keep the names. Yes!"                                                               | `owner.txt` (no change) |
| N-b796721c                | normalise the WSA1R labels' 0-for-O spelling (`MidiFileL0ad_*`)? | "Normalise: rename across the whole tree, L0ad→Load, S0und→Sound, C0py→Copy, F0rmat→Format, and so on." | lane open9/zero-for-o   |

Each `*.txt` is an ITEM-OUTCOMES block (`<id> <CLOSED|BLOCKED|OPEN> <text>`), applied with

    python3 notes/open-items/apply_outcomes.py notes/open-items/triage.json notes/open-items/outcomes-2026-11-06

Lane kernel-a3 found three new items, added by hand to `triage.json` as ACTIONABLE (`source` = the line in
`wsa1/notes/open9-a3-probes/README.md` that describes each): `L-kernel-a3-join-probe-stale`,
`L-kernel-a3-softtimer-boot-header` and `L-kernel-a3-kn5000-maincpu` (the KN5000 main CPU's kernel as a fourth
processor of `kernel.s`).
