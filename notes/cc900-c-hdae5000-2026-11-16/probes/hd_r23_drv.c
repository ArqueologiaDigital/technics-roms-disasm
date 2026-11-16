/* hd_r23_drv.c (helper h_nm3a, lane_hd round 23), form a: hd_r20_drva.c (runs 2026-11-16-95-hd-r20) with what
   departed fixed.  Same thirteen functions of hdae5000_hd_driver.s (v2.06i), ROM address order.  Changes:
   - stacked arguments of non-__cdecl calls in REVERSE of r20's order: V4.23 pushes them left to right (r20's
     DeleteSongParts(.., 0, 1) gave pushw 0; pushw 1, the ROM pushes 1 then 0).  So DeleteSongParts(.., 1, 0),
     KillApTimer / SetApTimer(time, catch, -1, EVT_HDAE_TIMER_BACK, obj), and the prototypes
     LoadSongWithUi(dir, song, mask, int ui, long obj), SaveSongWithUi(dir, song, mask, char *name, int ui, long obj)
     (h_nm3b's song module reads its stacked parameters in that order too);
   - `if ((v = f()) != K)` wherever the ROM compares a copy of the result (`ld xiz,xhl; ld xwa,xiz; or xwa,xwa`,
     `ld wa,hl; cp wa,K`): FdList_Scan (label, h, n), HDDNamingCheck / HDD_DIRNAMECheck (p, as the matched
     CP_FD_DIRNAMECheck), Lbn_TypeDigit (r, m);
   - a page base + list index stored or passed on is (unsigned int)arg + DirPageBase (int): the ROM loads the base
     (the converted operand, evaluated first) before arg (SEL_DIR_Screen; r20's (int)arg + base used the base as a
     memory operand, `add wa,(base)`);
   - names the checker cannot resolve: HDAE5000_RAM_Browser_State+12 is ram_23a09a, HDAE5000_RAM_Name_ColumnRuler
     ram_23a04e (both .set in hdae5000_init_data.s); HDAE5000_Str_Chr3A_SongScreen_Refresh pushed as a constant is
     ram_2e2512 (its 31-character listing name is not translated);
   - SongScreen_Refresh takes unsigned char parameters (the ROM stores C and A to its stack: drvb's char prototype
     matched that prologue); the callers in this file, which load WA / BC, call it through an int-typed alias
     (cc900-name: SongScrRefresh_w=HDAE5000_SongScreen_Refresh; declared, never defined);
   - see each function's comment for the rest.
   Unsolved, kept: SongScreen_Refresh's row offset `ld wa,30; muls xwa,iz` (V4.23: `ld wa,iz; muls wa,30`).
   r20's header follows.
   cc900-name: SongScrRefresh_w=HDAE5000_SongScreen_Refresh

   hd_r20_drva.c (helper h_drv, lane_hd round 20), form a: thirteen functions of hdae5000_hd_driver.s (v2.06i), in ROM
   address order -- FdList_Scan, HDAETitleFunc, SEL_DIR_Screen, SongScreen_Refresh, AttenDelDirSwCatch,
   AttenDelFileSwCatch, HDDNamingCheck, HDD_DIRNAMECheck, HDD_UTIL_PAGE, SaveOptSwEventCatch, AttenHDFormatSwCatch,
   LBNLoadSwCatch, Lbn_TypeDigit.  All are in the one big calr module (0x280008-0x28f543).
   - HDAE5000_AttenHDFormatSwCatch is the whole function at 0x286666: the survey's "HDAE5000_AttenHDFormatSwCatch_OnCancel"
     (0x28678e) is its jump-table case 6/7 plus the code after the inner switch, not a function of its own.  Its
     inner switch is a V4.23 jump table (HDAE5000_AttenHDFormatSwCatch_CaseTable, 8 x u16, case 5 = default).
   - The UI procedures take (obj, ev, arg) as longs and switch on ev; the cases are written in the order that makes
     V4.23's reverse-order compares match the ROM (AttenCpToHDSwCatch, run 49): the case compared LAST in the ROM
     is the first in the source.  A procedure whose unmatched events reach InheritedProc after the switch has no
     default: the cases break and `return InheritedProc(...)` follows the switch.
   - Addresses passed to the main CPU with a constant first argument are WRAP(x) (TitleInfo_Build, matched); with a
     non-constant first argument (long)x (AttenCpToHDSwCatch, matched); FdList.label as the plain member
     (FdList_Clear, matched).
   - Library string routines: plain char * destinations and sources (lyrics module); StrNCpy's source const char *,
     because the ROM pushes the name buffer as a constant when it is the destination and loads it (lda/push) when it
     is the source.
   - Names over 31 characters whose first 31 are not unique are written as ram_<address> with the label in a comment.
   - The row offset of SongScreen_Refresh (`ldw wa,30; muls xwa,iz`) is the open idiom of DirList_BuildPage
     (hd_r13_nb.c): written here as 30 * i, which V4.23 is known to compile as `ld wa,iz; muls wa,30`.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_FlsScreen_Refresh HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsList_BuildPage HDAE5000_Lbn_ShowEntry HDAE5000_PartList_Build
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_DelOpt_InitFromSong HDAE5000_NameHistory_Recall
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_TypeSel_Init HDAE5000_TypeSel_ShowSaveFlags
   cc900-module: HDAE5000_SaveSongWithUi HDAE5000_LoadSongWithUi HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_HardTest_Print HDAE5000_FormatDialog_CodeDigit HDAE5000_UiObj_SetCaption
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* ---- library (stack arguments, caller pops) ---- */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, char *, int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_LToA(unsigned long, char *, int);

