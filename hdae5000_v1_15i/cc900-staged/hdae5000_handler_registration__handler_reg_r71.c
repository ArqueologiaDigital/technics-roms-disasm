/* hdae5000_v1_15i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-59-hd-r71-v1misc (hd_r71m_handler_registration__handler_reg.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r71m_handler_registration__handler_reg.c.
   cc900-options: -Xr
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
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x2f6, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x2f6, HDAE5000_UiObjectName_PtrTable);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, (long)HDAE5000_GFX_INIT_PARAMS);
}
