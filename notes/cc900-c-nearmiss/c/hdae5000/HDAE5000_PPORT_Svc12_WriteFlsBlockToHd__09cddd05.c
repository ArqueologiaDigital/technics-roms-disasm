/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hdae5000_pport_services.c (2026-11-16-63-hd-r9s-staged)
   sha256 09cddd050395beafd4a0e0cd5d9ebb6b1de7f55773e63f88691ed87f0d1acb18 (tar-sha256); compiled at -Xr */
/* The PC-link (PPORT) service module of hdae5000_ui_display.s (0x294414-0x29501c in v2.06i), the functions of it that
   Toshiba V4.23 reproduces.  Firmware C (cc900 phase 6), STAGED (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv,
   "MATCH calr"): each calls HDAE5000_DebugTrace, which this file defines, and asm900 writes that call as calr, as the
   ROM has it (run 2026-11-16-56-hd-r6: the object file shows calr; hd_v423.py --calr models it).  So these build
   only as one C file (one module) once the build relaxes same-file calls (lane_vmb's cc900-module work).
   From helper h_pport's probes/hd_r4_ppa.c.
   cc900-options: -Xr
   cc900-name: PP_Svc02=HDAE5000_PPORT_Svc02_TurnHdMotorOff
   cc900-name: PP_Svc07=HDAE5000_PPORT_Svc07_ReadDirBlockFromHd
   cc900-name: PP_Svc08=HDAE5000_PPORT_Svc08_ReadFileBlockFromHd
   cc900-name: PP_Svc09=HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd
   cc900-name: PP_Svc10=HDAE5000_PPORT_Svc10_WriteDirBlockToHd
   cc900-name: PP_Svc11=HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd
   cc900-name: PP_Svc12=HDAE5000_PPORT_Svc12_WriteFlsBlockToHd
   cc900-name: PP_Svc22=HDAE5000_PPORT_Svc22_WriteCloseHD
   cc900-name: PP_Svc23=HDAE5000_PPORT_Svc23_WriteFileHD
   cc900-name: PP_Svc25=HDAE5000_PPORT_Svc25_ReadFileHD
   cc900-module: HDAE5000_DebugTrace
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
