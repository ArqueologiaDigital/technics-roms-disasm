/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/seq_event_playback_m264.c (2026-11-16-68-p6-r12)
   sha256 0f333e23055fff882a1f4110ecdd46aa5a4a5c8780376da623269d06211a0bd7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
