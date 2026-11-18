/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-18-33-p6-r37)
   sha256 3d090dec7072b6d91ac87ef5c131872301c5e4c8211606fc0bea070f356bfff8 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_1d7e;
extern unsigned char __near ram_1d80;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d80 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d7e = 1;
	} else {
		if (ram_1d7e != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d80 = 1;
	}
}
