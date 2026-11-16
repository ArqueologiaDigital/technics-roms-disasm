/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r27_c5.c (2026-11-16-116-hd-r27c)
   sha256 6a393e2176b58693e5d71a13690481e7fc87847960ad688cc318a2a0c593f546 (tar-sha256); compiled at -Xr */
/* lane_hd round 27, helper h_r27c, file 5: the PC-link (PPORT) service module, hd_r4_ppa.c (helper h_pport) with
   the departures of run 2026-11-16-56-hd-r6 worked in.  Apart from the calr to HDAE5000_DebugTrace (same file),
   that run differed from the ROM only in:
   - the stacked SPrintf formats: the ROM pushes `pushw hi16 / pushw lo16`, V4.23 gave `ld xwa,imm; push xwa` for
     the constant pointers.  They are now char arrays (by address) and SPrintf's format a plain char *: an array
     passed with no conversion is pushed as the pair (the matched TitleInfo_Build);
   - HD_GetBlockInfo's and GetResouceInfo's structure argument: the ROM has `lda xwa,(xsp+N); ld xbc,xwa`, a
     converted argument: now cast ((void *) / (char *), the latter as the matched HDD_UTIL_PAGE);
   - the stacked int arguments of LoadSong / SaveSong / DeleteSongParts: the ROM pushes 0 then 1 (and SaveSong's
     mask first); V4.23 pushes left to right, so the source order is reversed;
   - Svc21's frame: ret at +4 and i at +6 in the ROM, the other way in run 56: i is now declared after ret.
   Not re-read against the ROM beyond those points: Svc03, Svc13, Svc16, Svc20, Svc24 (run 56's other notes apply).
   cc900-options: -Xr
   cc900-module: HDAE5000_DebugTrace
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
extern char ram_2f8f7c[];
#define F_ppib_adr ram_2f8f7c
extern char ram_2f8fc6[];
#define F_hddname ram_2f8fc6
extern char ram_2f8fd2[];
#define F_hddtrck ram_2f8fd2
extern char ram_2f8fe0[];
#define F_hddhead ram_2f8fe0
extern char ram_2f8fee[];
#define F_hddsctr ram_2f8fee
extern char ram_2f8ffc[];
#define F_hddscby ram_2f8ffc
extern char ram_2f902e[];
#define F_FGB_ptr ram_2f902e
extern char ram_2f903c[];
#define F_FGB_wid ram_2f903c
extern char ram_2f904a[];
#define F_FGB_num ram_2f904a
extern char ram_2f9082[];
#define F_FEB_ptr ram_2f9082
extern char ram_2f9090[];
#define F_FEB_wid ram_2f9090
extern char ram_2f909e[];
#define F_FEB_num ram_2f909e
extern char ram_2f90d0[];
#define F_FLS_ptr ram_2f90d0
extern char ram_2f90de[];
#define F_FLS_wid ram_2f90de
extern char ram_2f90ec[];
#define F_FLS_num ram_2f90ec
extern char ram_2f90fa[];
#define F_FLS_ent ram_2f90fa
extern char ram_2f91ea[];
#define F_dirname ram_2f91ea
extern char ram_2f91f8[];
#define F_sngname ram_2f91f8
extern char ram_2f92ae[];
#define F_work_adr ram_2f92ae
extern char ram_2f92fa[];
#define F_SUFFIX ram_2f92fa

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
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
extern int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, unsigned int mask, int sleep,
                             int spin);
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

    HDAE5000_HD_GetBlockInfo(0, (void *)&bi);
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

    HDAE5000_HD_GetBlockInfo(1, (void *)&bi);
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

    HDAE5000_HD_GetBlockInfo(2, (void *)&bi);
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
    CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
    PP_L(70) = (unsigned long)info.addr;
    PP_L(74) = info.size;
    PPIB[78] = 0;
    CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
    PP_L(79) = (unsigned long)info.addr;
    PP_L(83) = info.size;
    PPIB[87] = 0;
    CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
    PP_L(88) = (unsigned long)info.addr;
    PP_L(92) = info.size;
    PPIB[96] = 0;
    CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
    PP_L(97) = (unsigned long)info.addr;
    PP_L(101) = info.size;
    PP_L(101) += CALLR(unsigned long, HAMA->SeqSavePre)();
    PPIB[105] = 0;
    CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
    PP_L(106) = (unsigned long)info.addr;
    PP_L(110) = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    PPIB[114] = 0;
    CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
    PP_L(115) = (unsigned long)info.addr;
    PP_L(119) = 0x72aaL;
    PPIB[123] = 0;
    CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
    PP_L(124) = (unsigned long)info.addr;
    PP_L(128) = CALLR(unsigned long, HAMA->msp_sv_mae)();
    PPIB[132] = 0;
    CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
    PP_L(133) = (unsigned long)info.addr;
    PP_L(137) = 0xad000L;
    PPIB[141] = 0;
    CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
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
    if (HDAE5000_LoadSong(dir, song, PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f9208);
    HDAE5000_DebugTrace(ram_2f922a);
    return ret;
}

int PP_Svc15(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_SaveSong(dir, song, (char *)(PPIB + 2), PP_W(0), 0, 1) == -1)
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
    int ret;
    unsigned char i;
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
    HDAE5000_DeleteSongParts(dir, song, PP_W(0), 0, 1);
    return 0;
}
