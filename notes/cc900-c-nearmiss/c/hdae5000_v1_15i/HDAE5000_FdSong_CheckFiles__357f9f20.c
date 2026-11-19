/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_fdsong_check.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 357f9f2011d7fb2b4edd3ef406aabdee0bb33eeaf6a635dd737a69da203861c0 (tar-sha256); compiled at -Xr
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
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern char ram_2e09be[], ram_2e09c4[], ram_2e09ca[], ram_2e09d4[], ram_2e09de[], ram_2e09e8[];
extern char ram_2e09f2[], ram_2e09fa[], ram_2e0a04[], ram_2e0a0e[], ram_2e0a16[];
extern char ram_2e09d0[], ram_2e09da[], ram_2e09e4[], ram_2e09ee[], ram_2e09f6[];
extern char ram_2e0a00[], ram_2e0a0a[], ram_2e0a12[], ram_2e0a1c[];
extern int HDAE5000_CheckFileSignature(unsigned int part, const unsigned char *buf);
int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask)
{
    long h;
    unsigned char ff[266];
    char path[13];

    HDAE5000_MemFill(path, 0, 13);
    HDAE5000_MemCopy(path, name, 8);
    HDAE5000_StrCpy(&path[8], ram_2e09be);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], ram_2e09c4);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], ram_2e09ca);
        CALLV(HAMA->fopen_ext)(path, ram_2e09d0);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], ram_2e09d4);
        CALLV(HAMA->fopen_ext)(path, ram_2e09da);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], ram_2e09de);
        CALLV(HAMA->fopen_ext)(path, ram_2e09e4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], ram_2e09e8);
        CALLV(HAMA->fopen_ext)(path, ram_2e09ee);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], ram_2e09f2);
        CALLV(HAMA->fopen_ext)(path, ram_2e09f6);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], ram_2e09fa);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a00);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], ram_2e0a04);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a0a);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], ram_2e0a0e);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a12);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x100) {
        HDAE5000_StrCpy(&path[8], ram_2e0a16);
        CALLV(HAMA->fopen_ext)(path, ram_2e0a1c);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(8, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