/* ---- this module (calr) ---- */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_FdList_Clear(void);
extern int HDAE5000_FdName_SongNumber(char *name);
extern void HDAE5000_ShowErrorMessageTitle(int code);
void HDAE5000_SongScreen_Refresh(unsigned char page, unsigned char skip);
extern void SongScrRefresh_w(int page, int skip);       /* = HDAE5000_SongScreen_Refresh, for the callers (WA, BC) */
extern void HDAE5000_FlsScreen_Refresh(int page, int skip);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_FlsList_BuildPage(void);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_DelOpt_InitFromSong(unsigned int dir, unsigned int song, int all);
extern char *HDAE5000_NameHistory_Recall(unsigned char *hist);
extern int HDAE5000_DirName_StoreWithUi(unsigned int dir, char *name, long obj);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_TypeSel_ShowSaveFlags(void);
/* stacked parameters in V4.23's left-to-right order: the ROM pushes name, ui, obj (Save) / ui, obj (Load) */
extern int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, char *name, int ui, long obj);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int ui, long obj);
extern void HDAE5000_HardTest_HddIdRead(void);
extern void HDAE5000_HardTest_Print(char *line);
extern int HDAE5000_FormatDialog_CodeDigit(int digit);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
/* DirName_Address as char *: StrNCat takes it with no conversion (the ROM pushes the count before the call).
   SongRecord_Address: the ROM calls it before pushing MemCopy's count, so its result is a local (XHL) assigned in a
   statement of its own (r20's nested call was evaluated after the count push) */
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteDirectory(unsigned int dir, int ui, int keep);
extern void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);
extern int HDAE5000_HD_FormatDrive(int ui);
extern int HDAE5000_HD_StoreSettings(int keep);
extern unsigned char HDAE5000_Get_Init_Flag(void);

