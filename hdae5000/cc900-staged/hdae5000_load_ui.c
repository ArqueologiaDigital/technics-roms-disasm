/* LoadSongWithUi of hdae5000_ui_display.s: h_nm3b's C (module-local calls in cc900-module).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r23_uif.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_RequestMode HDAE5000_UiObj_SetCaption
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_RAM_JumpAfterLoad;

extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_RequestMode();             /* no prototype: the ROM loads WA */
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int mode, int keep);

int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int mode, long obj)
{
    int ret;

    if (mode == 1) {
        CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
        HDAE5000_YieldUntilSem1Zero();
    } else {
        CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
        CALLV(HAMA->pdly_tim_X)(100);
        HDAE5000_YieldUntilSem1Zero();
    }
    if ((ret = HDAE5000_LoadSong(dir, song, mask, mode, 0)) != -1) {
        if (HDAE5000_RAM_JumpAfterLoad == 1) {
            HDAE5000_RequestMode(1);
        } else if (mode == 1) {
            CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
            CALLV(ROOT->PostEvent)(-1L, EVT_INDEXSW_DOWN, 0L);
        } else {
            CALLV(ROOT->ApPostEvent)(obj, EVT_SHOW, 0L);
            CALLV(ROOT->ApPostEvent)(-1L, EVT_INDEXSW_DOWN, 0L);
        }
    } else {
        if (mode == 1)
            CALLV(ROOT->SendEvent)(OBJ_ERR_LOAD, EVT_SHOW, 0L);
        else
            CALLV(ROOT->ApPostEvent)(OBJ_ERR_LOAD, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_LOAD_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_LOAD_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_LOAD_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    return ret;
}
