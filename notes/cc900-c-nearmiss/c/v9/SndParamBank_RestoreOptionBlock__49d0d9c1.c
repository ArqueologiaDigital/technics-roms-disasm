/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/tonegen_fileio_handlers_m277.c (2026-11-16-91-p6-r17)
   sha256 49d0d9c1524f602485f384592dbac6cdb359c3c4ab8a77e9d202972be1fbea91 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void Gfx_ClearFrameBuffers(void);
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
void SndParamBank_RestoreOptionBlock(void)
{
	unsigned char *b;

	b = Malloc(0x50);
	if (b == 0) return;
	Memset(b, 0x50, 0);
	Mem_Copy(b, (void *)0x3d3400L, 2);
	Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
	Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
	Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
	Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
	FlashWrite(1, b, 0x50, 0x3d3400L);
	Free(b);
	Gfx_ClearFrameBuffers();
}