/* ---- RAM ---- */
struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern long ram_23a09a;                          /* HDAE5000_RAM_Browser_State + 12: the screen to show next */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern unsigned char HDAE5000_RAM_LyricJump;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_FlsSeqStopPending;
extern char HDAE5000_RAM_TitleInfoText[];
extern char HDAE5000_RAM_FlsListText[];
extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_PcLinkStatusText[];
extern char HDAE5000_RAM_SongScreenTitle[];
extern char HDAE5000_RAM_SongListText[];
extern char HDAE5000_RAM_NameEditBuffer[];       /* 0x23a06e */
extern char ram_23a04e[];                        /* HDAE5000_RAM_Name_ColumnRuler (a .set, not resolvable) */
extern unsigned char HDAE5000_RAM_DirNameHistory[];
extern unsigned char ram_22ac7e[];               /* the song-name history (NameHistory_Recall layout) */
extern unsigned char ram_22ad9c[];               /* format-code dialog: count, pad, HDAE5000_RAM_FormatCodeDigits */

/* ---- ROM ---- */
extern char HDAE5000_Str_STATUS[];
extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_DIRECTORY[];
extern char ram_2e2512[];   /* HDAE5000_Str_Chr3A_SongScreen_Refresh (pushed as a constant: the listing's 31-char
                               name is not translated) */
