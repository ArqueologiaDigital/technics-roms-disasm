/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/flash_floppy_handlers.c (2026-11-16-55-p6-r10)
   sha256 2052a567040ae4891326bec758cdc63a742aa3788a305f28bd6878a3402cf9de (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_LANGUAGE_PTR 0x1e0009fL
extern long NAKA_InitDataBlock_PtrTable_7[], NAKA_InitDataBlock_PtrTable_8[], NAKA_InitDataBlock_PtrTable_9[];
long FtLangText08(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)NAKA_InitDataBlock_PtrTable_9;
	return 0;
}
