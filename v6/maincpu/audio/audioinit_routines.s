; ============================================================================
; AudioInit_ConfigStereoVoice - Configure stereo voice routing and panning
; ============================================================================
; Input:  Voice index (from voice type table at 0xee8e62)
; Output: Updates audio config flags at address 50588
; Default handler in voice-source dispatch table. Routes voices by type:
; simple stereo (type < 3) or extended routing with panning configuration.
; ============================================================================
AudioInit_ConfigStereoVoice:
	ld	a, (PART_SELECT:16)
	extz	wa
	lda	xbc, (AudioInit_ChannelMapA:24)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0x3
	.byte 0x67, 0x78
	ld	a, (PART_SELECT:16)
	extz	wa
	lda	xbc, (AudioInit_ChannelMapA:24)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	(AUDIO_STATE+1:16), a
	cp	a, 0xff
	jr	z, AudioInit_VoiceNotConfigured
	orw	(AUDIO_STATE_CHANGES:16), 2
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	nz, AudioInit_SetDefaultLevels
AudioInit_CheckVoiceMixFlags:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x7
	jr	z, AudioInit_SetDefaultLevels
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	nz, AudioInit_ClearModeRegister
	set	3, (AUDIO_STATE:16)
	jr	AudioInit_AfterModeSet
AudioInit_ClearModeRegister:
	ld	(AUDIO_STATE:16), 0
AudioInit_AfterModeSet:
	orw	(AUDIO_STATE_CHANGES:16), 1
AudioInit_SetDefaultLevels:
	ld	(AUDIO_STATE+188:16), 255
	ld	(AUDIO_STATE+189:16), 255
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_CheckBit5_FD07
	ld	(AUDIO_STATE+6:16), 2
AudioInit_CheckBit5_FD07:
	bit	5, (PANEL_PART_BASS+13:16)
	jr	nz, AudioInit_CheckBit5_FBF1
	ld	(AUDIO_STATE+26:16), 22
AudioInit_CheckBit5_FBF1:
	orw	(AUDIO_STATE_CHANGES:16), 260
	jp	AudioInit_ConfigurePanning
