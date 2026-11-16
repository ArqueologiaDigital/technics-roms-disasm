/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_7f0b;
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_STATE_CHANGES;
void AudioInit_CheckMIDIStatus(void)
{
	if (ram_7f0b != 0) {
		AUDIO_STATE[123] = 0;
		AUDIO_STATE[124] = 255;
	} else {
		AUDIO_STATE[123] = 255;
		AUDIO_STATE[124] = 255;
	}
	AUDIO_STATE_CHANGES |= 32;
}
