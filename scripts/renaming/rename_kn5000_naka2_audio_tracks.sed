# lane open12/kn5000-naka2: Audio_CheckInitStatus's "group A / group B" are the play tracks (SEQ_TRACK_MASK |
# 0x0d51) and the record tracks (SEQ_REC_TRACKS | 0x0d4f); "type 0xE / 0x10" are TRACK ASSIGN 14 APC and 16
# RHYTHM (AUDIO_SEQ_TRACK_FLAGS in shared/ram_variables_by_use.s has the evidence).  All five trees.
s/AudioInit_CheckGroupA\/B, AudioInit_GroupA\/B_\*/AudioInit_CheckPlayTrack \/ CheckRecTrack, AudioInit_PlayTrack_* \/ RecTrack_*/g
s/\bAudioInit_ClearStatusBit8\b/AudioInit_NoPlayTracks/g
s/\bAudioInit_CheckGroupB_Presence\b/AudioInit_CheckRecTracks/g
s/\bAudioInit_ClearStatusBit9\b/AudioInit_NoRecTracks/g
s/\bAudioInit_CheckGroupA\b/AudioInit_CheckPlayTrack/g
s/\bAudioInit_GroupA_TypeE\b/AudioInit_PlayTrack_Apc/g
s/\bAudioInit_GroupA_OtherType\b/AudioInit_PlayTrack_OtherAssign/g
s/\bAudioInit_GroupA_NoAuxMapping\b/AudioInit_PlayTrack_NoAuxMapping/g
s/\bAudioInit_GroupA_DefaultMapping\b/AudioInit_PlayTrack_DefaultMapping/g
s/\bAudioInit_GroupA_NoSecondary\b/AudioInit_PlayTrack_NoSecondary/g
s/\bAudioInit_CheckGroupB_Channel\b/AudioInit_CheckRecTrack/g
s/\bAudioInit_GroupB_CheckType\b/AudioInit_RecTrack_CheckType/g
s/\bAudioInit_GroupB_TypeE\b/AudioInit_RecTrack_Apc/g
s/\bAudioInit_GroupB_Type10\b/AudioInit_RecTrack_Rhythm/g
s/\bAudioInit_GroupB_DefaultMapping\b/AudioInit_RecTrack_OtherAssign/g
