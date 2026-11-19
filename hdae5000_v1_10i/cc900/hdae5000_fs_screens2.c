/* Functions of hdae5000_filesystem.s.  (hdae5000_fs_screens2.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fs_screens2.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

#define APFUNC_FlsNamingCheck 0x012a0016L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */
#define APFUNC_CP_FD_DIRNAMECheck 0x012a0018L   /* NAKA_APFUNC_CP_FD_DIRNAMECheck */

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
/* +0 title, +14 the 20 rows of 12 (and 2 bytes), +0x100 present flags, +0x114 selected flags */
struct FdList { char label[14]; char rows[242]; unsigned char present[20]; unsigned char sel[20]; };
struct FindData { char b[266]; };

/* an array read as an lvalue member at offset 0 (hd_r9_b2.c FdList_Clear: `lda xwa,(sym); ld xde,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, const char *, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

/* other modules (call) */
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, void *out);
extern unsigned int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);
extern unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item);
extern int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item);
extern int HDAE5000_FlsItem_SetDir(unsigned int fls, unsigned int item, unsigned int dir);
extern int HDAE5000_FlsItem_SetSong(unsigned int fls, unsigned int item, unsigned int song);
extern void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, int on);
extern void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, int on);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Dir_IsBlankName(unsigned int dir);
extern unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls);
extern unsigned int HDAE5000_Dir_CountEmptySongs(unsigned int dir);
extern unsigned int HDAE5000_HD_StoreTables(int keep);   /* unsigned: the ROM compares HL with 0xffff unconverted */
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, unsigned int mask,
                                            int a, int b);

/* this module (calr, cc900-module) */
extern void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask);
extern char *HDAE5000_NameHistory_Recall(unsigned char *history);
extern void HDAE5000_FlsName_StoreWithUi(unsigned int fls, char *name, long obj);
extern void HDAE5000_DirName_StoreWithUi(unsigned int dir, char *name, long obj);
extern void HDAE5000_FlsList_BuildPage(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_SongScreen_Refresh(int variant, int mode);     /* old-style, char parameters */
extern void HDAE5000_YieldUntilSem1Zero(void);
extern unsigned int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int flag, long obj);
extern unsigned int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, char *name,
                                            int flag, long obj);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int flag);
extern void HDAE5000_DelOpt_ShowFlags(void);
extern unsigned int HDAE5000_Count_Active_Files(void);
/* the callers load WA / BC: they call the label through an int prototype; the definition, with the ROM's
   unsigned char parameters, is FlsScrRefresh_c (cc900-name, same label) */
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);
void FlsScrRefresh_c(unsigned char variant, unsigned char mode);
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir);

/* RAM */
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern int HDAE5000_RAM_DirPageBase;
extern int HDAE5000_RAM_FlsPageBase;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
extern unsigned int HDAE5000_RAM_FlsChainFls;
extern unsigned int HDAE5000_RAM_FlsChainItem;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_LyricJump;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern char HDAE5000_RAM_LbnEntryText[];
extern char ram_22aa20[], ram_22aa32[], ram_22aa38[];   /* LbnEntryText + 6 / + 0x18 / + 0x1e */
extern char HDAE5000_RAM_NameEditBuffer[];
extern char ram_23d286[];                               /* HDAE5000_RAM_Name_ColumnRuler */
extern unsigned char HDAE5000_RAM_FlsNameHistory[];
extern unsigned char HDAE5000_RAM_DirNameHistory[];
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern struct FdList HDAE5000_RAM_FdList;
extern char ram_22a058[];                               /* the FLS screen's title text */
extern char ram_22a078[];                               /* its LOC text */
extern char ram_22afd8[];                               /* its 16 item rows of 37 */

/* ROM */
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];
extern unsigned char HDAE5000_DelOpt_TemplateBlank[];
extern char HDAE5000_Str_Wrcn[];
extern char HDAE5000_Str_OVWR[];
extern char HDAE5000_Str_DEL_DelOptSwEventCatch[];
extern char HDAE5000_Str_Blank3Tab[];
extern char HDAE5000_Str_Blank16Tab[];
extern char HDAE5000_Str_Blank3Tab_Lbn_ShowEntry[];
extern char HDAE5000_Str_Blank26Tab[];
extern char HDAE5000_Fmt_1_1d[];
extern char ram_2cb1b6[];                               /* HDAE5000_Fmt_2_2d_Lbn_ShowEntry */
extern char HDAE5000_Fmt_3_3d_Lbn_ShowEntry[];
extern char HDAE5000_Fmt_1_1d_Lbn_ShowEntry[];
extern char ram_2cb1ca[];                               /* HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2 */
/* unsigned long: the ROM evaluates ObjIds[variant] first among the arguments (a converted argument's order) */
extern unsigned long ram_2cb2f0[], ram_2cb2f8[], ram_2cb300[], ram_2cb308[], ram_2cb310[], ram_2cb318[];
                                                        /* HDAE5000_FlsScreen_Refresh_ObjIds .. _ObjIds_6 */
