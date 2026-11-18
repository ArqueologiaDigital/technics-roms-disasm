/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m234.c (2026-11-18-33-p6-r37)
   sha256 c57ba700c56e4c9969b54025fd3e9f71db60a8f229871827d77e02f026b03680 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_1d84;
extern unsigned char __near ram_1d86;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d86 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d84 = 1;
	} else {
		if (ram_1d84 != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d86 = 1;
	}
}
