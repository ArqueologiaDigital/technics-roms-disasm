/* hd_r36_fix2.c (helper h_fix2, lane_hd round 36): HDAE5000_FlsScreen_Refresh and HDAE5000_CopyToHd_Execute alone,
   from hd_r27_b_fsb.c, with variants (read against run 2026-11-16-119-hd-r30).  Options: -Xr.

   FlsScreen_Refresh (FlsScrRefresh_c).  Two things departed in r27's forms:
   - the row offset: the ROM loads 37 into WA and multiplies by IZ; r27's local `k` got the upper half of XIZ (QIZ),
     loaded there and copied to WA, and that is also why V4.23 saved XIZ where the ROM saves IZ (the +3 difference).
     A local can only be loaded straight into WA if it lives in WA, and WA is busy between a `k = 37;` statement and
     the multiply (the earlier arguments are pushed through XWA).  So here the assignment is INSIDE the index
     expression, after the earlier arguments: `(k = 37) * i` (form _c: `(k = 37, k * i)`).  Form _l keeps the literal
     `37 * i` (known result: the frame matches, only the multiply departs), to check the rest.
   - PartList_Build(obj, item.dir, item.song, r): the ROM loads XWA (ObjIds), BC, DE in that order, straight from
     their places, and pushes IZ last.  r27's casts / locals moved them through WA or HL.  Here PartList_Build's
     prototype has `int dir, int song` (as in the matched Lbn_TypeDigit: an unsigned operand converted by the
     prototype is loaded early and directly) and the call passes the members plainly.
   CopyToHd_Execute.  What departed:
   - registers: the ROM has i in IZ and j / mask in QIZ; V4.23 gave i QIZ and j / mask IZ for every declaration
     tried so far, all of which declared i FIRST (i, j, mask; with `register` on i, or on j and mask).  In the three
     loop functions whose V4.23 code I read (FdLyricList_AddTlx, this one, FlsScreen_Refresh) the first-declared
     local got QIZ, so here j is declared first.  Forms:
       HDAE5000_CopyToHd_Execute  declared j, mask, i
       CpHdExec_o                 declared j, i, mask
       CpHdExec_b                 i at the top, j and mask declared in the block that uses them
       CpHdExec_g                 declared i, j, mask; the slot search written with if / goto, not a nested `for`
   - sel[i] and the row name: the ROM extends the index to 32 bits, adds the member offset (0x114, 14) in 32 bits,
     loads the list's address as an immediate and adds.  V4.23 added the offset in 16 bits and used `lda` for the
     struct member spellings.  Here the list is a flat byte array at the same address with the offset added to an
     unsigned long index (V4.23's own code for FlsScreen_Refresh's flat row array has the immediate base);
     CpHdExec_b reaches the members through a constant struct pointer instead.
   - Song_IsUsed(dir, j): the ROM loads BC (j) before WA (dir); the matched Dir_CountEmptySongs loads WA first with
     an unsigned parameter.  Here the second parameter is `int`, so that j is a converted argument.
   Unchanged from r27: everything else.
   cc900-name: FlsScrRefresh_c=HDAE5000_FlsScreen_Refresh
   cc900-name: FlsScr_c=HDAE5000_FlsScreen_Refresh
   cc900-name: FlsScr_l=HDAE5000_FlsScreen_Refresh
   cc900-name: CpHdExec_o=HDAE5000_CopyToHd_Execute
   cc900-name: CpHdExec_b=HDAE5000_CopyToHd_Execute
   cc900-name: CpHdExec_g=HDAE5000_CopyToHd_Execute
   cc900-options: -Xr
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
/* +0 title, +14 the 20 rows of 12 (and 2 bytes), +0x100 present flags, +0x114 selected flags */
struct FdList { char label[14]; char rows[242]; unsigned char present[20]; unsigned char sel[20]; };
struct FindData { char b[266]; };

/* an array read as an lvalue member at offset 0 (`lda xwa,(sym); ld xde,xwa`) */
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
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, void *out);
extern unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
/* r36: `int song`, so that CopyToHd_Execute's unsigned j is a converted argument (the ROM loads BC before WA) */
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, int song);
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, unsigned int mask,
                                            int a, int b);

/* this module (calr, cc900-module) */
/* r36: `int dir, int song` (the matched Lbn_TypeDigit's prototype): the unsigned members are loaded early */
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);

/* RAM */
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
/* the floppy list (HDAE5000_RAM_FdList, 0x22aa9c) as a flat byte array */
extern unsigned char ram_22aa9c[];
extern char ram_22a058[];                               /* the FLS screen's title text */
extern char ram_22a078[];                               /* its LOC text */
extern char ram_22b020[];                               /* its 16 item rows of 37 */

