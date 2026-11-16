/* hd_r23_uif.c (helper h_nm3b, lane_hd round 23): HDAE5000_LoadSongWithUi (hdae5000_ui_display.s), of the big
   calr group (the song-copy / delete module); its own calr targets are listed below and declared extern.
   Round 20's hd_r20_uif.c with these changes, from run 95:
   - V4.23 pushes the stack arguments of a non-__cdecl call LEFT TO RIGHT (the last parameter at the lowest
     offset): r20's `LoadSong(dir, song, mask, 0, mode)` gave `pushw 0; pushw iz`, the ROM has `pushw iz;
     pushw 0`; r20's parameters (.., long obj, int mode) read mode at xsp+14, the ROM reads mode at +18 and obj at
     +14.  So the parameters are (dir, song, mask, mode, obj), LoadSong is called (dir, song, mask, mode, 0), and
     the timer calls pass (0x14d, CATCH, -1, EVT_HDAE_TIMER_BACK, obj) (the ROM pushes the event first).
   - the result tested as an assignment's value, `if ((ret = LoadSong(..)) != -1)`: the ROM stores it and reads it
     back, `ld (xsp+2),hl; ld wa,(xsp+2); cp wa,0xffff`, where `ret = ..; if (ret != -1)` gave
     `cpw (xsp+2),0xffff`.
   Arguments: WA dir, BC song, DE part mask, then on the stack the int mode and the long caller object (retd 6);
   mode 1 = called from the panel (SendEvent / PostEvent), else from the AP side (ApPostEvent).
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
