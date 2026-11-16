/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SysEx_ApplyVoiceParam_49 SysEx_ApplyVoiceParam_49_128 SysEx_ApplyVoiceParam_4B SysEx_ApplyVoiceParam_4B_128 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char SEQ_SONG_RECORD[], SEQ_SONG_SLOTS[];
extern void SysEx_ApplyVoiceParam_4B(unsigned int, unsigned char *);
extern void SysEx_ApplyVoiceParam_4B_128(unsigned int, unsigned char *);
extern void SysEx_ApplyVoiceParam_49(unsigned int, unsigned char *);
extern void SysEx_ApplyVoiceParam_49_128(unsigned int, unsigned char *);
extern void SysEx_ValidateRolandHeader(unsigned char *p, unsigned char n);

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
