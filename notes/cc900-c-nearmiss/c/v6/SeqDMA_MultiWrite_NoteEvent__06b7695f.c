/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/system_handlers_m0.c (2026-11-16-68-p6-r12)
   sha256 06b7695f3250962b2dca428d03af273c088d26feb738224936164292fbe503a0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void __cdecl SeqBuf_DmaChan0_WriteByte(int);
void SeqDMA_MultiWrite_NoteEvent(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_DmaChan0_WriteByte(*p++);
}
