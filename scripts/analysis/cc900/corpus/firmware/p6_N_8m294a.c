/* lane_p6 helper N, round 8, form a: module 294 (audio/dsp_config_sysex.s), new function.
   Audio_CheckSubsystemReady: after the init-status check (and a tone-bank refresh when the sequencer tracks need
   neither audio group), marks the audio state for re-send (state byte bits, 0xff at +2/+3/+182/+190, both change
   bits) and, unless the current mode's voice handler is the "none" sentinel, calls it with 0 and runs the five
   AudioInit steps.  The handler part is written inside the `!=` test so its last call is a call (the ROM's
   `call; ret`), not a tail jump.
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
