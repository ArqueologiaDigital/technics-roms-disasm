# rename_open4_engine.sed -- lane open4/kn5000-b-engine (2026-10-31): kn5000-nl6 leads and
# kn5000-rlb / kn5000-98j names.  Evidence for each rename: notes/open4-kn5000-b/engine/README.md.
#
# Main CPU (v10, v9, v7, v6, v5): the composer measure-view scroll routines that were called
# ChordDetect_* (they test measure numbers, not chords) and their exit labels.
s/\bChordDetect_CheckDescending\b/AccTiming_ScrollFourBarViewBack/g
s/\bChordDetect_CheckRoot1\b/AccTiming_WrapFourBarViewToEnd/g
s/\bChordDetect_CheckInversion1\b/AccTiming_WrapFourBarViewToStart/g
s/\bChordDetect_CheckAscending\b/AccTiming_ScrollTwoBarViewForward/g
s/\bChordDetect_CheckMirror\b/AccTiming_ScrollTwoBarViewBack/g
s/\bChordDetect_CheckRoot2\b/AccTiming_WrapTwoBarViewToEnd/g
s/\bChordDetect_CheckInversion2\b/AccTiming_WrapTwoBarViewToStart/g
s/\bRhythmParam_CheckExit6\b/AccTiming_ScrollFourBarViewForward_Ret/g
s/\bRhythmParam_CheckExit6_Pad\b/AccTiming_ScrollFourBarViewForward_Pad/g
s/\bToneGen_NullRet2\b/AccTiming_ScrollFourBarViewBack_Ret/g
s/\bToneGen_NullRet2_Pad\b/AccTiming_ScrollFourBarViewBack_Pad/g
s/\bRhythmParam_CheckExit5\b/AccTiming_WrapFourBarViewToEnd_Ret/g
s/\bRhythmParam_CheckExit5_Pad\b/AccTiming_WrapFourBarViewToEnd_Pad/g
s/\bRhythmParam_CheckExit4\b/AccTiming_WrapFourBarViewToStart_Ret/g
s/\bRhythmParam_CheckExit4_Pad\b/AccTiming_WrapFourBarViewToStart_Pad/g
s/\bRhythmParam_CheckExit3\b/AccTiming_ScrollTwoBarViewForward_Ret/g
s/\bRhythmParam_CheckExit3_Pad\b/AccTiming_ScrollTwoBarViewForward_Pad/g
s/\bRhythm_NullRet\b/AccTiming_ScrollTwoBarViewBack_Ret/g
s/\bRhythm_NullRet_Pad\b/AccTiming_ScrollTwoBarViewBack_Pad/g
s/\bRhythmParam_CheckExit2\b/AccTiming_WrapTwoBarViewToEnd_Ret/g
s/\bRhythmParam_CheckExit2_Pad\b/AccTiming_WrapTwoBarViewToEnd_Pad/g
s/\bRhythmParam_ValidExit\b/AccTiming_WrapTwoBarViewToStart_Ret/g
s/\bRhythmParam_ValidExit_Pad\b/AccTiming_WrapTwoBarViewToStart_Pad/g
#
# Main CPU: the pattern-editor step that replaces the note event at the cursor.
s/\bToneGen_CompareVoiceBlocks\b/ToneGen_ReplaceCursorNoteEvent/g
s/\bVoiceCompare_Done\b/ToneGen_MultiChan_Done/g
#
# Main CPU: the composer STEP title's record-part steps and their two 32-byte maps (data that was
# spelled as instructions; respelled by scripts/tools/respell_open4_engine_tables.py).
s/\bRhythmVariation_InlineCode_Code2\b/CmpStep_RecPartTowardDrums_Map/g
s/\bRhythmVariation_InlineCode_Code\b/CmpStep_RecPartTowardBass_Map/g
s/\bRhythmVariation_Select_Helper6\b/CmpStep_MoveRecPartTowardBass_Impl/g
s/\bAccScreen_DataBlock_Helper3\b/CmpStep_MoveRecPartTowardBass/g
#
# Main CPU: song-memory (sequencer track) cursor routines that were VoiceSlot_*.
s/\bVoiceSlot_FinalRetZ\b/SeqTrack_ReadByteAndAdvance/g
s/\bVoiceSlot_ReadParamsWithSaveRestore_Helper2\b/SeqTrack_AdvanceCursor/g
s/\bVoiceSlot_FinalRetZ_/SeqBlockChain_/g
#
# Sub CPU v142 (v141/v140 regenerate from it): the voice allocator.
s/\bVoice_KeyTable_Remapping\b/Voice_StealPoolOrder/g
s/\bVoice_SFX_ModulationTable\b/Voice_LayerClassTable/g
s/\bVoice_Pitch_Table_High\b/Voice_Part_PoolPtr_ModeB/g
s/\bNoteChain_FindNode_B_Walk\b/Voice_FindStealCandidate_Walk/g
s/\bNoteChain_FindNode_B_Advance\b/Voice_FindStealCandidate_Advance/g
s/\bNoteChain_FindNode_B_NotFound\b/Voice_FindStealCandidate_NotFound/g
s/\bNoteChain_FindNode_B\b/Voice_FindStealCandidate/g
s/\bVoice_Allocate_Nodes_WalkNext\b/Voice_Allocate_Nodes_StealAtQuota/g
s/\bVoice_Allocate_Nodes_AdvancePriority\b/Voice_Allocate_Nodes_CountAgainstQuota/g
#
# Main CPU: the song player's event cases (SeqNoteCh_DispatchEventType) for status 0x80 (tempo),
# 0xd2, 0x85 (accompaniment start) and 0x86 (accompaniment stop), and the tempo-event routine.
s/\bAccPedalConfig_ApplyTempo\b/SeqEvt_ApplyTempoEvent/g
s/\bSeqNote_NoteOff_CheckActive2\b/SeqNoteCh_HandleEventD2/g
s/\bSeqNote_NoteOff_CheckActive\b/SeqNoteCh_HandleTempoEvent/g
s/\bSeqNote_UpdatePositionA_Entry\b/SeqNoteCh_HandleAccStartEvent/g
s/\bSeqNote_UpdatePositionB_Entry\b/SeqNoteCh_HandleAccStopEvent/g
