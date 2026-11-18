/* hd_r58_misc_reg.c (helper h_misc, lane_hd round 58): HDAE5000_Handler_Registration (hd-ae5000_v2_06i.s, 0x280020,
   750 B), three forms.  Calls only the main CPU: its own calr group.
   cc900-options: -Xr
   cc900-name: HandlerReg_h=HDAE5000_Handler_Registration
   cc900-name: HandlerReg_i=HDAE5000_Handler_Registration

   Runs 2026-11-18-20-hd-r55 and -25-hd-r57 (hd_r54_misc_reg.c, hd_r56_misc_reg.c, seven forms): the eleven
   RegisterObjectTable blocks match every time; only RegisterTitle's two stacked arguments differ, and the reason is
   their ORDER, not how the name is spelled: V4.23 pushes the stacked arguments of a register-argument call LEFT TO
   RIGHT (every form pushed the 4th argument, the name, before the 5th, the 10: `lda xwa,(name); push xwa;
   pushw 10`, or `pushw @hi16; pushw @lo16; pushw 10` for the plain array).  The ROM pushes 10 first and the name
   last (`pushw 10; lda xwa,(name); push xwa`), so in the original call the module number is the 4th argument and the
   name the 5th (the callee finds the name at (xsp+4), the number at (xsp+8), its `retd 6`).  These swap them:
     HDAE5000_Handler_Registration  (..., 10, (long)HDAE5000_GFX_INIT_PARAMS)  (r55's cast: lda + push xwa)
     HandlerReg_h                   (..., 10, (void *)HDAE5000_GFX_INIT_PARAMS)
     HandlerReg_i                   (..., 10, &HDAE5000_GFX_INIT_PARAMS[0])     (r57's HandlerReg_f spelling)
   REG() is the block that matched, one call per table (a short macro).  RAM tables as in hd_r54_misc_reg.c
   (RAM copy = ROM label - 0xbff88).
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
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, (long)HDAE5000_GFX_INIT_PARAMS);
}

void HandlerReg_h(void)
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
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, (void *)HDAE5000_GFX_INIT_PARAMS);
}

void HandlerReg_i(void)
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
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, &HDAE5000_GFX_INIT_PARAMS[0]);
}
