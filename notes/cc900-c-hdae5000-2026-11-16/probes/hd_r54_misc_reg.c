/* hd_r54_misc_reg.c (helper h_misc, lane_hd round 54): HDAE5000_Handler_Registration (hd-ae5000_v2_06i.s,
   0x280020, 750 B, survey kind `tail`), two forms.  No earlier probe defined it (the probes only declared it extern,
   as Boot_Init's callee).  It calls nothing of its own module.
   cc900-options: -Xr
   cc900-name: HandlerReg_b=HDAE5000_Handler_Registration

   ROM: a 14-byte stack record (`lda xsp,(xsp-14)`), eleven times {class id, the proc read from the main CPU's
   RootFn table, a count (a word variable or a constant), a table address (lda)}, each handed to
   RootFn_RegisterObjectTable with the record address computed FIRST (`lda xwa,(xsp); ld xbc,xwa`, the converted-
   argument order: `(void *)&rec`), then the function pointer into XHL, then the constant index in WA (int).
   Then RegisterTitle(0x7f, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, "TT_HDDEXT", 10): `pushw 10`, then the
   name as `lda xwa,(sym); push xwa` (not pushw @hi16/@lo16, so a converted argument), then XHL, XWA, XBC, XDE.
     HDAE5000_Handler_Registration  the name passed as `(long)HDAE5000_GFX_INIT_PARAMS`
     HandlerReg_b                   the name passed as the plain array (expected: pushw @hi16/@lo16 instead)
   The RAM tables are `.set` labels of hdae5000_init_data.s (RAM copy = ROM label - 0xbff88), written here as
   ram_<hex> cells: 23952a ObjHandler_Table, 239642 ObjName_Table, 2397ea EventName_Table, 239822 EventName_Count,
   239824 MessageName_Table, 239870 MessageName_Count, 239872 ClassProc_Table, 2398aa ClassName_Table,
   239fd2 ScreenProc_Table, 23a00e ScreenName_Table.  0x315 = HDAE5000_UI_OBJECT_COUNT.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ObjReg { long cls; void *proc; unsigned int count; void *table; };

extern unsigned int HDAE5000_RECORD_COUNT;
extern unsigned char HDAE5000_RECORD_TABLE[];
extern void *HDAE5000_UiObject_PtrTable[];
extern void *HDAE5000_UiObjectName_PtrTable[];
extern char HDAE5000_GFX_INIT_PARAMS[];

extern unsigned int ram_239822;     /* HDAE5000_RAM_EventName_Count */
extern unsigned int ram_239870;     /* HDAE5000_RAM_MessageName_Count */
extern void *ram_23952a[];          /* HDAE5000_RAM_ObjHandler_Table */
extern void *ram_239642[];          /* HDAE5000_RAM_ObjName_Table */
extern void *ram_2397ea[];          /* HDAE5000_RAM_EventName_Table */
extern void *ram_239824[];          /* HDAE5000_RAM_MessageName_Table */
extern void *ram_239872[];          /* HDAE5000_RAM_ClassProc_Table */
extern void *ram_2398aa[];          /* HDAE5000_RAM_ClassName_Table */
extern void *ram_239fd2[];          /* HDAE5000_RAM_ScreenProc_Table */
extern void *ram_23a00e[];          /* HDAE5000_RAM_ScreenName_Table */

