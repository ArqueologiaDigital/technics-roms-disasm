/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -Xr */
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_STATE_CHANGES;
void AudioInit_SelectPriority(void)
{
	switch (CMP_RECORD_PART) {
	case 1:
		AUDIO_STATE[84] = 0; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	case 2:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 1; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	case 4:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 2; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	case 8:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 3; AUDIO_STATE[88] = 255;
		break;
	case 16:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 4;
		break;
	default:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	}
	AUDIO_STATE_CHANGES |= 16;
}
