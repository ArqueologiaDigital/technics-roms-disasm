/* Functions of hdae5000_ui_display.s.  (hdae5000_boot.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_boot.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_Clear_Work_Buffer HDAE5000_Load_Palette HDAE5000_Alloc_Memory
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);

extern void HDAE5000_Clear_Work_Buffer(void);
extern void HDAE5000_Handler_Registration(void);
extern void HDAE5000_Load_Palette(unsigned char *pal);
extern unsigned char *HDAE5000_Alloc_Memory(long obj, long ev, long arg);
extern unsigned char HDAE5000_Check_HD_Present(void);
extern void HDAE5000_Finalize_Init(void);
extern void HDAE5000_UiState_Reset(void);
extern unsigned char HDAE5000_Fls_GetAutoLoadPending(void);
extern void HDAE5000_Fls_SetSeqStopPending();   /* no prototype: the ROM loads WA */
extern void HDAE5000_RequestTitle15();          /* no prototype: the ROM loads WA */
extern void HDAE5000_PPORT_ServicePending(void);

extern unsigned char HDAE5000_Palette_BootSplash[];
extern char HDAE5000_Display_Params[];

extern unsigned char HDAE5000_RAM_HdPresent;
extern unsigned char *HDAE5000_RAM_SqSrtcPtr;
extern unsigned int *HDAE5000_RAM_SqBtofPtr;
extern unsigned char *HDAE5000_RAM_SqBeadtPtr;
extern unsigned char HDAE5000_RAM_SqSrtcBit2Prev;
extern long HDAE5000_RAM_LyricBoxObj;
extern unsigned int HDAE5000_RAM_LyricPosEvt;     /* +0 of the event block: sqbtof */
extern unsigned int HDAE5000_RAM_LyricPosStep;    /* +2 */
extern unsigned long HDAE5000_RAM_LyricPosition;  /* +4 */

void HDAE5000_Frame_Handler(void)
{
    unsigned char step;
    unsigned char bit;

    if (HDAE5000_RAM_LyricBoxObj != -1L) {
        step = *HDAE5000_RAM_SqBeadtPtr >> 3;
        HDAE5000_RAM_LyricPosition = (unsigned long)step + 2 + (unsigned long)*HDAE5000_RAM_SqBtofPtr * 12;
        if (++step != HDAE5000_RAM_LyricPosStep) {
            HDAE5000_RAM_LyricPosStep = step;
            HDAE5000_RAM_LyricPosEvt = *HDAE5000_RAM_SqBtofPtr;
            CALLV(ROOT->ApPostEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_TICKS, (long)&HDAE5000_RAM_LyricPosEvt);
        }
    }
    bit = *HDAE5000_RAM_SqSrtcPtr & 4;
    if (bit != HDAE5000_RAM_SqSrtcBit2Prev) {
        HDAE5000_RAM_SqSrtcBit2Prev = bit;
        if (bit == 0) {
            if (HDAE5000_Fls_GetAutoLoadPending() == 1) {
                if (CALLR(long, ROOT->GetTitleNow)() != TITLE_HDDEXT) {
                    HDAE5000_Fls_SetSeqStopPending(1);
                    HDAE5000_RequestTitle15(0x7f);
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD_SW_EDIT, EVT_SHOW, 0L);
                    CALLV(ROOT->DeleteEvent)(OBJ_FLS_FILE_LOAD_SW_EDIT, EVT_HDAE_SEQ_STOP);
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD_SW_EDIT, EVT_HDAE_SEQ_STOP, 0L);
                }
            }
        }
    }
    HDAE5000_PPORT_ServicePending();
}
