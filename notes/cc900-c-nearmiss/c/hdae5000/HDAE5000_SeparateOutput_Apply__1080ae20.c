/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_sepout.c (2026-11-17-17-hd-r45-ports)
   sha256 1080ae20319e4d8b25f6ee8ca9c0ac63b1634e31e7ad12af547a726ff7dac260 (tar-sha256); compiled at -Xr
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
#define CALLV(f) ((void (*)())(f))
extern unsigned char HDAE5000_RAM_SeparateOutputMode;
extern unsigned char HDAE5000_RAM_SeparateDrumPart;
extern unsigned char HDAE5000_RAM_SeparateBassPart;
extern unsigned char HDAE5000_RAM_SeparateDrumPartSent;
extern unsigned char HDAE5000_RAM_SeparateBassPartSent;
void HDAE5000_SeparateOutput_Apply(void)
{
    CALLV(HAMA->SetSepaOutMode)(HDAE5000_RAM_SeparateOutputMode);
    if (HDAE5000_RAM_SeparateDrumPartSent != 0) {
        HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateDrumPartSent = 0;
    }
    if (HDAE5000_RAM_SeparateBassPartSent != 0) {
        HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateBassPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateBassPartSent = 0;
    }
    switch (HDAE5000_RAM_SeparateOutputMode) {
    case 0:
        break;
    case 1:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        break;
    case 2:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 0);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    case 3:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 2);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            HDAE5000_SeparateOutput_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 1);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    }
}