extern char HDAE5000_Str_Blank0Tab[];
extern char HDAE5000_Str_Chr3A2020202020[];
extern char HDAE5000_Str_DELD[];
extern char HDAE5000_Str_DELF[];
extern char HDAE5000_Str_UTIL[];
extern char HDAE5000_Str_SVOP[];
extern char HDAE5000_Str_FMT[];
extern char HDAE5000_Str_LBN[];
extern char ram_2e250c[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh, "%2.2d" */
extern char ram_2e2534[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh_2 */
/* unsigned long: the ROM evaluates ObjIds[page] before the other arguments (`ld xde,(xbc+wa)` ahead of the text
   address; before PartList_Build's stack push), the order of a converted argument; passed as (long) / to long obj */
extern unsigned long ram_2e24e8[];   /* HDAE5000_SongScreen_Refresh_ObjIds */
extern unsigned long ram_2e24f0[];   /* HDAE5000_SongScreen_Refresh_ObjIds_2 */
extern unsigned long ram_2e24f8[];   /* HDAE5000_SongScreen_Refresh_ObjIds_3 */
extern long HDAE5000_HDAETitleFunc_ObjIds[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];
extern char HDAE5000_Str_LSWFileInfo[], HDAE5000_Str_SDAFileInfo[], HDAE5000_Str_PMTFileInfo[];
extern char HDAE5000_Str_SQFFileInfo[], HDAE5000_Str_SEQFileInfo[], HDAE5000_Str_CMPFileInfo[];
extern char HDAE5000_Str_TMFileInfo[], HDAE5000_Str_MSPFileInfo[], HDAE5000_Str_RCMFileInfo[];
extern char HDAE5000_Str_MDFileInfo[];
extern char HDAE5000_Str_Adr[], HDAE5000_Str_Size[], HDAE5000_Str_Adr_HDD_UTIL_PAGE[];
extern char ram_2e25b4[];   /* HDAE5000_Str_Size_HDD_UTIL_PAGE (its 31 characters are the _2.._9 names' prefix) */
extern char ram_2e25d6[], ram_2e25de[];   /* HDAE5000_Str_Adr_HDD_UTIL_PAGE_2, HDAE5000_Str_Size_HDD_UTIL_PAGE_2 */
extern char ram_2e2600[], ram_2e2608[];   /* _3 */
extern char ram_2e262a[], ram_2e2632[];   /* _4 */
extern char ram_2e2654[], ram_2e265c[];   /* _5 */
extern char ram_2e267c[], ram_2e2684[];   /* _6 */
extern char ram_2e26a6[], ram_2e26ae[];   /* _7 */
extern char ram_2e26d0[], ram_2e26d8[];   /* _8 */
extern char ram_2e26f8[], ram_2e2700[];   /* _9 */

/* an array read as an lvalue member at offset 0: `lda xwa,(sym); ld xde,xwa` (hd_r9_b2.c, TitleInfo_Build) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

/* NAKA_APFUNC_HDD_DIRNAMECheck (hdae5000_ui_tree.s, not in hdae_ids.h) */
#define APFUNC_HDD_DIRNAMECHECK 0x012a0002L

/* the main CPU's FAT driver's find block: the name at +6 */
struct FindBlk { char head[6]; char name[260]; };

/* ------------------------------------------------------------------------------------------------------------- */

/* r23: label / h / n assigned in their conditions (the ROM compares copies: `ld xwa,xiz; or xwa,xwa`,
   `ld xwa,xiz; cp xwa,0`, `ld wa,hl; cp wa,0xffff`).  n stays in HL (no call in its life).
   - line1[n]: the ROM adds the member offset to a 16-bit index (`ld wa,hl; add wa,0x100; lda xbc,(FdList);
     ld (xbc+wa),1`); V4.23 does that for an index EXPRESSION (r20's rows[i*12+10]), while a plain variable index
     folds the offset into the base (`lda xwa,(line1); ld (xwa+hl),1`): n is unsigned and indexed as (int)n, a
     conversion node with no code of its own and no extz (a signed index).
   - the row address: the product on the LEFT of the integer sum (the ROM: `muls wa,12; lda xbc,(rows+3);
     exts xwa; add xwa,xbc`: product evaluated, base loaded, then the product extended; r20's base + product loaded
     the product first and moved it to BC).
   - the loop: the ROM extends i first and adds the member offset in 32 bits, then adds the struct's address as an
     immediate (`extz xwa; add xwa,0x114; ld xbc,FdList; add xbc,xwa; cp (xbc),1`), as for a 32-bit index;
     V4.23 gave `extz xwa; add wa,0x114; lda xbc,(FdList); cp (xbc+wa),1` for an unsigned int index.  Written
     with an unsigned long index.  (Form b: the same through pointer arithmetic, *(member + index).) */
int HDAE5000_FdList_Scan(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    unsigned int n;
    unsigned int i;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                HDAE5000_RAM_FdList.line1[(int)n] = 1;
                HDAE5000_MemCopy((void *)((int)n * 12 + (unsigned long)&HDAE5000_RAM_FdList.rows[3]),
                                 &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                    HDAE5000_RAM_FdList.line1[(int)n] = 1;
                    HDAE5000_MemCopy((void *)((int)n * 12 + (unsigned long)&HDAE5000_RAM_FdList.rows[3]),
                                     &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            HDAE5000_RAM_FdList.rows[(unsigned long)(i * 12 + 10)] = ' ';
            if (HDAE5000_RAM_FdList.line2[(unsigned long)i] == 1)
                HDAE5000_RAM_FdList.rows[(unsigned long)(i * 12 + 10)] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

/* r23: not checked in run 95 (Browser_State unresolvable); now ram_23a09a, and the inner switch unsigned */
long HDAE5000_HDAETitleFunc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ACTIVATE_STATE:
        switch ((unsigned long)arg) {     /* r23: the ROM's bound checks are unsigned (`dec 2; cp 0; jrl c`) */
        case 2:
            HDAE5000_RAM_TitleInfoText[150] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_TitleInfoText));
            SongScrRefresh_w(0, 0);
            HDAE5000_RAM_FlsListText[1920] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
            HDAE5000_FlsScreen_Refresh(0, 2);
            HDAE5000_RAM_DirListText[504] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            HDAE5000_FlsList_BuildPage();
            HDAE5000_Lbn_ShowEntry(0, 0, 6, 0);
            HDAE5000_MemCopy(HDAE5000_RAM_PcLinkStatusText, HDAE5000_Str_STATUS, 0x21);
            CALLV(ROOT->ApPostEvent)(OBJ_PP_STATUS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_PcLinkStatusText));
            ram_23a09a = OBJ_HDDMENU;
            if (HDAE5000_RAM_FlsAutoLoadPending == 1 && HDAE5000_RAM_FlsSeqStopPending == 1)
                ram_23a09a = OBJ_FLS_FILE_LOAD;
            break;
        case 9:
            switch (HDAE5000_RAM_QuickLoadMode) {
            case 1:
                ram_23a09a = OBJ_SELECT_FILE;
                break;
            case 2:
                ram_23a09a = OBJ_LOAD_BY_NUM;
                break;
            case 3:
                ram_23a09a = OBJ_FLS_FILE_LOAD;
                break;
            }
            break;
        case 8:
            CALLV(ROOT->ApPostEvent)(ram_23a09a, EVT_SHOW, 0L);
            CALLV(ROOT->ApPostEvent)(-1L, EVT_INDEXSW_DOWN, 0L);
            if (HDAE5000_RAM_FlsAutoLoadPending == 1 && HDAE5000_RAM_FlsSeqStopPending == 1) {
                HDAE5000_RAM_FlsSeqStopPending = 0;
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP, 0L);
            }
            break;
        case 6:
            ram_23a09a = HDAE5000_HDAETitleFunc_ObjIds[HDAE5000_Get_Init_Flag()];
        }
    }
    return 0;
}

