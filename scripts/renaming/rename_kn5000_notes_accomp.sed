# Lane kn5000-notes (wave 10, 2026-11-06): accompaniment names, notes/kn5000-notes-2026-11-06/README.md.
# The phrase player's chord converter (N-1d99fc9b): Rhythm_TransposeWithMod converts a note of the
# AccompSeq phrase engine (accompseq_routines.s) for the chord; its two callers decide fixed notes.
s/\bRhythm_TransposeWithMod_Tramp\b/Rhythm_PhraseConvertNote_Tramp/g
s/\bRhythm_TransposeWithMod\b/Rhythm_PhraseConvertNote/g
s/\bRhythm_TranspMod_ModCheck\b/Rhythm_PhraseExtShift/g
s/\bRhythm_TranspMod_BaseApply\b/Rhythm_PhraseChordRow/g
s/\bRhythm_TranspMod_OctaveWrap\b/Rhythm_PhraseRootShift/g
s/\bRhythm_TranspMod_ApplyBoth\b/Rhythm_PhraseConv_ApplyBoth/g
s/\bRhythm_TranspMod_BaseLookup\b/Rhythm_PhraseConv_BaseLookup/g
s/\bRhythm_TranspMod_Done\b/Rhythm_PhraseConv_Done/g
s/\bRhythm_TranspMod_LookupTable\b/Rhythm_PhraseConv_LookupTable/g
s/\bRhythm_TranspMod_MuteCheck\b/Rhythm_PhraseConv_MuteCheck/g
s/\bRhythm_TranspMod_Offset1\b/Rhythm_PhraseConv_Offset1/g
s/\bRhythm_TranspMod_Return\b/Rhythm_PhraseConv_Return/g
s/\bRhythm_TranspMod_SubOffset\b/Rhythm_PhraseConv_SubOffset/g
s/\bRhythm_TranspMod_WrapClamp\b/Rhythm_PhraseConv_WrapClamp/g
s/\bRhythm_TranspMod_WrapDone\b/Rhythm_PhraseConv_WrapDone/g
s/\bRhythm_TranspMod_WrapJump\b/Rhythm_PhraseConv_WrapJump/g
s/\bRhythm_TranspMod_WrapNeg\b/Rhythm_PhraseConv_WrapNeg/g
s/\bAccompSeq_CheckVelocityFlags\b/AccompSeq_ConvertNote90/g
s/\bAccompSeq_VelFlags_CallDispatch\b/AccompSeq_ConvNote90_CallDispatch/g
s/\bAccompSeq_VelFlags_CheckProgram\b/AccompSeq_ConvNote90_CheckProgram/g
s/\bAccompSeq_CheckVelFlagsExtended\b/AccompSeq_ConvertNote91/g
s/\bAccompSeq_ExtVelFlags_CheckProg\b/AccompSeq_ConvNote91_CheckProg/g
s/\bAccompSeq_ExtVelFlags_Dispatch\b/AccompSeq_ConvNote91_Dispatch/g
# The sounding-note slots (N-4d5d5317): the routine clears byte +0 of every slot of the six parts.
s/\bAccompVoice_BulkReadRegisters\b/AccNotes_ForgetAllSounding/g
s/\bBulkRead_Loop1_6Byte\b/AccNotes_ForgetDrum1_Loop/g
s/\bBulkRead_Loop2_6Byte\b/AccNotes_ForgetDrum2_Loop/g
s/\bBulkRead_Loop3_9Byte\b/AccNotes_ForgetBass_Loop/g
s/\bBulkRead_Loop4_9Byte\b/AccNotes_ForgetAccomp1_Loop/g
s/\bBulkRead_Loop5_9Byte\b/AccNotes_ForgetAccomp2_Loop/g
s/\bBulkRead_Loop6_9Byte\b/AccNotes_ForgetAccomp3_Loop/g
