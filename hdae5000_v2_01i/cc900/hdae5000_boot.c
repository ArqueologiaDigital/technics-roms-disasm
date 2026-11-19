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

unsigned char HDAE5000_Get_Init_Flag(void)
{
    return HDAE5000_RAM_HdPresent;
}

void HDAE5000_Boot_Init(struct NakaWs *ws)
{
    unsigned char *bmp;
    unsigned char *v;

    HDAE5000_Clear_Work_Buffer();
    HDAE5000_RAM_MainWorkspacePtr = ws;
    HDAE5000_Handler_Registration();
    HDAE5000_Load_Palette(HDAE5000_Palette_BootSplash);
    bmp = HDAE5000_Alloc_Memory(0L, EVT_GET_BITMAP_DATA, 0L);
    HDAE5000_MemCopy((unsigned char *)0x1a0000L, bmp, 0x9600);     /* converted: ld xwa,imm; push xwa */
    HDAE5000_MemCopy((unsigned char *)0x1a9600L, bmp + 0x9600, 0x9600);
    v = CALLR(unsigned char *, ROOT->GetViewInstance)(0x600002L);
    *(long *)v = NAKA_CLASS_HDTitleMenu;
    *(char **)(v + 42) = HDAE5000_Display_Params;
    HDAE5000_RAM_SqSrtcPtr = CALLR(unsigned char *, HAMA->GetAdr_sqsrtc)();
    HDAE5000_RAM_SqBtofPtr = CALLR(unsigned int *, HAMA->GetAdr_sqbtof)();
    HDAE5000_RAM_SqBeadtPtr = CALLR(unsigned char *, HAMA->GetAdr_sq_beadt)();
    if ((HDAE5000_RAM_HdPresent = HDAE5000_Check_HD_Present()) != 0)
        CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, TITLE_HDDEXT);
    HDAE5000_Finalize_Init();
    HDAE5000_UiState_Reset();
}

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
                    /* v2.01i's object 0x7f013e (v2.06i's OBJ_FLS_FILE_LOAD_SW_EDIT) */
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD_AcIndexEditSw, EVT_SHOW, 0L);
                    CALLV(ROOT->DeleteEvent)(OBJ_FLS_FILE_LOAD_AcIndexEditSw, EVT_HDAE_SEQ_STOP);
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD_AcIndexEditSw, EVT_HDAE_SEQ_STOP, 0L);
                }
            }
        }
    }
    HDAE5000_PPORT_ServicePending();
}
