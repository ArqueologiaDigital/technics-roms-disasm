/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m294a.c (2026-11-22-17-p6-r84)
   sha256 9e2dcc5cb805d8c46a73527971b514460fb1840461862b005b0dcbe6fc9526e7 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near AUDIO_CONFIG_FLAGS;
extern unsigned char __near ram_3284;
extern unsigned char __near ram_c5a0;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned int __near AUDIO_CONFIG_UPDATE;
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned char __near CURRENT_MODE;
extern void (*AudioVoiceHandler_Table[])(unsigned int);
extern void AudioVoiceHandler_NoneSentinel(unsigned int);
extern void AudioInit_RefreshToneBank(void);
extern void AccSynchro_PeriodicCheck(void);
extern void AudioInit_ClearPartFlags_ByMode(void);
extern void AudioInit_DispatchChanges(void);
void Audio_InitDispatchReturn(unsigned char a)
{
	void (*f)(unsigned int);

	if (a == 0 || ((AUDIO_SEQ_TRACK_FLAGS & 4) && (SEQ_METRO_FLAGS & 1))) {
		AUDIO_CONFIG_FLAGS &= 0xfdff;
		ram_3284 &= ~1;
		AudioInit_RefreshToneBank();
		ram_c5a0 = 0;
	} else {
		AUDIO_CONFIG_FLAGS |= 0x200;
		AccSynchro_PeriodicCheck();
		if (AUDIO_CONFIG_FLAGS & 7) ram_c5a0 = 31;
		else ram_c5a0 = 16;
	}
	if (PANEL_CONDUCTOR[1] & 2) {
		if (!(AUDIO_CONFIG_UPDATE & 0x10)) AUDIO_STATE[0] |= 4;
		else AUDIO_STATE[0] = 0;
		AUDIO_STATE_CHANGES |= 1;
	}
	f = AudioVoiceHandler_Table[CURRENT_MODE];
	if (f != AudioVoiceHandler_NoneSentinel) {
		f(0);
		AudioInit_ClearPartFlags_ByMode();
	}
	AudioInit_DispatchChanges();
}