long HDAE5000_SEL_DIR_Screen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_DirPageBase = 0;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 1:
            HDAE5000_RAM_DirPageBase = 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 5:
            HDAE5000_RAM_DirPageBase = 48;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 6:
            HDAE5000_RAM_DirPageBase = 72;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 7:
            HDAE5000_RAM_DirPageBase = 96;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
    case EVT_HDAE_SELECT_OK2:
        /* r23: the int base is converted to unsigned, so V4.23 loads it first (`ld bc,(base); ld wa,iz;
           add wa,bc`), as the ROM; r20's (int)arg + base added it as a memory operand */
        HDAE5000_RAM_CurDir = (unsigned int)arg + HDAE5000_RAM_DirPageBase;
        SongScrRefresh_w(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_HDD_DIRNAMECHECK, EVT_SET_STRING,
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir =
                                                             (unsigned int)arg + HDAE5000_RAM_DirPageBase));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_DIR_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_DirPageBase >= 24) {
            HDAE5000_RAM_DirPageBase -= 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_DirPageBase < 96) {
            HDAE5000_RAM_DirPageBase += 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}

/* page: which of the three object sets (ObjIds tables); skip != 0: only the part list.  The ROM takes the two
   parameters as bytes (A, C) and keeps them in stack slots (`ld (xsp+24),c; ld (xsp+26),a`): r23 declares them
   unsigned char (r20's drvb form, whose prologue matched); the callers use SongScrRefresh_w.
   r23 also: ObjIds unsigned long (see the declaration); the row address with the product on the left (the ROM loads
   the base after the product and extends the product last); the song record a local assigned before the MemCopy
   (the ROM calls SongRecord_Address before pushing the count and pushes XHL); the ":" string as ram_2e2512.
   Open: `ld wa,30; muls xwa,iz` (V4.23 writes `ld wa,iz; muls wa,30`). */
void HDAE5000_SongScreen_Refresh(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2e2512);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy((void *)(30 * i + (unsigned long)&HDAE5000_RAM_SongListText[2]),
                             HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy((void *)(30 * i + (unsigned long)&HDAE5000_RAM_SongListText[0]), buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy((void *)(30 * i + (unsigned long)&HDAE5000_RAM_SongListText[3]), rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

long HDAE5000_AttenDelDirSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_DELD);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0:
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_WAIT_DEL_DIR, EVT_SHOW, 3L);
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_DeleteDirectory(HDAE5000_RAM_CurDir, 1, 0);
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            SongScrRefresh_w(0, 0);
            CALLV(ROOT->PostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
        }
        return 0;
    }
}

