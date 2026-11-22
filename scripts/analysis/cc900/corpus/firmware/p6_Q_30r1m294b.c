/* lane_p6 helper Q, round 30r1, form b: module 294 (audio/dsp_config_sysex.s), AudioInit_ProcessModeChange (130 B,
   roots30_Q) and its twin Audio_CheckSubsystemReady (retry of p6_N_9m294a, run p6-r54: Xr matched to +30, then
   the if / else of bit 4 was the wrong way round, and the handler was read twice from the table).  Both re-apply the
   audio configuration: bit 2 of AUDIO_STATE byte 0 or a cleared byte 0 when PANEL_CONDUCTOR[1] bit 1 is set,
   AUDIO_STATE+182 / +190 / +2 / +3 = 255, AUDIO_STATE_CHANGES |= 0x101, then the mode's AudioVoiceHandler_Table
   entry unless it is the sentinel, and the AudioInit_* passes.
   Form b: as form a (bit-4 test `== 0`, set first), but the handler a `register` local and compared with the
   handler on the left.
   cc900-options: -Xr
*/

typedef void (*vhandler)(int);
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near AUDIO_CONFIG_UPDATE;
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near CURRENT_MODE;
extern vhandler AudioVoiceHandler_Table[];
extern void AudioVoiceHandler_NoneSentinel(int);
extern void Audio_CheckInitStatus(void);
extern void AudioInit_RefreshToneBank(void);
extern void AudioInit_DrumRoutingCheck(void);
extern void AudioInit_DrumSaveReturn(void);
extern void AudioInit_VoiceParamCtrl(void);
extern void AudioInit_ClearPartFlags_ByMode(void);
extern void AudioInit_DispatchChanges(void);
extern void AudioInit_ProcessModeChange(void);
extern void Audio_CheckSubsystemReady(void);

void AudioInit_ProcessModeChange(void)
{
	register vhandler h;

	if ((AUDIO_CONFIG_UPDATE & 4) == 0)
		return;
	Audio_CheckInitStatus();
	AUDIO_CONFIG_UPDATE &= ~4;
	if (PANEL_CONDUCTOR[1] & 0x02) {
		if ((AUDIO_CONFIG_UPDATE & 0x10) == 0)
			AUDIO_STATE[0] |= 0x04;
		else
			AUDIO_STATE[0] = 0;
	}
	AUDIO_STATE[0] &= ~0x08;
	AUDIO_STATE[182] = 255;
	AUDIO_STATE[190] = 255;
	AUDIO_STATE[2] = 255;
	AUDIO_STATE[3] = 255;
	AUDIO_STATE_CHANGES |= 0x101;
	h = AudioVoiceHandler_Table[CURRENT_MODE];
	if ((void *)h != (void *)AudioVoiceHandler_NoneSentinel) {
		h(0);
		AudioInit_DrumRoutingCheck();
		AudioInit_DrumSaveReturn();
		AudioInit_VoiceParamCtrl();
		AudioInit_ClearPartFlags_ByMode();
		AudioInit_DispatchChanges();
	}
}

void Audio_CheckSubsystemReady(void)
{
	register vhandler h;

	Audio_CheckInitStatus();
	if ((AUDIO_SEQ_TRACK_FLAGS & 0x60) == 0)
		AudioInit_RefreshToneBank();
	if (PANEL_CONDUCTOR[1] & 0x02) {
		if ((AUDIO_CONFIG_UPDATE & 0x10) == 0)
			AUDIO_STATE[0] |= 0x04;
		else
			AUDIO_STATE[0] = 0;
	}
	AUDIO_STATE[0] &= ~0x08;
	AUDIO_STATE[182] = 255;
	AUDIO_STATE[190] = 255;
	AUDIO_STATE[2] = 255;
	AUDIO_STATE[3] = 255;
	AUDIO_STATE_CHANGES |= 0x101;
	h = AudioVoiceHandler_Table[CURRENT_MODE];
	if ((void *)h != (void *)AudioVoiceHandler_NoneSentinel) {
		h(0);
		AudioInit_DrumRoutingCheck();
		AudioInit_DrumSaveReturn();
		AudioInit_VoiceParamCtrl();
		AudioInit_ClearPartFlags_ByMode();
		AudioInit_DispatchChanges();
	}
}
