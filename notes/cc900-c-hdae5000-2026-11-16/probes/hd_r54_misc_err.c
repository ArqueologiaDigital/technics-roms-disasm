/* hd_r54_misc_err.c (helper h_misc, lane_hd round 54): two procs that call only the main CPU (each its own calr
   group): HDAE5000_LyricJumpEditCheck_Unregistered (hdae5000_hd_driver.s, 0x285f8b, 91 B; the unregistered twin of
   the matched LyricJumpEditCheck, cc900-staged/hdae5000_edit_checks.c) and HDAE5000_ShowErrorMessageTitle
   (hdae5000_ui_display.s, 0x28acfa, 78 B, survey `other` for its final `jp (xhl)`).  No earlier probe defined
   either (the probes only called ShowErrorMessageTitle).
   cc900-options: -Xr
   cc900-name: LyricJumpUnreg=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LyricJumpUnreg_b=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LyricJumpUnreg_c=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: ShowErrMsgTitle_b=HDAE5000_ShowErrorMessageTitle

   LyricJumpEditCheck_Unregistered (ROM): obj kept in XIZ (returned after a call); `cp xbc` in place SW_IN,
   RAM_DATA_REQ, GET_RAM_STRING (jr nz: the first source case inverted), bodies in source order: SPrintf(str,
   "%1d", value) -> return obj; return 0; SendEvent(0x02600024, EVT_MAKE_EDIT_SW_ID, arg) with arg still in XDE
   (no load, so `arg` passed unconverted; the function pointer then goes to XIX, as in the matched
   LBNPage1SwCatch) and its result tested and ignored (`or xhl,xhl; jr z` to the next instruction); then the
   common `ld xhl,0`.
     LyricJumpUnreg    `if (SendEvent(...)) ;` then break
     LyricJumpUnreg_b  `if (SendEvent(...) == 0) break;` then break
     LyricJumpUnreg_c  `if (SendEvent(...) != 0) { }` then break
   ShowErrorMessageTitle (ROM): `extz wa` (the code widened from a byte), HamaFn_SetGlobalError(code) with its
   pointer chain in XBC/XHL, RootFn_DeleteEvent(-1, EVT_INTERRUPT_TITLE), then `jp (xhl)` into
   RootFn_ApPostEvent(-1, EVT_INTERRUPT_TITLE, TITLE_MESAGE): V4.23 writes a void function's final call as a jump
   when it has no frame (HardTest_Print, matched, ends the same way).
     HDAE5000_ShowErrorMessageTitle  `int code` (the callers' prototype) passed as `(unsigned char)code`
     ShowErrMsgTitle_b               an `unsigned char code` parameter
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long LyricJumpUnreg(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg))
            ;
        break;
    }
    return 0;
}

long LyricJumpUnreg_b(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg) == 0)
            break;
        break;
    }
    return 0;
}

long LyricJumpUnreg_c(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg) != 0) {
        }
        break;
    }
    return 0;
}

/* show an error: SetGlobalError(code), then replace any pending title interrupt by the message title */
void HDAE5000_ShowErrorMessageTitle(int code)
{
    CALLV(HAMA->SetGlobalError)((unsigned char)code);
    CALLV(ROOT->DeleteEvent)(-1L, EVT_INTERRUPT_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, TITLE_MESAGE);
}

void ShowErrMsgTitle_b(unsigned char code)
{
    CALLV(HAMA->SetGlobalError)(code);
    CALLV(ROOT->DeleteEvent)(-1L, EVT_INTERRUPT_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, TITLE_MESAGE);
}
