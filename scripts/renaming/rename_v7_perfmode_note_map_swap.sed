# v7 had PerfMode_MapEventNoteToDisplay on the INVERSE routine (the one PerfMode_StepNoteNumber calls after
# storing the stepped note to 0x3718, before VoiceSlot_WriteCurrentParam), and only a placeholder on the
# forward one.  v10 names them the other way, with the calls in the same order.  Swap, through a temporary.
# Proof: python3 scripts/analysis/v7_routine_equivalence.py
#   PerfMode_MapEventNoteToDisplay=PerfMode_MapEventNoteToDisplay=36 PerfMode_MapDisplayNoteToEvent=PerfMode_MapDisplayNoteToEvent=36
s/\bPerfMode_MapEventNoteToDisplay\b/HARMONIZE_TMP_PERFMODE_SWAP/g
s/\bDisplayMode_Handler_3_Helper8\b/PerfMode_MapEventNoteToDisplay/g
s/\bHARMONIZE_TMP_PERFMODE_SWAP\b/PerfMode_MapDisplayNoteToEvent/g
