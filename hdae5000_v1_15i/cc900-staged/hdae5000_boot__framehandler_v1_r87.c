/* hdae5000_v1_15i: v1.x per-tree C, round 87 (2026-11-20), run 2026-11-20-1-hd-r87-v1gap
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r87a_boot__framehandler_v1.c.
   cc900-options: -Xr
   cc900-name: FrameH_a=HDAE5000_Frame_Handler
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_Fls_GetAutoLoadPending(void);
extern void HDAE5000_Fls_SetSeqStopPending();   /* no prototype: the ROM loads WA */
extern void HDAE5000_RequestTitle15();          /* no prototype: the ROM loads WA */
extern void HDAE5000_PPORT_ServicePending(void);

extern unsigned char HDAE5000_RAM_FrameCount;
extern unsigned char *HDAE5000_RAM_SqSrtcPtr;
extern unsigned char HDAE5000_RAM_SqSrtcBit2Prev;

void FrameH_a(void)
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
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_SHOW, 0L);
                    CALLV(ROOT->DeleteEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP);
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP, 0L);
                }
            }
        }
    }
    HDAE5000_PPORT_ServicePending();
}
