/* Functions of hdae5000_ui_display.s.  (hdae5000_boot.c, v1.10i)
   Firmware C (cc900 phase 6) for HD-AE5000 v1.10i, round 88 (2026-11-20).
   cc900-options: -Xr
   v1.15i's Frame_Handler (hd_r87a_boot__framehandler_v1.c, FrameH_a; run 2026-11-20-1-hd-r87-v1gap matched it in
   v1.15i) with v1.10i's AUTO LOAD object: v1.10i's ROM posts to 0x7f0132 where v1.15i's posts to 0x7f0134
   (OBJ_FLS_FILE_LOAD); v1.10i's hand source spells it as a number and its header names no object 0x7f0132.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

#define OBJ_AUTOLOAD_V110 0x7f0132L     /* v1.10i hdae5000_ui_display.s, HDAE5000_Frame_Handler_Status__init_display */

extern unsigned char HDAE5000_Fls_GetAutoLoadPending(void);
extern void HDAE5000_Fls_SetSeqStopPending();   /* no prototype: the ROM loads WA */
extern void HDAE5000_RequestTitle15();          /* no prototype: the ROM loads WA */
extern void HDAE5000_PPORT_ServicePending(void);

extern unsigned char HDAE5000_RAM_FrameCount;
extern unsigned char *HDAE5000_RAM_SqSrtcPtr;
extern unsigned char HDAE5000_RAM_SqSrtcBit2Prev;

void HDAE5000_Frame_Handler(void)
{
    unsigned char bit;

    HDAE5000_RAM_FrameCount++;
    bit = *HDAE5000_RAM_SqSrtcPtr & 4;
    if (bit != HDAE5000_RAM_SqSrtcBit2Prev) {
        HDAE5000_RAM_SqSrtcBit2Prev = bit;
        if (bit == 0) {
            if (HDAE5000_Fls_GetAutoLoadPending() == 1) {
                if (CALLR(long, ROOT->GetTitleNow)() != TITLE_HDDEXT) {
                    HDAE5000_Fls_SetSeqStopPending(1);
                    HDAE5000_RequestTitle15(0x7f);
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_AUTOLOAD_V110, EVT_SHOW, 0L);
                    CALLV(ROOT->DeleteEvent)(OBJ_AUTOLOAD_V110, EVT_HDAE_SEQ_STOP);
                    CALLV(ROOT->ApPostEvent)(OBJ_AUTOLOAD_V110, EVT_HDAE_SEQ_STOP, 0L);
                }
            }
        }
    }
    HDAE5000_PPORT_ServicePending();
}
