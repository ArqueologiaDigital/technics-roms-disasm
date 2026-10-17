# InitializeObjectTable's four loop labels (r1 corrections, analysis/kn5000-naming/proposals-2026-10-17-corrections-r1.json):
# v9 and v7 hold the same code; the harmonizer refuses them because the old names were non-local parents there.
s/\bExitWindow_Paint\b/InitializeObjectTable_Loop/g
s/\bExitWindow_Confirm\b/InitializeObjectTable_Loop2/g
s/\bExitWindow_OK\b/InitializeObjectTable_Loop3/g
s/\bExitWindow_Return\b/InitializeObjectTable_Loop4/g
