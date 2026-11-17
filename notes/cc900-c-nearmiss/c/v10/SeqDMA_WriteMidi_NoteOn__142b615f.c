/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_2a.c (2026-11-16-68-p6-r12)
   sha256 142b615fa87d9a2c1a23991cd35a1c56f44c514ada1d12b5095f91c20ccc177a (tar-sha256); compiled at -O3 -Xr */
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
