# N-edb08959, lane open6/kn5000-d naming (2026-11-02): the renames notes/kn5000-style-2026-10-31/README.md
# ("Names in the firmware that this changes") found, each re-checked against the v10 code.  Applied to the
# .s/.c/.h/.ld files of v10/v9/v7/v6/v5 maincpu.  Evidence: notes/open6-kn5000-d/naming/README.md.
#
# Word 0x9480E = style image +0x0E, the Composer password (FmmPasswordFunc / EVT_SET_PASSWORD), not a slot.
s/\bSetCurrentSlotIndex\b/Composer_SetPassword/g
s/\bGetCurrentSlotIndex\b/Composer_GetPassword/g
s/\bCheckIsCurrentSlot\b/Composer_IsPassword/g
s/\bCheckSlotIndexValid\b/Composer_HasPassword/g
# Indexed by STYLE_SECTION_TIME_SIG; the word goes to section record +0x10 / +0x11, the PANEL_STYLE pair.
s/\bAccPatch_VoiceStrideTable\b/AccPatch_DefaultStyleByTimeSig/g
# Swapped names: "_Bass" reads PANEL_PART_DRUM into record +0x18, "_Rhythm" PANEL_PART_BASS into +0x20.
# (Drum first, so the old _Rhythm becoming _Bass is not caught again.)
s/\bAccPatch_SyncVoice_Bass\b/AccPatch_SyncVoice_Drum/g
s/\bAccPatch_SyncBass_/AccPatch_SyncDrum_/g
s/\bAccPatch_SyncVoice_Rhythm\b/AccPatch_SyncVoice_Bass/g
s/\bAccPatch_SyncRhythm_/AccPatch_SyncBass_/g
# XIY = RHYTHM_PATTERN_BUF_A + 0xBA0 + 32 * (0x390A): the COMPOSER CHORD MAP record selected by 0x390A.
s/\bTimeSig_DisplayStrings_Helper\b/ComposerChordMap_GetRecord/g
# The RECORD SETTING page's row handlers (DrumVoice_DispatchTable, index = cursor row - 1).
s/\bDrumVoice_DispatchTable\b/CmpRecSet_RowHandlers/g
s/\bDrumVoice_Dispatch\b/CmpRecSet_DispatchRow/g
s/\bDrumVoice_Select\b/CmpRecSet_DispatchCursorRow/g
s/\bDrumVoice_ClampMin\b/CmpRecSet_DispatchCursorRow_Clamp/g
s/\bDrumVoice_InlineStub\b/CmpRecSet_DispatchRow_Wrap/g
s/\bDrumVoice_NullHandler\b/CmpRecSet_NopRow/g
s/\bDrumVoice_Handler0/CmpRecSet_OnMeasure/g
s/\bDrumVoice_Handler1/CmpRecSet_OnTimeSig/g
s/\bDrumVoice_Handler2/CmpRecSet_OnKey/g
s/\bDrumVoice_Handler3/CmpRecSet_OnChord/g
s/\bDrumVoice_Handler4/CmpRecSet_OnBassType/g
s/\bDrumVoice_Handler5/CmpRecSet_OnAccompType/g
s/\bDrumVoice_Handler6/CmpRecSet_OnRhythmProgram/g
s/\bDrumVoice_Handler7/CmpRecSet_OnRhythmBank/g
