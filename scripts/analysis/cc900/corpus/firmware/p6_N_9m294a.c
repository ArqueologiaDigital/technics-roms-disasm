/* lane_p6 helper N, round 9, form a: module 294 (audio/dsp_config_sysex.s), retry of p6_N_8m294a (p6-r52 Xr: +0).
   Audio_CheckSubsystemReady: V4.23 kept the handler pointer in XIZ (push / pop XIZ); the ROM has no frame, holds
   the handler in XHL (a copy in XBC for the sentinel compare, `ret z`) and calls it at once.  Form a: no pointer
   variable -- the table entry read into a `void *` only for the compare, the call through the same entry (left
   to -O3's CSE).
   cc900-options: -O3 -Xr
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

void Audio_CheckSubsystemReady(void)
{
	Audio_CheckInitStatus();
	if ((AUDIO_SEQ_TRACK_FLAGS & 0x60) == 0)
		AudioInit_RefreshToneBank();
	if (PANEL_CONDUCTOR[1] & 0x02) {
		if (AUDIO_CONFIG_UPDATE & 0x10)
			AUDIO_STATE[0] = 0;
		else
			AUDIO_STATE[0] |= 0x04;
	}
	AUDIO_STATE[0] &= ~0x08;
	AUDIO_STATE[182] = 255;
	AUDIO_STATE[190] = 255;
	AUDIO_STATE[2] = 255;
	AUDIO_STATE[3] = 255;
	AUDIO_STATE_CHANGES |= 0x101;
	if ((void *)AudioVoiceHandler_NoneSentinel != (void *)AudioVoiceHandler_Table[CURRENT_MODE]) {
		AudioVoiceHandler_Table[CURRENT_MODE](0);
		AudioInit_DrumRoutingCheck();
		AudioInit_DrumSaveReturn();
		AudioInit_VoiceParamCtrl();
		AudioInit_ClearPartFlags_ByMode();
		AudioInit_DispatchChanges();
	}
}