extern char HDAE5000_Str_FLSNAME[];
extern char ram_2cb32a[];                               /* HDAE5000_Fmt_2_2d_FlsScreen_Refresh */
extern char ram_2cb330[];                               /* HDAE5000_Str_Chr3A_FlsScreen_Refresh */
extern char ram_2cb332[];                               /* HDAE5000_Str_Blank0Tab_FlsScreen_Refresh */
extern char HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh[];
extern char ram_2cb358[];                               /* HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2 */
extern char HDAE5000_Fmt_LOC_3_3d_2_2d[];
extern char HDAE5000_Str_LOC00000[];
extern char ram_2cb398[];                               /* HDAE5000_Fmt_2_2d_CopyToHd_Execute */
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[], HDAE5000_Str_TLX[];

/* the load-by-number entry: digit position pos 0..6 (no digit, directory hundreds / tens / units, song tens /
   units, reset); direct = 1 sends to the objects, else posts; returns 0, -1 (bad directory) or -2 (bad song) */

/* the FLS naming window's check procedure (the FLS select screen) */

/* the same for the FLS edit screen */

/* the FLS screen: title "FLS NAME NN:<name>", the 16 items of the page, the selected item's LOC and part list;
   variant picks the object ids (0 load screen, 1 edit screen); mode 0 or 2 redraws title and items, 2 skips the
   two lines at the end.
   r23 (run 98 could not check form a; fsb's K&R listing departed at +160): unsigned char parameters (fsb's
   prologue matched); ObjIds unsigned long passed as (long) / to PartList_Build's long; the song record a local
   assigned before its MemCopy (the ROM calls FlsItem_SongRecord before pushing the count, then pushes XHL);
   FlsItem_Get's &item early through its void * parameter; the part mask in r (the ROM keeps i, the item result
   and the mask in IZ: `ld iz,hl` after Song_PartMask, `push iz` last).
   Open: `ld wa,37; mul xwa,iz` (V4.23: `ld wa,iz; mul wa,37`). */

/* the FLS select screen (list of 120 FLS, pages of 24).  r23 (run 98: +188): (unsigned int)arg + FlsPageBase */
long HDAE5000_SelectFlsScreen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_FlsPageBase = 0;
            HDAE5000_FlsList_BuildPage();
            break;
        case 1:
            HDAE5000_RAM_FlsPageBase = 24;
            HDAE5000_FlsList_BuildPage();
            break;
        case 5:
            HDAE5000_RAM_FlsPageBase = 48;
            HDAE5000_FlsList_BuildPage();
            break;
        case 6:
            HDAE5000_RAM_FlsPageBase = 72;
            HDAE5000_FlsList_BuildPage();
            break;
        case 7:
            HDAE5000_RAM_FlsPageBase = 96;
            HDAE5000_FlsList_BuildPage();
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
    case EVT_HDAE_SELECT_OK2:
        HDAE5000_RAM_CurFls = (unsigned int)arg + HDAE5000_RAM_FlsPageBase;
        HDAE5000_FlsScreen_Refresh(0, 2);
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_FlsNamingCheck, EVT_SET_STRING,
                                HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls =
                                                               (unsigned int)arg + HDAE5000_RAM_FlsPageBase));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_FLS_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsPageBase >= 24) {
            HDAE5000_RAM_FlsPageBase -= 24;
            HDAE5000_FlsList_BuildPage();
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsPageBase < 96) {
            HDAE5000_RAM_FlsPageBase += 24;
            HDAE5000_FlsList_BuildPage();
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}

/* the FLS load screen: its 32 items (pages of 16); AL items chain the next load (EVT_HDAE_AFTER_LOAD).
   r23 (run 98 departed at +12, the timer): SetApTimer / LoadSongWithUi stacked arguments reversed; &it through
   FlsItem_Get's void * (the ROM: `lda xwa,(xsp+4); ld xde,xwa` before WA / BC); mask int, converted to the unsigned
   mask parameter (the ROM loads `ld de,iz` before the pushes); the page base cast to int (see the header). */

