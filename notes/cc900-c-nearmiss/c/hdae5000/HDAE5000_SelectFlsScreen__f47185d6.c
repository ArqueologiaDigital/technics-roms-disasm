/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r20_fsb.c (2026-11-16-98-hd-r22)
   sha256 f47185d6b271b60bb1a28118ac5d0f77322f5dcc32841f0123a11f2b4089832d (tar-sha256); compiled at -Xr */
/* lane_hd round 20, helper h_fs, form b: alternatives to hd_r20_fsa.c (same names) for four of its functions, in ROM
   address order.  Options: -Xr.
   - HDAE5000_FlsScreen_Refresh: the old-style definition with char parameters, called through the prototype with
     the promoted types (the lyric module's idiom, which V4.23 matched): the ROM's prologue stores C and A as bytes
     (`ld (xsp+30),c; ld (xsp+32),a`).  For the probe only: the build cannot parse K&R yet.
   - HDAE5000_SelectFlsScreen / HDAE5000_CopyToHDDirSelScreen: the page base + list index whose sum is also passed
     on (SELECT_SAVE, and CopyToHD's SELECT_OK) is computed `ld wa,(base); ld bc,iz; add bc,wa` in the ROM, unlike
     the stored-only sum `ld bc,(base); ld wa,iz; add wa,bc`.  Form a writes both base + (unsigned int)arg; here the
     passed-on sums are int + int, base + (int)arg (no conversion, so no operand is evaluated early).
   - HDAE5000_FlsEditScreen: the switch-state test `bit 7,iz` as (unsigned int)arg & 0x80 (form a: arg & 0x80 on the
     long).
   cc900-options: -Xr
   cc900-module: HDAE5000_PartList_Build HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_YieldUntilSem1Zero HDAE5000_UiObj_SetCaption
   cc900-module: HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
*/
/* ---- hdae_ws.h (inlined) ---- */
/* the main CPU workspace and its function tables (gen_ws_header.py, from the RootFn_* / HamaFn_* .equ) */
typedef void (*VFN)();
struct RootFns {
    void *pad0[33];
    void *UpdateScreen;
    void *pad1[5];
    void *DrawLine;
    void *pad2[1];
    void *DrawBox;
    void *DrawFrame;
    void *pad3[1];
    void *MovePixels;
    void *pad4[4];
    void *DrawString;
    void *pad5[5];
    void *InheritedProc;
    void *pad6[1];
    void *RegisterObjectTable;
    void *pad7[6];
    void *SendEvent;
    void *PostEvent;
    void *pad8[7];
    void *ApPostEvent;
    void *pad9[5];
    void *ResEventProc;
    void *ResMethodProc;
    void *pad10[1];
    void *ResNameProc;
    void *pad11[1];
    void *GetCharHeight;
    void *GetCharDescent;
    void *GetCenteredDelta;
    void *ConvertStrings;
    void *pad12[2];
    void *ClassProc;
    void *pad13[54];
    void *FunctionProc;
    void *ApFunctionProc;
    void *MainFunctionProc;
    void *ApFuncCall;
    void *MainFuncCall;
    void *pad14[6];
    void *RegisterTitle;
    void *pad15[1];
    void *GetTitleNow;
    void *pad16[1];
    void *ViewableProc;
    void *pad17[4];
    void *SetVisible;
    void *pad18[11];
    void *GetViewInstance;
    void *pad19[3];
    void *GetClientBox;
    void *pad20[1];
    void *DrawDesignBox;
    void *pad21[57];
    void *SetDialEnable;
    void *SetDialUp;
    void *SetDialDown;
    void *pad22[16];
    void *SetApTimer;
    void *pad23[1];
    void *KillApTimer;
    void *pad24[4];
    void *SetAutoInc;
    void *pad25[55];
    void *GetNamingWindowID;
    void *pad26[9];
    void *DeleteEvent;
    void *SleepMainTask;
    void *WakeUpMainTask;
};
struct HamaFns {
    void *pad0[1];
    void *FDLoadSaveTest;
    void *GetMediaType;
    void *PreLswLoad;
    void *PostLswLoad;
    void *PreLswSave;
    void *PostLswSave;
    void *PrePmLoad;
    void *PostPmLoad;
    void *PrePmSave;
    void *PostPmSave;
    void *SeqLoadPre;
    void *SeqLoadPost;
    void *SeqSavePre;
    void *SeqSavePost;
    void *cmp_ld_mae;
    void *cmp_ld_ato;
    void *cmp_sv_mae;
    void *cmp_sv_ato;
    void *PreTmLoad;
    void *PostTmLoad;
    void *PreTmSave;
    void *PostTmSave;
    void *msp_ld_mae;
    void *msp_ld_ato;
    void *msp_sv_mae;
    void *msp_sv_ato;
    void *PreMidiLoad;
    void *PostMidiLoad;
    void *PreMidiSave;
    void *PostMidiSave;
    void *FlashWrite;
    void *GetResouceInfo;
    void *SetSepaOutMode;
    void *pad1[2];
    void *GetVolumeLabel;
    void *findfirst;
    void *findnext;
    void *findclose;
    void *fopen_ext;
    void *pad2[1];
    void *fread_ext;
    void *fclose_ext;
    void *rcm_ld_XAPR_j;
    void *rcm_sv_XAPR_j;
    void *rot_rdq_X;
    void *pad3[5];
    void *ref_sem_X;
    void *pad4[4];
    void *pdly_tim_X;
    void *PlayHalt;
    void *PlayStandBy;
    void *EditSwRefresh;
    void *pad5[3];
    void *GetAdr_sqbtof;
    void *GetAdr_sq_beadt;
    void *GetAdr_sqsrtc;
    void *pad6[2];
    void *sendCOMM;
    void *pad7[2];
    void *SwbtWr;
    void *pad8[2];
    void *SetGlobalError;
    void *malloc_X;
    void *free_X;
    void *ChangePalette;
    void *ChangeWall;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
/* every call goes through a cast: CALLR(int, ROOT->GetTitleNow)(), CALLV(ROOT->SendEvent)(obj, ev, arg) */
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
/* ---- end of hdae_ws.h ---- */
/* ---- hdae_ids.h (inlined) ---- */
/* HD-AE5000 UI object ids and event codes (gen_ids_header.py) */
#define EVT_SHOW 0x1c00001L
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_SET_STRING 0x1e00086L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_CHANGE_SEL_NUM 0x1ea0002L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_OK2 0x1ea0007L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_ATTEN_CP_UNNAMED 0x7f02b0L
#define OBJ_ATTEN_CP_UNNAMED_CATCH 0x7f02b2L
#define OBJ_ATTEN_DEL_FLS1 0x7f022fL
#define OBJ_ATTEN_DEL_FLS2 0x7f020dL
#define OBJ_ATTEN_FULL_DIR 0x7f02a9L
#define OBJ_ATTEN_FULL_DIR_CATCH 0x7f02abL
#define OBJ_CP_FD 0x7f00d2L
#define OBJ_CP_FD_DIRBOX 0x7f00e6L
#define OBJ_CP_FD_DIRSEL 0x7f00e2L
#define OBJ_CP_FD_DIR_NAMING 0x7f017bL
#define OBJ_ERR_SAVE 0x7f0297L
#define OBJ_ERR_SAVE_CATCH 0x7f0299L
#define OBJ_ERR_SAVE_EXIT 0x7f0298L
#define OBJ_FLS_DIR_BOX 0x7f0151L
#define OBJ_FLS_DIR_SEL 0x7f014eL
#define OBJ_FLS_EDIT 0x7f0163L
#define OBJ_FLS_EDIT_LIST_BOX 0x7f0169L
#define OBJ_FLS_FILE_LOAD 0x7f013aL
#define OBJ_HDD_FLS_NAMING 0x7f0134L
#define OBJ_HD_PLEASE 0x7f02c1L
#define OBJ_SEL_FLS 0x7f00fbL
/* ---- end of hdae_ids.h ---- */

#define APFUNC_FlsNamingCheck 0x012a0017L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */
#define APFUNC_CP_FD_DIRNAMECheck 0x012a0019L   /* NAKA_APFUNC_CP_FD_DIRNAMECheck */

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
/* +0 title, +14 the 20 rows of 12, +0x100 present flags, +0x114 selected flags */
struct FdList { char label[14]; char rows[20][12]; char pad[2]; unsigned char present[20]; unsigned char sel[20]; };

/* an array read as an lvalue member at offset 0 (hd_r9_b2.c FdList_Clear: `lda xwa,(sym); ld xde,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, const char *, unsigned int);

extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, struct FlsItem *out);
extern unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item);
extern int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item);
extern void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, int on);
extern void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, int on);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Dir_IsBlankName(unsigned int dir);
extern unsigned int HDAE5000_Dir_CountEmptySongs(unsigned int dir);
extern unsigned int HDAE5000_HD_StoreTables(int keep);   /* unsigned: the ROM compares HL with 0xffff unconverted */

extern void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask);
extern void HDAE5000_FlsList_BuildPage(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern unsigned int HDAE5000_Count_Active_Files(void);
extern unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir);
void HDAE5000_FlsScreen_Refresh(int variant, int mode);

extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern int HDAE5000_RAM_DirPageBase;
extern int HDAE5000_RAM_FlsPageBase;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
extern struct FdList HDAE5000_RAM_FdList;
extern char ram_22a058[];                               /* the FLS screen's title text */
extern char ram_22a078[];                               /* its LOC text */
extern char ram_22b020[];                               /* its 16 item rows of 37 */

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

void HDAE5000_FlsScreen_Refresh(variant, mode)
unsigned char variant;
unsigned char mode;
{
    char s[22];
    struct FlsItem item;
    unsigned int i;
    unsigned int r;
    unsigned int mask;

    if (mode == 0 || mode == 2) {
        HDAE5000_MemFill(ram_22a058, 0, 0x20);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_FLSNAME);
        HDAE5000_SPrintf(s, ram_2e2eb6, HDAE5000_RAM_CurFls + 1);
        HDAE5000_StrCat(ram_22a058, s);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_Chr3A_FlsScreen_Refresh);
        HDAE5000_StrNCat(ram_22a058, (char *)HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls), 16);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_Blank0Tab_FlsScreen_Refresh);
        CALLV(ROOT->SendEvent)(ram_2e2e7c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a058));
        CALLV(ROOT->SendEvent)(ram_2e2e7c[variant], EVT_PARA_DRAW, -1L);
    }
    if (mode == 0 || mode == 2) {
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
        CALLV(ROOT->SendEvent)(ram_2e2e84[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22b020));
        CALLV(ROOT->SendEvent)(ram_2e2e84[variant], EVT_PARA_DRAW, -1L);
    }
    HDAE5000_MemFill(ram_22a078, 0, 16);
    if ((r = HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &item)) != 0xffff)
        HDAE5000_SPrintf(s, HDAE5000_Fmt_LOC_3_3d_2_2d, item.dir + 1, item.song + 1);
    else
        HDAE5000_SPrintf(s, HDAE5000_Str_LOC00000);
    HDAE5000_MemCopy(ram_22a078, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)(ram_2e2e8c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a078));
    CALLV(ROOT->SendEvent)(ram_2e2e8c[variant], EVT_PARA_DRAW, -1L);
    if (r != 0xffff) {
        mask = HDAE5000_Song_PartMask(item.dir, item.song);
        HDAE5000_PartList_Build(ram_2e2e94[variant], item.dir, item.song, mask);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[variant], 0xffff, 0xffff, 0xffff);
    if (mode != 2) {
        CALLV(ROOT->SendEvent)(ram_2e2e9c[variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)(ram_2e2ea4[variant], EVT_DRAW, 0L);
    }
}

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
                                HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls = HDAE5000_RAM_FlsPageBase + (int)arg));
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
            if ((unsigned int)arg & 0x80)
                HDAE5000_FlsItem_SetAutoStart(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 0);
            else
                HDAE5000_FlsItem_SetAutoStart(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 1);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        case 7:
            if ((unsigned int)arg & 0x80)
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
        if (HDAE5000_Dir_IsBlankName(HDAE5000_RAM_CurDir = HDAE5000_RAM_DirPageBase + (int)arg) == 0xffff) {
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
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir = HDAE5000_RAM_DirPageBase + (int)arg));
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
