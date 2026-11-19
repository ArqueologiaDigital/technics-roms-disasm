/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_song_module__tlx_r74.c (2026-11-19-64-hd-r76-staged)
   sha256 7d2864aecfd0dd1e6951bdab3eefdd8c3069c84997c2144e68c52d6fd402aaa6 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
struct ResInfo { unsigned long addr; unsigned long size; };
struct TlxHdr { unsigned char pad[18]; unsigned long trlen; };
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int HDAE5000_HD_WriteFile();
unsigned long HDAE5000_RoundUpToSector(unsigned long n);
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern char ram_2f8446[];
extern char ram_2f8440[];
#define STR_TLX ram_2f8440
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
int HDAE5000_CopyFdSongToHd_Tlx(unsigned int dir, unsigned int song, char *fdname)
{
    int ret = 0;
    struct ResInfo info;
    char fname[14];

    HDAE5000_MemCopy(fname, fdname, 8);
    HDAE5000_StrCpy(fname + 8, STR_TLX);
    if (CALLR(int, HAMA->fopen_ext)(fname, ram_2f8446) >= 0) {
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x16L);
        info.size = HDAE5000_RoundUpToSector(((struct TlxHdr *)HDAE5000_RAM_HdStreamBuffer)->trlen + 0x16);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, info.size);
        ret = HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(8, dir, song));
        HAS(8, dir, song) = 1;
        CALLV(HAMA->fclose_ext)();
    } else
        ret = -1;
    return ret;
}
