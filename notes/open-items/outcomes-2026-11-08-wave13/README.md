# Lane outcomes, 2026-11-07/08 (wave 13, the owner said "Keep working on open items")

The ITEM-OUTCOMES blocks of lanes kn5000-naka3, kn7000-ic21, sibling-names3, mn10300-data5 and
kn7000-subsystems (`<id> <CLOSED|BLOCKED|OPEN> <evidence / blocker / next step>`), applied to `../triage.json` with

    python3 notes/open-items/apply_outcomes.py notes/open-items/triage.json notes/open-items/outcomes-2026-11-08-wave13

The wave was paused for most of 2026-11-07 while the share was below the 15 GB floor, and resumed that evening.

- sibling-names3 and kn7000-subsystems both moved N-a810f3f6, N-f22bdce4 and N-b3ba9d8b; their two lines are
  combined in `kn7000-subsystems.txt` (sibling-names3 first, then the aligned names that 941's new names carried).
- mn10300-data5 also reported its KN7000 opaque groups and the O- rows; those have no triage id of their own (the
  O- rows are re-counted by `collect_open_items.py --write`).  Their before / after is in sections 3-4 of its README.
- Two hand-overs became hand-listed rows: `L-wave13-kn7000-reader-label-flags` and
  `L-wave13-kn7000-table-voices-comment` (both ACTIONABLE).

| lane              | merge on main | notes                                        |
|-------------------|---------------|----------------------------------------------|
| kn5000-naka3      | 60b5271a0     | `notes/kn5000-naka3-2026-11-07/README.md`    |
| kn7000-ic21       | 251a6e70f     | `kn7000/notes/kn7000-ic21/README.md`         |
| sibling-names3    | 5ee2082dd     | `kn7000/notes/sibling-names3/README.md`      |
| mn10300-data5     | 4e1d77a5b     | `kn7000/notes/mn10300-data5/README.md`       |
| kn7000-subsystems | d8aa8ade1     | `kn7000/notes/kn7000-subsystems/README.md`   |
