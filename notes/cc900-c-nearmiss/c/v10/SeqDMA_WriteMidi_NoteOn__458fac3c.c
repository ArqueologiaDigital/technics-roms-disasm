/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_1b.c (2026-11-16-45-p6-r9)
   sha256 458fac3c50a56452c643aff2a328f80b03d0e17483a3bfc68b066764994c47b5 (tar-sha256); compiled at -O3 -Xr */
extern void __cdecl SeqBuf_NoteEvent_WriteByte(unsigned char);
void SeqDMA_WriteMidi_NoteOn(unsigned char ch, unsigned char *p)
{
	if (*p == 0x90) {
		SeqBuf_NoteEvent_WriteByte(*++p);
		SeqBuf_NoteEvent_WriteByte(*++p);
	}
}
