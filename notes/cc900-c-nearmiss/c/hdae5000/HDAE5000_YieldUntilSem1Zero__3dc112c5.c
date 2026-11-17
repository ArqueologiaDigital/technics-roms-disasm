/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r2_ma.c (2026-11-16-48-hd-r2b)
   sha256 3dc112c56ffc9fe0435ce604d056875001eec301be930b905b124ba34e7a14bf (tar-sha256); compiled at -Xr */
typedef void (*VFN)();
struct HamaFns {
    VFN pad0[1];
    VFN FDLoadSaveTest;
    VFN GetMediaType;
    VFN PreLswLoad;
    VFN PostLswLoad;
    VFN PreLswSave;
    VFN PostLswSave;
    VFN PrePmLoad;
    VFN PostPmLoad;
    VFN PrePmSave;
    VFN PostPmSave;
    VFN SeqLoadPre;
    VFN SeqLoadPost;
    VFN SeqSavePre;
    VFN SeqSavePost;
    VFN cmp_ld_mae;
    VFN cmp_ld_ato;
    VFN cmp_sv_mae;
    VFN cmp_sv_ato;
    VFN PreTmLoad;
    VFN PostTmLoad;
    VFN PreTmSave;
    VFN PostTmSave;
    VFN msp_ld_mae;
    VFN msp_ld_ato;
    VFN msp_sv_mae;
    VFN msp_sv_ato;
    VFN PreMidiLoad;
    VFN PostMidiLoad;
    VFN PreMidiSave;
    VFN PostMidiSave;
    VFN FlashWrite;
    VFN GetResouceInfo;
    VFN SetSepaOutMode;
    VFN pad1[2];
    VFN GetVolumeLabel;
    VFN findfirst;
    VFN findnext;
    VFN findclose;
    VFN fopen_ext;
    VFN pad2[1];
    VFN fread_ext;
    VFN fclose_ext;
    VFN rcm_ld_XAPR_j;
    VFN rcm_sv_XAPR_j;
    VFN rot_rdq_X;
    VFN pad3[5];
    VFN ref_sem_X;
    VFN pad4[4];
    VFN pdly_tim_X;
    VFN PlayHalt;
    VFN PlayStandBy;
    VFN EditSwRefresh;
    VFN pad5[3];
    VFN GetAdr_sqbtof;
    VFN GetAdr_sq_beadt;
    VFN GetAdr_sqsrtc;
    VFN pad6[2];
    VFN sendCOMM;
    VFN pad7[2];
    VFN SwbtWr;
    VFN pad8[2];
    VFN SetGlobalError;
    VFN malloc_X;
    VFN free_X;
    VFN ChangePalette;
    VFN ChangeWall;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
#define CALLR(t, f) ((t (*)())(f))
void HDAE5000_YieldUntilSem1Zero(void)
{
    while (CALLR(int, HAMA->ref_sem_X)(1) != 0)
        HAMA->rot_rdq_X(3);
}
