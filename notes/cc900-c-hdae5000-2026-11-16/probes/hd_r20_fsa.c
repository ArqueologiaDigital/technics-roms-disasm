/* lane_hd round 20, helper h_fs, form a: fifteen UI procedures of hdae5000/hdae5000_filesystem.s (v2.06i), in ROM
   address order.  They are screen / object procedures the main CPU calls with (object, event, argument): a switch on
   the event; the event catchers pass unhandled events on to RootFn_InheritedProc.  Options: -Xr.
   - HDAE5000_Lbn_ShowEntry_Reset is not a function: it is case 6 of HDAE5000_Lbn_ShowEntry (0x2870d6, one frame
     `lda xsp,(xsp-36); pushw iz`, one epilogue `retd 2`, jump table HDAE5000_Lbn_ShowEntry_CaseTable, cases
     NoDigitTyped .. SongUnitsTyped, Reset), so the whole procedure is written here (as LyricBoxProc in lyrics.c).
   - HDAE5000_FlsScreen_Refresh takes char parameters (A, C) but its callers load WA / BC: the original is an
     old-style definition.  Here it is prototype-style with int parameters and casts inside (the brief's rule while the
     build cannot parse K&R); the prologue's two stores will then be word stores (`ld (xsp+30),bc`) where the ROM has
     `ld (xsp+30),c`.  Form b has the K&R definition.
   - Several variables share one register in the ROM (V4.23's allocation follows live ranges, as GetSongInfo's ret in
     HL): obj and the recalled name in XIZ (the naming checks), i / the item result / the part mask in IZ
     (FlsScreen_Refresh), arg / fls / mask in IZ and item in QIZ (FlsLoadScreen), arg / the file count in IZ
     (CopyToHDDirSelScreen).  Written as separate variables here; form b reuses one variable where that is an option.
   - `if ((v = f()) != K)` where the ROM moves the result and compares a copy (`ld iz,hl; ld wa,iz; cp wa,K`, or
     `ld wa,hl; cp wa,K` with v in HL); a later plain test of the same variable is `cp iz,K`.
   - Unsolved idiom kept as plain C: FlsScreen_Refresh's row offset `ldw wa,37; mul xwa,iz` (hd_r13_nb.c's 21 / 30
     rows: V4.23 writes `ld wa,iz; mul wa,37`).
   ram_<hex>: RAM the tree has not named, and ROM labels whose first 31 characters are not unique
   (HDAE5000_FlsScreen_Refresh_ObjIds*, HDAE5000_Fmt_2_2d_FlsScreen_Refresh*, HDAE5000_Fmt_2_2d_Lbn_ShowEntry*).
   ram_23a04e is HDAE5000_RAM_Name_ColumnRuler (a .set in hdae5000_init_data.s, not a numeric .equ).
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
int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int direct)
{
    char s[32];
    int ret = 0;

    switch (pos) {
    case 0:
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, HDAE5000_Str_Blank3Tab, 5);
        HDAE5000_MemCopy(ram_22aa68, HDAE5000_Str_Blank16Tab, 18);
        HDAE5000_MemCopy(ram_22aa7a, HDAE5000_Str_Blank3Tab_Lbn_ShowEntry, 5);
        HDAE5000_MemCopy(ram_22aa80, HDAE5000_Str_Blank26Tab, 28);
        break;
    case 1:
        HDAE5000_SPrintf(s, HDAE5000_Fmt_1_1d, dir / 100);
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, s, HDAE5000_StrLen(s));
        break;
    case 2:
        HDAE5000_SPrintf(s, ram_2e2d2a, dir / 10);
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, s, HDAE5000_StrLen(s));
        break;
    case 3:
        HDAE5000_SPrintf(s, HDAE5000_Fmt_3_3d_Lbn_ShowEntry, dir);
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, s, HDAE5000_StrLen(s));
        if (dir != 0 && dir <= 120)
            HDAE5000_MemCopy(ram_22aa68, HDAE5000_DirName_Address(dir - 1), 16);
        else
            ret = -1;
        break;
    case 4:
        HDAE5000_SPrintf(s, HDAE5000_Fmt_1_1d_Lbn_ShowEntry, song / 10);
        HDAE5000_MemCopy(ram_22aa7a, s, HDAE5000_StrLen(s));
        break;
    case 5:
        HDAE5000_SPrintf(s, ram_2e2d3e, song);
        HDAE5000_MemCopy(ram_22aa7a, s, HDAE5000_StrLen(s));
        if (dir != 0 && dir <= 120) {
            if (song != 0 && song <= 16)
                HDAE5000_MemCopy(ram_22aa80, HDAE5000_SongRecord_Address(dir - 1, song - 1), 26);
            else
                ret = -2;
        } else
            ret = -1;
        break;
    case 6:
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, HDAE5000_Str_Blank3Tab, 5);
        HDAE5000_MemCopy(ram_22aa68, HDAE5000_Str_Blank16Tab, 18);
        HDAE5000_MemCopy(ram_22aa7a, HDAE5000_Str_Blank3Tab_Lbn_ShowEntry, 5);
        HDAE5000_MemCopy(ram_22aa80, HDAE5000_Str_Blank26Tab, 28);
        HDAE5000_RAM_LbnDir = 0;
        HDAE5000_RAM_LbnSong = 0;
        HDAE5000_RAM_LbnDigitPos = 0;
        HDAE5000_PartList_Build(OBJ_LBN_OPTION, 0xffff, 0xffff, 0xffff);
        break;
    }
    if (direct == 1) {
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_LbnEntryText));
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa68));
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNAME_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa7a));
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa80));
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENAME_BOX, EVT_PARA_DRAW, -1L);
    } else {
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_LbnEntryText));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa68));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNAME_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa7a));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa80));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENAME_BOX, EVT_PARA_DRAW, -1L);
    }
    return ret;
}

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
void HDAE5000_FlsScreen_Refresh(int variant, int mode)
{
    char s[22];
    struct FlsItem item;
    unsigned int i;
    unsigned int r;
    unsigned int mask;

    if ((unsigned char)mode == 0 || (unsigned char)mode == 2) {
        HDAE5000_MemFill(ram_22a058, 0, 0x20);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_FLSNAME);
        HDAE5000_SPrintf(s, ram_2e2eb6, HDAE5000_RAM_CurFls + 1);
        HDAE5000_StrCat(ram_22a058, s);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_Chr3A_FlsScreen_Refresh);
        HDAE5000_StrNCat(ram_22a058, (char *)HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls), 16);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_Blank0Tab_FlsScreen_Refresh);
        CALLV(ROOT->SendEvent)(ram_2e2e7c[(unsigned char)variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a058));
        CALLV(ROOT->SendEvent)(ram_2e2e7c[(unsigned char)variant], EVT_PARA_DRAW, -1L);
    }
    if ((unsigned char)mode == 0 || (unsigned char)mode == 2) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&ram_22b020[37 * i + 2], HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh, 35);
            HDAE5000_SPrintf(s, ram_2e2ee4, HDAE5000_RAM_FlsItemPageBase + i + 1);
            HDAE5000_MemCopy(&ram_22b020[37 * i], s, HDAE5000_StrLen(s));
            HDAE5000_MemCopy(&ram_22b020[37 * i + 3],
                             HDAE5000_FlsItem_SongRecord(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i), 26);
            if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i, &item) != 0xffff) {
                if (item.as == 1)
                    ram_22b020[37 * i + 32] = '*';
                if (item.al == 1)
                    ram_22b020[37 * i + 35] = '*';
            }
        }
        CALLV(ROOT->SendEvent)(ram_2e2e84[(unsigned char)variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22b020));
        CALLV(ROOT->SendEvent)(ram_2e2e84[(unsigned char)variant], EVT_PARA_DRAW, -1L);
    }
    HDAE5000_MemFill(ram_22a078, 0, 16);
    if ((r = HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &item)) != 0xffff)
        HDAE5000_SPrintf(s, HDAE5000_Fmt_LOC_3_3d_2_2d, item.dir + 1, item.song + 1);
    else
        HDAE5000_SPrintf(s, HDAE5000_Str_LOC00000);
    HDAE5000_MemCopy(ram_22a078, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)(ram_2e2e8c[(unsigned char)variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a078));
    CALLV(ROOT->SendEvent)(ram_2e2e8c[(unsigned char)variant], EVT_PARA_DRAW, -1L);
    if (r != 0xffff) {
        mask = HDAE5000_Song_PartMask(item.dir, item.song);
        HDAE5000_PartList_Build(ram_2e2e94[(unsigned char)variant], item.dir, item.song, mask);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[(unsigned char)variant], 0xffff, 0xffff, 0xffff);
    if ((unsigned char)mode != 2) {
        CALLV(ROOT->SendEvent)(ram_2e2e9c[(unsigned char)variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)(ram_2e2ea4[(unsigned char)variant], EVT_DRAW, 0L);
    }
}

/* the FLS select screen (list of 120 FLS, pages of 24) */
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
        HDAE5000_RAM_CurFls = HDAE5000_RAM_FlsPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(0, 2);
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_FlsNamingCheck, EVT_SET_STRING,
                                HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls =
                                                               HDAE5000_RAM_FlsPageBase + (unsigned int)arg));
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

