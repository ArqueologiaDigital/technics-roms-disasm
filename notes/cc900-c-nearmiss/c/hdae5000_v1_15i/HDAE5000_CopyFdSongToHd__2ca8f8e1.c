/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v1_15i/hdae5000_song_module2__notlx_r82.c (2026-11-19-85-hd-r86-staged)
   sha256 2ca8f8e12da19183c71657b618435c9b768df3f79d651b64cf49b1c5f988c493 (tar-sha256); compiled at -Xr */
/* hdae5000_v1_15i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-79-hd-r82-v1notlx (hd_r82a_song_module2__notlx.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r82a_song_module2__notlx.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_Song_IsUsed HDAE5000_Song_CheckFreeSpace HDAE5000_Song_PartMask
   cc900-module: HDAE5000_LoadSong_Lsw HDAE5000_LoadSong_Pmt HDAE5000_LoadSong_Sqt HDAE5000_LoadSong_Cmp HDAE5000_LoadSong_Tm
   cc900-module: HDAE5000_LoadSong_Msp HDAE5000_LoadSong_Rcm HDAE5000_LoadSong_Md
   cc900-module: HDAE5000_SaveSong_Lsw HDAE5000_SaveSong_Pmt HDAE5000_SaveSong_Sqt HDAE5000_SaveSong_Cmp HDAE5000_SaveSong_Tm
   cc900-module: HDAE5000_SaveSong_Msp HDAE5000_SaveSong_Rcm HDAE5000_SaveSong_Md
   cc900-module: HDAE5000_CopyFdSongToHd_Lsw HDAE5000_CopyFdSongToHd_Pmt HDAE5000_CopyFdSongToHd_Sqt HDAE5000_CopyFdSongToHd_Cmp
   cc900-module: HDAE5000_CopyFdSongToHd_Tm HDAE5000_CopyFdSongToHd_Msp HDAE5000_CopyFdSongToHd_Rcm HDAE5000_CopyFdSongToHd_Md
   cc900-module: HDAE5000_DeleteSongPart_Lsw HDAE5000_DeleteSongPart_Pmt HDAE5000_DeleteSongPart_Sqt HDAE5000_DeleteSongPart_Cmp
   cc900-module: HDAE5000_DeleteSongPart_Tm HDAE5000_DeleteSongPart_Msp HDAE5000_DeleteSongPart_Rcm HDAE5000_DeleteSongPart_Md
   cc900-module: HDAE5000_DeleteSongParts HDAE5000_Fls_ForgetSong
   cc900-module: HDAE5000_RoundUpToSector HDAE5000_HD_WriteOpen HDAE5000_HD_WriteClose
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

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_WriteTables_Status(void);

/* the module's other functions (cc900-module), defined elsewhere */
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_CheckFreeSpace(unsigned int mask);
extern int HDAE5000_LoadSong_Lsw(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Rcm(unsigned int dir, unsigned int song);
extern int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Lsw(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Pmt(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Sqt(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Rcm(unsigned int dir, unsigned int song);
extern int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song);
extern int HDAE5000_CopyFdSongToHd_Lsw(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Pmt(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Sqt(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Cmp(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Tm(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Msp(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Rcm(unsigned int dir, unsigned int song, char *fdname);
extern int HDAE5000_CopyFdSongToHd_Md(unsigned int dir, unsigned int song, char *fdname);
extern void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song);
extern void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song);
extern void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song);
void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);

extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)

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
    if (keep != 1)
        HDAE5000_ATA_Standby_Status();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return ret;
}

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
        if (ret != -1) {
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0xff, 0, keep);
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

/* XDE = the floppy song's 8-character file name; stacked words (retd 6), lowest first: keep, sleep, mask.
   v1.x: the song is named from the file name's last six characters, padded with blanks (no .TTX file) */
int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, char *fdname, unsigned int mask, int sleep,
                            int keep)
{
    int ret = 0;
    char name[27];

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
        if (ret != -1) {
            HDAE5000_MemFill(name, ' ', 26);
            name[26] = 0;
            HDAE5000_MemCopy(name, fdname + 2, 6);
            HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], name, 26);
            HDAE5000_HD_WriteTables_Status();
        } else
            HDAE5000_DeleteSongParts(dir, song, 0xff, 0, keep);
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