/* r23: run 95's only departure was DeleteSongParts' two stacked flags (the ROM pushes 1, then 0) */
long HDAE5000_AttenDelFileSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_DELF);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0:
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_WAIT_DEL_FILE, EVT_SHOW, 3L);
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_DeleteSongParts(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_DeleteOptions.mask, 1, 0);
            HDAE5000_DelOpt_InitFromSong(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, 1);
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            SongScrRefresh_w(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_FILE_DEL_SCREEN, EVT_SHOW, 0L);
        }
        return 0;
    }
}

/* r23: not checked in run 95 (Name_ColumnRuler unresolvable).  Read against the ROM: p assigned in its condition,
   SaveSongWithUi's stacked arguments in the ROM's push order (name, 1, obj) */
long HDAE5000_HDDNamingCheck(long obj, long ev, long arg)
{
    char *p;
    unsigned int m;

    switch (ev) {
    case EVT_GET_STRING:
        HDAE5000_StrNCpy((char *)arg, ram_23a04e, 26);
        return obj;
    case EVT_SET_STRING:
        HDAE5000_StrNCpy(ram_23a04e, (char *)arg, 26);
        return obj;
    case EVT_GET_NAMING_MODE:
        return 0;
    case EVT_GET_STRING_LENGTH:
        return 26;
    case EVT_SW_IN:
        switch (arg) {
        case 0x8a:
            if ((p = HDAE5000_NameHistory_Recall(ram_22ac7e)) != 0) {     /* r23: the ROM tests a copy */
                HDAE5000_MemCopy(ram_23a04e, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_SET_STRING, WRAP(ram_23a04e));
            }
            break;
        case 0x0a:
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) == 0xffff)
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
            else
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateAllNo, 2);
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23a04e));
            CALLV(ROOT->PostEvent)(OBJ_SAVE_OPT_SCREEN, EVT_SHOW, 0L);
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23a04e));
            if (HDAE5000_RAM_WriteConfirm == 1 && HDAE5000_Song_IsUsed(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong) != -1)
                CALLV(ROOT->PostEvent)(OBJ_ATTEN_OVER_FILE, EVT_SHOW, 0L);
            else
                HDAE5000_SaveSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        ram_23a04e, 1, OBJ_SELECT_FILE);
            SongScrRefresh_w(0, 0);
            break;
        }
        break;
    }
    return 0;
}

long HDAE5000_HDD_DIRNAMECheck(long obj, long ev, long arg)
{
    char *p;

    switch (ev) {
    case EVT_GET_STRING:
        HDAE5000_StrNCpy((char *)arg, HDAE5000_RAM_NameEditBuffer, 16);
        return obj;
    case EVT_SET_STRING:
        HDAE5000_StrNCpy(HDAE5000_RAM_NameEditBuffer, (char *)arg, 16);
        HDAE5000_RAM_NameEditBuffer[16] = 0;
        return obj;
    case EVT_GET_NAMING_MODE:
        return 0;
    case EVT_GET_STRING_LENGTH:
        return 16;
    case EVT_SW_IN:
        switch (arg) {
        case 0x8a:
            /* r23: as the matched CP_FD_DIRNAMECheck (run 95's only departure: `or xiz,xiz` for the ROM's
               `ld xwa,xiz; or xwa,xwa`) */
            if ((p = HDAE5000_NameHistory_Recall(HDAE5000_RAM_DirNameHistory)) != 0) {
                HDAE5000_MemCopy(HDAE5000_RAM_NameEditBuffer, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_SET_STRING,
                                       (long)HDAE5000_RAM_NameEditBuffer);
            }
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_GET_STRING,
                                   (long)HDAE5000_RAM_NameEditBuffer);
            HDAE5000_DirName_StoreWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_NameEditBuffer, OBJ_SELECT_DIR);
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        }
        break;
    }
    return 0;
}

