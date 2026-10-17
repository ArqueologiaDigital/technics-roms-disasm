# v142 (sub CPU): Voice_CtrlChange's arms for the controllers the main CPU's SndPart_SetParam sends carry General MIDI
# guesses that do not even match General MIDI (CC 0x5B/0x5D are the reverb/chorus sends there, not sostenuto/soft
# pedal).  The main CPU sends each KN5000 part parameter as the controller of its Lsw number
# (README-lsw-param-namespace-map.md sections 5-9; main CPU SndPart_SetParam, scripts/renaming/rename_sndpart_setters.sed):
#   0x5B ReverbSend  0x5D DspEffect (send)  0x80 BendRange  0x81 Tuning  0x82 KeyShift
#   0x95 GlidePedal (Lsw 0x603)  0x97 SustainLength (0x600)  0x9C KeyScaling (0x602)
# and the bodies agree: 0x81 stores (v - 0x80) * 2 and calls Pitch_Refresh_Sounding_Voices, 0x82 stores v - 0x40
# (KeyShift is 52..76 = 64 +- 12), 0x95 / 0x9C set or clear one flag bit (the main CPU sends 0 or 0x7F).
# Left as they are: 0x5E (Voice_CC_Portamento / Voice_Portamento_OnHandler) and 0x91 / 0x9B / 0x9D, which
# SndPart_SetParam does not send.
s/\bVoice_CC_Sostenuto\b/Voice_CC_ReverbSend/g
s/\bVoice_CC_SetSostenuto\b/Voice_CC_SetReverbSend/g
s/\bVoice_CC_Soft\b/Voice_CC_DspEffectSend/g
s/\bVoice_CC_SetSoftPedal\b/Voice_CC_SetDspEffectSend/g
s/\bVoice_CC_Num128\b/Voice_CC_BendRange/g
s/\bVoice_CC_SetPortamentoRate\b/Voice_CC_SetBendRange/g
s/\bVoice_CC_Num129\b/Voice_CC_Tuning/g
s/\bVoice_CC_SetPortamentoDepth\b/Voice_CC_SetTuning/g
s/\bVoice_CC_Num130\b/Voice_CC_KeyShift/g
s/\bVoice_CC_SetPortamentoTime\b/Voice_CC_SetKeyShift/g
s/\bVoice_CC_95\b/Voice_CC_GlidePedal/g
s/\bVoice_CC_SetChorusEnable\b/Voice_CC_SetGlidePedal/g
s/\bVoiceCC_SetChorus_ClearBit\b/VoiceCC_SetGlidePedal_ClearBit/g
s/\bVoice_CC_97\b/Voice_CC_SustainLength/g
s/\bVoice_CC_SetChorusDepth\b/Voice_CC_SetSustainLength/g
s/\bVoice_CC_9C\b/Voice_CC_KeyScaling/g
s/\bVoice_CC_SetDelayEnable\b/Voice_CC_SetKeyScaling/g
s/\bVoiceCC_SetDelay_ClearBit\b/VoiceCC_SetKeyScaling_ClearBit/g
