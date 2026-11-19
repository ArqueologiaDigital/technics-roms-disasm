/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_hardtest.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 f83c16720bed63939cb9a01745d2606bb5ed8725e8c64c237baced3dcb36a491 (tar-sha256); compiled at -Xr
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
#define EVT_SET_PARAM 0x1e0003bL
#define EVT_GET_PARAM 0x1e0006bL
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define OBJ_FD_SW 0x7f0049L
#define OBJ_HDD_SW 0x7f004aL
#define OBJ_PPORT_SW 0x7f0048L
#define OBJ_RUN_STOP 0x7f0046L
extern void HDAE5000_YieldUntilSem1Zero(void);
void HDAE5000_HardTest_Print(char *line);
void HDAE5000_HardTest_PortTest(void);
void HDAE5000_HardTest_HddIdRead(void);
extern char HDAE5000_Str_Test[];
extern char HDAE5000_Str_PPORTTEST[];
extern char HDAE5000_Str_HDDIDREAD[];
extern char HDAE5000_Str_FDTEST[];
extern char HDAE5000_Str_OK[];
extern char HDAE5000_Str_ERROR[];
extern char HDAE5000_Str_ERROR_HardTestPage[];
extern char HDAE5000_Str_STOPTESTLOOP[];
extern char HDAE5000_Str_STARTTESTLOOP[];
long HDAE5000_HardTestPage(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Test);
        return 0;
    case EVT_SW_IN:
        switch (arg) {
        case 9:
            CALLV(ROOT->SendEvent)(OBJ_PPORT_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_PPORTTEST);
            HDAE5000_HardTest_PortTest();
            CALLV(ROOT->SendEvent)(OBJ_PPORT_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 10L);
            break;
        case 10:
            CALLV(ROOT->SendEvent)(OBJ_HDD_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_HDDIDREAD);
            HDAE5000_HardTest_HddIdRead();
            CALLV(ROOT->SendEvent)(OBJ_HDD_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 11L);
            break;
        case 11:
            CALLV(ROOT->SendEvent)(OBJ_FD_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_FDTEST);
            switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
            case 2:
            case 3:
                if (CALLR(int, HAMA->FDLoadSaveTest)() == 0)
                    HDAE5000_HardTest_Print(HDAE5000_Str_OK);
                else
                    HDAE5000_HardTest_Print(HDAE5000_Str_ERROR);
                break;
            default:
                HDAE5000_HardTest_Print(HDAE5000_Str_ERROR_HardTestPage);
                break;
            }
            CALLV(ROOT->SendEvent)(OBJ_FD_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 9L);
            break;
        case 12:
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1) {
                CALLV(ROOT->SendEvent)(OBJ_RUN_STOP, EVT_SET_PARAM, 0L);
                HDAE5000_HardTest_Print(HDAE5000_Str_STOPTESTLOOP);
            } else {
                CALLV(ROOT->SendEvent)(OBJ_RUN_STOP, EVT_SET_PARAM, 1L);
                HDAE5000_HardTest_Print(HDAE5000_Str_STARTTESTLOOP);
                CALLV(ROOT->PostEvent)(-1L, EVT_SW_IN, 9L);
            }
            break;
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