long HDAE5000_HDD_UTIL_PAGE(long obj, long ev, long arg)
{
    char line[64];
    char num[32];
    struct { unsigned long addr; unsigned long size; } info;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_UTIL);
        return 0;
    case EVT_SW_IN:
        if (arg == 0x0b) {
            HDAE5000_HardTest_HddIdRead();

            CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_LSWFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Size);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SDAFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr_HDD_UTIL_PAGE);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e25b4);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_PMTFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e25d6);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e25de);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SQFFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2600);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2608);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(4, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SEQFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e262a);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2632);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_CMPFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2654);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e265c);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_TMFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e267c);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2684);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_MSPFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26a6);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26ae);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_RCMFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26d0);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26d8);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_MDFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26f8);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2700);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* r23: not checked in run 95 (Name_ColumnRuler unresolvable); read against the ROM, only SaveSongWithUi's
   stacked arguments change */
long HDAE5000_SaveOptSwEventCatch(long obj, long ev, long arg)
{
    unsigned int m;

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
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23a04e));
            if (HDAE5000_RAM_WriteConfirm == 1 && HDAE5000_Song_IsUsed(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong) != -1)
                CALLV(ROOT->PostEvent)(OBJ_ATTEN_OVER_FILE, EVT_SHOW, 0L);
            else
                HDAE5000_SaveSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        ram_23a04e, 1, OBJ_SELECT_FILE);
            SongScrRefresh_w(0, 0);
            break;
        case 9:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x0a:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x1ff, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x0b:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x8b:
            m = HDAE5000_RAM_SaveOptions.mask;
            if ((m & 0x100) == 0x100)
                m -= 0x100;
            else
                m += 0x100;
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        }
        return 0;
    }
}

/* r23 (run 95 departed at +1):
   - the ROM keeps arg in XIZ and res in a stack word (`dec 6,xsp; push xiz; ld xiz,xde`, `ldw (xsp+4),0`); V4.23 gave
     res IZ and arg a slot.  arg is declared `register` (served first, as FlsItemSetAS_u's item);
   - the edit-switch number is compared unsigned (`cp xwa,7; jrl ugt`, no lower bound): CALLR(unsigned long, ..);
   - the digit: the ROM branches and loads WA (`bit 7,iz; jr z; ld wa,0; jr; ld wa,1; calr`); V4.23 compiled the
     ternary as a byte select (`ld c,1; ..; bit 7,wa; jr z; ld c,0; ld a,c; exts wa`).  Written as if / else into a
     local that dies at the call (form b keeps the ternary with the register arg);
   - the timers' stacked arguments reversed (V4.23 pushes left to right). */
long HDAE5000_AttenHDFormatSwCatch(long obj, long ev, register long arg)
{
    int res;
    int d;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_FMT);
        return 0;
    case EVT_SW_IN:
        res = 0;
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            if (arg & 0x80)
                d = 0;
            else
                d = 1;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 1:
            if (arg & 0x80)
                d = 2;
            else
                d = 3;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 2:
            if (arg & 0x80)
                d = 4;
            else
                d = 5;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 3:
            if (arg & 0x80)
                d = 6;
            else
                d = 7;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 4:
            if (arg & 0x80)
                d = 8;
            else
                d = 9;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 6:
        case 7:
            HDAE5000_MemFill(ram_22ad9c, 0, 10);
            CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
        }
        switch (res) {
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_AGAIN_HD_FORMAT, EVT_SHOW, 3L);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_AGAIN_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_AGAIN_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            break;
        case 2:
            CALLV(ROOT->SendEvent)(OBJ_WAIT_HD_FORMAT, EVT_SHOW, 0L);
            HDAE5000_YieldUntilSem1Zero();
            if (HDAE5000_HD_FormatDrive(1) == 0) {
                CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
                HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
                SongScrRefresh_w(0, 0);
                HDAE5000_FlsList_BuildPage();
                HDAE5000_FlsScreen_Refresh(0, 2);
            } else {
                CALLV(ROOT->PostEvent)(OBJ_ERR_HD_FORMAT, EVT_SHOW, 3L);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            }
            break;
        case 3:
            HDAE5000_RAM_QuickLoadMode = 1;
            HDAE5000_RAM_LoadByNumberMode = 1;
            HDAE5000_RAM_JumpAfterLoad = 1;
            CALLV(ROOT->SendEvent)(OBJ_WAIT_TR0_RECOVER, EVT_SHOW, 0L);
            HDAE5000_YieldUntilSem1Zero();
            if (HDAE5000_HD_StoreSettings(0) != -1) {
                CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
            } else {
                CALLV(ROOT->PostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 3L);
                HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            }
            break;
        }
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(OBJ_ATTEN_HD_FORMAT, EVT_SHOW, 0L);
        return 0;
    }
}

