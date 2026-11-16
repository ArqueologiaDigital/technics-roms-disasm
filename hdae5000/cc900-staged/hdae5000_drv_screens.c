/* Screens and switch catches of hdae5000_hd_driver.s: the functions of helper h_drv's C that match (module-local calls in cc900-module).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r20_drva.c.
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
void HDAE5000_SongScreen_Refresh(int page_arg, int skip_arg);
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
extern int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, long obj, int ui, char *name);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, long obj, int ui);
extern void HDAE5000_HardTest_HddIdRead(void);
extern void HDAE5000_HardTest_Print(char *line);
extern int HDAE5000_FormatDialog_CodeDigit(int digit);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
/* DirName_Address as char *: StrNCat takes it with no conversion (the ROM pushes the count before the call);
   SongRecord_Address as unsigned char *, int song: MemCopy's const void * and the int index are conversions, which
   is why the ROM calls it before pushing the count and loads BC (the index) before WA */
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteDirectory(unsigned int dir, int ui, int keep);
extern void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int keep, int sleep);
extern int HDAE5000_HD_FormatDrive(int ui);
extern int HDAE5000_HD_StoreSettings(int keep);
extern unsigned char HDAE5000_Get_Init_Flag(void);

/* ---- RAM ---- */
struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
struct BrowserState { char pad[12]; long next; };
extern struct FdList HDAE5000_RAM_FdList;
extern struct BrowserState HDAE5000_RAM_Browser_State;
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
extern char HDAE5000_RAM_Name_ColumnRuler[];     /* 0x23a04e */
extern unsigned char HDAE5000_RAM_DirNameHistory[];
extern unsigned char ram_22ac7e[];               /* the song-name history (NameHistory_Recall layout) */
extern unsigned char ram_22ad9c[];               /* format-code dialog: count, pad, HDAE5000_RAM_FormatCodeDigits */

/* ---- ROM ---- */
extern char HDAE5000_Str_STATUS[];
extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_DIRECTORY[];
extern char HDAE5000_Str_Chr3A_SongScreen_Refresh[];
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
extern long ram_2e24e8[];   /* HDAE5000_SongScreen_Refresh_ObjIds */
extern long ram_2e24f0[];   /* HDAE5000_SongScreen_Refresh_ObjIds_2 */
extern long ram_2e24f8[];   /* HDAE5000_SongScreen_Refresh_ObjIds_3 */
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

/* page: which of the three object sets (ObjIds tables); skip != 0: only the part list.  The ROM takes the two
   parameters as bytes (A, C) while every caller loads WA, BC: int parameters stored to char locals. */

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
            HDAE5000_SongScreen_Refresh(0, 0);
            CALLV(ROOT->PostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
        }
        return 0;
    }
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

/* r in QIZ, m in IZ in the ROM */
