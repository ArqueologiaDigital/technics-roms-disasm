/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/flash_floppy_handlers_m0.c (2026-11-16-68-p6-r12)
   sha256 d81a16c91bc7c7253b54adf03f28e6404a12e9b4a7430015c391d4caea534066 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_LANGUAGE_PTR  0x1e0009fL
extern long NAKA_InitDataBlock_PtrTable_16[], FtLangText16_LangStrings[], FtLangText17_Texts[];
long FtLangText16(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)FtLangText16_LangStrings;
	return 0;
}