AudioInit_VoiceNotConfigured:
	ld	(AUDIO_STATE+1:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 3
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	nz, AudioInit_RouteAndPan
AudioInit_CheckMixFlagsAlt:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x7
	jr	nz, AudioInit_CheckBit2Mode
	bit	2, (AUDIO_STATE:16)
	jr	z, AudioInit_RouteAndPan
AudioInit_CheckBit2Mode:
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	nz, AudioInit_ClearModeAlt
	set	3, (AUDIO_STATE:16)
	jr	AudioInit_AfterModeSetAlt
AudioInit_ClearModeAlt:
	ld	(AUDIO_STATE:16), 0
AudioInit_AfterModeSetAlt:
	orw	(AUDIO_STATE_CHANGES:16), 1
AudioInit_RouteAndPan:
	call	AudioInit_ConfigureVoiceRouting
	call	AudioInit_ConfigurePanning
	jp	AudioInit_CheckStereoMode
AudioInit_ConfigureVoiceFromFlags:
	ld	bc, (AUDIO_SEQ_TRACK_FLAGS:16)
	bit	0, bc
	jr	z, AudioInit_FallbackToStereo
	ldmm8	0xc13f, AUDIO_REC_TRACK_SLOT
	orw	(AUDIO_STATE_CHANGES:16), 2
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x6e
	jr	z, AudioInit_VoiceRouteJump
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0xe
	jr	z, AudioInit_VoiceRouteJump
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	nz, AudioInit_ClearModeFromFlags
	set	3, (AUDIO_STATE:16)
	jr	AudioInit_VoiceRouteJump
AudioInit_ClearModeFromFlags:
	ld	(AUDIO_STATE:16), 0
AudioInit_VoiceRouteJump:
	call	AudioInit_ConfigureVoiceRouting
	jp	AudioInit_ConfigurePanning
AudioInit_FallbackToStereo:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioInit_SelectVoiceByType:
	ld	a, (CMP_RECORD_PART:16)
	cp	a, 0x60
	jr	z, AudioInit_StereoVoiceCfg
	cp	a, 0x10
	jr	z, AudioInit_StereoVoiceCfg
	cp	a, 0x8
	jr	z, AudioInit_SetVoice19
	cp	a, 4:i3
	jr	z, AudioInit_SetVoice18
	cp	a, 2:i3
	jr	z, AudioInit_SetVoice17
	cp	a, 1:i3
	jr	nz, AudioInit_StereoVoiceCfg
	ld	(AUDIO_STATE+1:16), 16
	orw	(AUDIO_STATE_CHANGES:16), 2
	ret
AudioInit_SetVoice17:
	ld	(AUDIO_STATE+1:16), 17
	orw	(AUDIO_STATE_CHANGES:16), 2
	ret
AudioInit_SetVoice18:
	ld	(AUDIO_STATE+1:16), 18
	orw	(AUDIO_STATE_CHANGES:16), 2
	ret
AudioInit_SetVoice19:
	ld	(AUDIO_STATE+1:16), 19
	orw	(AUDIO_STATE_CHANGES:16), 2
	ret
AudioInit_StereoVoiceCfg:
	ld	(AUDIO_STATE+1:16), 20
	orw	(AUDIO_STATE_CHANGES:16), 2
	ret
AudioInit_PushAndConfigVoice:
	dec	2, xsp
	ld	(xsp), a
	cp	(xsp), 0x1
	call	z, (AudioInit_RefreshToneBank:24)
	orw	(AUDIO_CONFIG_UPDATE:16), 2
	ld	a, (xsp)
	extz	wa
	calr	AudioInit_ConfigStereoVoice
	inc	2, xsp
	ret
AudioInit_PushAndConfigVoiceAlt:
	dec	2, xsp
	ld	(xsp), a
	cp	(xsp), 0x1
	call	z, (AudioInit_RefreshToneBank:24)
	ld	a, (CURRENT_TITLE:16)
	cp	a, 0xc9
	jr	nz, AudioInit_LoadStackAndConfig
	ld	(AUDIO_STATE+1:16), 23
	orw	(AUDIO_STATE_CHANGES:16), 2
	jr	AudioInit_RestoreStack
AudioInit_LoadStackAndConfig:
	ld	a, (xsp)
	extz	wa
	calr	AudioInit_ConfigStereoVoice
AudioInit_RestoreStack:
	inc	2, xsp
	ret
AudioInit_CheckSoundGroup:
	cp	(CURRENT_TITLE:16), 3
	jr	z, AudioInit_LoadGroupVoice
	cp	(CURRENT_TITLE:16), 8
	jr	nz, AudioInit_GroupFallbackDefault
AudioInit_LoadGroupVoice:
	ld	c, (PART_SELECT:16)
	extz	bc
	lda	xde, (AudioInit_ChannelMapA:24)
	ld	c, (xde+bc)
	ld	(AUDIO_STATE+1:16), c
	cp	c, 0xff
	jr	z, AudioInit_GroupFallbackStereo
	orw	(AUDIO_STATE_CHANGES:16), 2
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	nz, AudioInit_SetGroupLevels
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x7
	jr	z, AudioInit_SetGroupLevels
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	nz, AudioInit_ClearGroupMode
	set	3, (AUDIO_STATE:16)
	jr	AudioInit_AfterGroupModeSet
AudioInit_ClearGroupMode:
	ld	(AUDIO_STATE:16), 0
AudioInit_AfterGroupModeSet:
	orw	(AUDIO_STATE_CHANGES:16), 1
AudioInit_SetGroupLevels:
	ld	(AUDIO_STATE+188:16), 255
	ld	(AUDIO_STATE+189:16), 255
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_CheckGroupBit5_FD07
	ld	(AUDIO_STATE+6:16), 2
AudioInit_CheckGroupBit5_FD07:
	bit	5, (PANEL_PART_BASS+13:16)
	jr	nz, AudioInit_CheckGroupBit5_FBF1
	ld	(AUDIO_STATE+26:16), 22
AudioInit_CheckGroupBit5_FBF1:
	orw	(AUDIO_STATE_CHANGES:16), 260
	jp	AudioInit_ConfigurePanning
AudioInit_GroupFallbackStereo:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioInit_GroupFallbackDefault:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioInit_CheckSoundGroup51:
	cp	(CURRENT_TITLE:16), 81
	jr	nz, AudioInit_G51FallbackDefault
	ld	c, (PART_SELECT:16)
	extz	bc
	lda	xde, (AudioInit_ChannelMapB:24)
	ld	c, (xde+bc)
	ld	(AUDIO_STATE+1:16), c
	cp	c, 0xff
	jr	z, AudioInit_G51FallbackStereo
	orw	(AUDIO_STATE_CHANGES:16), 2
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	nz, AudioInit_SetGroup51Levels
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x7
	jr	z, AudioInit_SetGroup51Levels
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	nz, AudioInit_ClearGroup51Mode
	set	3, (AUDIO_STATE:16)
	jr	AudioInit_AfterGroup51ModeSet
AudioInit_ClearGroup51Mode:
	ld	(AUDIO_STATE:16), 0
AudioInit_AfterGroup51ModeSet:
	orw	(AUDIO_STATE_CHANGES:16), 1
AudioInit_SetGroup51Levels:
	ld	(AUDIO_STATE+188:16), 255
	ld	(AUDIO_STATE+189:16), 255
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_CheckG51Bit5_FD07
	ld	(AUDIO_STATE+6:16), 2
AudioInit_CheckG51Bit5_FD07:
	bit	5, (PANEL_PART_BASS+13:16)
	jr	nz, AudioInit_CheckG51Bit5_FBF1
	ld	(AUDIO_STATE+26:16), 22
AudioInit_CheckG51Bit5_FBF1:
	orw	(AUDIO_STATE_CHANGES:16), 260
	jp	AudioInit_ConfigurePanning
AudioInit_G51FallbackStereo:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioInit_G51FallbackDefault:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioInit_CheckMixMode:
	ld	c, (CURRENT_TITLE:16)
	cp	c, 0x76
	jr	z, AudioInit_LoadAndConfigure
	cp	c, 0x73
	jr	z, AudioInit_LoadAndConfigure
	cp	c, 0x72
	jr	z, AudioInit_LoadAndConfigure
	cp	c, 0x6f
	jr	nz, AudioInit_MixFallbackDefault
AudioInit_LoadAndConfigure:
	ld	c, (PART_SELECT:16)	; LD C, (238D3Ah) - 24-bit addressing mode
	extz	bc
	lda	xde, (AudioInit_ChannelMapB:24)
	ld	c, (xde+bc)
	ld	(AUDIO_STATE+1:16), c
	cp	c, 0xff
	jr	z, AudioInit_MixFallbackConfig
	orw	(AUDIO_STATE_CHANGES:16), 2
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	ret	z
	.byte	0xf1, 0x3f, 0xc1, 0x00, 0xff
	ret
AudioInit_MixFallbackConfig:
	extz	wa
	calr	AudioInit_ConfigStereoVoice
	ret
AudioInit_MixFallbackDefault:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioVoiceHandler_NoneSentinel:
	extz	wa
	jrl	AudioInit_ConfigStereoVoice
AudioInit_DrumSaveReturn:
	ldw	(0xc4e4:16), 0
	ldw	(0xc4e6:16), 0
	push	xde
	push	xhl
	push	xix
	push	xiz
	lda	xwa, (AUDIO_STATE:16)
	call	CtrlPanel_RefreshIndicatorState
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ret
AudioInit_VoiceParamCtrl:
	dec	6, xsp
	ld	c, 0x0:opc
	bit	0, (PANEL_MIDI+3:16)
	jr	z, AudioInit_CheckVoiceParamState
	set	1, c
AudioInit_CheckVoiceParamState:
	cp	(AUDIO_STATE+1:16), 255
	jr	nz, AudioInit_CompareAndSendMIDI
	cp	(0xc508:16), 255
	jr	z, AudioInit_CheckBit2VoiceParam
	set	0, c
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x80
	cp	wa, 0x80
	jr	nz, AudioInit_CompareAndSendMIDI
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x3
	jr	z, AudioInit_CompareAndSendMIDI
	set	4, c
	jr	AudioInit_CompareAndSendMIDI
AudioInit_CheckBit2VoiceParam:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	2, wa
	jr	z, AudioInit_CompareAndSendMIDI
	or	c, 0x18
AudioInit_CompareAndSendMIDI:
	cp	(0xc4e8:16), c
	jr	z, AudioInit_VoiceParamDone
	ld	(0xc4e8:16), c
	ld	(xsp + 0:8), 0x4	; LD (XSP + 000h), 004h - explicit displacement encoding
	ld	(xsp + 1), 0xf0
	ld	(xsp + 2), 0x50
	ld	(xsp + 3), 0x91
	ldmi16	(xsp + 4), 0xc4e8
	lda	xwa, (xsp)
	call	MIDI_SendCmdPacket
	call	MIDI_PostSendStub
	cp	(CURRENT_MODE:16), 13
	jr	z, AudioInit_VoiceParamDone
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	Audio_ProcessPartExpressions
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
AudioInit_VoiceParamDone:
	inc	6, xsp
	ret
AudioInit_DrumRoutingCheck:
	ld	de, 0:i3
	bit	2, (AUDIO_STATE:16)
	.byte 0x6e, 0x16
AudioInit_CheckOutputFlags:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jrl	nz, AudioInit_NoRoutingActive
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x3
	jrl	z, AudioInit_NoRoutingActive
AudioInit_ProcessVoiceAssign:
	cp	(AUDIO_STATE+1:16), 255
	jr	nz, AudioInit_CheckStoredVoice
	set	3, de
	ldmm8	0xc508, 0xc4e2
	jr	AudioInit_UpdateVoiceBank0
AudioInit_CheckStoredVoice:
	cp	(0xc508:16), 255
	jr	z, AudioInit_ClearStoredVoice
	set	3, de
AudioInit_ClearStoredVoice:
	ld	(0xc508:16), 255
AudioInit_UpdateVoiceBank0:
	ld	a, (AUDIO_STATE+197:16)
	srl	a, 1
	cp	a, (0xc4e2:16)
	jr	z, AudioInit_UpdateVoiceBank1
	set	7, (AUDIO_STATE+196:16)
	ld	a, (0xc4e2:16)
	res	7, a
	sla	a, 1
	and	(AUDIO_STATE+197:16), 1
	or	(AUDIO_STATE+197:16), a
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_UpdateVoiceBank1:
	ld	a, (AUDIO_STATE+201:16)
	srl	a, 1
	cp	a, (0xc4e2:16)
	jr	z, AudioInit_UpdateVoiceBank2
	set	7, (AUDIO_STATE+200:16)
	ld	a, (0xc4e2:16)
	res	7, a
	sla	a, 1
	and	(AUDIO_STATE+201:16), 1
	or	(AUDIO_STATE+201:16), a
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_UpdateVoiceBank2:
	ld	a, (0xc4e2:16)
	dec	1, a
	ld	c, (AUDIO_STATE+204:16)
	res	7, c
	cp	c, a
	jr	z, AudioInit_CheckStereoRouting
	set	7, (AUDIO_STATE+204:16)
	ld	a, (0xc4e2:16)
	dec	1, a
	res	7, a
	and	(AUDIO_STATE+204:16), 128
	or	(AUDIO_STATE+204:16), a
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_CheckStereoRouting:
	bit	3, (AUDIO_STATE:16)
	jr	z, AudioInit_ClearStereoRouting
	ld	a, (0xc4e2:16)
	dec	1, a
	ld	c, (AUDIO_STATE+208:16)
	res	7, c
	cp	c, a
	jr	z, AudioInit_VoiceStereoCheck
	set	7, (AUDIO_STATE+208:16)
	ld	a, (0xc4e2:16)
	dec	1, a
	res	7, a
	and	(AUDIO_STATE+208:16), 128
	or	(AUDIO_STATE+208:16), a
	orw	(AUDIO_VOICE_CHANGES:16), 512
	jr	AudioInit_VoiceStereoCheck
AudioInit_ClearStereoRouting:
	ld	a, (AUDIO_STATE+208:16)
	res	7, a
	cp	a, 0:i3
	jr	z, AudioInit_VoiceStereoCheck
	set	7, (AUDIO_STATE+208:16)
	and	(AUDIO_STATE+208:16), 128
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_VoiceStereoCheck:
	ld	a, (AUDIO_STATE+213:16)
	srl	a, 1
	cp	a, (0xc4e2:16)
	jrl	z, AudioInit_UpdateIndicators
	set	7, (AUDIO_STATE+212:16)
	ld	a, (0xc4e2:16)
	res	7, a
	sla	a, 1
	and	(AUDIO_STATE+213:16), 1
	or	(AUDIO_STATE+213:16), a
	orw	(AUDIO_VOICE_CHANGES:16), 512
	jrl	AudioInit_UpdateIndicators
AudioInit_NoRoutingActive:
	cp	(0xc508:16), 255
	jr	z, AudioInit_ClearAllVoiceBanks
	set	3, de
AudioInit_ClearAllVoiceBanks:
	ld	(0xc508:16), 255
	ld	a, (AUDIO_STATE+197:16)
	res	0, a
	cp	a, 0:i3
	jr	z, AudioInit_ClearBank1Routing
	set	7, (AUDIO_STATE+196:16)
	and	(AUDIO_STATE+197:16), 1
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_ClearBank1Routing:
	ld	a, (AUDIO_STATE+201:16)
	res	0, a
	cp	a, 0:i3
	jr	z, AudioInit_ClearBank2Routing
	set	7, (AUDIO_STATE+200:16)
	and	(AUDIO_STATE+201:16), 1
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_ClearBank2Routing:
	ld	a, (AUDIO_STATE+204:16)
	res	7, a
	cp	a, 0:i3
	jr	z, AudioInit_CheckBit2Routing
	set	7, (AUDIO_STATE+204:16)
	and	(AUDIO_STATE+204:16), 128
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_CheckBit2Routing:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	2, wa
	jr	z, AudioInit_ClearBank3Routing
	ld	a, (AUDIO_STATE+208:16)
	res	7, a
	cp	a, 0x7f
	jr	z, AudioInit_UpdateIndicators
	set	7, (AUDIO_STATE+208:16)
	or	(AUDIO_STATE+208:16), 127
	orw	(AUDIO_VOICE_CHANGES:16), 512
	jr	AudioInit_UpdateIndicators
AudioInit_ClearBank3Routing:
	ld	a, (AUDIO_STATE+208:16)
	res	7, a
	cp	a, 0:i3
	jr	z, AudioInit_UpdateIndicators
	set	7, (AUDIO_STATE+208:16)
	and	(AUDIO_STATE+208:16), 128
	orw	(AUDIO_VOICE_CHANGES:16), 512
AudioInit_UpdateIndicators:
	bit	3, de
	ret	z
	ldw	wa, 0x45
	call	CtrlPanel_SetIndicatorBit
	cp	(0xc508:16), 255
	jr	z, AudioInit_ClearDrumModeAlt
	ld	a, (PANEL_PLAY_SETTINGS:16)
	and	a, 0x3
	jr	z, AudioInit_ClearDrumMode
	ld	a, (0xc4e2:16)
	cp	a, 0x43
	jr	z, AudioInit_SetDrumMode4
	cp	a, 0x3c
	jr	z, AudioInit_SetDrumMode2
	cp	a, 0x37
	ret	nz
	ld	(0x8e98:16), 1
	ret
AudioInit_SetDrumMode2:
	ld	(0x8e98:16), 2
	ret
AudioInit_SetDrumMode4:
	ld	(0x8e98:16), 4
	ret
AudioInit_ClearDrumMode:
	and	(0x8e98:16), 248
	ret
AudioInit_ClearDrumModeAlt:
	and	(0x8e98:16), 248
	ret
AudioInit_ClearPartFlags_ByMode:
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	and	wa, 0x3
	jr	z, AudioInit_SetPartMasks
	ld	de, 0:i3
	cp	de, 0x1a
	ret	nc
AudioInit_ClearPartFlags_Loop:
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	resm	5, (xwa)
	orw	(AUDIO_STATE_CHANGES:16), 8
	inc	1, de
	cp	de, 0x1a
	jr	c, AudioInit_ClearPartFlags_Loop
	ret
AudioInit_SetPartMasks:
	ld	de, 0:i3
	cp	de, 0x10
	jr	nc, AudioInit_CheckGlobalFlag6
AudioInit_SetPartMasks_Loop:
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	setm	5, (xwa)
	inc	1, de
	cp	de, 0x10
	jr	c, AudioInit_SetPartMasks_Loop
AudioInit_CheckGlobalFlag6:
	bit	6, (PANEL_MIDI+3:16)
	jr	z, AudioInit_ClearVoiceGroupFlags
	set	5, (AUDIO_STATE+324:16)
	set	5, (AUDIO_STATE+326:16)
	set	5, (AUDIO_STATE+328:16)
	set	5, (AUDIO_STATE+330:16)
	set	5, (AUDIO_STATE+334:16)
	jr	AudioInit_CheckVoiceFlag6
AudioInit_ClearVoiceGroupFlags:
	res	5, (AUDIO_STATE+324:16)
	res	5, (AUDIO_STATE+326:16)
	res	5, (AUDIO_STATE+328:16)
	res	5, (AUDIO_STATE+330:16)
	res	5, (AUDIO_STATE+334:16)
	orw	(AUDIO_STATE_CHANGES:16), 8
AudioInit_CheckVoiceFlag6:
	bit	6, (PANEL_MIDI:16)
	jr	z, AudioInit_ClearAuxVoiceFlag
	set	5, (AUDIO_STATE+332:16)
	jr	AudioInit_CheckReverbFlag
AudioInit_ClearAuxVoiceFlag:
	res	5, (AUDIO_STATE+332:16)
	orw	(AUDIO_STATE_CHANGES:16), 8
AudioInit_CheckReverbFlag:
	bit	7, (PANEL_MIDI+3:16)
	jr	z, AudioInit_ClearReverbFlag
	set	5, (AUDIO_STATE+342:16)
	ret
AudioInit_ClearReverbFlag:
	res	5, (AUDIO_STATE+342:16)
	orw	(AUDIO_STATE_CHANGES:16), 8
	ret
Audio_CheckInitStatus:
	dec	2, xsp
	ldw	(xsp), 0x0
	ldw	(AUDIO_SEQ_TRACK_FLAGS:16), 0
	ld	(AUDIO_REC_TRACK_SLOT:16), 255
	ld	hl, (SEQ_TRACK_MASK:16)
	or	hl, (3409:16)
	ld	wa, hl
	cp	wa, 0:i3
	jr	z, AudioInit_NoPlayTracks
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 256
	jr	AudioInit_CheckRecTracks
AudioInit_NoPlayTracks:
	andw	(AUDIO_SEQ_TRACK_FLAGS:16), 0xfeff
AudioInit_CheckRecTracks:
	ld	bc, (SEQ_REC_TRACKS:16)
	or	bc, (3407:16)
	ld	wa, bc
	cp	wa, 0:i3
	jr	z, AudioInit_NoRecTracks
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 512
	jr	AudioInit_ChannelLoop_Init
AudioInit_NoRecTracks:
	andw	(AUDIO_SEQ_TRACK_FLAGS:16), 0xfdff
AudioInit_ChannelLoop_Init:
	ld	e, 0x0:opc
	cp	e, 0x10
	jrl	nc, AudioInit_ChannelLoop_Done
AudioInit_ChannelLoop_Body:
	ld	a, e
	extz	wa
	lda	xix, (SEQ_TRACK_ASSIGN:16)
	extz	xwa
	add	xwa, xix
	ld	a, (xwa)
	ld	d, a
	bit	1, (62014:16)
	jr	z, AudioInit_ChannelLoop_Body_Skip2
	ldi_erpb	230, 255
	ld	a, e
	extz	wa
	lda	xix, (61872:16)
	extz	xwa
	add	xwa, xix
	cp	(xwa), 16
	jr	z, AudioInit_ChannelLoop_Body_Skip
	ld	a, e
	extz	wa
	lda	xix, (61872:16)
	extz	xwa
	add	xwa, xix
	ld	a, (xwa)
	ldfr_berp	a, 230
AudioInit_ChannelLoop_Body_Skip:
	ldto_berp	a, 230
	ldfr_berp	a, 226
	jr	AudioInit_CheckVoiceChanged
AudioInit_ChannelLoop_Body_Skip2:
	ld	a, e
	extz	wa
	add	wa, wa
	lda	xix, (Bit16Mask_Table:24)
	ld	wa, (xix+wa)
	and	wa, (0xf290:16)
	jr	z, AudioInit_VoiceNotAssigned
	ld	a, e
	extz	wa
	lda	xix, (SEQ_TRACK_ASSIGN:16)
	extz	xwa
	add	xwa, xix
	ld	a, (xwa)
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	extz	wa
	lda	xix, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xix
	ld	a, (xwa)
	ldfr_berp	A, 0xe2
	jr	AudioInit_CheckVoiceChanged
AudioInit_VoiceNotAssigned:
	ldi_erpb	0xe2, 0xff
AudioInit_CheckVoiceChanged:
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	cp	(xix+wa), 0xff
	jr	z, AudioInit_VoiceUnchanged
	ld	a, e
	extz	wa
	add	wa, wa
	lda	xix, (Bit16Mask_Table:24)
	ld	wa, (xix+wa)
	ld	ix, hl
	or	ix, bc
	and	ix, wa
	jr	nz, AudioInit_CheckPlayTrack
AudioInit_VoiceUnchanged:
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	extz	xwa
	add	xwa, xix
	ld	(xwa), 0xff
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+164:16)
	extz	xwa
	add	xwa, xix
	ld	(xwa), 0xff
	jrl	AudioInit_ChannelLoop_Next
