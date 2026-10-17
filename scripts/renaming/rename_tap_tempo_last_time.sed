# r1 corrections: RAM word 0x348E (v7 0x33F2) is the last TAP TEMPO press time, not a pattern selector
# (analysis/kn5000-naming/proposals-2026-10-17-corrections-r1.json)
s/\bRHYTHM_PATTERN_SEL_B\b/TAP_TEMPO_LAST_TAP_TIME/g
