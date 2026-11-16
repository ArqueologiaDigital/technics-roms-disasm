/* Phase 6, lane_p6 helper D, round 11 (refining round 9's form b, which run 87 matched up to the slot address: V4.23
   shifted n - 1 in a byte register and folded 0x2e0 into the base; here the shift is widened first and the address
   is written as an integer, base + offset, then + 0x2e0), module 290 (v10 audio/dsp_config_sysex.s): SysEx_ValidateRolandHeader.
   It checks the Roland header with post-incremented compares, picks the song record (the current one for channel 0,
   else slot n-1) and dispatches on the command byte; three cases end in a jump to a same-module routine, the 0x3A
   case in calr + ret.  Form a declares the 0x3A callee with a result (so its call is not the function's last
   statement in V4.23's view); form b (this file) declares all four void. */
/* cc900-module: SysEx_ApplyVoiceParam_49 SysEx_ApplyVoiceParam_49_128 SysEx_ApplyVoiceParam_4B SysEx_ApplyVoiceParam_4B_128 */   /* from scripts/analysis/cc900/module_calls.py v10 */

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
