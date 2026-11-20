/* hdae5000_v1_10i: v1.x per-tree C, round 87 (2026-11-20), run 2026-11-20-1-hd-r87-v1gap
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r87a_setup_copy_filesystem__copytohd_v1.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Redisplay HDAE5000_DirList_BuildPage HDAE5000_Count_Active_Files
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* these modules (calr, cc900-module) */
extern void HDAE5000_FdList_Redisplay(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern unsigned int HDAE5000_Count_Active_Files(void);

extern unsigned char HDAE5000_RAM_FdList[];     /* as a flat array: present[20] at 0x100, sel[20] at 0x114 */

#define FD_PRESENT(i) HDAE5000_RAM_FdList[(i) + 0x100]
#define FD_SEL(i) HDAE5000_RAM_FdList[(i) + 0x114]

long HDAE5000_CopyToHDScreen(long obj, long ev, unsigned long arg)
{
    switch (ev) {
    case EVT_HDAE_SELECT_OK:
        HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
        if (HDAE5000_Count_Active_Files() != 0)
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRSEL, EVT_SHOW, 0L);
        else
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CPFD_MARK, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        if (FD_PRESENT(arg) == 1) {
            if (FD_SEL(arg) == 1)
                FD_SEL(arg) = 0;
            else
                FD_SEL(arg) = 1;
            HDAE5000_FdList_Redisplay();
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_FdList_Redisplay();
        break;
    }
    return 0;
}