/* ROM */
/* unsigned long: the ROM evaluates ObjIds[variant] first among the arguments (a converted argument's order) */
extern unsigned long ram_2e2e7c[], ram_2e2e84[], ram_2e2e8c[], ram_2e2e94[], ram_2e2e9c[], ram_2e2ea4[];
                                                        /* HDAE5000_FlsScreen_Refresh_ObjIds .. _ObjIds_6 */
extern char HDAE5000_Str_FLSNAME[];
extern char ram_2e2eb6[];                               /* HDAE5000_Fmt_2_2d_FlsScreen_Refresh */
extern char ram_2e2ebc[];                               /* HDAE5000_Str_Chr3A_FlsScreen_Refresh */
extern char ram_2e2ebe[];                               /* HDAE5000_Str_Blank0Tab_FlsScreen_Refresh */
extern char HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh[];
extern char ram_2e2ee4[];                               /* HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2 */
extern char HDAE5000_Fmt_LOC_3_3d_2_2d[];
extern char HDAE5000_Str_LOC00000[];
extern char ram_2e2f24[];                               /* HDAE5000_Fmt_2_2d_CopyToHd_Execute */
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[], HDAE5000_Str_TLX[];

/* the FLS screen: title "FLS NAME NN:<name>", the 16 items of the page, the selected item's LOC and part list;
   variant picks the object ids (0 load screen, 1 edit screen); mode 0 or 2 redraws title and items, 2 skips the
   two lines at the end.  Main form: the row length assigned inside the index expression, `(k = 37) * i`. */
void FlsScrRefresh_c(unsigned char variant, unsigned char mode)
{
    char s[22];
    struct FlsItem item;
    unsigned int i;
    unsigned int r;
    const void *rec;
    unsigned int k;

    if (mode == 0 || mode == 2) {
        HDAE5000_MemFill(ram_22a058, 0, 0x20);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_FLSNAME);
        HDAE5000_SPrintf(s, ram_2e2eb6, HDAE5000_RAM_CurFls + 1);
        HDAE5000_StrCat(ram_22a058, s);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebc);
        HDAE5000_StrNCat(ram_22a058, (char *)HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls), 16);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebe);
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a058));
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_PARA_DRAW, -1L);
    }
    if (mode == 0 || mode == 2) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&ram_22b020[(k = 37) * i + 2], HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh, 35);
            HDAE5000_SPrintf(s, ram_2e2ee4, HDAE5000_RAM_FlsItemPageBase + i + 1);
            HDAE5000_MemCopy(&ram_22b020[(k = 37) * i], s, HDAE5000_StrLen(s));
            rec = HDAE5000_FlsItem_SongRecord(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i);
            HDAE5000_MemCopy(&ram_22b020[(k = 37) * i + 3], rec, 26);
            if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i, &item) != 0xffff) {
                if (item.as == 1)
                    ram_22b020[(k = 37) * i + 32] = '*';
                if (item.al == 1)
                    ram_22b020[(k = 37) * i + 35] = '*';
            }
        }
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22b020));
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_PARA_DRAW, -1L);
    }
    HDAE5000_MemFill(ram_22a078, 0, 16);
    if ((r = HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &item)) != 0xffff)
        HDAE5000_SPrintf(s, HDAE5000_Fmt_LOC_3_3d_2_2d, item.dir + 1, item.song + 1);
    else
        HDAE5000_SPrintf(s, HDAE5000_Str_LOC00000);
    HDAE5000_MemCopy(ram_22a078, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a078));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_PARA_DRAW, -1L);
    if (r != 0xffff) {
        r = HDAE5000_Song_PartMask(item.dir, item.song);
        HDAE5000_PartList_Build(ram_2e2e94[variant], item.dir, item.song, r);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[variant], 0xffff, 0xffff, 0xffff);
    if (mode != 2) {
        CALLV(ROOT->SendEvent)((long)ram_2e2e9c[variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)((long)ram_2e2ea4[variant], EVT_DRAW, 0L);
    }
}

