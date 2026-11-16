/* hdae5000_v1_15i: the functions of hdae5000/cc900-staged/hdae5000_fs_screens3.c that V4.23 reproduces unchanged in HD-AE5000 v1.15i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fs_screens3.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_FdList_Redisplay HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_Count_Active_Files
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct FdList { char label[14]; char rows[242]; unsigned char present[20]; unsigned char sel[20]; };

/* other modules (call) */
extern int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item);
extern int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item);

/* this module (calr, cc900-module) */
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);
extern void HDAE5000_FdList_Redisplay(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern unsigned int HDAE5000_Count_Active_Files(void);

extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern struct FdList HDAE5000_RAM_FdList;

extern char HDAE5000_Str_FLS[];
extern char HDAE5000_Str_DEL1[];
extern char HDAE5000_Str_DEL2[];

/* the FLS load screen's switches: 6 / 7 stop the chained auto load and the playback */
long HDAE5000_FlsFileLoadSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_FLS);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 6:
        case 7:
            HDAE5000_RAM_FlsAutoLoadPending = 0;
            CALLV(HAMA->PlayHalt)(0);
            break;
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* "delete the FLS item?" (the item is cleared): keys 0 / 1 do it, 6 / 7 go back */

/* the same, the item removed from the list */

/* the copy-to-HD screen (the floppy's song list): mark all present songs, go on to the directory selection,
   toggle one song's mark.  The ROM compares XBC in place and indexes FdList with 32-bit sums
   (`extz xwa; add xwa,0x100; ld xbc,FdList; add xbc,xwa`); in SELECT_SAVE's two stores it adds 0x114 to XDE (arg)
   itself (`add xde,0x114; ld xwa,FdList; add xwa,xde`). */
