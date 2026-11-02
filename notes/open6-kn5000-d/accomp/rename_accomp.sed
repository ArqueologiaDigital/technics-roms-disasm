# APPLIED 2026-11-02 by the lane lead in commit 5a5311c56 (see notes/open6-kn5000-d/README.md).
# rename_accomp.sed -- sub-lane accomp of lane kn5000-d (2026-11-02), kn5000-3qp and kn5000-rzg.
# For the lead (done, see the first line): apply to v10, v9 (v8), v7, v6 and v5 (.s AND .c: three of the names are
# typed in naka_widget_descriptors.c / referenced from C), symbols/, docs/, notes/ and ../technics-docs,
# then make gate.  Evidence for every rule: notes/open6-kn5000-d/accomp/README.md (section given).
# No new name collides with an existing v10 symbol (checked against symbols/maincpu_v10_symbols_reference.txt).
#
# --- kn5000-3qp: the chord conversion of pattern notes (README section A) ---
# 0xF55053: converts a status-0x90 pattern note for the chord: chord-type row delta, then Rhythm_TransposeNote.  Nothing to do with velocity.
s/\bRhythm_VelocityLookup_A\b/Rhythm_ChordConvertNote90/g
# 0xF551BD: the same for a status-0x91 note: first the ext1 / ext2 shift chosen by Rhythm_ChordExtSelect.
s/\bRhythm_VoiceMapLookup\b/Rhythm_ChordConvertNote91/g
# 0xF552D1: the same-family fast path (no ext shift) used when re-converting buffered notes for style numbers >= 0xF0.
s/\bRhythm_VelocityCompute\b/Rhythm_ChordConvertNoteFast/g
# 0xF550BB: A = Note_PitchClassTable[A].
s/\bRhythm_InstrBaseLookup\b/Rhythm_NotePitchClass/g
# 0xF550CA / 0xF550FB / 0xF5512C: chord type -> row of Rhythm_ChordNoteDeltaRows, for parts 16/32, part 8 (ACCOMP1), part 4 (BASS).
s/\bRhythm_InstrMapTable_Default\b/Rhythm_ChordRowMap/g
s/\bRhythm_InstrMapTable_D4\b/Rhythm_ChordRowMap_Acc1/g
s/\bRhythm_VelLookA_CheckBit3_Data\b/Rhythm_ChordRowMap_Bass/g
# 0xE461C2 (C data, naka_widget_descriptors.c): 21 rows x 16 signed semitone deltas per pitch class.
s/\bRhythm_VelLookA_TableLookup_Table\b/Rhythm_ChordNoteDeltaRows/g
# 0xF5526F / 0xF552A0: chord type -> 0 no shift / 1 use ext1 / 2 use ext2 (0x91 notes); the second for BASS.
s/\bRhythm_PitchShiftTable_Default\b/Rhythm_ChordExtSelect/g
s/\bRhythm_VoiceMap_ClampInstr_Data\b/Rhythm_ChordExtSelect_Bass/g
# 0xF5532E / 0xF5535F: the fast path's row maps (differ from Rhythm_ChordRowMap only at type 7).
s/\bRhythm_VelocityTable_A\b/Rhythm_ChordRowMapFast/g
s/\bRhythm_VelComp_SelectTable_Data\b/Rhythm_ChordRowMapFast_Acc1/g
# Sets 0x32F4 bit 4 for a NOTE >= 0x78 (such notes are not converted); the byte is a note, not a velocity.
s/\bRhythm_CheckVelocityThreshold\b/Rhythm_CheckFixedNote/g
# BASS only: on an on-bass chord (flags bit 1), flags bit 0, or the first bass note after a chord change, the note
# becomes the C of its octave (= the bass root after transposition) with a floor at 0x332E.
s/\bRhythm_CrossVoiceCorrect\b/Rhythm_BassToRoot/g
# With 0x32D7 bit 0: every note becomes the C of its octave (root only); not a range check.
s/\bRhythm_NoteRangeCheck\b/Rhythm_RootOnlyNote/g
# 0xE49FC8 (C data): chord type -> family 0 major, 1 minor, 2 seventh, 3 dim7; and its readers.
s/\bAccTuning_ReadAndApplyOffset_Table\b/Chord_TypeFamilyTable/g
s/\bAccTuning_ReadAndApplyOffset\b/Chord_LookupTypeFamily/g
s/\bAccTuning_CallWithSaveRestore\b/Chord_LookupTypeFamily_Saved/g
# The note writer's converter (called by AccBuf_WriteExtendedEvent for parts 4..32).
s/\bAccVoice_CorrectNote\b/AccVoice_ConvertNoteForChord/g
#
# --- kn5000-rzg: synchro start / stop and the end of an ending (README section B) ---
# 0xF5AF3C: PLAY_TRANSPORT_STATE = 12 (stop at the next 24-tick boundary) when running, ACC_TRANSPORT_STATE = 12, marker 0x86.
s/\bAccPlayMode_StopToSync2\b/AccPlayMode_StopPlayAndAcc/g
# Its tail: ACC_TRANSPORT_STATE = 12 only (the accompaniment stops, a song keeps playing).
s/\bAccPlayMode_StartPlay2\b/AccPlayMode_StopAcc/g
s/\bAccPlayMode_StartPlay2_Padding\b/AccPlayMode_StopAcc_Padding/g
s/\bAccWrap_PlayModeStopSync\b/AccWrap_PlayModeStopPlayAndAcc/g
s/\bAccWrap_PlayModeStartPlay\b/AccWrap_PlayModeStopAcc/g
# 0xF591D1: after all six ending lanes are parked, waits until no ending note sounds, then stops.
s/\bAccState_CollectAll\b/AccEnding_StopWhenSilent/g
# 0xF56A56: at a lane's 0x83 end marker during an ending: parks the lane (0x332A); all six -> 0x3283 bit 2.
s/\bAccVoice_ActivatePart\b/AccVoice_ParkLaneAtEnd/g
s/\bAccVoice_ActivatePart_Return\b/AccVoice_ParkLaneAtEnd_Return/g
# 0xF5ACB6: all chord-zone keys released while SYNCHRO is armed and the accompaniment runs: synchro stop.
s/\bAccAutoPlay_SeqHandoff\b/AccSynchro_StopOnChordRelease/g
s/\bAccAutoPlay_SeqHandoff_Process\b/AccSynchro_StopOnChordRelease_Song/g
s/\bAccAutoPlay_SeqHandoff_Finalize\b/AccSynchro_StopOnChordRelease_SongStopped/g
s/\bAccAutoPlay_SeqHandoff_Return\b/AccSynchro_StopOnChordRelease_Return/g
s/\bAccAutoPlay_SeqHandoff_Padding\b/AccSynchro_StopOnChordRelease_Padding/g
# 0xF5A9FC: per chord-zone key event: first key -> synchro start request, all keys released -> synchro stop.
s/\bAccAutoPlay_TriggerCheck\b/AccSynchro_OnChordKeyEvent/g
# 0xF5AAFB: 0x346D bit 7 = synchro allowed (SYNCHRO lit, chord mode on, no song recording / playing).
s/\bAccAutoPlay_SetConfig\b/AccSynchro_UpdateArmed/g
s/\bAccAutoPlay_SetConfig_Apply\b/AccSynchro_UpdateArmed_Off/g
s/\bAccAutoPlay_SetConfig_Return\b/AccSynchro_UpdateArmed_Return/g
# 0xF5AC07 / 0xF5AC5C: stopped -> request a start (0x346D bit 2, or bit 0/1 deferred to the main loop); stopping -> cancel the stop.
s/\bAccAutoPlay_SubModeA\b/AccSynchro_StartOrCancelStop/g
s/\bAccAutoPlay_SubModeA_Check\b/AccSynchro_StartOrCancelStop_Now/g
s/\bAccAutoPlay_SubModeA_Apply\b/AccSynchro_StartOrCancelStop_Running/g
s/\bAccAutoPlay_SubModeA_Return\b/AccSynchro_StartOrCancelStop_Return/g
s/\bAccAutoPlay_SubModeA_Padding\b/AccSynchro_StartOrCancelStop_Padding/g
s/\bAccAutoPlay_SubModeB\b/AccSynchro_StartOrCancelStopSong/g
s/\bAccAutoPlay_SubModeB_Check\b/AccSynchro_StartOrCancelStopSong_Now/g
s/\bAccAutoPlay_SubModeB_Apply\b/AccSynchro_StartOrCancelStopSong_Running/g
s/\bAccAutoPlay_SubModeB_Return\b/AccSynchro_StartOrCancelStopSong_Return/g
s/\bAccAutoPlay_SubModeB_Padding\b/AccSynchro_StartOrCancelStopSong_Padding/g
# 0xF5ABF3: clears SYNCHRO (PANEL_STYLE+5 bit 1) and posts its switch event; the only code besides the button that clears it.
s/\bAccAutoPlay_Disable\b/AccSynchro_Disarm/g
s/\bAccAutoPlay_Disable_Return\b/AccSynchro_Disarm_Padding/g
# 0xF5ABBC: disarms SYNCHRO as soon as a song track plays or records.
s/\bAccAutoPlay_PeriodicCheck\b/AccSynchro_PeriodicCheck/g
