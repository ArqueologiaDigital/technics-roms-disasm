/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/flash_floppy_handlers.c (2026-11-16-55-p6-r10)
   sha256 d3bd8e92d83087828323052c0ab8ba2ea5ca5e886f1d4985edf751e632303165 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_LANGUAGE_PTR 0x1e0009fL
extern long NAKA_InitDataBlock_PtrTable_10[], NAKA_InitDataBlock_PtrTable_11[], FtLangText11_Texts[];
long FtLangText10(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_11;
	return 0;
}
