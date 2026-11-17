/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_11m290.c (2026-11-16-92-p6-r18)
   sha256 64b6dab0b0e5f8d3fb14ce14db7af372354a813719de5f65297550491b0ace08 (tar-sha256); compiled at -O3 -XS -Xr */
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
