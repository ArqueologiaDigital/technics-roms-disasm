/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_1a.c (2026-11-16-45-p6-r9)
   sha256 cc0bda5345cdcced7e97786f7a184f7ef2235df303e8522b4b48c42bcf9b3e72 (tar-sha256); compiled at -Xr */
extern void __cdecl SeqBuf_DspSysEx_WriteByte(int);
void SeqDMA_MultiWrite_DspSysEx(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_DspSysEx_WriteByte(*p++);
}
