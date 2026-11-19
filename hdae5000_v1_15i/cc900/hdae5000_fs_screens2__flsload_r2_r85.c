/* Functions of hdae5000_filesystem.s.  (hdae5000_fs_screens2__flsload_r2_r85.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fs_screens2__flsload_r2_r85.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: FlsLoad_c=HDAE5000_FlsLoadScreen
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

#define APFUNC_FlsNamingCheck 0x012a0016L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

/* other modules (call) */
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, void *out);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls);

/* this module (calr, cc900-module) */
extern unsigned int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int flag, long obj);
/* the callers load WA / BC: they call the label through an int prototype */
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);

/* RAM */
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
extern unsigned int HDAE5000_RAM_FlsChainFls;
extern unsigned int HDAE5000_RAM_FlsChainItem;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;

/* the FLS load screen: its 32 items (pages of 16); AL items chain the next load (EVT_HDAE_AFTER_LOAD).
   r23 (run 98 departed at +12, the timer): SetApTimer / LoadSongWithUi stacked arguments reversed; &it through
   FlsItem_Get's void * (the ROM: `lda xwa,(xsp+4); ld xde,xwa` before WA / BC); the page base cast to int. */
long FlsLoad_c(long obj, long ev, long arg)
{
    struct FlsItem it;
    unsigned int fls;
    unsigned int item;
    unsigned int mask;  /* r2 form c: unsigned, loaded late (no conversion to the parameter) */

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SEQ_STOP:
        CALLV(ROOT->SetApTimer)(0x53L, obj, -1L, EVT_HDAE_AFTER_LOAD, 0L);
        break;
    case EVT_HDAE_AFTER_LOAD:
        if (HDAE5000_RAM_FlsAutoLoadPending == 1) {
            fls = HDAE5000_RAM_FlsChainFls;
            if ((item = HDAE5000_RAM_FlsChainItem + 1) >= 32) {
                if (++fls >= 120)
                    fls = 0;
                item = 0;
            }
            if (HDAE5000_FlsItem_Get(fls, item, &it) != 0xffff) {
                if (it.al == 1) {
                    HDAE5000_RAM_FlsAutoLoadPending = 1;
                    HDAE5000_RAM_FlsChainFls = fls;
                    HDAE5000_RAM_FlsChainItem = item;
                } else
                    HDAE5000_RAM_FlsAutoLoadPending = 0;
                mask = HDAE5000_Song_PartMask(it.dir, it.song);
                if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, 0, OBJ_FLS_FILE_LOAD) != 0xffff) {
                    if (it.as == 1)
                        CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
                }
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
        }
        break;
    case EVT_SW_IN:
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_RAM_CurFlsItem = (int)HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &it) != 0xffff) {
            if (it.al == 1) {
                HDAE5000_RAM_FlsAutoLoadPending = 1;
                HDAE5000_RAM_FlsChainFls = HDAE5000_RAM_CurFls;
                HDAE5000_RAM_FlsChainItem = HDAE5000_RAM_CurFlsItem;
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
            mask = HDAE5000_Song_PartMask(it.dir, it.song);
            if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, 0, OBJ_FLS_FILE_LOAD) != 0xffff) {
                if (it.as == 1)
                    CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        HDAE5000_RAM_CurFlsItem = (int)HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(1, 0);
        if (HDAE5000_Fls_IsBlankName(HDAE5000_RAM_CurFls) != 0xffff)
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        else {
            CALLV(ROOT->ApFuncCall)(APFUNC_FlsNamingCheck, EVT_SET_STRING,
                                    HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls));
            CALLV(ROOT->ApPostEvent)(OBJ_HDD_FLS_NAMING2, EVT_SHOW, 0L);
        }
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase == 0) {
            if (HDAE5000_RAM_CurFls != 0) {
                HDAE5000_RAM_CurFls--;
                HDAE5000_RAM_FlsItemPageBase = 16;
                HDAE5000_FlsScreen_Refresh(0, 0);
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
            }
        } else {
            HDAE5000_RAM_FlsItemPageBase = 0;
            HDAE5000_FlsScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase != 0) {
            if (HDAE5000_RAM_CurFls < 119) {
                HDAE5000_RAM_CurFls++;
                HDAE5000_RAM_FlsItemPageBase = 0;
                HDAE5000_FlsScreen_Refresh(0, 0);
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
            }
        } else {
            HDAE5000_RAM_FlsItemPageBase = 16;
            HDAE5000_FlsScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurFlsItem = (int)HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(0, 1);
        break;
    }
    return 0;
}
