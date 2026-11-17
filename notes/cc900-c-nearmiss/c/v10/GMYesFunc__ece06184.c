/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1a.c (2026-11-16-55-p6-r10)
   sha256 ece06184ca870f3eb6c12fa1d8cc3c5914bcde7e5e780156071ffba817b7601d (tar-sha256); compiled at -Xr */
#define EVT_HIDE                      0x1c00002L
#define EVT_INTERRUPT_TITLE           0x1c00016L
#define EVT_GET_PARAM                 0x1e0006bL
#define TITLE_MESAGE                  0x1a000eeL
extern long SendEvent(long, long, long);
extern long PostEvent(long, long, long);
extern void MainLswPut(long, int, int);
extern unsigned char __near GLOBAL_ERROR_CODE;
long GMYesFunc(long obj, long evt, long param)
{
    MainLswPut(0xc0, SendEvent(0x580001L, EVT_GET_PARAM, 0), 1);
    PostEvent(-1, EVT_HIDE, 0);
    GLOBAL_ERROR_CODE = 35;
    PostEvent(-1, EVT_INTERRUPT_TITLE, TITLE_MESAGE);
    return 0;
}
