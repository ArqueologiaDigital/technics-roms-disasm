# Lane outcomes, 2026-10-31

The ITEM-OUTCOMES blocks of the wave-3 and wave-4 lanes, as each lane reported them (`<id> <CLOSED|BLOCKED|OPEN> <evidence /
blocker / next step>`), one file per lane (`wave3-lanes.txt` holds the integrator's transcription for the five wave-3 lanes
whose reports listed outcomes in prose). `../apply_outcomes.py` applies them to `../triage.json`:

    python3 notes/open-items/apply_outcomes.py notes/open-items/triage.json notes/open-items/outcomes-2026-10-31

CLOSED becomes RESOLVED (evidence), BLOCKED stays BLOCKED (blocker), OPEN becomes ACTIONABLE (the lane's next step).
