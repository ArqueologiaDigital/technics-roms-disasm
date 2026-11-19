/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r9_b2.c (2026-11-16-64-hd-r9b)
   sha256 aaba87631250018403c4016b379b5ee32214b30a702e035f28c4a495dc5ee4f3 (tar-sha256); compiled at -Xr */
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
#define EVT_ACTIVATE_STATE 0x1c00013L
extern int HDAE5000_HD_ReadFile();
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
struct ResInfo { unsigned long addr; unsigned long size; };
struct SqtHdr { unsigned char pad[199]; unsigned char bank; };
struct SqtBlk { unsigned char pad[78]; unsigned int len[1]; };
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])
int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info4;
    struct ResInfo info3;
    unsigned long size;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile(WRAP(HDAE5000_RAM_HdStreamBuffer), 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        size = ((struct SqtBlk *)((unsigned int *)HDAE5000_RAM_HdStreamBuffer
               + (((struct SqtHdr *)HDAE5000_RAM_HdStreamBuffer)->bank << 10)))->len[0];
        size <<= 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}