AudioInit_CheckPlayTrack:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	bit	8, wa
	jrl	z, AudioInit_CheckRecTrack
	ld	a, e
	extz	wa
	add	wa, wa
	lda	xix, (Bit16Mask_Table:24)
	ld	wa, (xix+wa)
	and	wa, hl
	jrl	z, AudioInit_CheckRecTrack
	ld	a, d
	cp	a, 0xe
	jr	z, AudioInit_PlayTrack_Apc
	cp	a, 0xd
	jrl	nz, AudioInit_PlayTrack_OtherAssign
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 32
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	jrl	AudioInit_CheckRecTrack
AudioInit_PlayTrack_Apc:
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 64
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	jrl	AudioInit_CheckRecTrack
AudioInit_PlayTrack_OtherAssign:
	cp	(CURRENT_TITLE:16), 138
	jr	nz, AudioInit_PlayTrack_DefaultMapping
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	add	wa, wa
	lda	xix, (Bit16Mask_Table:24)
	ld	wa, (xix+wa)
	and	wa, (3928:16)
	jr	z, AudioInit_PlayTrack_NoAuxMapping
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	jr	AudioInit_StoreChannelMapping
AudioInit_PlayTrack_NoAuxMapping:
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	(xiy), 0xff
	jr	AudioInit_StoreChannelMapping
