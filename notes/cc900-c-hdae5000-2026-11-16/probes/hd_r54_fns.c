/* hd_r54_fns.c (lane_hd round 54): HDAE5000_FILE_Naming_Screen (hdae5000_hd_driver.s, 46 B), three forms.
   Runs 2026-11-18-7-hd-r51 and -13-hd-r52 (hd_r50_chk_edit*.c, hd_r52_chk_fns.c, helper h_chk): every form whose
   call result is only tested (an empty if, a goto to the next statement, a switch with an empty case) lost the
   `cp xhl,11` and loaded the function pointer into XHL; the ROM loads it into XIX and keeps the compare and its
   `jr z` to the very next instruction.  In SelectListProc the pointer went to XIX only when the call's result was
   assigned to a register local held in XHL (`u = GETVIEWL(obj)`, long u), so these keep the result in a long r:
     HDAE5000_FILE_Naming_Screen  r = SendEvent(..); if (r == 11) goto done; done: return 0;
     FileNaming_d                 if ((r = SendEvent(..)) == 11) goto done;
     FileNaming_e                 r = SendEvent(..); if (r != 11) { } (an empty block)
   cc900-options: -Xr
   cc900-name: FileNaming_d=HDAE5000_FILE_Naming_Screen
   cc900-name: FileNaming_e=HDAE5000_FILE_Naming_Screen
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

long HDAE5000_FILE_Naming_Screen(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        if (r == 11)
            goto done;
    }
done:
    return 0;
}

long FileNaming_d(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        if ((r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) == 11)
            goto done;
    }
done:
    return 0;
}

long FileNaming_e(long obj, long ev, long arg)
{
    long r;

    if (ev == EVT_SW_IN) {
        r = CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID);
        if (r != 11) {
        }
    }
    return 0;
}
