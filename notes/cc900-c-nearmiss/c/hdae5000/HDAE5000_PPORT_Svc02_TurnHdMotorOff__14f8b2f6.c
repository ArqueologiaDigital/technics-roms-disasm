/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_ppa.c (2026-11-16-56-hd-r6)
   sha256 14f8b2f6e52a7b7c9306f45841db09c00b3f45a67e845be4f571123ab9e00578 (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_pport, form a: the PC-link (PPORT) service module of hdae5000_ui_display.s,
   0x294414-0x29501c (HDAE5000_DebugTrace .. HDAE5000_PPORT_Svc27_DeleteSongParts), in ROM order.  Options: -Xr.
   Left out (hand assembly): HDAE5000_PPORT_ServicePending onward (nop padding, `ei`, XSP swaps).
   Included beyond the prompt's list, because they sit inside the module and look compiled: Svc18 (a tail
   `jp (xhl)`, like Svc16/Svc20's tail `jrl` to HDAE5000_DebugTrace) and Svc27 (Svc14's shape without the trace).
   Reading of the hand source behind these guesses:
   - every string is a C literal in the original; V4.23 spells a literal passed in a register as lda (an extern
     array does the same) but pushes a stacked one as `pushw hi16 / pushw lo16` (a 32-bit constant), which an
     extern array does not do (it gives lda + push).  So the banners are extern arrays and the stacked format
     strings are constant pointers, both by address (their labels are over 31 characters and share their first 31);
   - HDAE5000_RAM_PportInfoBlock is a byte array read through casts: its nine 9-byte part records put longs at odd
     offsets, which a struct might pad;
   - the song record of (dir, song) is DirNames + dir * 0x4c0 + 0x780 + song * 76 (SONG_OFS, as round 3); the ROM
     forms it with `ld xR, DirNames` (immediate, the pointer spelling) and adds the field offset to the index
     (i * 4 + 36, i + 26): written here as the struct member, so V4.23's own folding puts it in the index;
   - locals: the first declared gets the highest frame address (round 3's LoadSong_*); the 0x294415 `ret` is a
     second empty function that nothing calls.
   cc900-name: PP_Svc01=HDAE5000_PPORT_Svc01_GetInfoBlockPointer
   cc900-name: PP_Svc02=HDAE5000_PPORT_Svc02_TurnHdMotorOff
   cc900-name: PP_Svc03=HDAE5000_PPORT_Svc03_SendInfosAboutHd
   cc900-name: PP_Svc04=HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock
   cc900-name: PP_Svc05=HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock
   cc900-name: PP_Svc06=HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock
   cc900-name: PP_Svc07=HDAE5000_PPORT_Svc07_ReadDirBlockFromHd
   cc900-name: PP_Svc08=HDAE5000_PPORT_Svc08_ReadFileBlockFromHd
   cc900-name: PP_Svc09=HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd
   cc900-name: PP_Svc10=HDAE5000_PPORT_Svc10_WriteDirBlockToHd
   cc900-name: PP_Svc11=HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd
   cc900-name: PP_Svc12=HDAE5000_PPORT_Svc12_WriteFlsBlockToHd
   cc900-name: PP_Svc13=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   cc900-name: PP_Svc14=HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory
   cc900-name: PP_Svc15=HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd
   cc900-name: PP_Svc16=HDAE5000_PPORT_Svc16_InitWholeSongInMemory
   cc900-name: PP_Svc18=HDAE5000_PPORT_Svc18_RequestNormalMode
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace
   cc900-name: PP_Svc20=HDAE5000_PPORT_Svc20_PreWholeSongInMemory
   cc900-name: PP_Svc21=HDAE5000_PPORT_Svc21_WriteOpenHD
   cc900-name: PP_Svc22=HDAE5000_PPORT_Svc22_WriteCloseHD
   cc900-name: PP_Svc23=HDAE5000_PPORT_Svc23_WriteFileHD
   cc900-name: PP_Svc24=HDAE5000_PPORT_Svc24_ReadOpenHD
   cc900-name: PP_Svc25=HDAE5000_PPORT_Svc25_ReadFileHD
   cc900-name: PP_Svc27=HDAE5000_PPORT_Svc27_DeleteSongParts
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
#define EVT_ACTIVATE_STATE 0x1c00013L
#define EVT_CHANGE_MODE 0x1c00014L
#define NAKA_MODE_MD_NORMAL 0x1800001L
/* ---- end of hdae_ids.h ---- */

struct ResInfo { unsigned char *addr; unsigned long size; };
struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
struct SongRec { unsigned char name[26]; unsigned char part[9]; unsigned char pad; unsigned long slot[9];
                 unsigned char tail[4]; };

extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char ram_23a04a;                  /* HDAE5000_RAM_FileFormat_VersionMajor (a .set, not resolvable) */
extern unsigned char ram_23a04c;                  /* HDAE5000_RAM_FileFormat_VersionMinor */

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

/* trace banners and blank lines (HDAE5000_PPORT_SvcNN_*_Str_<name>), passed in XWA: lda */
extern char ram_2f8f5e[], ram_2f8f8c[];                                   /* Svc01 GetInfoBlockPointer, Blank1 */
extern char ram_2f8f8e[], ram_2f8fa8[];                                   /* Svc02 */
extern char ram_2f8faa[], ram_2f900a[];                                   /* Svc03 */
extern char ram_2f900c[], ram_2f9058[];                                   /* Svc04 */
extern char ram_2f905a[], ram_2f90ac[];                                   /* Svc05 */
extern char ram_2f90ae[], ram_2f9108[];                                   /* Svc06 */
extern char ram_2f910a[], ram_2f9128[];                                   /* Svc07 */
extern char ram_2f912a[], ram_2f9148[];                                   /* Svc08 */
extern char ram_2f914a[], ram_2f9168[];                                   /* Svc09 */
extern char ram_2f916a[], ram_2f9186[];                                   /* Svc10 */
extern char ram_2f9188[], ram_2f91ac[];                                   /* Svc11 */
extern char ram_2f91ae[], ram_2f91ca[];                                   /* Svc12 */
extern char ram_2f91cc[], ram_2f9206[];                                   /* Svc13 */
extern char ram_2f9208[], ram_2f922a[];                                   /* Svc14 */
extern char ram_2f922c[], ram_2f924c[];                                   /* Svc15 */
extern char ram_2f924e[], ram_2f926e[];                                   /* Svc16 */
extern char ram_2f9270[], ram_2f9284[];                                   /* Svc17 */
extern char ram_2f9286[], ram_2f92be[];                                   /* Svc19 */
extern char ram_2f92c0[], ram_2f92e0[];                                   /* Svc20 */
extern char ram_2f92e2[];                                                 /* Svc21 */
extern char ram_2f9306[];                                                 /* Svc22 */
extern char ram_2f931e[];                                                 /* Svc23 */
extern char ram_2f9336[];                                                 /* Svc24 */
extern char ram_2f934c[];                                                 /* Svc25 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
#define F_ppib_adr  ((char *)0x2f8f7cL)
#define F_hddname   ((char *)0x2f8fc6L)
#define F_hddtrck   ((char *)0x2f8fd2L)
#define F_hddhead   ((char *)0x2f8fe0L)
#define F_hddsctr   ((char *)0x2f8feeL)
#define F_hddscby   ((char *)0x2f8ffcL)
#define F_FGB_ptr   ((char *)0x2f902eL)
#define F_FGB_wid   ((char *)0x2f903cL)
#define F_FGB_num   ((char *)0x2f904aL)
#define F_FEB_ptr   ((char *)0x2f9082L)
#define F_FEB_wid   ((char *)0x2f9090L)
#define F_FEB_num   ((char *)0x2f909eL)
#define F_FLS_ptr   ((char *)0x2f90d0L)
#define F_FLS_wid   ((char *)0x2f90deL)
#define F_FLS_num   ((char *)0x2f90ecL)
#define F_FLS_ent   ((char *)0x2f90faL)
#define F_dirname   ((char *)0x2f91eaL)
#define F_sngname   ((char *)0x2f91f8L)
#define F_work_adr  ((char *)0x2f92aeL)
#define F_SUFFIX    ((char *)0x2f92faL)

extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_ATA_Standby_Status(void);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *g);
extern void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi);
extern int HDAE5000_HD_LoadTables(int spin);
extern int HDAE5000_HD_StoreTables(int spin);
extern int HDAE5000_TlxPart_Describe(int kind, struct ResInfo *info);
extern int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *si);
extern int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
extern int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, int spin, int sleep,
                             unsigned int mask);
extern int HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
extern int HDAE5000_HD_FormatDrive(int sleep);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern int HDAE5000_HD_WriteClose(void);
extern int HDAE5000_HD_WriteStream(void *src, unsigned long n);
extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, unsigned long *slot);
extern int HDAE5000_HD_ReadFileNext(void *dst, unsigned long n, unsigned long *slot);

void HDAE5000_DebugTrace(char *s)
{
}

void HDAE5000_DebugTrace_Unused(char *s)
{
}

unsigned char *PP_Svc01(void)
{
    char buf[32];

    HDAE5000_DebugTrace(ram_2f8f5e);
    HDAE5000_SPrintf(buf, F_ppib_adr, HDAE5000_RAM_PportInfoBlock);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f8f8c);
    return HDAE5000_RAM_PportInfoBlock;
}

int PP_Svc02(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_ATA_Standby_Status() == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f8f8e);
    HDAE5000_DebugTrace(ram_2f8fa8);
    return ret;
}

int PP_Svc03(void)
{
    struct HdGeom geom;
    char buf[64];

    HDAE5000_HD_GetGeometry(&geom);
    HDAE5000_MemCopy(PPIB + 151, geom.model, 30);
    PP_L(181) = geom.cyl;
    PP_W(185) = geom.heads;
    PP_W(187) = geom.spt;
    PP_W(189) = 512;
    PPIB[200] = ram_23a04a;
    PPIB[201] = ram_23a04c;
    HDAE5000_DebugTrace(ram_2f8faa);
    HDAE5000_SPrintf(buf, F_hddname);
    HDAE5000_MemCopy(buf + 10, PPIB + 151, 30);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddtrck, PP_L(181));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddhead, PP_W(185));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddsctr, PP_W(187));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddscby, PP_W(189));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f900a);
    return 0;
}

void PP_Svc04(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(0, &bi);
    PP_L(44) = (unsigned long)bi.base;
    PP_W(48) = bi.size;
    PP_W(50) = bi.count;
    HDAE5000_DebugTrace(ram_2f900c);
    HDAE5000_SPrintf(buf, F_FGB_ptr, PP_L(44));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_wid, PP_W(48));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_num, PP_W(50));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9058);
}

void PP_Svc05(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(1, &bi);
    PP_L(52) = (unsigned long)bi.base;
    PP_W(56) = bi.size;
    PP_W(58) = bi.count;
    HDAE5000_DebugTrace(ram_2f905a);
    HDAE5000_SPrintf(buf, F_FEB_ptr, PP_L(52));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_wid, PP_W(56));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_num, PP_W(58));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f90ac);
}

void PP_Svc06(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(2, &bi);
    PP_L(60) = (unsigned long)bi.base;
    PP_W(64) = bi.size;
    PP_W(66) = bi.count;
    PP_W(68) = bi.extra;
    HDAE5000_DebugTrace(ram_2f90ae);
    HDAE5000_SPrintf(buf, F_FLS_ptr, PP_L(60));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_wid, PP_W(64));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_num, PP_W(66));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_ent, PP_W(68));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9108);
}

int PP_Svc07(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_LoadTables(1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f910a);
    HDAE5000_DebugTrace(ram_2f9128);
    return ret;
}

int PP_Svc08(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_LoadTables(1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f912a);
    HDAE5000_DebugTrace(ram_2f9148);
    return ret;
}

int PP_Svc09(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_LoadTables(1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f914a);
    HDAE5000_DebugTrace(ram_2f9168);
    return ret;
}

int PP_Svc10(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_StoreTables(1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f916a);
    HDAE5000_DebugTrace(ram_2f9186);
    return ret;
}

int PP_Svc11(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_StoreTables(1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f9188);
    HDAE5000_DebugTrace(ram_2f91ac);
    return ret;
}

int PP_Svc12(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_StoreTables(1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f91ae);
    HDAE5000_DebugTrace(ram_2f91ca);
    return ret;
}

int PP_Svc13(unsigned int dir, unsigned int song)
{
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];
    int ret;

    ret = 1;
    PP_W(0) = 0;
    HDAE5000_MemFill(PPIB + 28, ' ', 16);
    HDAE5000_MemFill(PPIB + 2, ' ', 26);
    CALLV(HAMA->GetResouceInfo)(0, &info);
    PP_L(70) = (unsigned long)info.addr;
    PP_L(74) = info.size;
    PPIB[78] = 0;
    CALLV(HAMA->GetResouceInfo)(1, &info);
    PP_L(79) = (unsigned long)info.addr;
    PP_L(83) = info.size;
    PPIB[87] = 0;
    CALLV(HAMA->GetResouceInfo)(2, &info);
    PP_L(88) = (unsigned long)info.addr;
    PP_L(92) = info.size;
    PPIB[96] = 0;
    CALLV(HAMA->GetResouceInfo)(3, &info);
    PP_L(97) = (unsigned long)info.addr;
    PP_L(101) = info.size;
    PP_L(101) += CALLR(unsigned long, HAMA->SeqSavePre)();
    PPIB[105] = 0;
    CALLV(HAMA->GetResouceInfo)(5, &info);
    PP_L(106) = (unsigned long)info.addr;
    PP_L(110) = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    PPIB[114] = 0;
    CALLV(HAMA->GetResouceInfo)(6, &info);
    PP_L(115) = (unsigned long)info.addr;
    PP_L(119) = 0x72aaL;
    PPIB[123] = 0;
    CALLV(HAMA->GetResouceInfo)(7, &info);
    PP_L(124) = (unsigned long)info.addr;
    PP_L(128) = CALLR(unsigned long, HAMA->msp_sv_mae)();
    PPIB[132] = 0;
    CALLV(HAMA->GetResouceInfo)(8, &info);
    PP_L(133) = (unsigned long)info.addr;
    PP_L(137) = 0xad000L;
    PPIB[141] = 0;
    CALLV(HAMA->GetResouceInfo)(9, &info);
    PP_L(142) = (unsigned long)info.addr;
    PP_L(146) = info.size;
    PPIB[150] = 0;
    HDAE5000_TlxPart_Describe(10, &info);
    PP_L(191) = (unsigned long)info.addr;
    PP_L(195) = info.size;
    PPIB[199] = 0;
    if (HDAE5000_HD_GetSongInfo(dir, song, &si) != -1) {
        PP_W(0) = si.mask;
        HDAE5000_MemCopy(PPIB + 28, si.dirname, 16);
        HDAE5000_MemCopy(PPIB + 2, si.songname, 26);
        PPIB[78] = si.has[0];
        PPIB[96] = si.has[1];
        PPIB[105] = si.has[2];
        PPIB[114] = si.has[3];
        PPIB[123] = si.has[4];
        PPIB[132] = si.has[5];
        PPIB[141] = si.has[6];
        PPIB[150] = si.has[7];
        PPIB[199] = si.has[8];
        ret = 0;
    }
    HDAE5000_DebugTrace(ram_2f91cc);
    HDAE5000_SPrintf(buf, F_dirname, PPIB + 28);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_sngname, PPIB + 2);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9206);
    return ret;
}

int PP_Svc14(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_LoadSong(dir, song, PP_W(0), 1, 0) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f9208);
    HDAE5000_DebugTrace(ram_2f922a);
    return ret;
}

int PP_Svc15(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_SaveSong(dir, song, (char *)(PPIB + 2), 1, 0, PP_W(0)) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f922c);
    HDAE5000_DebugTrace(ram_2f924c);
    return ret;
}

void PP_Svc16(void)
{
    if (PP_W(0) & 0x01)
        CALLV(HAMA->PostLswLoad)(0);
    if (PP_W(0) & 0x02)
        CALLV(HAMA->PostPmLoad)(0);
    if (PP_W(0) & 0x04) {
        CALLV(HAMA->SeqLoadPost)(0);
        CALLV(((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    if (PP_W(0) & 0x08)
        CALLV(HAMA->cmp_ld_ato)(0);
    if (PP_W(0) & 0x10)
        CALLV(HAMA->PostTmLoad)(0);
    if (PP_W(0) & 0x20)
        CALLV(HAMA->msp_ld_ato)(0);
    if (PP_W(0) & 0x80)
        CALLV(HAMA->PostMidiLoad)(0);
    HDAE5000_DebugTrace(ram_2f924e);
    HDAE5000_DebugTrace(ram_2f926e);
}

int HDAE5000_PPORT_Svc17_FormatHd(void)
{
    int ret;

    ret = 0;
    if (HDAE5000_HD_FormatDrive(0) != 0)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f9270);
    HDAE5000_DebugTrace(ram_2f9284);
    return ret;
}

void PP_Svc18(void)
{
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_MODE, NAKA_MODE_MD_NORMAL);
}

unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2f9286);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[202]);
    HDAE5000_DebugTrace(ram_2f92be);
    return PPIB + 202;
}

void PP_Svc20(void)
{
    if (PP_W(0) & 0x01)
        CALLV(HAMA->PreLswLoad)();
    if (PP_W(0) & 0x02)
        CALLV(HAMA->PrePmLoad)();
    if (PP_W(0) & 0x04)
        CALLV(HAMA->SeqLoadPre)();
    if (PP_W(0) & 0x08)
        CALLV(HAMA->cmp_ld_mae)();
    if (PP_W(0) & 0x10)
        CALLV(HAMA->PreTmLoad)();
    if (PP_W(0) & 0x20)
        CALLV(HAMA->msp_ld_mae)();
    if (PP_W(0) & 0x80)
        CALLV(HAMA->PreMidiLoad)();
    HDAE5000_DebugTrace(ram_2f92c0);
    HDAE5000_DebugTrace(ram_2f92e0);
}

int PP_Svc21(unsigned int dir, unsigned int song)
{
    char buf[20];
    unsigned char i;
    int ret;
    unsigned int mask;

    ret = 1;
    HDAE5000_DebugTrace(ram_2f92e2);
    mask = PP_W(0);
    for (i = 0; i < 9; i++) {
        if (mask & 1) {
            if (HDAE5000_HD_WriteOpen(&SREC(dir, song)->slot[i]) != -1) {
                HDAE5000_StrNCpy((char *)SREC(dir, song)->name, (char *)(PPIB + 2), 26);
                SREC(dir, song)->part[i] = 1;
                ret = 0;
            }
            HDAE5000_SPrintf(buf, F_SUFFIX, i);
            HDAE5000_DebugTrace(buf);
            break;
        }
        mask >>= 1;
    }
    return ret;
}

int PP_Svc22(void)
{
    int ret;

    ret = 1;
    if (HDAE5000_HD_WriteClose() != -1 && HDAE5000_HD_StoreTables(1) != -1)
        ret = 0;
    HDAE5000_DebugTrace(ram_2f9306);
    return ret;
}

int PP_Svc23(void *src, unsigned long n)
{
    int ret;

    ret = 1;
    if (HDAE5000_HD_WriteStream(src, n) != -1)
        ret = 0;
    HDAE5000_DebugTrace(ram_2f931e);
    return ret;
}

int PP_Svc24(unsigned int dir, unsigned int song)
{
    int ret;
    unsigned char i;
    unsigned int mask;

    ret = 1;
    HDAE5000_DebugTrace(ram_2f9336);
    mask = PP_W(0);
    for (i = 0; i < 9; i++) {
        if (mask & 1) {
            *(unsigned long **)(PPIB + 206) = &SREC(dir, song)->slot[i];
            HDAE5000_RAM_PportReadState = 1;
            ret = 0;
            break;
        }
        mask >>= 1;
    }
    return ret;
}

int PP_Svc25(void *dst, unsigned long n)
{
    int ret;

    ret = 1;
    HDAE5000_DebugTrace(ram_2f934c);
    if (HDAE5000_RAM_PportReadState == 1) {
        HDAE5000_RAM_PportReadState = 2;
        if (HDAE5000_HD_ReadFile(dst, n, *(unsigned long **)(PPIB + 206)) != -1)
            ret = 0;
    } else if (HDAE5000_RAM_PportReadState == 2) {
        if (HDAE5000_HD_ReadFileNext(dst, n, *(unsigned long **)(PPIB + 206)) != -1)
            ret = 0;
    } else
        HDAE5000_RAM_PportReadState = 0;
    return ret;
}

int PP_Svc27(unsigned int dir, unsigned int song)
{
    HDAE5000_DeleteSongParts(dir, song, PP_W(0), 1, 0);
    return 0;
}