AudioInit_PlayTrack_DefaultMapping:
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	add	wa, wa
	lda	xix, (Bit16Mask_Table:24)
	ld	wa, (xix+wa)
	and	wa, (0xf1d0:16)
	jr	z, AudioInit_PlayTrack_NoSecondary
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	jr	AudioInit_StoreChannelMapping
AudioInit_PlayTrack_NoSecondary:
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	(xiy), 0xff
AudioInit_StoreChannelMapping:
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+164:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ldto_berp	A, 0xe2
	ld	(xiy), a
AudioInit_CheckRecTrack:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	bit	9, wa
	jrl	z, AudioInit_ChannelLoop_Next
	ld	a, e
	extz	wa
	add	wa, wa
	lda	xix, (Bit16Mask_Table:24)
	ld	wa, (xix+wa)
	and	wa, bc
	jrl	z, AudioInit_ChannelLoop_Next
	incw	1, (xsp)
	cp	(AUDIO_REC_TRACK_SLOT:16), 255
	jr	nz, AudioInit_RecTrack_CheckType
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	(AUDIO_REC_TRACK_SLOT:16), (xix+wa)
AudioInit_RecTrack_CheckType:
	ld	a, d
	cp	a, 0x10
	jrl	z, AudioInit_RecTrack_Rhythm
	cp	a, 0xe
	jr	z, AudioInit_RecTrack_Apc
	cp	a, 0xd
	jrl	nz, AudioInit_RecTrack_OtherAssign
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 2
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	jrl	AudioInit_ChannelLoop_Next
AudioInit_RecTrack_Apc:
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 4
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	jr	AudioInit_ChannelLoop_Next
AudioInit_RecTrack_Rhythm:
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 8
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	extz	xwa
	add	xwa, xix
	ld	(xwa), 0xff
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	extz	xwa
	add	xwa, xix
	ld	(xwa), 0xff
	jr	AudioInit_ChannelLoop_Next
AudioInit_RecTrack_OtherAssign:
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+132:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
	ld	a, e
	extz	wa
	lda	xix, (AUDIO_STATE+148:16)
	ld	iy, wa
	extz	xiy
	add	xiy, xix
	ld	a, d
	extz	wa
	lda	xix, (AudioInit_SlotOrderMap:24)
	ld	a, (xix+wa)
	ld	(xiy), a
AudioInit_ChannelLoop_Next:
	orw	(AUDIO_STATE_CHANGES:16), 192
	inc	1, e
	cp	e, 0x10
	jrl	c, AudioInit_ChannelLoop_Body
AudioInit_ChannelLoop_Done:
	cpw	(xsp), 0x1
	jr	nz, AudioInit_SetChangedFlag
	orw	(AUDIO_SEQ_TRACK_FLAGS:16), 1
AudioInit_SetChangedFlag:
	bit	3, (SEQ_CONTROL_FLAGS:16)
	jr	z, AudioInit_CheckExternalBit3
	andw	(AUDIO_SEQ_TRACK_FLAGS:16), 0xfdff
AudioInit_CheckExternalBit3:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	bit	6, wa
	jr	z, AudioInit_NoTypeE_CheckD
	ld	a, (PANEL_STYLE+4:16)
	and	a, 0x7
	extz	wa
	add	wa, wa
	lda	xbc, (ParamEdit_WordTable:24)
	ld	de, (xbc+wa)
	ld	a, (PANEL_STYLE+3:16)
	and	a, 0x8
	extz	wa
	add	wa, wa
	lda	xbc, (ParamEdit_WordTable:24)
	or	de, (xbc+wa)
	jr	AudioInit_ApplyOutputRouting
AudioInit_NoTypeE_CheckD:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x22
	cp	wa, 0x20
	jr	nz, AudioInit_DefaultOutputRouting
	ld	de, 2:i3
	ld	a, (PANEL_STYLE+3:16)
	and	a, 0x8
	extz	wa
	add	wa, wa
	lda	xbc, (ParamEdit_WordTable:24)
	or	de, (xbc+wa)
	jr	AudioInit_ApplyOutputRouting
AudioInit_DefaultOutputRouting:
	ld	a, (PANEL_STYLE+3:16)
	and	a, 0xf
	extz	wa
	add	wa, wa
	lda	xbc, (ParamEdit_WordTable:24)
	ld	de, (xbc+wa)
AudioInit_ApplyOutputRouting:
	andw	(AUDIO_CONFIG_FLAGS:16), 0xffe8
	or	(AUDIO_CONFIG_FLAGS:16), de
	inc	2, xsp
	ret
