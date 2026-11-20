/* Functions of hdae5000_ui_display.s.  (hdae5000_boot.c, v1.x)
   Firmware C (cc900 phase 6) for HD-AE5000 v1.15i / v1.10i, round 87 (2026-11-20).
   cc900-options: -Xr
   cc900-name: FrameH_a=HDAE5000_Frame_Handler
   cc900-name: FrameH_b=HDAE5000_Frame_Handler
   v1.x has no lyrics: Frame_Handler counts frames in a byte (HDAE5000_RAM_FrameCount, read nowhere) where v2.x
   follows the lyric position, then watches sqsrtc bit 2 as v2.x does.  Its AUTO LOAD object is 0x7f0134,
   OBJ_FLS_FILE_LOAD in v1.x's header.  Two spellings of the count: ++ (a) and += 1 (b).
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

void FrameH_b(void)
{
    unsigned char bit;

    HDAE5000_RAM_FrameCount += 1;
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
