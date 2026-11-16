/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SndParamBank_WriteFlashDefaults */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SndParamBank_WriteFlashDefaults(void);
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
