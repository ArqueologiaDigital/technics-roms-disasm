/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_loadsong2.c (2026-11-17-13-hd-r42-ports)
   sha256 601083a765c1ea160f0a9ff82d991019896a0ddc9f15c69814ff1f3448e8613d (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: LdCmp_b=HDAE5000_LoadSong_Cmp */
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
#define CALLV(f) ((void (*)())(f))
struct ResInfo { unsigned long addr; unsigned long size; };
struct CmpHdr { unsigned char pad[46]; unsigned int blocks; };
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern int HDAE5000_HD_ReadFile();
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define CMP_BLOCKS (((struct CmpHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks)
int LdCmp_b(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;
    unsigned long n;

    if (SLOT(3, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(3, dir, song)) == -1)
            return -1;
        n = CMP_BLOCKS;
        size = n;
        n <<= 4;
        size = n;
        CALLV(HAMA->cmp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(3, dir, song));
        CALLV(HAMA->cmp_ld_ato)(ret);
    }
    return ret;
}
