/* Functions of hdae5000_hd_driver.s.  (hdae5000_drv_screens6.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_drv_screens6.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_FlsScreen_Refresh HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsList_BuildPage HDAE5000_Lbn_ShowEntry HDAE5000_PartList_Build
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_DelOpt_InitFromSong HDAE5000_NameHistory_Recall
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_TypeSel_Init HDAE5000_TypeSel_ShowSaveFlags
   cc900-module: HDAE5000_SaveSongWithUi HDAE5000_LoadSongWithUi HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_HardTest_Print HDAE5000_FormatDialog_CodeDigit HDAE5000_UiObj_SetCaption
   cc900-data: HDAE5000_HDAETitleFunc 1 = HDAE5000_HDAETitleFunc_CaseTable
   cc900-data: HDAE5000_AttenHDFormatSwCatch 1 = HDAE5000_AttenHDFormatSwCatch_CaseTable
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
/* the callers load WA / BC: they call the label through an int prototype; the definition, with the ROM's
   unsigned char parameters, is SongScrRefresh_c (cc900-name, same label) */
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
void SongScrRefresh_c(unsigned char page, unsigned char skip);
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
extern long ram_23d2d2;                          /* HDAE5000_RAM_Browser_State + 12: the screen to show next */
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
extern unsigned char ram_22ac36[];               /* the song-name history (NameHistory_Recall layout) */
extern unsigned char ram_22ad54[];               /* format-code dialog: count, pad, HDAE5000_RAM_FormatCodeDigits */

/* ---- ROM ---- */
extern char HDAE5000_Str_STATUS[];
extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_DIRECTORY[];
extern char ram_2cab20[];   /* HDAE5000_Str_Chr3A_SongScreen_Refresh (pushed as a constant: the listing's 31-char
                               name is not translated) */
extern char HDAE5000_Str_Blank0Tab[];
extern char HDAE5000_Str_Chr3A2020202020[];
extern char HDAE5000_Str_DELD[];
extern char HDAE5000_Str_DELF[];
extern char HDAE5000_Str_UTIL[];
extern char HDAE5000_Str_SVOP[];
extern char HDAE5000_Str_FMT[];
extern char HDAE5000_Str_LBN[];
extern char ram_2cab1a[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh, "%2.2d" */
extern char ram_2cab42[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh_2 */
/* unsigned long: the ROM evaluates ObjIds[page] before the other arguments (`ld xde,(xbc+wa)` ahead of the text
   address; before PartList_Build's stack push), the order of a converted argument; passed as (long) / to long obj */
extern unsigned long ram_2caaf6[];   /* HDAE5000_SongScreen_Refresh_ObjIds */
extern unsigned long ram_2caafe[];   /* HDAE5000_SongScreen_Refresh_ObjIds_2 */
extern unsigned long ram_2cab06[];   /* HDAE5000_SongScreen_Refresh_ObjIds_3 */
extern long HDAE5000_HDAETitleFunc_ObjIds[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];
extern char HDAE5000_Str_LSWFileInfo[], HDAE5000_Str_SDAFileInfo[], HDAE5000_Str_PMTFileInfo[];
extern char HDAE5000_Str_SQFFileInfo[], HDAE5000_Str_SEQFileInfo[], HDAE5000_Str_CMPFileInfo[];
extern char HDAE5000_Str_TMFileInfo[], HDAE5000_Str_MSPFileInfo[], HDAE5000_Str_RCMFileInfo[];
extern char HDAE5000_Str_MDFileInfo[];
extern char HDAE5000_Str_Adr[], HDAE5000_Str_Size[], HDAE5000_Str_Adr_HDD_UTIL_PAGE[];
extern char ram_2cac14[];   /* HDAE5000_Str_Size_HDD_UTIL_PAGE (its 31 characters are the _2.._9 names' prefix) */
extern char ram_2cac36[], ram_2cac3e[];   /* HDAE5000_Str_Adr_HDD_UTIL_PAGE_2, HDAE5000_Str_Size_HDD_UTIL_PAGE_2 */
extern char ram_2cac60[], ram_2cac68[];   /* _3 */
extern char ram_2cac8a[], ram_2cac92[];   /* _4 */
extern char ram_2cacb4[], ram_2cacbc[];   /* _5 */
extern char ram_2cacdc[], ram_2cace4[];   /* _6 */
extern char ram_2cad06[], ram_2cad0e[];   /* _7 */
extern char ram_2cad30[], ram_2cad38[];   /* _8 */
extern char ram_2cad58[], ram_2cad60[];   /* _9 */

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

/* r23: not checked in run 95 (Browser_State unresolvable); now ram_23d2d2, and the inner switch unsigned */
long HDAE5000_HDAETitleFunc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ACTIVATE_STATE:
        switch ((unsigned long)arg) {     /* r23: the ROM's bound checks are unsigned (`dec 2; cp 0; jrl c`) */
        case 2:
            HDAE5000_RAM_TitleInfoText[150] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_TitleInfoText));
            HDAE5000_SongScreen_Refresh(0, 0);
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
            ram_23d2d2 = OBJ_HDDMENU;
            if (HDAE5000_RAM_FlsAutoLoadPending == 1 && HDAE5000_RAM_FlsSeqStopPending == 1)
                ram_23d2d2 = OBJ_FLS_FILE_LOAD;
            break;
        case 9:
            switch (HDAE5000_RAM_QuickLoadMode) {
            case 1:
                ram_23d2d2 = OBJ_SELECT_FILE;
                break;
            case 2:
                ram_23d2d2 = OBJ_LOAD_BY_NUM;
                break;
            case 3:
                ram_23d2d2 = OBJ_FLS_FILE_LOAD;
                break;
            }
            break;
        case 8:
            CALLV(ROOT->ApPostEvent)(ram_23d2d2, EVT_SHOW, 0L);
            CALLV(ROOT->ApPostEvent)(-1L, EVT_INDEXSW_DOWN, 0L);
            if (HDAE5000_RAM_FlsAutoLoadPending == 1 && HDAE5000_RAM_FlsSeqStopPending == 1) {
                HDAE5000_RAM_FlsSeqStopPending = 0;
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP, 0L);
            }
            break;
        case 6:
            ram_23d2d2 = HDAE5000_HDAETitleFunc_ObjIds[HDAE5000_Get_Init_Flag()];
        /* r27: the ROM dispatches through a jump table over 2..9 whose entries for 3, 4, 5 and 7 are the
           switch's end; V4.23 wrote a compare chain for the four cases alone.  The four empty labels make the
           case set dense; placed last, with case 6 falling into them, they add no code. */
        case 3:
        case 4:
        case 5:
        case 7:
            ;
        }
    }
    return 0;
}