/* r23: run 95's only departure in form a was LoadSongWithUi's stacked arguments (the ROM pushes 1, then the obj) */
long HDAE5000_LBNLoadSwCatch(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_SHOW:
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
        else
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
        break;
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_LBN);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 8:
        case 9:
            if (HDAE5000_RAM_LbnDigitPos == 5) {
                HDAE5000_LoadSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        1, OBJ_LOAD_BY_NUM);
                HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
                if (HDAE5000_RAM_LyricJump == 2 && (HDAE5000_RAM_SaveOptions.mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
            }
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* r in QIZ, m in IZ in the ROM.
   r23 (run 95 departed at +249): r and m assigned in their conditions (`ld wa,qiz; cp wa,0`, `ld wa,iz;
   cp wa,0xffff`); m is int: the ROM loads it early for TypeSel_Init (`ld bc,iz` before `pushw 2`) and copies it
   for PartList_Build's push (`ld wa,iz; push wa`), the order of an int converted to the unsigned mask parameter
   (r20's unsigned m was loaded late and pushed as `push iz`); LoadSongWithUi / SetApTimer stacked arguments
   reversed. */
void HDAE5000_Lbn_TypeDigit(long obj, unsigned int digit)
{
    int r;
    int m;

    r = 0;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        HDAE5000_RAM_LbnDir = digit * 100;
        HDAE5000_RAM_LbnSong = 0;
        HDAE5000_RAM_LbnDigitPos = 1;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 1:
        HDAE5000_RAM_LbnDir += digit * 10;
        HDAE5000_RAM_LbnDigitPos = 2;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 2:
        HDAE5000_RAM_LbnDir += digit;
        HDAE5000_RAM_LbnDigitPos = 3;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 3:
        HDAE5000_RAM_LbnSong = digit * 10;
        HDAE5000_RAM_LbnDigitPos = 4;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 4:
        HDAE5000_RAM_LbnSong += digit;
        HDAE5000_RAM_LbnDigitPos = 5;
        if ((r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1))
                == 0) {
            HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
            HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
                HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
            } else {
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
                HDAE5000_PartList_Build(OBJ_LBN_OPTION, 0xffff, 0xffff, 0xffff);
            }
            if (HDAE5000_RAM_LoadByNumberMode == 2) {
                HDAE5000_LoadSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        1, OBJ_LOAD_BY_NUM);
                HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
                if (HDAE5000_RAM_LyricJump == 2 && (HDAE5000_RAM_SaveOptions.mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
            }
        }
    }
    switch (r) {
    case -1:
        CALLV(ROOT->PostEvent)(OBJ_DIR_OUT_RANGE, EVT_SHOW, 5L);
        CALLV(ROOT->SetApTimer)(0x21L, OBJ_DIR_OUT_RANGE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_LOAD_BY_NUM);
        break;
    case -2:
        CALLV(ROOT->PostEvent)(OBJ_FILE_OUT_RANGE, EVT_SHOW, 5L);
        CALLV(ROOT->SetApTimer)(0x21L, OBJ_FILE_OUT_RANGE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_LOAD_BY_NUM);
    }
}
