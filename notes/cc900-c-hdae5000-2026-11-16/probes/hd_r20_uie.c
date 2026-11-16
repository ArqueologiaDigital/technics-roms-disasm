/* hd_r20_uie.c (helper h_ui, lane_hd round 20): HDAE5000_IvHddNamingProc (hd-ae5000_v2_06i.s), a calr
   singleton: the class proc of the HD naming view.  Same shape as the staged AttenCp*SwCatch procs: the default
   case first in the source (its body sits right after the compares), the others in reverse compare order.
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