/* page: which of the three object sets (ObjIds tables); skip != 0: only the part list.  The ROM takes the two
   parameters as bytes (A, C) and keeps them in stack slots (`ld (xsp+24),c; ld (xsp+26),a`): r23 declares them
   unsigned char (r20's drvb form, whose prologue matched), defined as SongScrRefresh_c (cc900-name).
   r23 also: ObjIds unsigned long (see the declaration); the row address with the product on the left (the ROM loads
   the base after the product and extends the product last); the song record a local assigned before the MemCopy
   (the ROM calls SongRecord_Address before pushing the count and pushes XHL); the ":" string as ram_2cab20.
   Open: `ld wa,30; muls xwa,iz` (V4.23 writes `ld wa,iz; muls wa,30`). */

/* r23: run 95's only departure was DeleteSongParts' two stacked flags (the ROM pushes 1, then 0) */

/* r23: not checked in run 95 (Name_ColumnRuler unresolvable).  Read against the ROM: p assigned in its condition,
   SaveSongWithUi's stacked arguments in the ROM's push order (name, 1, obj) */

/* r23: not checked in run 95 (Name_ColumnRuler unresolvable); read against the ROM, only SaveSongWithUi's
   stacked arguments change */

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
            HDAE5000_MemFill(ram_22ad54, 0, 10);
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
                HDAE5000_SongScreen_Refresh(0, 0);
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

/* r in QIZ, m in IZ in the ROM.
   r23 (run 95 departed at +249): r and m assigned in their conditions (`ld wa,qiz; cp wa,0`, `ld wa,iz;
   cp wa,0xffff`); m is int: the ROM loads it early for TypeSel_Init (`ld bc,iz` before `pushw 2`) and copies it
   for PartList_Build's push (`ld wa,iz; push wa`), the order of an int converted to the unsigned mask parameter
   (r20's unsigned m was loaded late and pushed as `push iz`); LoadSongWithUi / SetApTimer stacked arguments
   reversed. */
