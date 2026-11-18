/* lane_hd round 52, helper h_chk: second try at HDAE5000_FILE_Naming_Screen.  In run 2026-11-18-7-hd-r51 both
   round-50 forms (an empty `if (id != 11) {}` and an empty single-case switch) lost the compare altogether, and
   with the result unused the function pointer went to XHL instead of XIX.  The ROM keeps `cp xhl,11; jr z` to
   the very next instruction, so the result must be used by something that survives: a goto.
   HDAE5000_FILE_Naming_Screen: `if (id == 11) goto done; done: return 0;`
   FileNaming_b: `switch (id) { case 11: goto done; } done:`
   FileNaming_c: a switch with `default:` first and an empty `case 11:` after it.
   cc900-options: -Xr
   cc900-name: FileNaming_b=HDAE5000_FILE_Naming_Screen
   cc900-name: FileNaming_c=HDAE5000_FILE_Naming_Screen
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

long HDAE5000_FILE_Naming_Screen(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        if (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID) == 11)
            goto done;
    }
done:
    return 0;
}

long FileNaming_b(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 11:
            goto done;
        }
    }
done:
    return 0;
}

long FileNaming_c(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        default:
            break;
        case 11:
            break;
        }
    }
    return 0;
}
