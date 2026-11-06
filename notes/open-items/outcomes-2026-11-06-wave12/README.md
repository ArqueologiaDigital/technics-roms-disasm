# Lane outcomes, 2026-11-06 (wave 12, the owner said "work on the actionable items")

The ITEM-OUTCOMES blocks of lanes v6v5-port3, kn7000-research2, kn5000-naka2, sibling-names2 and
mn10300-data4 (`<id> <CLOSED|BLOCKED|OPEN> <evidence / blocker / next step>`), applied to `../triage.json` with

    python3 notes/open-items/apply_outcomes.py notes/open-items/triage.json notes/open-items/outcomes-2026-11-06-wave12

mn10300-data4 also closed two items the register did not list (the SP7001 plug-in's data generation,
b1424ca71 + fd2b1906b, and the KN6000 / KN6500 24-byte records regression); its O- rows' before / after is
in section 2 of its README.  Two hand-overs became hand-listed rows: `L-wave12-kn7000-handback-names`
(ACTIONABLE) and `L-wave12-kn7000-mame-audio-lines` (BLOCKED on the kn7000_mame repository).

| lane             | merge on main | notes                                       |
|------------------|---------------|---------------------------------------------|
| v6v5-port3       | 169e58ff0     | `notes/v6v5-port3-2026-11-06/README.md`     |
| kn7000-research2 | 77589c2b9     | `kn7000/notes/kn7000-research2/README.md`   |
| kn5000-naka2     | d45909cea     | `notes/kn5000-naka2-2026-11-06/README.md`   |
| sibling-names2   | 0aa9f82f9     | `kn7000/notes/sibling-names2/README.md`     |
| mn10300-data4    | 8d0865c27     | `kn7000/notes/mn10300-data4/README.md`      |
