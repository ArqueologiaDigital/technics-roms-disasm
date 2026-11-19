/* Functions of hd-ae5000_v1_10i.s.  (hdae5000_handler_registration.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_handler_registration.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   v1.10i port (h_v1misc 2026-11-19): as v1.15i's (the same RAM cells and counts) except the UI object count, 0x2f3
   (v1.15i 0x2f6, v2.06i 0x315).  v1.15i's notes follow.
   v1.15i port: v1.15i's RAM copies of the init-data tables sit at its own addresses
   (event names 0x23cb74 / count 0x23cb84, message names 0x23cb86 / count 0x23cbbe, ApFunction handlers 0x23c914 and
   names 0x23ca14, Function 0x23cbc0 / 0x23cbec, MainFunction 0x23d20e / 0x23d24a), and its tables are shorter:
   0x3f ApFunctions (v2.06i 0x45), 0x0a Functions (0x0d), 0x2f6 UI objects (0x315).  MainFunction stays 0x0e.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ObjReg { long cls; void *proc; unsigned int count; void *table; };

extern unsigned int HDAE5000_RECORD_COUNT;
extern unsigned char HDAE5000_RECORD_TABLE[];
extern void *HDAE5000_UiObject_PtrTable[];
extern void *HDAE5000_UiObjectName_PtrTable[];
extern char HDAE5000_GFX_INIT_PARAMS[];

extern unsigned int ram_23cb84;     /* HDAE5000_RAM_EventName_Count */
extern unsigned int ram_23cbbe;     /* HDAE5000_RAM_MessageName_Count */
extern void *ram_23c914[];          /* HDAE5000_RAM_ObjHandler_Table */
extern void *ram_23ca14[];          /* HDAE5000_RAM_ObjName_Table */
extern void *ram_23cb74[];          /* HDAE5000_RAM_EventName_Table */
extern void *ram_23cb86[];          /* HDAE5000_RAM_MessageName_Table */
extern void *ram_23cbc0[];          /* HDAE5000_RAM_ClassProc_Table */
extern void *ram_23cbec[];          /* HDAE5000_RAM_ClassName_Table */
extern void *ram_23d20e[];          /* HDAE5000_RAM_ScreenProc_Table */
extern void *ram_23d24a[];          /* HDAE5000_RAM_ScreenName_Table */

#define REG(n, c, p, cnt, t) \
    rec.cls = c; rec.proc = ROOT->p; rec.count = cnt; rec.table = t; \
    CALLV(ROOT->RegisterObjectTable)(n, (void *)&rec)

void HDAE5000_Handler_Registration(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_23cb84, ram_23cb74);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_23cbbe, ram_23cb86);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x3f, ram_23c914);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x3f, ram_23ca14);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0a, ram_23cbc0);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0a, ram_23cbec);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23d20e);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23d24a);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x2f3, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x2f3, HDAE5000_UiObjectName_PtrTable);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, (long)HDAE5000_GFX_INIT_PARAMS);
}
