/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/dsp_config_sysex_m290.c (2026-11-16-111-p6-r22-staged)
   sha256 6fc8a14470034b3b1b2e22c131d7c68bb8a641e5d87b925879483d90b8ed30d6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_SONG_RECORD[], SEQ_SONG_SLOTS[];
extern void SysEx_ApplyVoiceParam_4B(unsigned int, unsigned char *);
extern void SysEx_ApplyVoiceParam_4B_128(unsigned int, unsigned char *);
extern void SysEx_ApplyVoiceParam_49(unsigned int, unsigned char *);
extern void SysEx_ApplyVoiceParam_49_128(unsigned int, unsigned char *);
void SysEx_ValidateRolandHeader(unsigned char *p, unsigned char n)
{
	unsigned char *rec;

	if (n > 10) return;
	if (*p++ != 0xf0) return;
	p++;
	if (*p++ != 0x41) return;
	p++;
	if (*p++ != 0x42) return;
	if (*p++ != 0x12) return;
	if (*p++ != 0x40) return;
	if (*p++ != 0x01) return;
	if (n == 0) rec = (unsigned char *)((unsigned long)SEQ_SONG_RECORD + 0x2e0);
	else rec = (unsigned char *)(((unsigned long)SEQ_SONG_SLOTS + (long)((int)(unsigned char)(n - 1) << 11)) + 0x2e0);
	switch (*p++) {
	case 0x30:
		SysEx_ApplyVoiceParam_4B(*p, rec);
		break;
	case 0x33:
		SysEx_ApplyVoiceParam_4B_128(*p, rec);
		break;
	case 0x38:
		SysEx_ApplyVoiceParam_49(*p, rec);
		break;
	case 0x3a:
		SysEx_ApplyVoiceParam_49_128(*p, rec);
		break;
	}
}
