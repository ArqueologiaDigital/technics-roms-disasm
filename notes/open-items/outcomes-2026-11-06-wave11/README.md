# Lane outcomes, 2026-11-06 (wave 11, the owner said "Work on the actionable items")

The ITEM-OUTCOMES blocks of lanes kn5000-naka, v6v5-port2, sibling-names, kn7000-research and mn10300-data3
(`<id> <CLOSED|BLOCKED|OPEN> <evidence / blocker / next step>`), applied to `../triage.json` with

    python3 notes/open-items/apply_outcomes.py notes/open-items/triage.json notes/open-items/outcomes-2026-11-06-wave11

mn10300-data3.txt lists only the O- rows whose bytes moved; its other opaque groups are in
`kn7000/notes/mn10300-data3/README.md`.  Each lane's notes and probes:

| lane            | merge on main | notes                                      |
|-----------------|---------------|--------------------------------------------|
| kn5000-naka     | 2dd3f68eb     | `notes/kn5000-naka-2026-11-06/README.md`   |
| v6v5-port2      | 98ff6ff7c     | `notes/v6v5-port2-2026-11-06/README.md`    |
| sibling-names   | 5b72cf364     | `kn7000/notes/sibling-names/README.md`     |
| kn7000-research | 122ea7c9e     | `kn7000/notes/kn7000-research/README.md`   |
| mn10300-data3   | 3834c8773     | `kn7000/notes/mn10300-data3/README.md`     |
