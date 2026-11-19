/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v2_01i/hdae5000_song_module2.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 2a80f3489306a0e4339407ea0b31078ac2ad049c73cebe379b233db3cf589627 (tar-sha256); compiled at -Xr */
/* Functions of hdae5000_ui_display.s.  (hdae5000_song_module2.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_song_module2.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_Song_IsUsed HDAE5000_Song_CheckFreeSpace HDAE5000_Song_PartMask
   cc900-module: HDAE5000_LoadSong_Lsw HDAE5000_LoadSong_Pmt HDAE5000_LoadSong_Sqt HDAE5000_LoadSong_Cmp HDAE5000_LoadSong_Tm
   cc900-module: HDAE5000_LoadSong_Msp HDAE5000_LoadSong_Rcm HDAE5000_LoadSong_Md HDAE5000_LoadSong_Tlx
   cc900-module: HDAE5000_SaveSong_Lsw HDAE5000_SaveSong_Pmt HDAE5000_SaveSong_Sqt HDAE5000_SaveSong_Cmp HDAE5000_SaveSong_Tm
   cc900-module: HDAE5000_SaveSong_Msp HDAE5000_SaveSong_Rcm HDAE5000_SaveSong_Md HDAE5000_SaveSong_Tlx
   cc900-module: HDAE5000_CopyFdSongToHd_Lsw HDAE5000_CopyFdSongToHd_Pmt HDAE5000_CopyFdSongToHd_Sqt HDAE5000_CopyFdSongToHd_Cmp
   cc900-module: HDAE5000_CopyFdSongToHd_Tm HDAE5000_CopyFdSongToHd_Msp HDAE5000_CopyFdSongToHd_Rcm HDAE5000_CopyFdSongToHd_Md
   cc900-module: HDAE5000_CopyFdSongToHd_Tlx
   cc900-module: HDAE5000_DeleteSongPart_Lsw HDAE5000_DeleteSongPart_Pmt HDAE5000_DeleteSongPart_Sqt HDAE5000_DeleteSongPart_Cmp
   cc900-module: HDAE5000_DeleteSongPart_Tm HDAE5000_DeleteSongPart_Msp HDAE5000_DeleteSongPart_Rcm HDAE5000_DeleteSongPart_Md
   cc900-module: HDAE5000_DeleteSongPart_Tlx HDAE5000_DeleteSongParts HDAE5000_Fls_ForgetSong
   cc900-module: HDAE5000_RoundUpToSector HDAE5000_TlxPart_Describe HDAE5000_HD_WriteOpen HDAE5000_HD_WriteClose
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

struct ResInfo { unsigned long addr; unsigned long size; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
struct RcmCtx { unsigned int state; unsigned int dir; unsigned int song; unsigned int result; };
struct TlxHdr { unsigned char pad[18]; unsigned long trlen; };
typedef struct { long quot; long rem; } ldiv_t;

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern ldiv_t __cdecl HDAE5000_LDiv(long, long);

extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
extern int HDAE5000_SwapBytes32();
extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_WriteTables_Status(void);
extern void HDAE5000_SeparateOutput_Apply(void);
extern void HDAE5000_Lyrics_ClearBuffer(void);
extern int HDAE5000_RcmStream_Read();
extern int HDAE5000_RcmStream_Write();
extern unsigned int HDAE5000_RcmStream_LastResult(void);
extern long HDAE5000_RcmStream_FreeSpace();

/* the module's other functions (cc900-module), defined elsewhere or below */
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_CheckFreeSpace(unsigned int mask);
extern int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song);
extern void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song);
extern int HDAE5000_HD_WriteClose(void);
int HDAE5000_TlxPart_Describe();
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);
unsigned long HDAE5000_RoundUpToSector(unsigned long n);
int HDAE5000_HD_WriteOpen(long *slot);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern unsigned char HDAE5000_RAM_SeparateOutputMode;
extern unsigned char HDAE5000_RAM_SeparateDrumPart;
extern unsigned char HDAE5000_RAM_SeparateBassPart;
extern struct RcmCtx HDAE5000_RAM_RcmStreamState;
extern unsigned int HDAE5000_RAM_RcmStreamDir;
extern unsigned int HDAE5000_RAM_RcmStreamSong;
extern struct RcmCtx HDAE5000_RcmStream_InitialState;
extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern unsigned long HDAE5000_RAM_LyricFileLength;

