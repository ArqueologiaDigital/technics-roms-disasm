/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m234a.c (2026-11-19-15-p6-r42)
   sha256 d7efe7eef9f2d9d9a7938278db54022cb6ec94fce706eeaafc7243941223c5ad (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_1d84;
extern unsigned char __near ram_1d86;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
void SeqBuf_WriteMidiEventDirect(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d86 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		SeqBuf_FlushAndReinit_NoteEvents();
	} else {
		if (ram_1d84 != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		SeqBuf_FlushAndReinit_VoiceCCEvents();
	}
}