/* the FLS edit screen.  r23 (run 98: +529, only the timers): stacked arguments reversed */
long HDAE5000_FlsEditScreen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT_LIST_BOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_FLS1, EVT_SHOW, 0L);
            break;
        case 1:
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_FLS2, EVT_SHOW, 0L);
            break;
        case 5:
            HDAE5000_FlsItem_Insert(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        case 6:
            if (arg & 0x80)
                HDAE5000_FlsItem_SetAutoStart(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 0);
            else
                HDAE5000_FlsItem_SetAutoStart(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 1);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        case 7:
            if (arg & 0x80)
                HDAE5000_FlsItem_SetAutoLoad(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 0);
            else
                HDAE5000_FlsItem_SetAutoLoad(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 1);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_DIR_SEL, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
        CALLV(HAMA->pdly_tim_X)(100);
        HDAE5000_YieldUntilSem1Zero();
        if (HDAE5000_HD_StoreTables(0) != 0xffff)
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        else {
            CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
            HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_FLS_EDIT);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_FLS_EDIT);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_FLS_EDIT);
        }
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase != 0) {
            HDAE5000_RAM_FlsItemPageBase = 0;
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT_LIST_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase == 0) {
            HDAE5000_RAM_FlsItemPageBase = 16;
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT_LIST_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurFlsItem = (unsigned int)arg + HDAE5000_RAM_FlsItemPageBase;
        HDAE5000_FlsScreen_Refresh(1, 1);
        break;
    }
    return 0;
}

/* the FLS item's directory selection.  r23 (run 98: +195): (unsigned int)arg + DirPageBase */

/* the FLS item's song selection.  r23 (run 98: +158): SetDir / SetSong unsigned, TypeSel_Init void * */
long HDAE5000_FlsFileSelScreen(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_SEL_LISTBOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_RAM_CurSong = (unsigned int)arg;
        if (HDAE5000_FlsItem_IsSet(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem) == 0xffff) {
            CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
            CALLV(HAMA->pdly_tim_X)(100);
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_FlsItem_SetDir(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, HDAE5000_RAM_CurDir);
            HDAE5000_FlsItem_SetSong(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, HDAE5000_RAM_CurSong);
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        } else
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_OVER_FLS, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_CurDir != 0) {
            HDAE5000_RAM_CurDir--;
            HDAE5000_SongScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_SEL_LISTBOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_CurDir < 119) {
            HDAE5000_RAM_CurDir++;
            HDAE5000_SongScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_SEL_LISTBOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurSong = (unsigned int)arg;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
        else
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
        HDAE5000_SongScreen_Refresh(1, 1);
        break;
    }
    return 0;
}

/* the "overwrite the FLS item?" switch.  r23 (run 98: +203): SetDir / SetSong take unsigned (DE loaded last) */
long HDAE5000_FlsOverWrSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_OVWR);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0:
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_FlsItem_SetDir(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, HDAE5000_RAM_CurDir);
            HDAE5000_FlsItem_SetSong(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, HDAE5000_RAM_CurSong);
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

/* copy the floppy songs selected in the copy screen's list (FdList.sel) into free songs of directory dir;
   sel (XWA) is not read: the list is HDAE5000_RAM_FdList itself.
   r23 (run 98: registers swapped from +16, then the FdList address forms and the stacked arguments):
   - i `register`: the ROM keeps i in IZ and j / mask in QIZ; V4.23 gave i QIZ (`ld wa,qiz; cp wa,(xsp+..)`);
   - sel[i]: the ROM's 32-bit form (`extz xwa; add xwa,0x114; ld xbc,FdList; add xbc,xwa; cp (xbc),1`), written
     with an unsigned long index as in hd_r23_drv.c's FdList_Scan (r20's sel[i]: `add wa,0x114; (xbc+wa)`);
   - the row name as &rows[i * 12 + 3] of the 1-D rows (the ROM: `mul wa,12; inc 3,wa; extz xwa; add xwa,0xe;
     ld xbc,FdList; add xbc,xwa; push xbc`, the brief's `&arr[i]` argument form; r20's [20][12] scaled by shifts);
   - CopyFdSongToHd(dir, slot, num, mask, 0, 0) and the timers' stacked arguments in V4.23's left-to-right order. */

/* the copy-to-HD screen's directory selection.  r23 (run 98: +204): (unsigned int)arg + DirPageBase; timers */

/* the copy-to-HD directory naming window's check procedure */

/* the "write confirm" switch: keys 0 / 1 save the song under the typed name, 6 / 7 go back.
   r23 (run 98: +229): SaveSongWithUi's stacked arguments in the ROM's push order (name, 1, obj) */

/* the delete-option switches: 8 asks to delete, 10 / 11 reset the delete options from the song's parts.
   r23 (run 98: +214): TypeSel_Init(void *, .., unsigned char *, ..), as the drv module's matched calls */