/* the "rb" fopen modes, HDAE5000_CopyFdSongToHd_Str_rb and HDAE5000_CopyFdSongToHd_<Part>_Str_rb */
extern char HDAE5000_CopyFdSongToHd_Str_rb[];
extern char ram_2f83fa[], ram_2f8404[], ram_2f840e[], ram_2f8418[], ram_2f8420[];
extern char ram_2f842a[], ram_2f8434[], ram_2f843c[], ram_2f8446[];
/* the extensions, pushed as pushw hi16 / lo16 (an extern array; a numeric constant gives ld xwa,imm / push xwa):
   HDAE5000_CopyFdSongToHd_Str_TTX (0x2f8efe), HDAE5000_CopyFdSongToHd_<Part>_Str_<PART>, under ram_<hex> names
   because the part labels share their first 31 characters with _Str_rb */
extern char ram_2f83f4[], ram_2f83f4[], ram_2f83fe[], ram_2f8408[], ram_2f8412[];
extern char ram_2f841c[], ram_2f8424[], ram_2f842e[], ram_2f8438[], ram_2f8440[];
#define STR_TTX ram_2f83f4
#define STR_LSW ram_2f83f4
#define STR_PMT ram_2f83fe
#define STR_SQT ram_2f8408
#define STR_CMP ram_2f8412
#define STR_TM  ram_2f841c
#define STR_MSP ram_2f8424
#define STR_RCM ram_2f842e
#define STR_MD  ram_2f8438
#define STR_TLX ram_2f8440

#define TLX_TRLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer[18])

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

unsigned int HDAE5000_Dir_CountEmptySongs(unsigned int dir)
{
    unsigned int n;
    unsigned int song;

    n = 0;
    for (song = 0; song < 16; song++)
        if (HDAE5000_Song_IsUsed(dir, song) == -1)
            n++;
    return n;
}

int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song);
int HDAE5000_LoadSong_Rcm(unsigned int dir, unsigned int song);
int HDAE5000_LoadSong_Tlx(unsigned int dir, unsigned int song);

/* the stacked words (retd 4; V4.23 puts the last parameter lowest): keep = 1 leaves the drive spinning (xsp+12),
   sleep = 1 puts the main task to sleep (xsp+14) */
int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep)
{
    int ret;

    CALLV(HAMA->PlayHalt)(1);
    if (sleep == 1)
        CALLV(ROOT->SleepMainTask)();
    HDAE5000_ATA_SoftReset_Status();
    if (mask & 0x001)
        ret = HDAE5000_LoadSong_Lsw(dir, song);
    if (ret != -1 && (mask & 0x002))
        ret = HDAE5000_LoadSong_Pmt(dir, song);
    if (ret != -1 && (mask & 0x004))
        ret = HDAE5000_LoadSong_Sqt(dir, song);
    if (ret != -1 && (mask & 0x008))
        ret = HDAE5000_LoadSong_Cmp(dir, song);
    if (ret != -1 && (mask & 0x010))
        ret = HDAE5000_LoadSong_Tm(dir, song);
    if (ret != -1 && (mask & 0x020))
        ret = HDAE5000_LoadSong_Msp(dir, song);
    if (ret != -1 && (mask & 0x040))
        ret = HDAE5000_LoadSong_Rcm(dir, song);
    if (ret != -1 && (mask & 0x080))
        ret = HDAE5000_LoadSong_Md(dir, song);
    if (ret != -1 && (mask & 0x100))
        ret = HDAE5000_LoadSong_Tlx(dir, song);
    if (keep != 1)
        HDAE5000_ATA_Standby_Status();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return ret;
}

int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Pmt(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song);
int HDAE5000_SaveSong_Tlx(unsigned int dir, unsigned int song);