AudioInit_SelectPriority:
	ld	a, (CMP_RECORD_PART:16)
	cp	a, 0x10
	jrl	z, AudioInit_Priority_Mode10
	cp	a, 0x8
	jr	z, AudioInit_Priority_Mode8
	cp	a, 4:i3
	jr	z, AudioInit_Priority_Mode4
	cp	a, 2:i3
	jr	z, AudioInit_Priority_Mode2
	cp	a, 1:i3
	jrl	nz, AudioInit_Priority_Default
	ld	(AUDIO_STATE+84:16), 0
	ld	(AUDIO_STATE+85:16), 255
	ld	(AUDIO_STATE+86:16), 255
	ld	(AUDIO_STATE+87:16), 255
	ld	(AUDIO_STATE+88:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 16
	ret
AudioInit_Priority_Mode2:
	ld	(AUDIO_STATE+84:16), 255
	ld	(AUDIO_STATE+85:16), 1
	ld	(AUDIO_STATE+86:16), 255
	ld	(AUDIO_STATE+87:16), 255
	ld	(AUDIO_STATE+88:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 16
	ret
AudioInit_Priority_Mode4:
	ld	(AUDIO_STATE+84:16), 255
	ld	(AUDIO_STATE+85:16), 255
	ld	(AUDIO_STATE+86:16), 2
	ld	(AUDIO_STATE+87:16), 255
	ld	(AUDIO_STATE+88:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 16
	ret
AudioInit_Priority_Mode8:
	ld	(AUDIO_STATE+84:16), 255
	ld	(AUDIO_STATE+85:16), 255
	ld	(AUDIO_STATE+86:16), 255
	ld	(AUDIO_STATE+87:16), 3
	ld	(AUDIO_STATE+88:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 16
	ret
AudioInit_Priority_Mode10:
	ld	(AUDIO_STATE+84:16), 255
	ld	(AUDIO_STATE+85:16), 255
	ld	(AUDIO_STATE+86:16), 255
	ld	(AUDIO_STATE+87:16), 255
	ld	(AUDIO_STATE+88:16), 4
	orw	(AUDIO_STATE_CHANGES:16), 16
	ret
AudioInit_Priority_Default:
	ld	(AUDIO_STATE+84:16), 255
	ld	(AUDIO_STATE+85:16), 255
	ld	(AUDIO_STATE+86:16), 255
	ld	(AUDIO_STATE+87:16), 255
	ld	(AUDIO_STATE+88:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 16
	ret
AudioInit_CheckMIDIStatus:
	cp	(0x7e53:16), 0
	jr	z, AudioInit_MIDIDisabled
	ld	(AUDIO_STATE+123:16), 0
	ld	(AUDIO_STATE+124:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 32
	ret
AudioInit_MIDIDisabled:
	ld	(AUDIO_STATE+123:16), 255
	ld	(AUDIO_STATE+124:16), 255
	orw	(AUDIO_STATE_CHANGES:16), 32
	ret
AudioInit_RefreshToneBank:
	pushw	iz
	ld	iz, (AUDIO_CONFIG_FLAGS:16)
	andw	(AUDIO_CONFIG_FLAGS:16), 0xffef
	call	Voice_UpdatePlayModeState
	cp	l, 0xff
	call	nz, (VoiceEvent_AllocAllLayers:24)
	call	NoteMap_FindBestMatch
	cp	l, 0xff
	call	nz, (VoiceEvent_DispatchTable:24)
	ld	(AUDIO_CONFIG_FLAGS:16), iz
	popw	iz
	ret
; NOTE: THE NAME IS A MISNOMER. These 248 bytes are a ROUTINE, not a table, and
; nothing in the tree references this label. It clears bit 7 and sets bits 5/6
; across the two 0x20-entry arrays at 0xc2e2 and 0xc322, after a run of
; `or (0xc2c2),0x7f` / `and (0xc2c3),0x01` pairs whose address operand steps by
; one from 0xc2c2 to 0xc2d5, and it ends on `ret` at its last byte. The name is
; left alone (semantic labeling is deferred, and renaming an unreferenced label
; buys nothing); this comment is the record. The 119 bytes still spelled
; `.byte` below are `or (nnnn),n`, `and (nnnn),n`, `res n,(XWA)` and
; `set n,(XWA)`, which tlcs900_backend cannot yet encode -- they are not data.
AudioInit_VoiceRoutingTable:
	ret
	ret
	ret
	ret
	ret
	ret
	ret
	ld	(AUDIO_STATE:16), 0
	or	(AUDIO_STATE+196:16), 0x7f
	and	(AUDIO_STATE+197:16), 0x1
	or	(AUDIO_STATE+198:16), 0xfe
	and	(AUDIO_STATE+199:16), 0x1
	or	(AUDIO_STATE+200:16), 0x7f
	and	(AUDIO_STATE+201:16), 0x1
	or	(AUDIO_STATE+202:16), 0xfe
	and	(AUDIO_STATE+203:16), 0x1
	or	(AUDIO_STATE+204:16), 0x7f
	and	(AUDIO_STATE+205:16), 0x1
	or	(AUDIO_STATE+206:16), 0xfe
	and	(AUDIO_STATE+207:16), 0x1
	or	(AUDIO_STATE+208:16), 0x7f
	and	(AUDIO_STATE+209:16), 0x1
	or	(AUDIO_STATE+210:16), 0xfe
	and	(AUDIO_STATE+211:16), 0x1
	or	(AUDIO_STATE+212:16), 0x7f
	and	(AUDIO_STATE+213:16), 0x1
	or	(AUDIO_STATE+214:16), 0xfe
	and	(AUDIO_STATE+215:16), 0x1
	ld	de, 0:i3
	cp	de, 32
	ret	nc
AudioInit_RefreshToneBank_Loop:
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+228:16)
	extz	xwa
	add	xwa, xbc
	res	7, (xwa)
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+228:16)
	extz	xwa
	add	xwa, xbc
	and	(xwa), 0x8f
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	res	7, (xwa)
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	set	6, (xwa)
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	set	5, (xwa)
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	res	4, (xwa)
	ld	wa, de
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	and	(xwa), 0xf1
	ld	wa, de
	add	wa, wa
	add	wa, 292
	lda	xbc, (AUDIO_STATE+1:16)
	extz	xwa
	add	xwa, xbc
	and	(xwa), 0xf
	inc	1, de
	cp	de, 32
	jr	c, AudioInit_RefreshToneBank_Loop
	ret
AudioInit_ConfigureVoiceRouting:
	andw	(AUDIO_CONFIG_FLAGS:16), 0xfeff
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x3
	jrl	z, AudioInit_Routing_NoActiveVoices
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0xa0
	cp	wa, 0xa0
	jrl	nz, AudioInit_Routing_NoGroupAB
	res	2, (AUDIO_STATE:16)
	orw	(AUDIO_STATE_CHANGES:16), 1
	ld	(AUDIO_STATE+188:16), 2
	ld	(AUDIO_STATE+189:16), 22
	ld	(AUDIO_STATE+6:16), 255
	ld	(AUDIO_STATE+26:16), 255
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	9, wa
	jr	z, AudioInit_Routing_CheckSplitMode
	ld	a, (PANEL_STYLE+5:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_SetOverrideFlag
	ld	a, (PANEL_STYLE+6:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_SetOverrideFlag
	bit	5, (PANEL_PART_LEFT+13:16)
	jrl	nz, AudioInit_Routing_SkipToEnd
	ld	(AUDIO_STATE+6:16), 2
	jrl	AudioInit_Routing_Done
AudioInit_Routing_SetOverrideFlag:
	orw	(AUDIO_CONFIG_FLAGS:16), 256
	jrl	AudioInit_Routing_Done
AudioInit_Routing_CheckSplitMode:
	bit	1, (PANEL_STYLE+5:16)
	jr	z, AudioInit_Routing_NoSplit
	ld	a, (PANEL_STYLE+5:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_SplitOverride
	ld	a, (PANEL_STYLE+6:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_SplitOverride
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_Routing_SplitCheckAux
	ld	(AUDIO_STATE+6:16), 2
AudioInit_Routing_SplitCheckAux:
	bit	5, (PANEL_PART_BASS+13:16)
	jrl	nz, AudioInit_Routing_SkipToEnd
	ld	(AUDIO_STATE+26:16), 22
	jrl	AudioInit_Routing_Done
AudioInit_Routing_SplitOverride:
	orw	(AUDIO_CONFIG_FLAGS:16), 256
	jrl	AudioInit_Routing_Done
AudioInit_Routing_NoSplit:
	ld	a, (PANEL_STYLE+5:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_CheckTypeEDFlags
	ld	a, (PANEL_STYLE+6:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_CheckTypeEDFlags
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_Routing_NoSplitCheckAux
	ld	(AUDIO_STATE+6:16), 2
AudioInit_Routing_NoSplitCheckAux:
	bit	5, (PANEL_PART_BASS+13:16)
	jrl	nz, AudioInit_Routing_Done
	ld	(AUDIO_STATE+26:16), 22
	jrl	AudioInit_Routing_Done
AudioInit_Routing_CheckTypeEDFlags:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	nz, AudioInit_Routing_TypeED_Override
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_Routing_TypeED_CheckAux
	ld	(AUDIO_STATE+6:16), 2
AudioInit_Routing_TypeED_CheckAux:
	bit	5, (PANEL_PART_BASS+13:16)
	jrl	nz, AudioInit_Routing_Done
	ld	(AUDIO_STATE+26:16), 22
	jrl	AudioInit_Routing_Done
AudioInit_Routing_TypeED_Override:
	orw	(AUDIO_CONFIG_FLAGS:16), 256
	jrl	AudioInit_Routing_Done
AudioInit_Routing_NoGroupAB:
	bit	5, (PANEL_PART_LEFT+13:16)
	jr	nz, AudioInit_Routing_SimpleAssign
	ld	(AUDIO_STATE+6:16), 2
AudioInit_Routing_SimpleAssign:
	ld	(AUDIO_STATE+188:16), 21
	ld	(AUDIO_STATE+189:16), 22
	ld	(AUDIO_STATE+25:16), 255
	ld	(AUDIO_STATE+26:16), 255
	cp	(3431:16), 4
	jr	z, AudioInit_Routing_AllDisabled
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x22
	cp	wa, 0x20
	jr	nz, AudioInit_Routing_CheckMixMode
AudioInit_Routing_AllDisabled:
	ld	(AUDIO_STATE+188:16), 255
	ld	(AUDIO_STATE+189:16), 255
	jrl	AudioInit_Routing_Done
AudioInit_Routing_CheckMixMode:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	9, wa
	jrl	nz, AudioInit_Routing_Done
	bit	1, (PANEL_STYLE+5:16)
	jr	nz, AudioInit_Routing_Done
	ld	a, (PANEL_STYLE+5:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_MixFCBits
	ld	a, (PANEL_STYLE+6:16)
	and	a, 0xfc
	jr	nz, AudioInit_Routing_MixFCBits
	bit	5, (PANEL_PART_CHRD+13:16)
	jr	nz, AudioInit_Routing_MixCheckAux
	ld	(AUDIO_STATE+25:16), 21
AudioInit_Routing_MixCheckAux:
	bit	5, (PANEL_PART_BASS+13:16)
	jr	nz, AudioInit_Routing_Done
	ld	(AUDIO_STATE+26:16), 22
	jr	AudioInit_Routing_Done
AudioInit_Routing_MixFCBits:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	nz, AudioInit_Routing_Done
	bit	5, (PANEL_PART_CHRD+13:16)
	jr	nz, AudioInit_Routing_MixFCCheckAux
	ld	(AUDIO_STATE+25:16), 21
AudioInit_Routing_MixFCCheckAux:
	bit	5, (PANEL_PART_BASS+13:16)
	jr	nz, AudioInit_Routing_Done
	ld	(AUDIO_STATE+26:16), 22
AudioInit_Routing_SkipToEnd:
	jr	AudioInit_Routing_Done
AudioInit_Routing_NoActiveVoices:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	2, wa
	jr	z, AudioInit_Routing_FullDisable
	ld	(AUDIO_STATE+188:16), 21
	ld	(AUDIO_STATE+189:16), 22
	ld	(AUDIO_STATE+25:16), 255
	ld	(AUDIO_STATE+26:16), 255
	jr	AudioInit_Routing_Done
AudioInit_Routing_FullDisable:
	ld	(AUDIO_STATE+188:16), 255
	ld	(AUDIO_STATE+189:16), 255
	ld	(AUDIO_STATE+25:16), 255
	ld	(AUDIO_STATE+26:16), 255
AudioInit_Routing_Done:
	orw	(AUDIO_STATE_CHANGES:16), 260
	ret
AudioInit_ConfigurePanning:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and	wa, 0x400
	cp	wa, 0x400
	ret	nz
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	2, wa
	ret	nz
	.byte	0xc1, 0x3f, 0xc1, 0x3f, 0xff
	jr	nz, AudioInit_Pan_CheckMode0
	bit	0, (AUDIO_STATE:16)
	jr	nz, AudioInit_Pan_SetStereoLeft
AudioInit_Pan_CheckMode0:
	cp	(AUDIO_STATE+1:16), 0
	jr	nz, AudioInit_Pan_CheckMode1
AudioInit_Pan_SetStereoLeft:
	ld	(AUDIO_STATE+182:16), 0
	jr	AudioInit_Pan_CheckReverbChannel
AudioInit_Pan_CheckMode1:
	cp	(AUDIO_STATE+1:16), 255
	jr	nz, AudioInit_Pan_CheckMode1b
	bit	1, (AUDIO_STATE:16)
	jr	nz, AudioInit_Pan_SetStereoRight
AudioInit_Pan_CheckMode1b:
	cp	(AUDIO_STATE+1:16), 1
	jr	nz, AudioInit_Pan_CheckTypeED
AudioInit_Pan_SetStereoRight:
	ld	(AUDIO_STATE+182:16), 1
	jr	AudioInit_Pan_CheckReverbChannel
AudioInit_Pan_CheckTypeED:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	z, AudioInit_Pan_DefaultCenter
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	z, AudioInit_Pan_DefaultCenter
	ld	a, (PANEL_CONDUCTOR:16)
	and	a, 0x3
	cp	a, 2:i3
	jr	nz, AudioInit_Pan_TypeED_Left
	ld	(AUDIO_STATE+182:16), 1
	jr	AudioInit_Pan_CheckReverbChannel
AudioInit_Pan_TypeED_Left:
	ld	(AUDIO_STATE+182:16), 0
	jr	AudioInit_Pan_CheckReverbChannel
AudioInit_Pan_DefaultCenter:
	ld	(AUDIO_STATE+182:16), 255
AudioInit_Pan_CheckReverbChannel:
	cp	(0xe8d6:16), 14
	jr	ule, AudioInit_Pan_Reverb_CopyFromMain
	cp	(AUDIO_STATE+1:16), 255
	jr	nz, AudioInit_Pan_Reverb_CheckMode0
	bit	0, (AUDIO_STATE:16)
	jr	nz, AudioInit_Pan_Reverb_Left
AudioInit_Pan_Reverb_CheckMode0:
	cp	(AUDIO_STATE+1:16), 0
	jr	nz, AudioInit_Pan_Reverb_CheckMode1
AudioInit_Pan_Reverb_Left:
	ld	(AUDIO_STATE+190:16), 0
	jr	AudioInit_Pan_Done
AudioInit_Pan_Reverb_CheckMode1:
	cp	(AUDIO_STATE+1:16), 255
	jr	nz, AudioInit_Pan_Reverb_CheckMode1b
	bit	1, (AUDIO_STATE:16)
	jr	nz, AudioInit_Pan_Reverb_Right
AudioInit_Pan_Reverb_CheckMode1b:
	cp	(AUDIO_STATE+1:16), 1
	jr	nz, AudioInit_Pan_Reverb_CheckTypeED
AudioInit_Pan_Reverb_Right:
	ld	(AUDIO_STATE+190:16), 1
	jr	AudioInit_Pan_Done
AudioInit_Pan_Reverb_CheckTypeED:
	ld	wa, (AUDIO_SEQ_TRACK_FLAGS:16)
	and	wa, 0x60
	jr	z, AudioInit_Pan_Reverb_Center
	ld	wa, (AUDIO_CONFIG_UPDATE:16)
	bit	4, wa
	jr	z, AudioInit_Pan_Reverb_Center
	ld	a, (PANEL_CONDUCTOR:16)
	and	a, 0x3
	cp	a, 2:i3
	jr	nz, AudioInit_Pan_Reverb_TypeED_Left
	ld	(AUDIO_STATE+190:16), 1
	jr	AudioInit_Pan_Done
AudioInit_Pan_Reverb_TypeED_Left:
	ld	(AUDIO_STATE+190:16), 0
	jr	AudioInit_Pan_Done
AudioInit_Pan_Reverb_Center:
	ld	(AUDIO_STATE+190:16), 255
	jr	AudioInit_Pan_Done
AudioInit_Pan_Reverb_CopyFromMain:
	ldmm8	AUDIO_STATE+190, 0xe8d6
AudioInit_Pan_Done:
	orw	(AUDIO_STATE_CHANGES:16), 256
	ret
AudioInit_CheckStereoMode:
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	11, wa
	ret	z
	bit	0, (AUDIO_STATE:16)
	jr	z, AudioInit_Stereo_CheckBit1
	ld	(AUDIO_STATE+2:16), 0
	jr	AudioInit_Stereo_CheckBit3
AudioInit_Stereo_CheckBit1:
	bit	1, (AUDIO_STATE:16)
	jr	z, AudioInit_Stereo_Default
	ld	(AUDIO_STATE+2:16), 1
	jr	AudioInit_Stereo_CheckBit3
AudioInit_Stereo_Default:
	ld	(AUDIO_STATE+2:16), 255
AudioInit_Stereo_CheckBit3:
	bit	3, (AUDIO_STATE:16)
	ret	z
	ld	(AUDIO_STATE+3:16), 0
	ret
AudioInit_DispatchChanges:
	ldw	(0xc40a:16), 0
	ld	wa, (AUDIO_STATE_CHANGES:16)
	and	wa, 0x188
	call	nz, (AudioInit_ComparePartStates:24)
	ld	wa, (AUDIO_STATE_CHANGES:16)
	and	wa, 0x1c0
	call	nz, (AudioInit_CompareChannelMappings:24)
	ld	wa, (AUDIO_STATE_CHANGES:16)
	and	wa, 0x102
	jr	z, AudioInit_Dispatch_CheckVoiceChange
	calr	AudioInit_CompareVoiceConfig
	jr	AudioInit_Dispatch_CheckPartChange
AudioInit_Dispatch_CheckVoiceChange:
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	0, wa
	jr	nz, AudioInit_Dispatch_SendVoiceChange
	ld	wa, (AUDIO_VOICE_CHANGES:16)
	bit	9, wa
	jr	z, AudioInit_Dispatch_CheckPartChange
AudioInit_Dispatch_SendVoiceChange:
	calr	AudioInit_CompareVoiceConfig
AudioInit_Dispatch_CheckPartChange:
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	8, wa
	jr	nz, AudioInit_Dispatch_SendPartChange
	ld	wa, (AUDIO_VOICE_CHANGES:16)
	and	wa, 0x7000
	jr	z, AudioInit_Dispatch_CheckMisc
AudioInit_Dispatch_SendPartChange:
	calr	AudioInit_ComparePriorityTable
AudioInit_Dispatch_CheckMisc:
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	2, wa
	call	nz, (AudioInit_ComparePartAssignment:24)
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	3, wa
	call	nz, (AudioInit_ComparePartConfig:24)
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	6, wa
	call	nz, (AudioInit_CompareChannelConfig:24)
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	4, wa
	call	nz, (AudioInit_CompareVolumeTable:24)
	ld	wa, (AUDIO_VOICE_CHANGES:16)
	bit	13, wa
	jr	z, AudioInit_Dispatch_CheckToneRefresh
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	bit	4, wa
	jr	z, AudioInit_Dispatch_RefreshTone
AudioInit_Dispatch_CheckToneRefresh:
	ld	wa, (AUDIO_VOICE_CHANGES:16)
	bit	12, wa
	jr	z, AudioInit_Dispatch_CheckVoiceAssign
AudioInit_Dispatch_RefreshTone:
	call	Voice_UpdatePlayModeState
	cp	l, 0xff
	call	nz, (VoiceEvent_AllocAllLayers:24)
AudioInit_Dispatch_CheckVoiceAssign:
	ld	wa, (AUDIO_VOICE_CHANGES:16)
	bit	14, wa
	jr	z, AudioInit_Dispatch_Finalize
	call	NoteMap_FindBestMatch
	cp	l, 0xff
	call	nz, (VoiceEvent_DispatchTable:24)
AudioInit_Dispatch_Finalize:
	call	VoiceEvent_HandlerTable
	ld	xiy, AUDIO_STATE
	ld	xix, AUDIO_STATE_SENT
	ldw	bc, 0xb3
	ldirw
	ldw	(AUDIO_STATE_CHANGES:16), 0
	ldw	(AUDIO_VOICE_CHANGES:16), 0
	ret
AudioInit_QueueCommand:
	dec	6, xsp
	ld	(xsp), e
	ld	(xsp + 2), c
	ld	(xsp + 4), a
	cpw	(0xc40a:16), 49
	jr	c, AudioInit_QueueCommand_Write
	call	VoiceEvent_HandlerTable
	ldw	(0xc40a:16), 0
AudioInit_QueueCommand_Write:
	ld	wa, (0xc40a:16)
	sll	wa, 2
	lda	xbc, (0xc40c:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	a, (xsp + 4)
	ld	(xde), a
	ld	wa, (0xc40a:16)
	sll	wa, 2
	lda	xbc, (0xc40d:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	a, (xsp + 2)
	ld	(xde), a
	ld	wa, (0xc40a:16)
	sll	wa, 2
	lda	xbc, (0xc40e:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	a, (xsp)
	ld	(xde), a
	ld	wa, (0xc40a:16)
	sll	wa, 2
	lda	xbc, (0xc40f:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	a, (xsp + 10)
	ld	(xde), a
	incw	1, (0xc40a:16)
	inc	6, xsp
	retd	0x2
AudioInit_ComparePartStates:
	pushw	iz
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	3, wa
	jrl	z, AudioInit_ComparePanState
	ld	iz, 0:i3
	cp	iz, 0x1a
	jrl	nc, AudioInit_PartCompare_CheckGlobalBits
AudioInit_PartCompare_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_PartCompare_SameVoice
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ld	wa, 0:i3
	calr	AudioInit_QueueCommand
	jr	AudioInit_PartCompare_Next
AudioInit_PartCompare_SameVoice:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0xff
	jr	z, AudioInit_PartCompare_Next
	ld	wa, iz
	add	wa, wa
	lda	xbc, (AUDIO_STATE_SENT+292:16)
	extz	xwa
	add	xwa, xbc
	ldcfm	6, (xwa)
	scc8	c, e
	ld	wa, iz
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	ldcfm	6, (xwa)
	scc8	c, a
	cp	a, e
	jr	z, AudioInit_PartCompare_Next
	ldto_berp	A, 0xf8
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, de
	ld	wa, 0:i3
	ldw	de, 0xff
	calr	AudioInit_QueueCommand
AudioInit_PartCompare_Next:
	inc	1, iz
	cp	iz, 0x1a
	jrl	c, AudioInit_PartCompare_Loop
AudioInit_PartCompare_CheckGlobalBits:
	ldcf_dd16	4, 0xc8, 0xc3
	scc8	c, a
	ldcf_dd16	4, 0x62, 0xc2
	scc8	c, c
	cp	c, a
	jr	z, AudioInit_ComparePanState
	ld	a, (AUDIO_STATE+36:16)
	extz	wa
	pushw	wa
	ld	wa, 0:i3
	ld	bc, 0:i3
	ldw	de, 0xff
	calr	AudioInit_QueueCommand
AudioInit_ComparePanState:
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	8, wa
	jr	z, AudioInit_PartCompare_Return
	ld	a, (AUDIO_STATE_SENT+182:16)
	cp	a, (AUDIO_STATE+182:16)
	jr	z, AudioInit_PartCompare_Return
	ld	a, (AUDIO_STATE+182:16)
	ld	c, a
	extz	bc
	ld	a, (AUDIO_STATE_SENT+182:16)
	extz	wa
	pushw	wa
	ld	de, bc
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	AudioInit_QueueCommand
AudioInit_PartCompare_Return:
	popw	iz
	ret
AudioInit_CompareVoiceConfig:
	ld	e, 0x0:opc
	ld	l, 0x0:opc
	ld	d, 0x1:opc
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	1, wa
	jr	z, AudioInit_VoiceCompare_BothFF
	ld	a, (AUDIO_STATE_SENT+1:16)
	cp	a, (AUDIO_STATE+1:16)
	jr	z, AudioInit_VoiceCompare_BothFF
	ld	a, (AUDIO_STATE+1:16)
	ld	c, a
	extz	bc
	ld	a, (AUDIO_STATE_SENT+1:16)
	extz	wa
	pushw	wa
	ld	de, bc
	ld	wa, 2:i3
	ld	bc, 1:i3
	calr	AudioInit_QueueCommand
	bit	3, (AUDIO_STATE_SENT:16)
	ret	z
	bit	3, (AUDIO_STATE:16)
	ret	nz
	pushw	0x8
	ld	wa, 2:i3
	ld	bc, 0:i3
	ld	de, 0:i3
	calr	AudioInit_QueueCommand
	ret
AudioInit_VoiceCompare_BothFF:
	cp	(AUDIO_STATE+1:16), 255
	jrl	nz, AudioInit_VoiceCompare_NotBothFF
	cp	(AUDIO_STATE_SENT+1:16), 255
	jrl	nz, AudioInit_VoiceCompare_NotBothFF
	ld	a, (AUDIO_STATE_SENT:16)
	xor	a, (AUDIO_STATE:16)
	ld	c, a
	ld	a, (AUDIO_STATE:16)
	and	a, c
	ld	e, a
	ld	a, (AUDIO_STATE_SENT:16)
	xor	a, (AUDIO_STATE:16)
	ld	c, a
	ld	a, (AUDIO_STATE_SENT:16)
	and	a, c
	ld	l, a
	ld	ix, 0:i3
	cp	ix, 6:i3
	jrl	nc, AudioInit_VoiceCompare_BuildCmd
AudioInit_VoiceCompare_LayerLoop:
	ld	wa, ix
	sll	wa, 2
	lda	xbc, (AUDIO_STATE+196:16)
	extz	xwa
	add	xwa, xbc
	bitm	7, (xwa)
	jr	z, AudioInit_VoiceCompare_LayerNext
	ld	wa, ix
	sll	wa, 2
	lda	xbc, (AUDIO_STATE_SENT+196:16)
	extz	xwa
	add	xwa, xbc
	ld	h, (xwa)
	res	7, h
	ld	wa, ix
	sll	wa, 2
	lda	xbc, (AUDIO_STATE+196:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	res	7, a
	cp	a, h
	jr	nz, AudioInit_VoiceCompare_LayerChanged
	ld	wa, ix
	sll	wa, 2
	add	wa, 0xc4
	lda	xbc, (AUDIO_STATE_SENT+1:16)
	extz	xwa
	add	xwa, xbc
	ld	h, (xwa)
	srl	h, 1
	ld	wa, ix
	sll	wa, 2
	add	wa, 0xc4
	lda	xbc, (AUDIO_STATE+1:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	srl	a, 1
	cp	a, h
	jr	z, AudioInit_VoiceCompare_LayerNext
AudioInit_VoiceCompare_LayerChanged:
	ld	a, (AUDIO_STATE:16)
	and	a, (AUDIO_STATE_SENT:16)
	and	a, d
	jr	z, AudioInit_VoiceCompare_LayerNext
	or	e, d
	or	l, d
AudioInit_VoiceCompare_LayerNext:
	add	d, d
	inc	1, ix
	cp	ix, 6:i3
	jrl	c, AudioInit_VoiceCompare_LayerLoop
	jr	AudioInit_VoiceCompare_BuildCmd
AudioInit_VoiceCompare_NotBothFF:
	cp	(AUDIO_STATE+1:16), 255
	jr	z, AudioInit_VoiceCompare_BuildCmd
	cp	(AUDIO_STATE_SENT+1:16), 255
	jr	z, AudioInit_VoiceCompare_BuildCmd
	ld	a, (AUDIO_STATE_SENT:16)
	xor	a, (AUDIO_STATE:16)
	ld	c, a
	ld	a, (AUDIO_STATE:16)
	and	a, c
	and	a, 0xf8
	ld	e, a
	ld	a, (AUDIO_STATE_SENT:16)
	xor	a, (AUDIO_STATE:16)
	ld	c, a
	ld	a, (AUDIO_STATE_SENT:16)
	and	a, c
	and	a, 0xf8
	ld	l, a
	bit	7, (AUDIO_STATE+208:16)
	jr	z, AudioInit_VoiceCompare_BuildCmd
	ld	a, (AUDIO_STATE_SENT+208:16)
	res	7, a
	ld	c, (AUDIO_STATE+208:16)
	res	7, c
	cp	c, a
	jr	nz, AudioInit_VoiceCompare_SetBit3
	ld	a, (AUDIO_STATE_SENT+209:16)
	srl	a, 1
	ld	c, (AUDIO_STATE+209:16)
	srl	c, 1
	cp	c, a
	jr	z, AudioInit_VoiceCompare_BuildCmd
AudioInit_VoiceCompare_SetBit3:
	set	3, e
	set	3, l
AudioInit_VoiceCompare_BuildCmd:
	cp	e, 0:i3
	jr	nz, AudioInit_VoiceCompare_QueueCmd
	cp	l, 0:i3
	jr	z, AudioInit_VoiceCompare_PanCheck
AudioInit_VoiceCompare_QueueCmd:
	ld	c, e
	extz	bc
	ld	a, l
	extz	wa
	pushw	wa
	ld	de, bc
	ld	wa, 2:i3
	ld	bc, 0:i3
	calr	AudioInit_QueueCommand
AudioInit_VoiceCompare_PanCheck:
	ld	a, (AUDIO_STATE_SENT+182:16)
	cp	a, (AUDIO_STATE+182:16)
	ret	z
	ld	a, (AUDIO_STATE+182:16)
	ld	c, a
	extz	bc
	ld	a, (AUDIO_STATE_SENT+182:16)
	extz	wa
	pushw	wa
	ld	de, bc
	ld	wa, 2:i3
	ld	bc, 2:i3
	calr	AudioInit_QueueCommand
	ret
AudioInit_CompareChannelMappings:
	pushw	iz
	ld	wa, (AUDIO_STATE_CHANGES:16)
	and	wa, 0xc0
	jrl	z, AudioInit_ChannelMap_CheckPan
	ld	iz, 0:i3
	cp	iz, 0x10
	jrl	nc, AudioInit_ChannelMap_CheckPan
AudioInit_ChannelMap_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+164:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+164:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_ChannelMap_CheckPrimary
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+164:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+164:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ld	wa, 3:i3
	calr	AudioInit_QueueCommand
AudioInit_ChannelMap_CheckPrimary:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+132:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+132:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_ChannelMap_Next
	ldto_berp	a, 248
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+132:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+132:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ld	wa, 4:i3
	calr	AudioInit_QueueCommand
AudioInit_ChannelMap_Next:
	inc	1, iz
	cp	iz, 0x10
	jrl	c, AudioInit_ChannelMap_Loop
AudioInit_ChannelMap_CheckPan:
	ld	wa, (AUDIO_STATE_CHANGES:16)
	bit	8, wa
	jr	z, AudioInit_ChannelMap_Return
	ld	a, (AUDIO_STATE_SENT+182:16)
	cp	a, (AUDIO_STATE+182:16)
	jr	z, AudioInit_ChannelMap_Return
	ld	a, (AUDIO_STATE+182:16)
	ld	c, a
	extz	bc
	ld	a, (AUDIO_STATE_SENT+182:16)
	extz	wa
	pushw	wa
	ld	de, bc
	ld	wa, 5:i3
	ld	bc, 0:i3
	calr	AudioInit_QueueCommand
AudioInit_ChannelMap_Return:
	popw	iz
	ret
AudioInit_ComparePriorityTable:
	pushw	iz
	ld	iz, 0:i3
	cp	iz, 3:i3
	jr	nc, AudioInit_Priority_Return
AudioInit_Priority_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+188:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+188:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_Priority_Next
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+188:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+188:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ld	wa, 6:i3
	calr	AudioInit_QueueCommand
AudioInit_Priority_Next:
	inc	1, iz
	cp	iz, 3:i3
	jr	c, AudioInit_Priority_Loop
AudioInit_Priority_Return:
	popw	iz
	ret
AudioInit_ComparePartAssignment:
	pushw	iz
	ld	iz, 0:i3
	cp	iz, 0x1a
	jrl	nc, AudioInit_PartAssign_Return
AudioInit_PartAssign_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+4:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+4:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jrl	z, AudioInit_PartAssign_Next
	cp	iz, 2:i3
	jr	nz, AudioInit_PartAssign_CheckIdx15
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+4:16)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0xff
	jr	z, AudioInit_PartAssign_CheckIdx15
	cp	(AUDIO_STATE+188:16), 2
	jr	nz, AudioInit_PartAssign_CheckIdx15
	cp	(AUDIO_STATE_SENT+188:16), 2
	jr	nz, AudioInit_PartAssign_Next
AudioInit_PartAssign_CheckIdx15:
	cp	iz, 0x15
	jr	nz, AudioInit_PartAssign_CheckIdx16
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+4:16)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0xff
	jr	z, AudioInit_PartAssign_CheckIdx16
	cp	(AUDIO_STATE+188:16), 21
	jr	nz, AudioInit_PartAssign_CheckIdx16
	cp	(AUDIO_STATE_SENT+188:16), 21
	jr	nz, AudioInit_PartAssign_Next
AudioInit_PartAssign_CheckIdx16:
	cp	iz, 0x16
	jr	nz, AudioInit_PartAssign_QueueChange
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+4:16)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0xff
	jr	z, AudioInit_PartAssign_QueueChange
	cp	(AUDIO_STATE+189:16), 22
	jr	nz, AudioInit_PartAssign_QueueChange
	cp	(AUDIO_STATE_SENT+189:16), 22
	jr	nz, AudioInit_PartAssign_Next
AudioInit_PartAssign_QueueChange:
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+4:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+4:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ld	wa, 7:i3
	calr	AudioInit_QueueCommand
AudioInit_PartAssign_Next:
	inc	1, iz
	cp	iz, 0x1a
	jrl	c, AudioInit_PartAssign_Loop
AudioInit_PartAssign_Return:
	popw	iz
	ret
AudioInit_ComparePartConfig:
	pushw	iz
	ld	iz, 0:i3
	cp	iz, 0x1a
	jrl	nc, AudioInit_PartConfig_Return
AudioInit_PartConfig_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_PartConfig_SameVoice
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ldw	wa, 0x8
	calr	AudioInit_QueueCommand
	jrl	AudioInit_PartConfig_Next
AudioInit_PartConfig_SameVoice:
	cp	iz, 0x19
	jr	nz, AudioInit_PartConfig_NotReverb
	ld	a, (AUDIO_STATE+190:16)
	extz	wa
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0xff
	jrl	z, AudioInit_PartConfig_Next
	ld	wa, iz
	add	wa, wa
	lda	xbc, (AUDIO_STATE_SENT+292:16)
	extz	xwa
	add	xwa, xbc
	ldcfm	5, (xwa)
	scc8	c, e
	ld	wa, iz
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	ldcfm	5, (xwa)
	scc8	c, a
	cp	a, e
	jr	z, AudioInit_PartConfig_Next
	ldto_berp	A, 0xf8
	ld	e, a
	extz	de
	ld	a, (AUDIO_STATE+190:16)
	extz	wa
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, de
	ldw	wa, 0x8
	ldw	de, 0xff
	calr	AudioInit_QueueCommand
	jr	AudioInit_PartConfig_Next
AudioInit_PartConfig_NotReverb:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	cp	(xwa), 0xff
	jr	z, AudioInit_PartConfig_Next
AudioInit_PartConfig_CheckCarry:
	ld	wa, iz
	add	wa, wa
	lda	xbc, (AUDIO_STATE_SENT+292:16)
	extz	xwa
	add	xwa, xbc
	ldcfm	5, (xwa)
	scc8	c, e
	ld	wa, iz
	add	wa, wa
	lda	xbc, (AUDIO_STATE+292:16)
	extz	xwa
	add	xwa, xbc
	ldcfm	5, (xwa)
	scc8	c, a
	cp	a, e
	jr	z, AudioInit_PartConfig_Next
	ldto_berp	A, 0xf8
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+36:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, de
	ldw	wa, 0x8
	ldw	de, 0xff
	calr	AudioInit_QueueCommand
AudioInit_PartConfig_Next:
	inc	1, iz
	cp	iz, 0x1a
	jrl	c, AudioInit_PartConfig_Loop
AudioInit_PartConfig_Return:
	popw	iz
	ret
AudioInit_CompareChannelConfig:
	pushw	iz
	ld	iz, 0:i3
	cp	iz, 0x10
	jr	nc, AudioInit_ChannelConfig_Return
AudioInit_ChannelConfig_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+132:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+132:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_ChannelConfig_Next
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+132:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+132:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ldw	wa, 0x9
	calr	AudioInit_QueueCommand
AudioInit_ChannelConfig_Next:
	inc	1, iz
	cp	iz, 0x10
	jr	c, AudioInit_ChannelConfig_Loop
AudioInit_ChannelConfig_Return:
	popw	iz
	ret
AudioInit_CompareVolumeTable:
	pushw	iz
	ld	iz, 0:i3
	cp	iz, 0x1a
	jr	nc, AudioInit_Volume_Return
AudioInit_Volume_Loop:
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+68:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+68:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (xde)
	jr	z, AudioInit_Volume_Next
	ldto_berp	A, 0xf8
	ld	l, a
	extz	hl
	ld	wa, iz
	lda	xbc, (AUDIO_STATE+68:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	e, a
	extz	de
	ld	wa, iz
	lda	xbc, (AUDIO_STATE_SENT+68:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	pushw	wa
	ld	bc, hl
	ldw	wa, 0xa
	calr	AudioInit_QueueCommand
AudioInit_Volume_Next:
	inc	1, iz
	cp	iz, 0x1a
	jr	c, AudioInit_Volume_Loop
AudioInit_Volume_Return:
	popw	iz
	ret
AudioInit_InitPartSendLevels:	.include "includes/generated/cc900/AudioInit_InitPartSendLevels.s"	; C: cc900/audioinit_routines_m0_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioInit_PartConfig_CheckCarry_Loop, AudioInit_InitPartSendLevels + 8
	.set	AudioInit_PartConfig_CheckCarry_Skip, AudioInit_InitPartSendLevels + 46