/* the FLS load screen: its 32 items (pages of 16); AL items chain the next load (EVT_HDAE_AFTER_LOAD) */
long HDAE5000_FlsLoadScreen(long obj, long ev, long arg)
{
    struct FlsItem it;
    unsigned int fls;
    unsigned int item;
    unsigned int mask;

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SEQ_STOP:
        CALLV(ROOT->SetApTimer)(0x53L, obj, -1L, 0L, EVT_HDAE_AFTER_LOAD);
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
                if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, OBJ_FLS_FILE_LOAD, 0) != 0xffff) {
                    if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                        CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
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
        HDAE5000_RAM_CurFlsItem = HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &it) != 0xffff) {
            if (it.al == 1) {
                HDAE5000_RAM_FlsAutoLoadPending = 1;
                HDAE5000_RAM_FlsChainFls = HDAE5000_RAM_CurFls;
                HDAE5000_RAM_FlsChainItem = HDAE5000_RAM_CurFlsItem;
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
            mask = HDAE5000_Song_PartMask(it.dir, it.song);
            if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, OBJ_FLS_FILE_LOAD, 0) != 0xffff) {
                if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
                if (it.as == 1)
                    CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        HDAE5000_RAM_CurFlsItem = HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
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
        HDAE5000_RAM_CurFlsItem = HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(0, 1);
        break;
    }
    return 0;
}

