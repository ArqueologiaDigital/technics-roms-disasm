/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v10/tonegen_fileio_handlers.c (2026-11-16-55-p6-r10)
   sha256 cfd43953743768bcfc6a64a6794b41ffa7878ff84f1a0d6e1242217624b94fc5 (tar-sha256); compiled at -O3 -Xr */
/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}

extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
extern unsigned char HELP_LANGUAGE;
extern unsigned char ram_340e6[], ram_340f2[], ram_340f6[], ram_340fa[];

void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}

void SndParamBank_LoadOptionBlock(void)
{
	Mem_Copy(&HELP_LANGUAGE, (void *)0x3d3400L, 2);
	Mem_Copy(ram_340e6, (void *)0x3d3410L, 12);
	Mem_Copy(ram_340f2, (void *)0x3d3420L, 4);
	Mem_Copy(ram_340f6, (void *)0x3d3430L, 4);
	Mem_Copy(ram_340fa, (void *)0x3d3440L, 6);
}

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
