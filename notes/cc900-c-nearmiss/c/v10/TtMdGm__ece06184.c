/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1a.c (2026-11-16-55-p6-r10)
   sha256 ece06184ca870f3eb6c12fa1d8cc3c5914bcde7e5e780156071ffba817b7601d (tar-sha256); compiled at -O3 -Xr */
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
