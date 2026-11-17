/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r27_b_fs.c (2026-11-16-119-hd-r30)
   sha256 aaefc413b546bf5be564c3000c3954b72e2e681e1994a2bdf7f425ed7108b381 (tar-sha256); compiled at -Xr */
/* hd_r27_b_fs.c (helper h_r27b, lane_hd round 27), form a: hd_r23_fs.c with TWO functions changed, from run 109
   (read with h_r27b/idiff4.py):
   - FlsScreen_Refresh (FlsScrRefresh_c): the row size through a local, `k = 37;` at the top of the loop body and
     `k * i` (run 109: `37 * i` gave `ld wa,iz; mul wa,37`; the ROM has `ld wa,37; mul xwa,iz`); and
     PartList_Build's dir / song arguments cast to int (the ROM loads BC / DE and pushes IZ last; run 109 pushed IZ
     first).  Nothing else departed.
   - CopyToHd_Execute: i without `register`, declared before j / mask.  Run 109 gave i QIZ and j / mask IZ, the
     ROM has i in IZ and j / mask in QIZ.  Reading (see hd_r27_b_drv.c): V4.23 serves `register` locals first,
     then the others in reverse declaration order, QIZ before IZ.  The FdList address forms are unchanged here
     (form b respells them).
   Lbn_ShowEntry is unchanged: run 109 departs only in the jump-table load `lda XIX,S50000` the checker does not
   translate, and a jr / jrl length that follows from the missing bytes.
   hd_r23_fs.c's header follows.
   hd_r23_fs.c (helper h_nm3a, lane_hd round 23), form a: hd_r20_fsa.c (run 2026-11-16-98-hd-r22) with what departed
   fixed.  Same fifteen functions, ROM address order.  Changes:
   - stacked arguments of non-__cdecl calls in REVERSE of r20's order (V4.23 pushes them left to right; the ROM
     pushes the event before the object, name before flag before object): KillApTimer / SetApTimer(time, catch, -1,
     event, obj); SetApTimer(0x53, obj, -1, EVT_HDAE_AFTER_LOAD, 0); prototypes LoadSongWithUi(dir, song, mask,
     int ui, long obj), SaveSongWithUi(dir, song, mask, char *name, int ui, long obj), CopyFdSongToHd(dir, song,
     name, mask, a, b) (h_nm3b reads the callee's stacked parameters in these orders too);
   - arguments the ROM evaluates early are conversions: TypeSel_Init(void *rec, .., unsigned char *tmpl, ..) (the
     drv module's matched form: `lda xwa,(rec)` before `pushw 2`); FlsItem_Get(.., void *out) (`lda xwa,(xsp+N);
     ld xde,xwa` before WA / BC); ObjIds[variant] (unsigned long tables passed as long);
   - FlsItem_SetDir / _SetSong take unsigned int: the ROM loads DE (CurDir / CurSong) last, no conversion;
   - page base + list index: (unsigned int)arg + int base (SelectFlsScreen, FlsDirSelScreen, CopyToHDDirSelScreen;
     the ROM loads the base first), and in FlsLoadScreen (int)FlsItemPageBase + (unsigned int)arg (the ROM loads arg
     first, `ld bc,iz; ld wa,(base); add wa,bc`, while FlsEditScreen's matched `ld wa,iz; add wa,(base)` keeps the
     base unsigned);
   - FlsScreen_Refresh with unsigned char parameters (the ROM stores C and A, fsb's K&R prologue matched), defined
     as FlsScrRefresh_c (cc900-name: FlsScrRefresh_c=HDAE5000_FlsScreen_Refresh), so that the callers in this file,
     which load WA / BC, call the label through an int prototype (hd_v423.py resolves a cc900-name only for a
     defined function);
   - CopyToHd_Execute: i `register` (the ROM: i in IZ, j / mask in QIZ; r20 had them swapped), the FdList rows 1-D
     and its accesses as in hd_r23_drv.c's FdList_Scan;
   - long ROM names pushed as constants, which the checker does not translate (31-character listing names), as
     ram_<hex>: ram_2e2ebc (Str_Chr3A_FlsScreen_Refresh), ram_2e2ebe (Str_Blank0Tab_FlsScreen_Refresh), ram_2e2f24
     (Fmt_2_2d_CopyToHd_Execute).
   HDAE5000_Lbn_ShowEntry is unchanged: run 98's listing departs only where to_llvm cannot translate V4.23's
   jump-table load `lda XIX,S50000` (and a jr / jrl relaxation that follows from the missing 5 bytes); the ROM has
   the same `lda xix,(table); ld wa,(xix+wa); lda xix,(base); jp` shape.
   Unsolved, kept: FlsScreen_Refresh's `ld wa,37; mul xwa,iz` (V4.23: `ld wa,iz; mul wa,37`).
   r20's header follows.
   cc900-name: FlsScrRefresh_c=HDAE5000_FlsScreen_Refresh

   lane_hd round 20, helper h_fs, form a: fifteen UI procedures of hdae5000/hdae5000_filesystem.s (v2.06i), in ROM
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
#define EVT_HDAE_SEQ_STOP 0x1ca0000L
#define EVT_HDAE_AFTER_LOAD 0x1ca0001L
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_GET_STRING 0x1e0003aL
#define EVT_GET_STRING_LENGTH 0x1e0007cL
#define EVT_GET_NAMING_MODE 0x1e00084L
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
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
#define OBJ_ATTEN_DEL_FILE 0x7f01fbL
#define OBJ_ATTEN_DEL_FLS1 0x7f022fL
#define OBJ_ATTEN_DEL_FLS2 0x7f020dL
#define OBJ_ATTEN_FULL_DIR 0x7f02a9L
#define OBJ_ATTEN_FULL_DIR_CATCH 0x7f02abL
#define OBJ_ATTEN_OVER_FLS 0x7f0204L
#define OBJ_CP_FD 0x7f00d2L
#define OBJ_CP_FD_DIRBOX 0x7f00e6L
#define OBJ_CP_FD_DIRSEL 0x7f00e2L
#define OBJ_CP_FD_DIR_NAMING 0x7f017bL
#define OBJ_ERR_NO_HK_DATA 0x7f02a3L
#define OBJ_ERR_NO_HK_DATA_CATCH 0x7f02a5L
#define OBJ_ERR_SAVE 0x7f0297L
#define OBJ_ERR_SAVE_CATCH 0x7f0299L
#define OBJ_ERR_SAVE_EXIT 0x7f0298L
#define OBJ_FLS_DIR_BOX 0x7f0151L
#define OBJ_FLS_DIR_SEL 0x7f014eL
#define OBJ_FLS_EDIT 0x7f0163L
#define OBJ_FLS_EDIT_LIST_BOX 0x7f0169L
#define OBJ_FLS_FILE_BOX 0x7f0148L
#define OBJ_FLS_FILE_LOAD 0x7f013aL
#define OBJ_FLS_FILE_SEL 0x7f0159L
#define OBJ_FLS_FILE_SEL_LISTBOX 0x7f015cL
#define OBJ_FLS_SELECT 0x7f00f0L
#define OBJ_HDD_FILE_NAMING 0x7f004eL
#define OBJ_HDD_FLS_NAMING 0x7f0134L
#define OBJ_HDD_FLS_NAMING2 0x7f0244L
#define OBJ_HD_PLEASE 0x7f02c1L
#define OBJ_HddNamingWindow 0x7f01aeL
#define OBJ_LBN_DIRNAME_BOX 0x7f00a9L
#define OBJ_LBN_DIRNO_BOX 0x7f00a8L
#define OBJ_LBN_FILENAME_BOX 0x7f00abL
#define OBJ_LBN_FILENO_BOX 0x7f00aaL
#define OBJ_LBN_OPTION 0x7f0098L
#define OBJ_SELECT_FILE 0x7f0018L
#define OBJ_SEL_DIR 0x7f0025L
#define OBJ_SEL_FLS 0x7f00fbL
#define OBJ_Tech_lyrics 0x7f02f0L
/* ---- end of hdae_ids.h ---- */

