# open4/kn5000-b-midi (2026-10-31): proprietary CC handlers 0x91/0x9B/0x9D named from what their
# stored bytes do (notes/open4-kn5000-b/midi/README.md, kn5000-5ck), and the TT_SQSTEP
# panel-button dispatcher that was called a SysEx bytecode dispatcher (kn5000-nl6 lead).
s/\bVoice_CC_SetReverbDepth\b/Voice_CC_SetVelSwitchConfig/g
s/\bVoice_CC_91\b/Voice_CC_VelSwitchConfig/g
s/\bVoice_CC_SetDelayDepth\b/Voice_CC_SetGateRoutingMode/g
s/\bVoice_CC_9B\b/Voice_CC_GateRoutingMode/g
s/\bVoice_CC_SetDelayFeedback\b/Voice_CC_SetTgPanMode/g
s/\bVoice_CC_9D\b/Voice_CC_TgPanMode/g
s/\bSysEx_BytecodeDispatcher/SqStep_PanelButtonDispatch/g
s/\bSysInit_BytecodeBlock\b/SqStep_ButtonRhythmModeBytes/g
# The 5-byte C0 record {5, 0xC0, part, program, bank, digital-effect switch} that selects a part's sound in
# the sub CPU (kn5000-8dy, sound-categories.md "step 4"); nothing in it sends channel pressure.
s/\bSendChannelPressure_Prologue\b/SndPart_SendProgramChange/g
s/\bSendChannelPressure_InitVal\b/SndPart_SendProgramChange_EffectSet/g
s/\bSendChannelPressure_LoadReg\b/SndPart_SendProgramChange_StoreEffect/g
s/\bSendChannelPressure_LoadParam\b/SndPart_SendProgramChange_Build/g
