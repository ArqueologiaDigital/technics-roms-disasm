/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1a.c (2026-11-16-55-p6-r10)
   sha256 ece06184ca870f3eb6c12fa1d8cc3c5914bcde7e5e780156071ffba817b7601d (tar-sha256); compiled at -O3 -Xr */
#define EVT_GET_LANGUAGE_PTR          0x1e0009fL
extern long StsSplitCheck_PtrTable[];
long StsSplitCheck(long obj, long evt, long param)
{
    if (evt == EVT_GET_LANGUAGE_PTR) return (long)StsSplitCheck_PtrTable;
    return 0;
}
