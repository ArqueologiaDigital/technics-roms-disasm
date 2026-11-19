/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v1_15i/hdae5000_fls_refresh.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 9166b096a04595b772cdb03c5fee770258941716f766bbd4b10247ae948cd9ff (tar-sha256); compiled at -Xr */
/* Functions of hdae5000_filesystem.s.  (hdae5000_fls_refresh.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fls_refresh.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: FlsScr_c=HDAE5000_FlsScreen_Refresh
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
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
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_CP_FD 0x7f00ceL
#define OBJ_ERR_NO_HK_DATA 0x7f0297L
#define OBJ_ERR_NO_HK_DATA_CATCH 0x7f0299L
#define OBJ_ERR_SAVE 0x7f028bL
#define OBJ_ERR_SAVE_CATCH 0x7f028dL
#define OBJ_ERR_SAVE_EXIT 0x7f028cL
/* ---- end of hdae_ids.h ---- */

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
   two lines at the end.  The row length goes through a comma expression, `(k = 37, k * i)`: that makes V4.23 load
   the constant into WA and multiply by the loop register, as the ROM does (run 2026-11-17-3-hd-r36). */
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

/* form _b: i at the top; j and mask declared in the block that uses them; the list's members through a constant
   struct pointer (0x22aa9c = HDAE5000_RAM_FdList) */
#define FDL ((struct FdList *)0x22aa9cL)

/* form _g: i, j, mask declared in that order; the slot search with if / goto, so that j is not the variable of a
   loop nested in i's (in case V4.23 serves the innermost loop's variable first) */
