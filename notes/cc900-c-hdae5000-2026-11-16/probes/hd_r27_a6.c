/* hd_r27_a6.c (helper h_r27a): four functions of hdae5000_filesystem.s's screen module (the large calr group of
   hdae5000_fs_screens*.c): HDAE5000_FlsFileLoadSwCatch HDAE5000_FlsDel1SwCatch HDAE5000_FlsDel2SwCatch
   HDAE5000_CopyToHDScreen.
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
long HDAE5000_FlsDel1SwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_DEL1);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0:
        case 1:
            HDAE5000_FlsItem_Clear(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem);
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->PostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        }
        return 0;
    }
}

/* the same, the item removed from the list */
long HDAE5000_FlsDel2SwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_DEL2);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0:
        case 1:
            HDAE5000_FlsItem_Remove(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem);
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->PostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        }
        return 0;
    }
}

/* the copy-to-HD screen (the floppy's song list): mark all present songs, go on to the directory selection,
   toggle one song's mark.  The ROM compares XBC in place and indexes FdList with 32-bit sums
   (`extz xwa; add xwa,0x100; ld xbc,FdList; add xbc,xwa`); in SELECT_SAVE's two stores it adds 0x114 to XDE (arg)
   itself (`add xde,0x114; ld xwa,FdList; add xwa,xde`). */
long HDAE5000_CopyToHDScreen(long obj, long ev, long arg)
{
    unsigned int i;

    switch (ev) {
    case EVT_HDAE_SELECT_ALL:
        for (i = 0; i < 20; i++) {
            if (HDAE5000_RAM_FdList.present[(unsigned long)i] == 1) {
                HDAE5000_RAM_FdList.sel[(unsigned long)i] = 1;
                HDAE5000_FdList_Redisplay();
            }
        }
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
        if (HDAE5000_Count_Active_Files() != 0)
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRSEL, EVT_SHOW, 0L);
        else
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CPFD_MARK, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        if (HDAE5000_RAM_FdList.present[arg] == 1) {
            if (HDAE5000_RAM_FdList.sel[arg] == 1)
                HDAE5000_RAM_FdList.sel[arg] = 0;
            else
                HDAE5000_RAM_FdList.sel[arg] = 1;
            HDAE5000_FdList_Redisplay();
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_FdList_Redisplay();
        break;
    }
    return 0;
}
