/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
#define EVT_GET_LANGUAGE_PTR 0x1e0009fL


unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}

extern long NAKA_InitDataBlock_PtrTable[], FDemo_BassPortSpanishHeading_Texts[], NAKA_InitDataBlock_PtrTable_3[];
extern long NAKA_InitDataBlock_PtrTable_4[], NAKA_InitDataBlock_PtrTable_5[], NAKA_InitDataBlock_PtrTable_6[];
extern long NAKA_InitDataBlock_PtrTable_7[], NAKA_InitDataBlock_PtrTable_8[], NAKA_InitDataBlock_PtrTable_9[];
extern long NAKA_InitDataBlock_PtrTable_10[], NAKA_InitDataBlock_PtrTable_11[], FtLangText11_Texts[];
extern long NAKA_InitDataBlock_PtrTable_13[], NAKA_InitDataBlock_PtrTable_14[], NAKA_InitDataBlock_PtrTable_15[];
extern long NAKA_InitDataBlock_PtrTable_16[], FtLangText16_LangStrings[], FtLangText17_Texts[];

long FtLangText01(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable;
	return 0;
}

long FtLangText01S(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)FDemo_BassPortSpanishHeading_Texts;
	return 0;
}

long FtLangText02(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_3;
	return 0;
}

long FtLangText03(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_4;
	return 0;
}

long FtLangText04(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_5;
	return 0;
}

long FtLangText05(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_6;
	return 0;
}

long FtLangText06(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_7;
	return 0;
}

long FtLangText07(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_8;
	return 0;
}

long FtLangText08(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_9;
	return 0;
}

long FtLangText09(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_10;
	return 0;
}

long FtLangText10(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_11;
	return 0;
}

long FtLangText11(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)FtLangText11_Texts;
	return 0;
}

long FtLangText12(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_13;
	return 0;
}

long FtLangText13(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_14;
	return 0;
}

long FtLangText14(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_15;
	return 0;
}

long FtLangText15(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_16;
	return 0;
}

long FtLangText16(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)FtLangText16_LangStrings;
	return 0;
}

long FtLangText17(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)FtLangText17_Texts;
	return 0;
}

void NAKA_InitDataBlock(void)
{
}
