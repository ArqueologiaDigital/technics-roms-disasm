/* Functions of hdae5000_hd_driver.s.  (hdae5000_drv_screens3.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_drv_screens3.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_FlsScreen_Refresh HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsList_BuildPage HDAE5000_Lbn_ShowEntry HDAE5000_PartList_Build
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_DelOpt_InitFromSong HDAE5000_NameHistory_Recall
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_TypeSel_Init HDAE5000_TypeSel_ShowSaveFlags
   cc900-module: HDAE5000_SaveSongWithUi HDAE5000_LoadSongWithUi HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_HardTest_Print HDAE5000_FormatDialog_CodeDigit HDAE5000_UiObj_SetCaption
   v1.15i port (h_v1misc 2026-11-19): HDAE5000_SaveOptSwEventCatch only (the declarations are the tree's own
   hdae5000_drv_screens3.c's).  v1.x has 8 parts: the edit-switch dispatch has no 0x8b case (v2.06i's toggle of the
   ninth part, mask bit 0x100), so the compare chain starts at 0x0b, and "all YES" (switch 0x0a) inits the record with
   mask 0xff instead of 0x1ff.  The unused local m of the 0x8b case is dropped.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* ---- this module (calr) ---- */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_TypeSel_ShowSaveFlags(void);
/* stacked parameters in V4.23's left-to-right order: the ROM pushes name, ui, obj (Save) / ui, obj (Load) */
extern int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, char *name, int ui, long obj);

/* ---- other modules (call) ---- */
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern char ram_23d286[];                        /* HDAE5000_RAM_Name_ColumnRuler (a .set, not resolvable) */

/* ---- ROM ---- */
extern char HDAE5000_Str_SVOP[];
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];

/* an array read as an lvalue member at offset 0: `lda xwa,(sym); ld xde,xwa` (hd_r9_b2.c, TitleInfo_Build) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

long HDAE5000_SaveOptSwEventCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_SVOP);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 8:
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23d286));
            if (HDAE5000_RAM_WriteConfirm == 1 && HDAE5000_Song_IsUsed(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong) != -1)
                CALLV(ROOT->PostEvent)(OBJ_ATTEN_OVER_FILE, EVT_SHOW, 0L);
            else
                HDAE5000_SaveSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        ram_23d286, 1, OBJ_SELECT_FILE);
            HDAE5000_SongScreen_Refresh(0, 0);
            break;
        case 9:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x0a:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0xff, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x0b:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        }
        return 0;
    }
}