void HDAE5000_Handler_Registration(void)
{
    struct ObjReg rec;

    rec.cls = NAKA_CLASS_Class;
    rec.proc = ROOT->ClassProc;
    rec.count = HDAE5000_RECORD_COUNT;
    rec.table = HDAE5000_RECORD_TABLE;
    CALLV(ROOT->RegisterObjectTable)(0x16a, (void *)&rec);
    rec.cls = NAKA_CLASS_ResEvent;
    rec.proc = ROOT->ResEventProc;
    rec.count = ram_239822;
    rec.table = ram_2397ea;
    CALLV(ROOT->RegisterObjectTable)(0x1ca, (void *)&rec);
    rec.cls = NAKA_CLASS_ResMethod;
    rec.proc = ROOT->ResMethodProc;
    rec.count = ram_239870;
    rec.table = ram_239824;
    CALLV(ROOT->RegisterObjectTable)(0x1ea, (void *)&rec);
    rec.cls = NAKA_CLASS_ApFunction;
    rec.proc = ROOT->ApFunctionProc;
    rec.count = 0x45;
    rec.table = ram_23952a;
    CALLV(ROOT->RegisterObjectTable)(0x12a, (void *)&rec);
    rec.cls = NAKA_CLASS_ApFunction;
    rec.proc = ROOT->ApFunctionProc;
    rec.count = 0x45;
    rec.table = ram_239642;
    CALLV(ROOT->RegisterObjectTable)(0x42a, (void *)&rec);
    rec.cls = NAKA_CLASS_Function;
    rec.proc = ROOT->FunctionProc;
    rec.count = 0x0d;
    rec.table = ram_239872;
    CALLV(ROOT->RegisterObjectTable)(0x10a, (void *)&rec);
    rec.cls = NAKA_CLASS_Function;
    rec.proc = ROOT->FunctionProc;
    rec.count = 0x0d;
    rec.table = ram_2398aa;
    CALLV(ROOT->RegisterObjectTable)(0x40a, (void *)&rec);
    rec.cls = NAKA_CLASS_MainFunction;
    rec.proc = ROOT->MainFunctionProc;
    rec.count = 0x0e;
    rec.table = ram_239fd2;
    CALLV(ROOT->RegisterObjectTable)(0x14a, (void *)&rec);
    rec.cls = NAKA_CLASS_MainFunction;
    rec.proc = ROOT->MainFunctionProc;
    rec.count = 0x0e;
    rec.table = ram_23a00e;
    CALLV(ROOT->RegisterObjectTable)(0x44a, (void *)&rec);
    rec.cls = NAKA_CLASS_Viewable;
    rec.proc = ROOT->ViewableProc;
    rec.count = 0x315;
    rec.table = HDAE5000_UiObject_PtrTable;
    CALLV(ROOT->RegisterObjectTable)(0x7f, (void *)&rec);
    rec.cls = NAKA_CLASS_ResName;
    rec.proc = ROOT->ResNameProc;
    rec.count = 0x315;
    rec.table = HDAE5000_UiObjectName_PtrTable;
    CALLV(ROOT->RegisterObjectTable)(0x37f, (void *)&rec);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, (long)HDAE5000_GFX_INIT_PARAMS, 10);
}

void HandlerReg_b(void)
{
    struct ObjReg rec;

    rec.cls = NAKA_CLASS_Class;
    rec.proc = ROOT->ClassProc;
    rec.count = HDAE5000_RECORD_COUNT;
    rec.table = HDAE5000_RECORD_TABLE;
    CALLV(ROOT->RegisterObjectTable)(0x16a, (void *)&rec);
    rec.cls = NAKA_CLASS_ResEvent;
    rec.proc = ROOT->ResEventProc;
    rec.count = ram_239822;
    rec.table = ram_2397ea;
    CALLV(ROOT->RegisterObjectTable)(0x1ca, (void *)&rec);
    rec.cls = NAKA_CLASS_ResMethod;
    rec.proc = ROOT->ResMethodProc;
    rec.count = ram_239870;
    rec.table = ram_239824;
    CALLV(ROOT->RegisterObjectTable)(0x1ea, (void *)&rec);
    rec.cls = NAKA_CLASS_ApFunction;
    rec.proc = ROOT->ApFunctionProc;
    rec.count = 0x45;
    rec.table = ram_23952a;
    CALLV(ROOT->RegisterObjectTable)(0x12a, (void *)&rec);
    rec.cls = NAKA_CLASS_ApFunction;
    rec.proc = ROOT->ApFunctionProc;
    rec.count = 0x45;
    rec.table = ram_239642;
    CALLV(ROOT->RegisterObjectTable)(0x42a, (void *)&rec);
    rec.cls = NAKA_CLASS_Function;
    rec.proc = ROOT->FunctionProc;
    rec.count = 0x0d;
    rec.table = ram_239872;
    CALLV(ROOT->RegisterObjectTable)(0x10a, (void *)&rec);
    rec.cls = NAKA_CLASS_Function;
    rec.proc = ROOT->FunctionProc;
    rec.count = 0x0d;
    rec.table = ram_2398aa;
    CALLV(ROOT->RegisterObjectTable)(0x40a, (void *)&rec);
    rec.cls = NAKA_CLASS_MainFunction;
    rec.proc = ROOT->MainFunctionProc;
    rec.count = 0x0e;
    rec.table = ram_239fd2;
    CALLV(ROOT->RegisterObjectTable)(0x14a, (void *)&rec);
    rec.cls = NAKA_CLASS_MainFunction;
    rec.proc = ROOT->MainFunctionProc;
    rec.count = 0x0e;
    rec.table = ram_23a00e;
    CALLV(ROOT->RegisterObjectTable)(0x44a, (void *)&rec);
    rec.cls = NAKA_CLASS_Viewable;
    rec.proc = ROOT->ViewableProc;
    rec.count = 0x315;
    rec.table = HDAE5000_UiObject_PtrTable;
    CALLV(ROOT->RegisterObjectTable)(0x7f, (void *)&rec);
    rec.cls = NAKA_CLASS_ResName;
    rec.proc = ROOT->ResNameProc;
    rec.count = 0x315;
    rec.table = HDAE5000_UiObjectName_PtrTable;
    CALLV(ROOT->RegisterObjectTable)(0x37f, (void *)&rec);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, HDAE5000_GFX_INIT_PARAMS, 10);
}
