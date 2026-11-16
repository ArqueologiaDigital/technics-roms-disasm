# v6 / v5 still call Harmony_FindReferenceNote (v7 / v9 / v10's name; same bytes: ld c,(HARMONY_REF_NOTE) /
# ld (HARMONY_PREV_REF_NOTE),c ...) by an older name.  VoiceMap_AllocateSlot's staged C, which calls it, could
# not be checked in v6 / v5 without it (run 2026-11-16-103-p6-r20-staged).
s/\bNoteMap_GetVoiceData_Entry\b/Harmony_FindReferenceNote/g
