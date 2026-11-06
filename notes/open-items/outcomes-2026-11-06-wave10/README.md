# Lane outcomes, 2026-11-06 (wave 10, the owner said "work on the open items")

The ITEM-OUTCOMES blocks of lanes kernel4, kn5000-notes, kn7000-names, mn10300-data2 and v6v5-port
(`<id> <CLOSED|BLOCKED|OPEN> <evidence / blocker / next step>`), applied to `../triage.json` with

    python3 notes/open-items/apply_outcomes.py notes/open-items/triage.json notes/open-items/outcomes-2026-11-06-wave10

The files are applied in name order, so mn10300-data2's rows for L-mn10300-names-kn2400-titles,
N-61c32961 and N-fb88572c (handed to it by kn7000-names, which had reported them BLOCKED on
gen_data_s.py) override kn7000-names' rows.  Each lane's notes and probes:

| lane          | merge on main | notes                                        |
|---------------|---------------|----------------------------------------------|
| kn5000-notes  | 55860e8d7     | `notes/kn5000-notes-2026-11-06/README.md`    |
| kn7000-names  | 1345995bc     | `kn7000/notes/kn7000-names/README.md`        |
| kernel4       | 17c2f1316     | `wsa1/notes/open10-kernel4-probes/README.md` |
| mn10300-data2 | 41ae4c535     | `kn7000/notes/mn10300-data2/README.md`       |
| v6v5-port     | 0bb738536     | `notes/v6v5-port-2026-11-06/README.md`       |