/* the FLS edit screen */
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
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, OBJ_FLS_EDIT, EVT_HDAE_TIMER_BACK);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, OBJ_FLS_EDIT, EVT_HDAE_TIMER_BACK);
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

/* the FLS item's directory selection */
long HDAE5000_FlsDirSelScreen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_DirPageBase = 0;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            break;
        case 1:
            HDAE5000_RAM_DirPageBase = 24;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            break;
        case 5:
            HDAE5000_RAM_DirPageBase = 48;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            break;
        case 6:
            HDAE5000_RAM_DirPageBase = 72;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            break;
        case 7:
            HDAE5000_RAM_DirPageBase = 96;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_RAM_CurDir = HDAE5000_RAM_DirPageBase + (unsigned int)arg;
        HDAE5000_SongScreen_Refresh(1, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_SEL, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_DirPageBase >= 24) {
            HDAE5000_RAM_DirPageBase -= 24;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_DIR_BOX, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_DirPageBase < 96) {
            HDAE5000_RAM_DirPageBase += 24;
            HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_DIR_BOX, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}

/* the FLS item's song selection */
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
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, &HDAE5000_TypeSel_TemplateBlank, 2);
        else
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, &HDAE5000_TypeSel_TemplateBlank, 2);
        HDAE5000_SongScreen_Refresh(1, 1);
        break;
    }
    return 0;
}

