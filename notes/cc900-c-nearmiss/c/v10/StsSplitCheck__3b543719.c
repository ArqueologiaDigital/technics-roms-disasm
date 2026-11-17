/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/seq_event_playback_m0_xr.c (2026-11-16-68-p6-r12)
   sha256 3b54371916501d051a1ed927d13048c6647f3830a68fe038d508729a3cd65117 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
#define EVT_GET_LANGUAGE_PTR          0x1e0009fL
extern long StsSplitCheck_PtrTable[];
long StsSplitCheck(long obj, long evt, long param)
{
    if (evt == EVT_GET_LANGUAGE_PTR) return (long)StsSplitCheck_PtrTable;
    return 0;
}
