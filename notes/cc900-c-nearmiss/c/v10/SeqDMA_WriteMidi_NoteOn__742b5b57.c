/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_m0.c (2026-11-16-92-p6-r18)
   sha256 742b5b57df057d6a9d24c8d645e72312c0d56d4bb0e5f4ace5f21f093c142c29 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void __cdecl SeqBuf_NoteEvent_WriteByte(int);
void SeqDMA_WriteMidi_NoteOn(unsigned char ch, unsigned char *p)
{
	unsigned char c;

	c = *p;
	if (c == 0x90) {
		p++;
		SeqBuf_NoteEvent_WriteByte(*p);
		p++;
		SeqBuf_NoteEvent_WriteByte(*p);
	}
}