/* stacked words (retd 6), lowest first: keep (xsp+18), sleep, mask (xsp+22) */
int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, unsigned int mask, int sleep, int keep)
{
    int ret = 0;

    if (mask == 0)
        return ret;
    if (HDAE5000_Song_CheckFreeSpace(mask) != -1) {
        CALLV(HAMA->PlayHalt)(1);
        if (sleep == 1)
            CALLV(ROOT->SleepMainTask)();
        HDAE5000_ATA_SoftReset_Status();
        if (mask & 0x001) {
            if ((ret = HDAE5000_SaveSong_Lsw(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Lsw(dir, song);
        } else
            HDAE5000_DeleteSongPart_Lsw(dir, song);
        if (ret != -1 && (mask & 0x002)) {
            if ((ret = HDAE5000_SaveSong_Pmt(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Pmt(dir, song);
        } else
            HDAE5000_DeleteSongPart_Pmt(dir, song);
        if (ret != -1 && (mask & 0x004)) {
            if ((ret = HDAE5000_SaveSong_Sqt(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Sqt(dir, song);
        } else
            HDAE5000_DeleteSongPart_Sqt(dir, song);
        if (ret != -1 && (mask & 0x008)) {
            if ((ret = HDAE5000_SaveSong_Cmp(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Cmp(dir, song);
        } else
            HDAE5000_DeleteSongPart_Cmp(dir, song);
        if (ret != -1 && (mask & 0x010)) {
            if ((ret = HDAE5000_SaveSong_Tm(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Tm(dir, song);
        } else
            HDAE5000_DeleteSongPart_Tm(dir, song);
        if (ret != -1 && (mask & 0x020)) {
            if ((ret = HDAE5000_SaveSong_Msp(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Msp(dir, song);
        } else
            HDAE5000_DeleteSongPart_Msp(dir, song);
        if (ret != -1 && (mask & 0x040)) {
            if ((ret = HDAE5000_SaveSong_Rcm(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Rcm(dir, song);
        } else
            HDAE5000_DeleteSongPart_Rcm(dir, song);
        if (ret != -1 && (mask & 0x080)) {
            if ((ret = HDAE5000_SaveSong_Md(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Md(dir, song);
        } else
            HDAE5000_DeleteSongPart_Md(dir, song);
        if (ret != -1 && (mask & 0x100)) {
            if ((ret = HDAE5000_SaveSong_Tlx(dir, song)) == -1)
                HDAE5000_DeleteSongPart_Tlx(dir, song);
        } else
            HDAE5000_DeleteSongPart_Tlx(dir, song);
        if (ret != -1) {
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0x1ff, 0, keep);
        if (keep != 1)
            HDAE5000_ATA_Standby_Status();
        if (sleep == 1)
            CALLV(ROOT->WakeUpMainTask)();
        CALLV(HAMA->EditSwRefresh)();
        CALLV(HAMA->PlayStandBy)();
    } else
        ret = -1;
    return ret;
}

int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song)
{
    int ret = 0;

    HDAE5000_RAM_RcmStreamState = HDAE5000_RcmStream_InitialState;
    HDAE5000_RAM_RcmStreamDir = dir;
    HDAE5000_RAM_RcmStreamSong = song;
    if ((ret = HDAE5000_HD_WriteOpen(&SLOT(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong))) != -1) {
        ret = CALLR(int, HAMA->rcm_sv_XAPR_j)((long)HDAE5000_RcmStream_FreeSpace, (long)HDAE5000_RcmStream_Write,
                                              (long)HDAE5000_RcmStream_LastResult);
        ret = HDAE5000_HD_WriteClose();
    }
    return ret;
}

/* the TLX part's extent; returns its first argument */

int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname);
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname);

/* XDE = the floppy song's 8-character file name; stacked words (retd 6), lowest first: keep, sleep, mask (xsp+64) */
int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, char *fdname, unsigned int mask, int sleep,
                            int keep)
{
    int ret = 0;
    char name[27];
    char fname[14];

    if (HDAE5000_Song_CheckFreeSpace(mask) != -1) {
        CALLV(HAMA->PlayHalt)(1);
        if (sleep == 1)
            CALLV(ROOT->SleepMainTask)();
        HDAE5000_ATA_SoftReset_Status();
        if (mask & 0x001) {
            if ((ret = HDAE5000_CopyFdSongToHd_Lsw(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Lsw(dir, song);
        }
        if (ret != -1 && (mask & 0x002)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Pmt(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Pmt(dir, song);
        }
        if (ret != -1 && (mask & 0x004)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Sqt(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Sqt(dir, song);
        }
        if (ret != -1 && (mask & 0x008)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Cmp(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Cmp(dir, song);
        }
        if (ret != -1 && (mask & 0x010)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Tm(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Tm(dir, song);
        }
        if (ret != -1 && (mask & 0x020)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Msp(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Msp(dir, song);
        }
        if (ret != -1 && (mask & 0x040)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Rcm(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Rcm(dir, song);
        }
        if (ret != -1 && (mask & 0x080)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Md(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Md(dir, song);
        }
        if (ret != -1 && (mask & 0x100)) {
            if ((ret = HDAE5000_CopyFdSongToHd_Tlx(dir, song, fdname)) == -1)
                HDAE5000_DeleteSongPart_Tlx(dir, song);
        }
        if (ret != -1) {
            HDAE5000_MemFill(name, ' ', 26);
            name[26] = 0;
            HDAE5000_MemCopy(fname, fdname, 8);
            HDAE5000_StrCpy(fname + 8, STR_TTX);
            if (CALLR(int, HAMA->fopen_ext)(fname, HDAE5000_CopyFdSongToHd_Str_rb) >= 0)
                CALLV(HAMA->fread_ext)(name, 26L);
            else
                HDAE5000_MemCopy(name, fdname + 2, 6);
            CALLV(HAMA->fclose_ext)();
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0x1ff, 0, keep);
        if (keep != 1)
            HDAE5000_ATA_Standby_Status();
        if (sleep == 1)
            CALLV(ROOT->WakeUpMainTask)();
        CALLV(HAMA->PlayStandBy)();
        CALLV(HAMA->EditSwRefresh)();
    } else
        ret = -1;
    return ret;
}

/* PMT: the first write's result is kept (ret); the 0x8000-byte reads that follow are appended */

/* SQT, CMP, RCM: as PMT, but the first write's result is only tested */

/* TM, MSP, MD: one read of the resource's size (TM's fixed at 0x72aa) */

/* TLX: the 22-byte TLhd header first (after clearing the buffer), then the TLtr chunk behind it */

/* WA = directory, BC = sleep, DE = keep */
void HDAE5000_DeleteDirectory(unsigned int dir, int sleep, int keep)
{
    unsigned int song;

    CALLV(HAMA->PlayHalt)(1);
    if (sleep == 1)
        CALLV(ROOT->SleepMainTask)();
    HDAE5000_ATA_SoftReset_Status();
    for (song = 0; song < 16; song++) {
        if (HDAE5000_Song_IsUsed(dir, song) != -1) {
            HDAE5000_DeleteSongPart_Lsw(dir, song);
            HDAE5000_DeleteSongPart_Pmt(dir, song);
            HDAE5000_DeleteSongPart_Sqt(dir, song);
            HDAE5000_DeleteSongPart_Cmp(dir, song);
            HDAE5000_DeleteSongPart_Tm(dir, song);
            HDAE5000_DeleteSongPart_Msp(dir, song);
            HDAE5000_DeleteSongPart_Rcm(dir, song);
            HDAE5000_DeleteSongPart_Md(dir, song);
            HDAE5000_DeleteSongPart_Tlx(dir, song);
            HDAE5000_Fls_ForgetSong(dir, song);
        }
        HDAE5000_MemFill(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], ' ', 26);
    }
    HDAE5000_MemFill(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ' ', 16);
    HDAE5000_HD_WriteTables_Status();
    if (keep != 1)
        HDAE5000_ATA_Standby_Status();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
}

/* stacked words (retd 4), lowest first: keep (xsp+12), sleep (xsp+14) */
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep)
{
    if (mask != 0) {
        CALLV(HAMA->PlayHalt)(1);
        if (sleep == 1)
            CALLV(ROOT->SleepMainTask)();
        HDAE5000_ATA_SoftReset_Status();
        if (mask & 0x001)
            HDAE5000_DeleteSongPart_Lsw(dir, song);
        if (mask & 0x002)
            HDAE5000_DeleteSongPart_Pmt(dir, song);
        if (mask & 0x004)
            HDAE5000_DeleteSongPart_Sqt(dir, song);
        if (mask & 0x008)
            HDAE5000_DeleteSongPart_Cmp(dir, song);
        if (mask & 0x010)
            HDAE5000_DeleteSongPart_Tm(dir, song);
        if (mask & 0x020)
            HDAE5000_DeleteSongPart_Msp(dir, song);
        if (mask & 0x040)
            HDAE5000_DeleteSongPart_Rcm(dir, song);
        if (mask & 0x080)
            HDAE5000_DeleteSongPart_Md(dir, song);
        if (mask & 0x100)
            HDAE5000_DeleteSongPart_Tlx(dir, song);
        if (HDAE5000_Song_IsUsed(dir, song) == -1) {
            HDAE5000_MemFill(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], ' ', 26);
            HDAE5000_Fls_ForgetSong(dir, song);
        }
        HDAE5000_HD_WriteTables_Status();
        if (keep != 1)
            HDAE5000_ATA_Standby_Status();
        if (sleep == 1)
            CALLV(ROOT->WakeUpMainTask)();
        CALLV(HAMA->PlayStandBy)();
        CALLV(HAMA->EditSwRefresh)();
    }
}

/* bytes rounded up to whole 512-byte sectors, 0 counting as one sector */

/* XDE = the 54-byte record to fill: mask, directory name, song name, part bytes; HL = 0, or 0xffff (no song) */

/* one return: the ROM's -1 path jumps (jr t) to the common ret; two returns gave two rets (run 75) */