#define APFUNC_FlsNamingCheck 0x012a0017L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */
#define APFUNC_CP_FD_DIRNAMECheck 0x012a0019L   /* NAKA_APFUNC_CP_FD_DIRNAMECheck */

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
extern char ram_2e2d2a[];                               /* HDAE5000_Fmt_2_2d_Lbn_ShowEntry */
extern char HDAE5000_Fmt_3_3d_Lbn_ShowEntry[];
extern char HDAE5000_Fmt_1_1d_Lbn_ShowEntry[];
extern char ram_2e2d3e[];                               /* HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2 */
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
   two lines at the end.
   r23 (run 98 could not check form a; fsb's K&R listing departed at +160): unsigned char parameters (fsb's
   prologue matched); ObjIds unsigned long passed as (long) / to PartList_Build's long; the song record a local
   assigned before its MemCopy (the ROM calls FlsItem_SongRecord before pushing the count, then pushes XHL);
   FlsItem_Get's &item early through its void * parameter; the part mask in r (the ROM keeps i, the item result
   and the mask in IZ: `ld iz,hl` after Song_PartMask, `push iz` last).
   Open: `ld wa,37; mul xwa,iz` (V4.23: `ld wa,iz; mul wa,37`). */
void FlsScrRefresh_c(unsigned char variant, unsigned char mode)
{
    char s[22];
    struct FlsItem item;
    unsigned int k;     /* r27: the row size through a local, for the ROM's `ld wa,37; mul xwa,iz` */
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
            k = 37;
            HDAE5000_MemCopy(&ram_22b020[k * i + 2], HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh, 35);
            HDAE5000_SPrintf(s, ram_2e2ee4, HDAE5000_RAM_FlsItemPageBase + i + 1);
            HDAE5000_MemCopy(&ram_22b020[k * i], s, HDAE5000_StrLen(s));
            rec = HDAE5000_FlsItem_SongRecord(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i);
            HDAE5000_MemCopy(&ram_22b020[k * i + 3], rec, 26);
            if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i, &item) != 0xffff) {
                if (item.as == 1)
                    ram_22b020[k * i + 32] = '*';
                if (item.al == 1)
                    ram_22b020[k * i + 35] = '*';
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
        /* r27: the ROM loads BC / DE before `pushw iz`; run 109 pushed first.  hd_r23_drv.c's matched call has
           int parameters for dir / song (a conversion: evaluated before the push); the casts stand for that here */
        HDAE5000_PartList_Build(ram_2e2e94[variant], (int)item.dir, (int)item.song, r);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[variant], 0xffff, 0xffff, 0xffff);
    if (mode != 2) {
        CALLV(ROOT->SendEvent)((long)ram_2e2e9c[variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)((long)ram_2e2ea4[variant], EVT_DRAW, 0L);
    }
}

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
long HDAE5000_FlsLoadScreen(long obj, long ev, long arg)
{
    struct FlsItem it;
    unsigned int fls;
    unsigned int item;
    int mask;

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
                if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
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
        HDAE5000_RAM_CurDir = (unsigned int)arg + HDAE5000_RAM_DirPageBase;
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
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int i;     /* r27: no `register` (run 109: it was served first and got QIZ); declared before j / mask */
    unsigned int j;
    unsigned int mask;
    long h;

    for (i = 0; i < count; i++) {
        if (HDAE5000_RAM_FdList.sel[(unsigned long)i] == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], &HDAE5000_RAM_FdList.rows[i * 12 + 3], 6);
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

/* the copy-to-HD screen's directory selection.  r23 (run 98: +204): (unsigned int)arg + DirPageBase; timers */
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
        if (HDAE5000_Dir_IsBlankName(HDAE5000_RAM_CurDir = (unsigned int)arg + HDAE5000_RAM_DirPageBase) == 0xffff) {
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CP_UNNAMED, EVT_SHOW, 0L);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ATTEN_CP_UNNAMED_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ATTEN_CP_UNNAMED_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
        } else {
            n = HDAE5000_Count_Active_Files();
            if (HDAE5000_Dir_CountEmptySongs(HDAE5000_RAM_CurDir) >= n) {
                CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
                if (HDAE5000_CopyToHd_Execute(HDAE5000_RAM_FdList.sel, 20, HDAE5000_RAM_CurDir) != 0xffff)
                    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, 0L);
            } else {
                CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_FULL_DIR, EVT_SHOW, 0L);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ATTEN_FULL_DIR_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ATTEN_FULL_DIR_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_CP_FD_DIRNAMECheck, EVT_SET_STRING,
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir =
                                                             (unsigned int)arg + HDAE5000_RAM_DirPageBase));
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

/* the "write confirm" switch: keys 0 / 1 save the song under the typed name, 6 / 7 go back.
   r23 (run 98: +229): SaveSongWithUi's stacked arguments in the ROM's push order (name, 1, obj) */
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
                                    ram_23a04e, 1, OBJ_SELECT_FILE);
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

/* the delete-option switches: 8 asks to delete, 10 / 11 reset the delete options from the song's parts.
   r23 (run 98: +214): TypeSel_Init(void *, .., unsigned char *, ..), as the drv module's matched calls */
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
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, HDAE5000_DelOpt_TemplateBlank, 2);
            HDAE5000_DelOpt_ShowFlags();
            break;
        case 11:
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, HDAE5000_DelOpt_TemplateBlank, 1);
            HDAE5000_RAM_DeleteOptions.mask = 0;
            HDAE5000_DelOpt_ShowFlags();
        }
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}