/* form _c: the row length through a comma expression, `(k = 37, k * i)` */
void FlsScr_c(unsigned char variant, unsigned char mode)
{
    char s[22];
    struct FlsItem item;
    unsigned int i;
    unsigned int r;
    const void *rec;
    unsigned int k;

    if (mode == 0 || mode == 2) {
        HDAE5000_MemFill(ram_22a058, 0, 0x20);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_FLSNAME);
        HDAE5000_SPrintf(s, ram_2e2eb6, HDAE5000_RAM_CurFls + 1);
        HDAE5000_StrCat(ram_22a058, s);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebc);
        HDAE5000_StrNCat(ram_22a058, (char *)HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls), 16);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebe);
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a058));
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_PARA_DRAW, -1L);
    }
    if (mode == 0 || mode == 2) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&ram_22b020[(k = 37, k * i) + 2], HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh, 35);
            HDAE5000_SPrintf(s, ram_2e2ee4, HDAE5000_RAM_FlsItemPageBase + i + 1);
            HDAE5000_MemCopy(&ram_22b020[(k = 37, k * i)], s, HDAE5000_StrLen(s));
            rec = HDAE5000_FlsItem_SongRecord(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i);
            HDAE5000_MemCopy(&ram_22b020[(k = 37, k * i) + 3], rec, 26);
            if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i, &item) != 0xffff) {
                if (item.as == 1)
                    ram_22b020[(k = 37, k * i) + 32] = '*';
                if (item.al == 1)
                    ram_22b020[(k = 37, k * i) + 35] = '*';
            }
        }
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22b020));
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_PARA_DRAW, -1L);
    }
    HDAE5000_MemFill(ram_22a078, 0, 16);
    if ((r = HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &item)) != 0xffff)
        HDAE5000_SPrintf(s, HDAE5000_Fmt_LOC_3_3d_2_2d, item.dir + 1, item.song + 1);
    else
        HDAE5000_SPrintf(s, HDAE5000_Str_LOC00000);
    HDAE5000_MemCopy(ram_22a078, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a078));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_PARA_DRAW, -1L);
    if (r != 0xffff) {
        r = HDAE5000_Song_PartMask(item.dir, item.song);
        HDAE5000_PartList_Build(ram_2e2e94[variant], item.dir, item.song, r);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[variant], 0xffff, 0xffff, 0xffff);
    if (mode != 2) {
        CALLV(ROOT->SendEvent)((long)ram_2e2e9c[variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)((long)ram_2e2ea4[variant], EVT_DRAW, 0L);
    }
}

/* form _l: the literal `37 * i` (no local: the frame and the IZ save match; the multiply is known to depart) */
void FlsScr_l(unsigned char variant, unsigned char mode)
{
    char s[22];
    struct FlsItem item;
    unsigned int i;
    unsigned int r;
    const void *rec;

    if (mode == 0 || mode == 2) {
        HDAE5000_MemFill(ram_22a058, 0, 0x20);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_FLSNAME);
        HDAE5000_SPrintf(s, ram_2e2eb6, HDAE5000_RAM_CurFls + 1);
        HDAE5000_StrCat(ram_22a058, s);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebc);
        HDAE5000_StrNCat(ram_22a058, (char *)HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls), 16);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebe);
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a058));
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_PARA_DRAW, -1L);
    }
    if (mode == 0 || mode == 2) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&ram_22b020[37 * i + 2], HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh, 35);
            HDAE5000_SPrintf(s, ram_2e2ee4, HDAE5000_RAM_FlsItemPageBase + i + 1);
            HDAE5000_MemCopy(&ram_22b020[37 * i], s, HDAE5000_StrLen(s));
            rec = HDAE5000_FlsItem_SongRecord(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i);
            HDAE5000_MemCopy(&ram_22b020[37 * i + 3], rec, 26);
            if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i, &item) != 0xffff) {
                if (item.as == 1)
                    ram_22b020[37 * i + 32] = '*';
                if (item.al == 1)
                    ram_22b020[37 * i + 35] = '*';
            }
        }
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22b020));
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_PARA_DRAW, -1L);
    }
    HDAE5000_MemFill(ram_22a078, 0, 16);
    if ((r = HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &item)) != 0xffff)
        HDAE5000_SPrintf(s, HDAE5000_Fmt_LOC_3_3d_2_2d, item.dir + 1, item.song + 1);
    else
        HDAE5000_SPrintf(s, HDAE5000_Str_LOC00000);
    HDAE5000_MemCopy(ram_22a078, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a078));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_PARA_DRAW, -1L);
    if (r != 0xffff) {
        r = HDAE5000_Song_PartMask(item.dir, item.song);
        HDAE5000_PartList_Build(ram_2e2e94[variant], item.dir, item.song, r);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[variant], 0xffff, 0xffff, 0xffff);
    if (mode != 2) {
        CALLV(ROOT->SendEvent)((long)ram_2e2e9c[variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)((long)ram_2e2ea4[variant], EVT_DRAW, 0L);
    }
}

/* one part file of the floppy song: name + extension looked up, its mask bit set when it exists */
#define PART(ext, setbit) \
    HDAE5000_StrCpy(&name[8], ext); \
    if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) { setbit; CALLV(HAMA->findclose)(h); }

/* the flat-array spellings of the list's members: selected flag i, and the name inside row i */
#define FD_SEL(i) ram_22aa9c[(unsigned long)(i) + 0x114]
#define FD_ROWNAME(i) ((char *)&ram_22aa9c[(unsigned long)((i) * 12 + 3) + 14])

