/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_module__copyfd_pmt_r75.c (2026-11-19-64-hd-r76-staged)
   sha256 6fc0668bc86c0944e07b183a31ab207a098baeea5c4c431dfbf7c976cce3d4c2 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: CopyFdPmt_a=HDAE5000_CopyFdSongToHd_Pmt */
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
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
unsigned long HDAE5000_RoundUpToSector(unsigned long n);
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern char ram_2e0896[];
extern char ram_2e0890[];
#define STR_PMT ram_2e0890
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
int CopyFdPmt_a(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    char fname[14];
    long n;

    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_PMT);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2e0896) < 0)
        return -1;
    CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
    if ((ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x10000L,
                                     &SLOT(1, dir, song))) != -1) {
        do {
            n = CALLR(long, HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x10000L);
            if ((ret = HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                              HDAE5000_RoundUpToSector(n), &SLOT(1, dir, song))) == -1)
                break;
        } while (n == 0x10000L);
        HAS(1, dir, song) = 1;
    }
    CALLV(HAMA->fclose_ext)();
    return ret;
}