/* the "overwrite the FLS item?" switch */
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
   sel (XWA) is not read: the list is HDAE5000_RAM_FdList itself */
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int i;
    unsigned int j;
    unsigned int mask;
    long h;

    for (i = 0; i < count; i++) {
        if (HDAE5000_RAM_FdList.sel[i] == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, HDAE5000_Fmt_2_2d_CopyToHd_Execute, i + 1);
            HDAE5000_StrNCpy(&num[2], &HDAE5000_RAM_FdList.rows[i][3], 6);
            slot = -1;
            for (j = 0; j < 16; j++) {
                if (HDAE5000_Song_IsUsed(dir, j) == 0xffff) {
                    slot = j;
                    break;
                }
            }
            if (slot != -1) {
                HDAE5000_MemCopy(name, num, 8);
                mask = 0;
                CALLV(HAMA->GetMediaType)();
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_LSW);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask = 1;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_PMT);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x002;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_SQT);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x004;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_CMP);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x008;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_TM);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x010;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_MSP);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x020;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_RCM);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x040;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_MD);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x080;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_TLX);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x100;
                    CALLV(HAMA->findclose)(h);
                }
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, 0, 0, mask) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, OBJ_CP_FD, EVT_HDAE_TIMER_BACK);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, OBJ_CP_FD, EVT_HDAE_TIMER_BACK);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, OBJ_CP_FD, EVT_HDAE_TIMER_BACK);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, OBJ_CP_FD, EVT_HDAE_TIMER_BACK);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}

/* the copy-to-HD screen's directory selection */
long HDAE5000_CopyToHDDirSelScreen(long obj, long ev, long arg)
{
    unsigned int n;

    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_DirPageBase = 0;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 1:
            HDAE5000_RAM_DirPageBase = 24;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 5:
            HDAE5000_RAM_DirPageBase = 48;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 6:
            HDAE5000_RAM_DirPageBase = 72;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 7:
            HDAE5000_RAM_DirPageBase = 96;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
        if (HDAE5000_Dir_IsBlankName(HDAE5000_RAM_CurDir = HDAE5000_RAM_DirPageBase + (unsigned int)arg) == 0xffff) {
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CP_UNNAMED, EVT_SHOW, 0L);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ATTEN_CP_UNNAMED_CATCH, -1L, OBJ_CP_FD_DIRSEL, EVT_HDAE_TIMER_BACK);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ATTEN_CP_UNNAMED_CATCH, -1L, OBJ_CP_FD_DIRSEL, EVT_HDAE_TIMER_BACK);
        } else {
            n = HDAE5000_Count_Active_Files();
            if (HDAE5000_Dir_CountEmptySongs(HDAE5000_RAM_CurDir) >= n) {
                CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
                if (HDAE5000_CopyToHd_Execute(HDAE5000_RAM_FdList.sel, 20, HDAE5000_RAM_CurDir) != 0xffff)
                    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, 0L);
            } else {
                CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_FULL_DIR, EVT_SHOW, 0L);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ATTEN_FULL_DIR_CATCH, -1L, OBJ_CP_FD_DIRSEL, EVT_HDAE_TIMER_BACK);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ATTEN_FULL_DIR_CATCH, -1L, OBJ_CP_FD_DIRSEL, EVT_HDAE_TIMER_BACK);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_CP_FD_DIRNAMECheck, EVT_SET_STRING,
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir =
                                                             HDAE5000_RAM_DirPageBase + (unsigned int)arg));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIR_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_DirPageBase >= 24) {
            HDAE5000_RAM_DirPageBase -= 24;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRBOX, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_DirPageBase < 96) {
            HDAE5000_RAM_DirPageBase += 24;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRBOX, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}

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
long HDAE5000_WrConfirmEventCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Wrcn);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23a04e));
            CALLV(ROOT->SendEvent)(OBJ_HDD_FILE_NAMING, EVT_SHOW, 0L);
            HDAE5000_SaveSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                    OBJ_SELECT_FILE, 1, ram_23a04e);
            HDAE5000_SongScreen_Refresh(0, 0);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
        }
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}

/* the delete-option switches: 8 asks to delete, 10 / 11 reset the delete options from the song's parts */
long HDAE5000_DelOptSwEventCatch(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_DEL_DelOptSwEventCatch);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 8:
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_FILE, EVT_SHOW, 0L);
            break;
        case 10:
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, &HDAE5000_DelOpt_TemplateBlank, 2);
            HDAE5000_DelOpt_ShowFlags();
            break;
        case 11:
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, &HDAE5000_DelOpt_TemplateBlank, 1);
            HDAE5000_RAM_DeleteOptions.mask = 0;
            HDAE5000_DelOpt_ShowFlags();
        }
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}