/* copy the floppy songs selected in the copy screen's list into free songs of directory dir; sel (XWA) is not
   read: the list is HDAE5000_RAM_FdList itself.  Main form: j, mask, i declared in that order. */
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int j;
    unsigned int mask;
    unsigned int i;
    long h;

    for (i = 0; i < count; i++) {
        if (FD_SEL(i) == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], FD_ROWNAME(i), 6);
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
                PART(HDAE5000_Str_LSW, mask = 1)
                PART(HDAE5000_Str_PMT, mask |= 0x002)
                PART(HDAE5000_Str_SQT, mask |= 0x004)
                PART(HDAE5000_Str_CMP, mask |= 0x008)
                PART(HDAE5000_Str_TM, mask |= 0x010)
                PART(HDAE5000_Str_MSP, mask |= 0x020)
                PART(HDAE5000_Str_RCM, mask |= 0x040)
                PART(HDAE5000_Str_MD, mask |= 0x080)
                PART(HDAE5000_Str_TLX, mask |= 0x100)
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, mask, 0, 0) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}

/* form _o: j, i, mask declared in that order */
unsigned int CpHdExec_o(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int j;
    unsigned int i;
    unsigned int mask;
    long h;

    for (i = 0; i < count; i++) {
        if (FD_SEL(i) == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], FD_ROWNAME(i), 6);
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
                PART(HDAE5000_Str_LSW, mask = 1)
                PART(HDAE5000_Str_PMT, mask |= 0x002)
                PART(HDAE5000_Str_SQT, mask |= 0x004)
                PART(HDAE5000_Str_CMP, mask |= 0x008)
                PART(HDAE5000_Str_TM, mask |= 0x010)
                PART(HDAE5000_Str_MSP, mask |= 0x020)
                PART(HDAE5000_Str_RCM, mask |= 0x040)
                PART(HDAE5000_Str_MD, mask |= 0x080)
                PART(HDAE5000_Str_TLX, mask |= 0x100)
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, mask, 0, 0) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}

/* form _b: i at the top; j and mask declared in the block that uses them; the list's members through a constant
   struct pointer (0x22aa9c = HDAE5000_RAM_FdList) */
#define FDL ((struct FdList *)0x22aa9cL)
unsigned int CpHdExec_b(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int i;
    long h;

    for (i = 0; i < count; i++) {
        if (FDL->sel[i] == 1) {
            unsigned int j;
            unsigned int mask;

            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], &FDL->rows[i * 12 + 3], 6);
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
                PART(HDAE5000_Str_LSW, mask = 1)
                PART(HDAE5000_Str_PMT, mask |= 0x002)
                PART(HDAE5000_Str_SQT, mask |= 0x004)
                PART(HDAE5000_Str_CMP, mask |= 0x008)
                PART(HDAE5000_Str_TM, mask |= 0x010)
                PART(HDAE5000_Str_MSP, mask |= 0x020)
                PART(HDAE5000_Str_RCM, mask |= 0x040)
                PART(HDAE5000_Str_MD, mask |= 0x080)
                PART(HDAE5000_Str_TLX, mask |= 0x100)
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, mask, 0, 0) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}

/* form _g: i, j, mask declared in that order; the slot search with if / goto, so that j is not the variable of a
   loop nested in i's (in case V4.23 serves the innermost loop's variable first) */
unsigned int CpHdExec_g(unsigned char *sel, unsigned int count, unsigned int dir)
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
        if (FD_SEL(i) == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], FD_ROWNAME(i), 6);
            slot = -1;
            j = 0;
            if (j < 16) {
            again:
                if (HDAE5000_Song_IsUsed(dir, j) == 0xffff) {
                    slot = j;
                    goto found;
                }
                j++;
                if (j < 16)
                    goto again;
            }
        found:
            if (slot != -1) {
                HDAE5000_MemCopy(name, num, 8);
                mask = 0;
                CALLV(HAMA->GetMediaType)();
                PART(HDAE5000_Str_LSW, mask = 1)
                PART(HDAE5000_Str_PMT, mask |= 0x002)
                PART(HDAE5000_Str_SQT, mask |= 0x004)
                PART(HDAE5000_Str_CMP, mask |= 0x008)
                PART(HDAE5000_Str_TM, mask |= 0x010)
                PART(HDAE5000_Str_MSP, mask |= 0x020)
                PART(HDAE5000_Str_RCM, mask |= 0x040)
                PART(HDAE5000_Str_MD, mask |= 0x080)
                PART(HDAE5000_Str_TLX, mask |= 0x100)
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, mask, 0, 0) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}
