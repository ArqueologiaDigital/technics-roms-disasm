/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/seq_event_playback_m0_xr.c (2026-11-16-68-p6-r12)
   sha256 3b54371916501d051a1ed927d13048c6647f3830a68fe038d508729a3cd65117 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
#define EVT_SHOW                      0x1c00001L
#define EVT_CHANGE_MODE               0x1c00014L
#define EVT_SET_NOT_DRAW_FLAG         0x1e0009eL
#define TITLE_MESAGE                  0x1a000eeL
#define NAKA_MODE_MD_NORMAL           0x1800001L
extern long SendEvent(long, long, long);
extern long PostEvent(long, long, long);
extern long GetTitleOld(void);
long TtMdGm(long obj, long evt, long param)
{
    if (evt == EVT_SHOW && GetTitleOld() == TITLE_MESAGE) {
        SendEvent(-1, EVT_SET_NOT_DRAW_FLAG, 1);
        PostEvent(-1, EVT_SET_NOT_DRAW_FLAG, 0);
        PostEvent(-1, EVT_CHANGE_MODE, NAKA_MODE_MD_NORMAL);
    }
    return 0;
}
