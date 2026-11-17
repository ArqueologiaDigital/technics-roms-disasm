/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_fdlyric.c (2026-11-16-104-hd-r24-staged)
   sha256 9240a7835a03288d0999fba194c956f60fd5e934875f9cf8cbd740e3e5cdd4eb (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct RootFns {
    void *pad0[33];
    void *UpdateScreen;
    void *pad1[5];
    void *DrawLine;
    void *pad2[1];
    void *DrawBox;
    void *DrawFrame;
    void *pad3[1];
    void *MovePixels;
    void *pad4[4];
    void *DrawString;
    void *pad5[5];
    void *InheritedProc;
    void *pad6[1];
    void *RegisterObjectTable;
    void *pad7[6];
    void *SendEvent;
    void *PostEvent;
    void *pad8[7];
    void *ApPostEvent;
    void *pad9[5];
    void *ResEventProc;
    void *ResMethodProc;
    void *pad10[1];
    void *ResNameProc;
    void *pad11[1];
    void *GetCharHeight;
    void *GetCharDescent;
    void *GetCenteredDelta;
    void *ConvertStrings;
    void *pad12[2];
    void *ClassProc;
    void *pad13[54];
    void *FunctionProc;
    void *ApFunctionProc;
    void *MainFunctionProc;
    void *ApFuncCall;
    void *MainFuncCall;
    void *pad14[6];
    void *RegisterTitle;
    void *pad15[1];
    void *GetTitleNow;
    void *pad16[1];
    void *ViewableProc;
    void *pad17[4];
    void *SetVisible;
    void *pad18[11];
    void *GetViewInstance;
    void *pad19[3];
    void *GetClientBox;
    void *pad20[1];
    void *DrawDesignBox;
    void *pad21[57];
    void *SetDialEnable;
    void *SetDialUp;
    void *SetDialDown;
    void *pad22[16];
    void *SetApTimer;
    void *pad23[1];
    void *KillApTimer;
    void *pad24[4];
    void *SetAutoInc;
    void *pad25[55];
    void *GetNamingWindowID;
    void *pad26[9];
    void *DeleteEvent;
    void *SleepMainTask;
    void *WakeUpMainTask;
};
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
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char HDAE5000_RAM_FdLyricNames[][9];
extern char HDAE5000_RAM_FdLyricTitles[][27];
extern unsigned char HDAE5000_RAM_FdLyricHasMid[];
extern unsigned int HDAE5000_RAM_FdLyricCount;
extern char HDAE5000_RAM_FdVolumeLabel[];
extern unsigned char ram_230e82;
extern char HDAE5000_Str_Chr202D3E[];
extern unsigned char HDAE5000_Str_Chr2A2E2A[];
extern char HDAE5000_Str_TTX[];
extern char HDAE5000_Str_Rb_FdLyricTtx[];
extern char HDAE5000_Str_MID[];
extern char HDAE5000_Str_Rb_FdLyricMid[];
long HDAE5000_FdLyricList_AddTlx(char *name);
long HDAE5000_FdLyricList_Scan(void)
{
    long r;
    char fname[100];
    char ff[266];
    char *label;
    long h;
    unsigned int i;

    r = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->SleepMainTask)();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdVolumeLabel, label, HDAE5000_StrLen(label));
        else
            HDAE5000_RAM_FdVolumeLabel[0] = 0;
        ram_230e82 = 0;
        if (HDAE5000_StrLen(HDAE5000_RAM_FdVolumeLabel) != 0)
            HDAE5000_StrCat(HDAE5000_RAM_FdVolumeLabel, HDAE5000_Str_Chr202D3E);
        h = CALLR(long, HAMA->findfirst)((char *)HDAE5000_Str_Chr2A2E2A, (void *)ff);
        r = HDAE5000_FdLyricList_AddTlx(&ff[6]);
        while (CALLR(int, HAMA->findnext)(h, (void *)ff) == 0)
            r = HDAE5000_FdLyricList_AddTlx(&ff[6]);
        CALLV(HAMA->findclose)(h);
        for (i = 0; i < HDAE5000_RAM_FdLyricCount; i++) {
            HDAE5000_StrCpy(fname, (char *)HDAE5000_RAM_FdLyricNames[i]);
            HDAE5000_StrCat(fname, HDAE5000_Str_TTX);
            CALLV(HAMA->fopen_ext)(fname, HDAE5000_Str_Rb_FdLyricTtx);
            CALLV(HAMA->fread_ext)(HDAE5000_RAM_FdLyricTitles[i], 26L);
            CALLV(HAMA->fclose_ext)();
            HDAE5000_StrCpy(fname, (char *)HDAE5000_RAM_FdLyricNames[i]);
            HDAE5000_StrCat(fname, HDAE5000_Str_MID);
            if (CALLR(int, HAMA->fopen_ext)(fname, HDAE5000_Str_Rb_FdLyricMid) >= 0)
                HDAE5000_RAM_FdLyricHasMid[i] = 1;
            else
                HDAE5000_RAM_FdLyricHasMid[i] = 0;
            CALLV(HAMA->fclose_ext)();
        }
        CALLV(ROOT->WakeUpMainTask)();
    }
    return r;
}
