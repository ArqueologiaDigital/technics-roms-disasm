/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_sepout_msg.c (2026-11-17-22-hd-r49-ports)
   sha256 090f68f3c3ff5ec2dae6622c3dd608c800032c327bf07cf392c15d606ae906a1 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg */
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
void SepOut_SendPartMsg(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, (char *)a);
        CALLV(HAMA->sendCOMM)(0, 4, (char *)b);
    }
}
