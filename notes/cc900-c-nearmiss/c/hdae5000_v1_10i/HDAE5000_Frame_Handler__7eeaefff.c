/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hd_r87a_boot__framehandler_v1.c (2026-11-20-1-hd-r87-v1gap)
   sha256 7eeaefff9c919d6dc1797acefa6b0aebd609c0961c2e31b6190034f93ec1dbe8 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: FrameH_a=HDAE5000_Frame_Handler */
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
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HDAE_SEQ_STOP 0x1ca0000L
#define TITLE_HDDEXT 0x1a0007fL
#define OBJ_FLS_FILE_LOAD 0x7f0134L
extern unsigned char HDAE5000_Fls_GetAutoLoadPending(void);
extern void HDAE5000_Fls_SetSeqStopPending();
extern void HDAE5000_RequestTitle15();
extern void HDAE5000_PPORT_ServicePending(void);
extern unsigned char HDAE5000_RAM_FrameCount;
extern unsigned char *HDAE5000_RAM_SqSrtcPtr;
extern unsigned char HDAE5000_RAM_SqSrtcBit2Prev;
void FrameH_a(void)
{
    unsigned char bit;

    HDAE5000_RAM_FrameCount++;
    bit = *HDAE5000_RAM_SqSrtcPtr & 4;
    if (bit != HDAE5000_RAM_SqSrtcBit2Prev) {
        HDAE5000_RAM_SqSrtcBit2Prev = bit;
        if (bit == 0) {
            if (HDAE5000_Fls_GetAutoLoadPending() == 1) {
                if (CALLR(long, ROOT->GetTitleNow)() != TITLE_HDDEXT) {
                    HDAE5000_Fls_SetSeqStopPending(1);
                    HDAE5000_RequestTitle15(0x7f);
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_SHOW, 0L);
                    CALLV(ROOT->DeleteEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP);
                    CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP, 0L);
                }
            }
        }
    }
    HDAE5000_PPORT_ServicePending();
}
