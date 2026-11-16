/* The HD naming procedure (IvHddNamingProc) of hd-ae5000_v2_06i.s: helper h_ui's C.
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r20_uie.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char HDAE5000_Str_Name[];

long HDAE5000_IvHddNamingProc(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Name);
        return 0;
    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_SET_AP_FUNCTION,
                               *(long *)(CALLR(unsigned char *, ROOT->GetViewInstance)(obj) + 0x16));
        CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, ev, 0L);
        return 0;
    case EVT_HIDE:
        CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, ev, 0L);
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        return 0;
    }
}
