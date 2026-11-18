/* hd_r56_misc_reg.c (helper h_misc, lane_hd round 56): HDAE5000_Handler_Registration (hd-ae5000_v2_06i.s, 0x280020,
   750 B), four new forms of its last call.  Calls only the main CPU: its own calr group.
   cc900-options: -Xr
   cc900-name: HandlerReg_c=HDAE5000_Handler_Registration
   cc900-name: HandlerReg_d=HDAE5000_Handler_Registration
   cc900-name: HandlerReg_e=HDAE5000_Handler_Registration
   cc900-name: HandlerReg_f=HDAE5000_Handler_Registration

   Run 2026-11-18-20-hd-r55 (hd_r54_misc_reg.c): the eleven RegisterObjectTable blocks match; only the stacked
   arguments of RegisterTitle differ.  ROM: `pushw 10`, then `lda xwa,(GFX_INIT_PARAMS); push xwa`.
     `(long)HDAE5000_GFX_INIT_PARAMS` (explicit cast, unprototyped call): lda+push evaluated EARLY, before pushw 10
       (DIFF +705);
     the plain array: a constant `pushw @hi16 / pushw @lo16` (DIFF +706).
   The matched list pages (cc900/hdae5000_list_pages_hd_driver.c, MemCopy / MemFill of a char array through their
   `void *` / `const void *` prototypes) show the ROM's order: the constant pushed first, then `lda xwa,(sym);
   push xwa`.  So the name is converted IMPLICITLY by a prototype here: RegisterTitle is called through a
   prototyped pointer type (no __cdecl: the callee pops, as its `retd 6` does).
     HDAE5000_Handler_Registration  4th parameter `void *`
     HandlerReg_c                   4th parameter `const void *`
     HandlerReg_d                   4th parameter `const char *` (a qualifier conversion only)
     HandlerReg_e                   4th parameter `long`, `(long)` cast as in r55 but into a prototyped parameter
     HandlerReg_f                   unprototyped call, `&HDAE5000_GFX_INIT_PARAMS[0]`
   REG() is the matched block of hd_r54_misc_reg.c, one call per table (a short macro, not one huge #define).
   RAM tables as in hd_r54_misc_reg.c (RAM copy = ROM label - 0xbff88).
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ObjReg { long cls; void *proc; unsigned int count; void *table; };

typedef void (*RegTitleV)(long, long, long, void *, int);
typedef void (*RegTitleCV)(long, long, long, const void *, int);
typedef void (*RegTitleCC)(long, long, long, const char *, int);
typedef void (*RegTitleL)(long, long, long, long, int);

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

#define REG(n, c, p, cnt, t) \
    rec.cls = c; rec.proc = ROOT->p; rec.count = cnt; rec.table = t; \
    CALLV(ROOT->RegisterObjectTable)(n, (void *)&rec)

void HDAE5000_Handler_Registration(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_239822, ram_2397ea);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239870, ram_239824);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_23952a);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_239642);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239872);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_2398aa);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239fd2);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23a00e);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x315, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x315, HDAE5000_UiObjectName_PtrTable);
    ((RegTitleV)ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, HDAE5000_GFX_INIT_PARAMS, 10);
}

void HandlerReg_c(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_239822, ram_2397ea);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239870, ram_239824);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_23952a);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_239642);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239872);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_2398aa);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239fd2);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23a00e);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x315, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x315, HDAE5000_UiObjectName_PtrTable);
    ((RegTitleCV)ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, HDAE5000_GFX_INIT_PARAMS, 10);
}

void HandlerReg_d(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_239822, ram_2397ea);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239870, ram_239824);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_23952a);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_239642);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239872);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_2398aa);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239fd2);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23a00e);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x315, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x315, HDAE5000_UiObjectName_PtrTable);
    ((RegTitleCC)ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, HDAE5000_GFX_INIT_PARAMS, 10);
}

void HandlerReg_e(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_239822, ram_2397ea);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239870, ram_239824);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_23952a);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_239642);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239872);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_2398aa);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239fd2);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23a00e);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x315, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x315, HDAE5000_UiObjectName_PtrTable);
    ((RegTitleL)ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, (long)HDAE5000_GFX_INIT_PARAMS, 10);
}

void HandlerReg_f(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_239822, ram_2397ea);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239870, ram_239824);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_23952a);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x45, ram_239642);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239872);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_2398aa);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239fd2);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_23a00e);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x315, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x315, HDAE5000_UiObjectName_PtrTable);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, &HDAE5000_GFX_INIT_PARAMS[0], 10);
}
