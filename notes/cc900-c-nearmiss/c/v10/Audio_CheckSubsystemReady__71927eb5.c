/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_8m294a.c (2026-11-19-68-p6-r52)
   sha256 71927eb531174100085d489143ebae815bea9444649de9bb05fff6d1f8e7d6f4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
	vhandler f;

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
	f = AudioVoiceHandler_Table[CURRENT_MODE];
	if ((void *)AudioVoiceHandler_NoneSentinel != (void *)f) {
		f(0);
		AudioInit_DrumRoutingCheck();
		AudioInit_DrumSaveReturn();
		AudioInit_VoiceParamCtrl();
		AudioInit_ClearPartFlags_ByMode();
		AudioInit_DispatchChanges();
	}
}
