/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hd_r85c_pport_svc13__svc13_v1_r3b.c (2026-11-19-82-hd-r85-v1fix2)
   sha256 01d3a36292867536e528fb776f509301a9a1c37da86f88755fe5568e3a098a68 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP13_d=HDAE5000_PPORT_Svc13_SendInfosAboutSong */
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
struct ResInfo { unsigned char *addr; unsigned long size; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
extern char ram_2e0cd0[], ram_2e0d0a[];
extern char ram_2e0cee[];
#define F_dirname ram_2e0cee
extern char ram_2e0cfc[];
#define F_sngname ram_2e0cfc
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *si);
extern void HDAE5000_DebugTrace(char *s);
int PP13_d(unsigned int dir, unsigned int song)
{
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];
    int ret;

    ret = 1;
    PP_W(0) = 0;
    HDAE5000_MemFill(PPIB + 28, ' ', 16);
    HDAE5000_MemFill(PPIB + 2, ' ', 26);
    CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
    PP_L(70) = (unsigned long)info.addr;
    PP_L(74) = info.size;
    PPIB[78] = 0;
    CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
    PP_L(79) = (unsigned long)info.addr;
    PP_L(83) = info.size;
    PPIB[87] = 0;
    CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
    PP_L(88) = (unsigned long)info.addr;
    PP_L(92) = info.size;
    PPIB[96] = 0;
    CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
    PP_L(97) = (unsigned long)info.addr;
    PP_L(101) = info.size;
    PP_L(101) += CALLR(unsigned long, HAMA->SeqSavePre)();
    PPIB[105] = 0;
    CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
    PP_L(106) = (unsigned long)info.addr;
    PP_L(110) = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    PPIB[114] = 0;
    CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
    PP_L(115) = (unsigned long)info.addr;
    PP_L(119) = 0x72aaL;
    PPIB[123] = 0;
    CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
    PP_L(124) = (unsigned long)info.addr;
    PP_L(128) = CALLR(unsigned long, HAMA->msp_sv_mae)();
    PPIB[132] = 0;
    CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
    PP_L(133) = (unsigned long)info.addr;
    PP_L(137) = 0xad000L;
    PPIB[141] = 0;
    CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
    PP_L(142) = (unsigned long)info.addr;
    PP_L(146) = info.size;
    PPIB[150] = 0;
    if (HDAE5000_HD_GetSongInfo(*&dir, song, (void *)&si) != -1) {
        PP_W(0) = si.mask;
        HDAE5000_MemCopy(PPIB + 28, si.dirname, 16);
        HDAE5000_MemCopy(PPIB + 2, si.songname, 26);
        PPIB[78] = si.has[0];
        PPIB[96] = si.has[1];
        PPIB[105] = si.has[2];
        PPIB[114] = si.has[3];
        PPIB[123] = si.has[4];
        PPIB[132] = si.has[5];
        PPIB[141] = si.has[6];
        PPIB[150] = si.has[7];
        ret = 0;
    }
    HDAE5000_DebugTrace(ram_2e0cd0);
    HDAE5000_SPrintf(buf, F_dirname, PPIB + 28);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_sngname, PPIB + 2);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2e0d0a);
    return ret;
}
