/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_song_check__isused_freespace_r72.c (2026-11-19-61-hd-r73-staged)
   sha256 381c66eeaf4d32e68e57379c310c55d96d7f1eb264e2cbeb3d67fafb11527ae0 (tar-sha256); compiled at -Xr
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
extern unsigned long HDAE5000_HD_ClusterCount(unsigned long bytes);
extern unsigned long HDAE5000_HD_CountFreeClusters_Status(void);
int HDAE5000_Song_CheckFreeSpace(unsigned int mask)
{
    int ret;
    struct ResInfo info;
    unsigned long total;

    ret = 0;
    total = 0;
    if (mask & 0x001) {
        CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
        total += info.size;
        CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
        total += info.size;
    }
    if (mask & 0x002) {
        CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
        total += info.size;
    }
    if (mask & 0x004) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
        total += info.size;
        total += CALLR(unsigned long, HAMA->SeqSavePre)();
    }
    if (mask & 0x008)
        total += CALLR(unsigned long, HAMA->cmp_sv_mae)();
    if (mask & 0x010) {
        info.size = 0x72aaL;
        total += info.size;
    }
    if (mask & 0x020)
        total += CALLR(unsigned long, HAMA->msp_sv_mae)();
    if (mask & 0x040) {
        CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
        total += info.size;
    }
    if (mask & 0x080) {
        CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
        total += info.size;
    }
    total = HDAE5000_HD_ClusterCount(total);
    if (HDAE5000_HD_CountFreeClusters_Status() <= total)
        ret = -1;
    return ret;
}
