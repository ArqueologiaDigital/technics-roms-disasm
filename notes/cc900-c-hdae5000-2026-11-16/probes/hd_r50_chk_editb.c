/* lane_hd round 50, helper h_chk: second form of HDAE5000_FILE_Naming_Screen (hd_r50_chk_edit.c has the first).
   The ROM tests the edit-switch id against 11 with a jump-if-EQUAL to the very next instruction: the first form
   writes `if (id != 11) {}`; this one an empty single-case switch, in case V4.23 compiles a lone case as
   `cp; j eq, case` and drops the jump to the end that would follow.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

long HDAE5000_FILE_Naming_Screen(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 11:
            break;
        }
    }
    return 0;
}
