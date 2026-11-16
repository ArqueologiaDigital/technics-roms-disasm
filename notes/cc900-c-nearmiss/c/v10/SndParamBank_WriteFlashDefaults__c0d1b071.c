/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/tonegen_fileio_handlers_m0.c (2026-11-16-87-p6-r15)
   sha256 c0d1b071825ca6e4e39e308ab4723868988e22a83819c651fa9e185911cfbbc5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char SndParamBank_DefaultHeader[];
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
void SndParamBank_WriteFlashDefaults(void)
{
	unsigned char *b;

	FlashWrite(1, SndParamBank_DefaultHeader, 0xfa, 0x3d3000L);
	FlashWrite(1, SndParamBank_DefaultHeader + 0xfa, 0xea, 0x3d3110L);
	FlashWrite(1, SndParamBank_DefaultHeader + 0xfa + 0xea, 0xea, 0x3d3210L);
	b = Malloc(0x50);
	if (b != 0) {
		Memset(b, 0x50, 0);
		Mem_Copy(b, SndParamBank_OptionDefault_00, 2);
		Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
		Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
		Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
		Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
		FlashWrite(1, b, 0x50, 0x3d3400L);
		Free(b);
	}
}
