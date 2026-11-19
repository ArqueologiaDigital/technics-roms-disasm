/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services2.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 d6363bb013b8943aedc5fb20dbcf750d60699ad8b4781bbed67a9df146fa62e3 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc20=HDAE5000_PPORT_Svc20_PreWholeSongInMemory */
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
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
extern char ram_2f92c0[], ram_2f92e0[];
void PP_Svc20(void)
{
    if (PP_W(0) & 0x01)
        CALLV(HAMA->PreLswLoad)();
    if (PP_W(0) & 0x02)
        CALLV(HAMA->PrePmLoad)();
    if (PP_W(0) & 0x04)
        CALLV(HAMA->SeqLoadPre)();
    if (PP_W(0) & 0x08)
        CALLV(HAMA->cmp_ld_mae)();
    if (PP_W(0) & 0x10)
        CALLV(HAMA->PreTmLoad)();
    if (PP_W(0) & 0x20)
        CALLV(HAMA->msp_ld_mae)();
    if (PP_W(0) & 0x80)
        CALLV(HAMA->PreMidiLoad)();
    HDAE5000_DebugTrace(ram_2f92c0);
    HDAE5000_DebugTrace(ram_2f92e0);
}
