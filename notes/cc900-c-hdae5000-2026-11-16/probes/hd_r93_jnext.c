/* hd_r93_jnext.c (lane_hd round 93, 2026-11-21): HDAE5000_FILE_Naming_Screen (46 B) and
   HDAE5000_LyricJumpEditCheck_Unregistered (87 B), the conditional jump to the next instruction.
   cc900-options: -Xr
   cc900-name: FNaming_a=HDAE5000_FILE_Naming_Screen
   cc900-name: FNaming_b=HDAE5000_FILE_Naming_Screen
   cc900-name: FNaming_c=HDAE5000_FILE_Naming_Screen
   cc900-name: LJUnreg_a=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LJUnreg_b=HDAE5000_LyricJumpEditCheck_Unregistered
   cc900-name: LJUnreg_c=HDAE5000_LyricJumpEditCheck_Unregistered
   Both ROMs keep a test of SendEvent's result and a conditional jump to the very next instruction (FILE_Naming:
   `cp xhl,11; jr z`, LyricJump: `or xhl,xhl; jr z`), with the call's function pointer in XIX (a used result).
   Every statement form tried (an empty if / else, a goto to the next statement, a switch with an empty case:
   rounds 50-56) lost the test, and helper h_misc found no jump to the next line in 10,578 V4.23 listings.  An
   EXPRESSION whose only code is the test is untried: a logical or conditional operator, evaluated for nothing,
   whose second operand generates no code.  The result is kept in a long local r (pointer in XIX):
     FNaming_a / LJUnreg_a  (void)(r == 11 || 0)    /  (void)(r != 0 || 0)
     FNaming_b / LJUnreg_b  r != 11 ? 0 : 0;        /  r ? 0 : 0;
     FNaming_c / LJUnreg_c  (void)(r != 11 && r)    /  (void)(r && r)
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];

long FNaming_a(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        (void)(r == 11 || 0);
    }
    return 0;
}

long FNaming_b(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        r != 11 ? 0 : 0;
    }
    return 0;
}

long FNaming_c(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        (void)(r != 11 && r);
    }
    return 0;
}

long LJUnreg_a(long obj, long ev, struct ParaBlk *arg)
{
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg);
        (void)(r != 0 || 0);
        break;
    }
    return 0;
}

long LJUnreg_b(long obj, long ev, struct ParaBlk *arg)
{
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg);
        r ? 0 : 0;
        break;
    }
    return 0;
}

long LJUnreg_c(long obj, long ev, struct ParaBlk *arg)
{
    long r;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_1d_LyricJumpEditCheck, arg->value);
        return obj;
    case EVT_RAM_DATA_REQ:
        return 0;
    case EVT_SW_IN:
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg);
        (void)(r && r);
        break;
    }
    return 0;
}
