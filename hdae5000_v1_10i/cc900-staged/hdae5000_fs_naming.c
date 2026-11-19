/* hdae5000_v1_10i: the functions of hdae5000/cc900/hdae5000_fs_naming.c that V4.23 reproduces in HD-AE5000 v1.10i with the tree's own object ids (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fs_naming.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

#define APFUNC_FlsNamingCheck 0x012a0017L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */
#define APFUNC_CP_FD_DIRNAMECheck 0x012a0019L   /* NAKA_APFUNC_CP_FD_DIRNAMECheck */

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
/* +0 title, +14 the 20 rows of 12, +0x100 present flags, +0x114 selected flags */
struct FdList { char label[14]; char rows[20][12]; char pad[2]; unsigned char present[20]; unsigned char sel[20]; };
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
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, struct FlsItem *out);
extern unsigned int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);
extern unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item);
extern int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item);
extern int HDAE5000_FlsItem_SetDir(unsigned int fls, unsigned int item, int dir);
extern int HDAE5000_FlsItem_SetSong(unsigned int fls, unsigned int item, int song);
extern void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, int on);
extern void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, int on);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Dir_IsBlankName(unsigned int dir);
extern unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls);
extern unsigned int HDAE5000_Dir_CountEmptySongs(unsigned int dir);
extern unsigned int HDAE5000_HD_StoreTables(int keep);   /* unsigned: the ROM compares HL with 0xffff unconverted */
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, int a, int b,
                                            unsigned int mask);

/* this module (calr, cc900-module) */
extern void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask);
extern char *HDAE5000_NameHistory_Recall(unsigned char *history);
extern void HDAE5000_FlsName_StoreWithUi(unsigned int fls, char *name, long obj);
extern void HDAE5000_DirName_StoreWithUi(unsigned int dir, char *name, long obj);
extern void HDAE5000_FlsList_BuildPage(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_SongScreen_Refresh(int variant, int mode);     /* old-style, char parameters */
extern void HDAE5000_YieldUntilSem1Zero(void);
extern unsigned int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, long obj, int flag);
extern unsigned int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, long obj, int flag,
                                            char *name);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern void HDAE5000_TypeSel_Init(struct TypeSel *rec, unsigned int mask, struct TypeSel *tmpl, int flag);
extern void HDAE5000_DelOpt_ShowFlags(void);
extern unsigned int HDAE5000_Count_Active_Files(void);
void HDAE5000_FlsScreen_Refresh(int variant, int mode);
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
extern char ram_22aa68[], ram_22aa7a[], ram_22aa80[];   /* LbnEntryText + 6 / + 0x18 / + 0x1e */
extern char HDAE5000_RAM_NameEditBuffer[];
extern char ram_23a04e[];                               /* HDAE5000_RAM_Name_ColumnRuler */
extern unsigned char HDAE5000_RAM_FlsNameHistory[];
extern unsigned char HDAE5000_RAM_DirNameHistory[];
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern struct FdList HDAE5000_RAM_FdList;
extern char ram_22a058[];                               /* the FLS screen's title text */
extern char ram_22a078[];                               /* its LOC text */
extern char ram_22b020[];                               /* its 16 item rows of 37 */

/* ROM */
extern struct TypeSel HDAE5000_TypeSel_TemplateBlank;
extern struct TypeSel HDAE5000_DelOpt_TemplateBlank;
extern char HDAE5000_Str_Wrcn[];
extern char HDAE5000_Str_OVWR[];
extern char HDAE5000_Str_DEL_DelOptSwEventCatch[];
extern char HDAE5000_Str_Blank3Tab[];
extern char HDAE5000_Str_Blank16Tab[];
extern char HDAE5000_Str_Blank3Tab_Lbn_ShowEntry[];
extern char HDAE5000_Str_Blank26Tab[];
extern char HDAE5000_Fmt_1_1d[];
extern char ram_2e2d2a[];                               /* HDAE5000_Fmt_2_2d_Lbn_ShowEntry */
extern char HDAE5000_Fmt_3_3d_Lbn_ShowEntry[];
extern char HDAE5000_Fmt_1_1d_Lbn_ShowEntry[];
extern char ram_2e2d3e[];                               /* HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2 */
extern long ram_2e2e7c[], ram_2e2e84[], ram_2e2e8c[], ram_2e2e94[], ram_2e2e9c[], ram_2e2ea4[];
                                                        /* HDAE5000_FlsScreen_Refresh_ObjIds .. _ObjIds_6 */
