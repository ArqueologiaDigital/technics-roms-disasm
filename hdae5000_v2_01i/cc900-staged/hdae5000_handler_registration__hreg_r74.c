/* hdae5000_v2_01i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-62-hd-r74-v201 (hd_r74v_handler_registration__hreg.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r74v_handler_registration__hreg.c.
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

extern unsigned int ram_2397b6;     /* HDAE5000_RAM_EventName_Count */
extern unsigned int ram_239804;     /* HDAE5000_RAM_MessageName_Count */
extern void *ram_2394ce[];          /* HDAE5000_RAM_ObjHandler_Table */
extern void *ram_2395de[];          /* HDAE5000_RAM_ObjName_Table */
extern void *ram_23977e[];          /* HDAE5000_RAM_EventName_Table */
extern void *ram_2397b8[];          /* HDAE5000_RAM_MessageName_Table */
extern void *ram_239806[];          /* HDAE5000_RAM_ClassProc_Table */
extern void *ram_23983e[];          /* HDAE5000_RAM_ClassName_Table */
extern void *ram_239f5a[];          /* HDAE5000_RAM_ScreenProc_Table */
extern void *ram_239f96[];          /* HDAE5000_RAM_ScreenName_Table */

#define REG(n, c, p, cnt, t) \
    rec.cls = c; rec.proc = ROOT->p; rec.count = cnt; rec.table = t; \
    CALLV(ROOT->RegisterObjectTable)(n, (void *)&rec)

void HDAE5000_Handler_Registration(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_2397b6, ram_23977e);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239804, ram_2397b8);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x43, ram_2394ce);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x43, ram_2395de);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239806);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_23983e);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239f5a);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239f96);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x312, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x312, HDAE5000_UiObjectName_PtrTable);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, (long)HDAE5000_GFX_INIT_PARAMS);
}
