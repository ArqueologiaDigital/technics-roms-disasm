/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -Xr */
struct ps { unsigned char f, g; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char __near PANEL_MIDI[];
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned int __near AUDIO_CONFIG_UPDATE;
void AudioInit_ClearPartFlags_ByMode(void)
{
	unsigned int i;

	if (AUDIO_CONFIG_UPDATE & 3) {
		for (i = 0; i < 26; i++) {
			((struct ps *)(AUDIO_STATE + 292))[i].f &= ~0x20;
			AUDIO_STATE_CHANGES |= 8;
		}
		return;
	}
	for (i = 0; i < 16; i++) ((struct ps *)(AUDIO_STATE + 292))[i].f |= 0x20;
	if (PANEL_MIDI[3] & 0x40) {
		AUDIO_STATE[324] |= 0x20; AUDIO_STATE[326] |= 0x20; AUDIO_STATE[328] |= 0x20; AUDIO_STATE[330] |= 0x20;
		AUDIO_STATE[334] |= 0x20;
	} else {
		AUDIO_STATE[324] &= ~0x20; AUDIO_STATE[326] &= ~0x20; AUDIO_STATE[328] &= ~0x20; AUDIO_STATE[330] &= ~0x20;
		AUDIO_STATE[334] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
	if (PANEL_MIDI[0] & 0x40) {
		AUDIO_STATE[332] |= 0x20;
	} else {
		AUDIO_STATE[332] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
	if (PANEL_MIDI[3] & 0x80) {
		AUDIO_STATE[342] |= 0x20;
	} else {
		AUDIO_STATE[342] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
}
