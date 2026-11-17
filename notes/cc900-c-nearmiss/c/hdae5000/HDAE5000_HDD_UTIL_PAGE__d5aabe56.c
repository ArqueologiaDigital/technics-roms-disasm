/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_drv_screens.c (2026-11-16-96-hd-r21-staged)
   sha256 d5aabe561c07c3c6bfb285b506a8fbf06640d6b42dc7f7a66e337a9a3cd27b02 (tar-sha256); compiled at -Xr
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
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_SW_IN 0x1c00007L
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_LToA(unsigned long, char *, int);
extern void HDAE5000_HardTest_HddIdRead(void);
extern void HDAE5000_HardTest_Print(char *line);
extern char HDAE5000_Str_UTIL[];
extern char HDAE5000_Str_LSWFileInfo[], HDAE5000_Str_SDAFileInfo[], HDAE5000_Str_PMTFileInfo[];
extern char HDAE5000_Str_SQFFileInfo[], HDAE5000_Str_SEQFileInfo[], HDAE5000_Str_CMPFileInfo[];
extern char HDAE5000_Str_TMFileInfo[], HDAE5000_Str_MSPFileInfo[], HDAE5000_Str_RCMFileInfo[];
extern char HDAE5000_Str_MDFileInfo[];
extern char HDAE5000_Str_Adr[], HDAE5000_Str_Size[], HDAE5000_Str_Adr_HDD_UTIL_PAGE[];
extern char ram_2e25b4[];
extern char ram_2e25d6[], ram_2e25de[];
extern char ram_2e2600[], ram_2e2608[];
extern char ram_2e262a[], ram_2e2632[];
extern char ram_2e2654[], ram_2e265c[];
extern char ram_2e267c[], ram_2e2684[];
extern char ram_2e26a6[], ram_2e26ae[];
extern char ram_2e26d0[], ram_2e26d8[];
extern char ram_2e26f8[], ram_2e2700[];
long HDAE5000_HDD_UTIL_PAGE(long obj, long ev, long arg)
{
    char line[64];
    char num[32];
    struct { unsigned long addr; unsigned long size; } info;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_UTIL);
        return 0;
    case EVT_SW_IN:
        if (arg == 0x0b) {
            HDAE5000_HardTest_HddIdRead();

            CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_LSWFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Size);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SDAFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr_HDD_UTIL_PAGE);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e25b4);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_PMTFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e25d6);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e25de);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SQFFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2600);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2608);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(4, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SEQFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e262a);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2632);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_CMPFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2654);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e265c);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_TMFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e267c);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2684);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_MSPFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26a6);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26ae);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_RCMFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26d0);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26d8);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_MDFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e26f8);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2e2700);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
