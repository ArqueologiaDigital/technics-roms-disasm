# SndPart_SetParam's handlers carried General MIDI guesses (RPN, bank MSB/LSB, coarse/fine tune ...).  Its dispatch
# selects them by the KN5000 Lsw number (README-lsw-param-namespace-map.md sections 7-9), and their bodies send:
#   0x1B0 PitchBend      -> MIDI_SendPitchBend            0x1B2 ChannelPressure -> MIDI_SendChannelPressure
#   0x080 BendRange      -> controller 0x80               0x081 Tuning          -> controller 0x81
#   0x082 KeyShift       -> controller 0x82               0x600 SustainLength   -> controller 0x97
#   0x602 KeyScaling / 0x603 GlidePedal -> clamped to 0 / 0x7F, then sent
#   0x05D DspEffect      -> controller 0x5D               0x05E DigitalEffect   -> stored in the per-part table 0xD050
#   0x020 Bank           -> stored in the per-part table 0xD010
# (analysis/disk-format-probes/sndparam-r3/observations.json, "misleading code labels met on the way").
s/\bSndPart_SetRPN\b/SndPart_SetPitchBend/g
s/\bSndPart_SetPitchBendSens\b/SndPart_SetChannelPressure/g
s/\bSndPart_SetCoarseTun_LoadReg\b/SndPart_SetGlidePedal_LoadReg/g
s/\bSndPart_SetCoarseTune\b/SndPart_SetGlidePedal/g
s/\bSndPart_SetFineTune_LoadReg\b/SndPart_SetKeyScaling_LoadReg/g
s/\bSndPart_SetFineTune\b/SndPart_SetKeyScaling/g
s/\bSndPart_SetBankMSB\b/SndPart_SetBendRange/g
s/\bSndPart_SetBankLSB\b/SndPart_SetTuning/g
s/\bSndPart_SetBankSelect\b/SndPart_SetKeyShift/g
s/\bSndPart_SetDelaySend\b/SndPart_SetDigitalEffect/g
s/\bSndPart_SetChorusSend\b/SndPart_SetDspEffect/g
s/\bSndPart_SetPitchBendRange\b/SndPart_SetSustainLength/g
s/\bSndPart_SetProgramMSB\b/SndPart_SetBank/g
# DSPCfg_ProcessInput's record-0x70 arm handles the FADE IN/OUT settings, not a compressor: byte 5 = FADE IN time
# (key 0x2A00) and byte 6 = FADE OUT time (0x2A01), each scaled into a ramp step (0xC1F8 / 0xC1FA); byte 7's bits
# are FADE OUT Rhythm Auto stop / SEQ Auto stop / Auto reset (0x2A10 / 0x2A11 / 0x2A12), copied to 0xC1F0 bits 4-6.
s/\bDSPCfg_CompressorDispatch\b/DSPCfg_FadeSettingDispatch/g
s/\bDSPCfg_CompParam_SubType6\b/DSPCfg_FadeSetting_OutTime/g
s/\bDSPCfg_CompParam_SubType7\b/DSPCfg_FadeSetting_Flags/g
s/\bDSPCfg_CompParam_Bit1\b/DSPCfg_FadeSetting_SeqAutoStop/g
s/\bDSPCfg_CompParam_Bit2\b/DSPCfg_FadeSetting_AutoReset/g