extern char HDAE5000_Str_FLSNAME[];
extern char ram_2e2eb6[];                               /* HDAE5000_Fmt_2_2d_FlsScreen_Refresh */
extern char HDAE5000_Str_Chr3A_FlsScreen_Refresh[];
extern char HDAE5000_Str_Blank0Tab_FlsScreen_Refresh[];
extern char HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh[];
extern char ram_2e2ee4[];                               /* HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2 */
extern char HDAE5000_Fmt_LOC_3_3d_2_2d[];
extern char HDAE5000_Str_LOC00000[];
extern char HDAE5000_Fmt_2_2d_CopyToHd_Execute[];
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[], HDAE5000_Str_TLX[];

/* the load-by-number entry: digit position pos 0..6 (no digit, directory hundreds / tens / units, song tens /
   units, reset); direct = 1 sends to the objects, else posts; returns 0, -1 (bad directory) or -2 (bad song) */

/* the FLS naming window's check procedure (the FLS select screen) */
long HDAE5000_FlsNamingCheck(long obj, long ev, long arg)
{
    char *p;

    switch (ev) {
    default:
        return 0;
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
            if ((p = HDAE5000_NameHistory_Recall(HDAE5000_RAM_FlsNameHistory)) != 0) {
                HDAE5000_MemCopy(HDAE5000_RAM_NameEditBuffer, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_SET_STRING,
                                       WRAP(HDAE5000_RAM_NameEditBuffer));
            }
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_GET_STRING,
                                   WRAP(HDAE5000_RAM_NameEditBuffer));
            HDAE5000_FlsName_StoreWithUi(HDAE5000_RAM_CurFls, HDAE5000_RAM_NameEditBuffer, OBJ_FLS_SELECT);
            HDAE5000_FlsList_BuildPage();
            break;
        }
        return 0;
    }
}

/* the same for the FLS edit screen */
long HDAE5000_FlsNamingCheck2(long obj, long ev, long arg)
{
    char *p;

    switch (ev) {
    default:
        return 0;
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
            if ((p = HDAE5000_NameHistory_Recall(HDAE5000_RAM_FlsNameHistory)) != 0) {
                HDAE5000_MemCopy(HDAE5000_RAM_NameEditBuffer, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_SET_STRING,
                                       WRAP(HDAE5000_RAM_NameEditBuffer));
            }
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_GET_STRING,
                                   WRAP(HDAE5000_RAM_NameEditBuffer));
            HDAE5000_FlsName_StoreWithUi(HDAE5000_RAM_CurFls, HDAE5000_RAM_NameEditBuffer, OBJ_FLS_EDIT);
            HDAE5000_FlsScreen_Refresh(1, 2);
            break;
        }
        return 0;
    }
}

/* the FLS screen: title "FLS NAME NN:<name>", the 16 items of the page, the selected item's LOC and part list;
   variant picks the object ids (0 load screen, 1 edit screen); mode 0 or 2 redraws title and items, 2 skips the
   two lines at the end */

/* the FLS select screen (list of 120 FLS, pages of 24) */

/* the FLS load screen: its 32 items (pages of 16); AL items chain the next load (EVT_HDAE_AFTER_LOAD) */

/* the FLS edit screen */

/* the FLS item's directory selection */

/* the FLS item's song selection */

/* the "overwrite the FLS item?" switch */

/* copy the floppy songs selected in the copy screen's list (FdList.sel) into free songs of directory dir;
   sel (XWA) is not read: the list is HDAE5000_RAM_FdList itself */

/* the copy-to-HD screen's directory selection */

/* the copy-to-HD directory naming window's check procedure */
long HDAE5000_CP_FD_DIRNAMECheck(long obj, long ev, long arg)
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
            if ((p = HDAE5000_NameHistory_Recall(HDAE5000_RAM_DirNameHistory)) != 0) {
                HDAE5000_MemCopy(HDAE5000_RAM_NameEditBuffer, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_SET_STRING,
                                       WRAP(HDAE5000_RAM_NameEditBuffer));
            }
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_GET_STRING,
                                   WRAP(HDAE5000_RAM_NameEditBuffer));
            HDAE5000_DirName_StoreWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_NameEditBuffer, OBJ_CP_FD_DIRSEL);
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        }
    }
    return 0;
}

/* the "write confirm" switch: keys 0 / 1 save the song under the typed name, 6 / 7 go back */

/* the delete-option switches: 8 asks to delete, 10 / 11 reset the delete options from the song's parts */
