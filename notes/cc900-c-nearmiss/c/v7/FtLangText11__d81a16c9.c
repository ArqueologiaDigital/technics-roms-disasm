/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/flash_floppy_handlers_m0.c (2026-11-16-68-p6-r12)
   sha256 d81a16c91bc7c7253b54adf03f28e6404a12e9b4a7430015c391d4caea534066 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_LANGUAGE_PTR  0x1e0009fL
extern long NAKA_InitDataBlock_PtrTable_10[], NAKA_InitDataBlock_PtrTable_11[], FtLangText11_Texts[];
long FtLangText11(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)FtLangText11_Texts;
	return 0;
}
