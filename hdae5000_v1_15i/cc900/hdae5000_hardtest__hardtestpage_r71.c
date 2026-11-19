/* Functions of hd-ae5000_v1_15i.s.  (hdae5000_hardtest__hardtestpage_r71.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_hardtest__hardtestpage_r71.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_HardTest_Print HDAE5000_HardTest_PortTest HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_PPI_Init HDAE5000_PPI_LoopbackByte HDAE5000_YieldUntilSem1Zero
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* this module (calr) */
extern void HDAE5000_YieldUntilSem1Zero(void);

void HDAE5000_HardTest_Print(char *line);
void HDAE5000_PPI_Init(void);
void HDAE5000_HardTest_PortTest(void);
void HDAE5000_HardTest_HddIdRead(void);

/* ROM */
extern char HDAE5000_Str_Test[];
extern char HDAE5000_Str_PPORTTEST[];
extern char HDAE5000_Str_HDDIDREAD[];
extern char HDAE5000_Str_FDTEST[];
extern char HDAE5000_Str_OK[];
extern char HDAE5000_Str_ERROR[];
extern char HDAE5000_Str_ERROR_HardTestPage[];
extern char HDAE5000_Str_STOPTESTLOOP[];
extern char HDAE5000_Str_STARTTESTLOOP[];

/* the hardware-test page: switches 9 (PPORT), 10 (HDD), 11 (FD) run a test and, while RUN/STOP is on, chain the
   next one through a timer; 12 toggles RUN/STOP */
long HDAE5000_HardTestPage(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Test);
        return 0;
    case EVT_SW_IN:
        switch (arg) {
        case 9:
            CALLV(ROOT->SendEvent)(OBJ_PPORT_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_PPORTTEST);
            HDAE5000_HardTest_PortTest();
            CALLV(ROOT->SendEvent)(OBJ_PPORT_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 10L);
            break;
        case 10:
            CALLV(ROOT->SendEvent)(OBJ_HDD_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_HDDIDREAD);
            HDAE5000_HardTest_HddIdRead();
            CALLV(ROOT->SendEvent)(OBJ_HDD_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 11L);
            break;
        case 11:
            CALLV(ROOT->SendEvent)(OBJ_FD_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_FDTEST);
            switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
            case 2:
            case 3:
                if (CALLR(int, HAMA->FDLoadSaveTest)() == 0)
                    HDAE5000_HardTest_Print(HDAE5000_Str_OK);
                else
                    HDAE5000_HardTest_Print(HDAE5000_Str_ERROR);
                break;
            default:
                HDAE5000_HardTest_Print(HDAE5000_Str_ERROR_HardTestPage);
                break;
            }
            CALLV(ROOT->SendEvent)(OBJ_FD_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 9L);
            break;
        case 12:
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1) {
                CALLV(ROOT->SendEvent)(OBJ_RUN_STOP, EVT_SET_PARAM, 0L);
                HDAE5000_HardTest_Print(HDAE5000_Str_STOPTESTLOOP);
            } else {
                CALLV(ROOT->SendEvent)(OBJ_RUN_STOP, EVT_SET_PARAM, 1L);
                HDAE5000_HardTest_Print(HDAE5000_Str_STARTTESTLOOP);
                CALLV(ROOT->PostEvent)(-1L, EVT_SW_IN, 9L);
            }
            break;
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
