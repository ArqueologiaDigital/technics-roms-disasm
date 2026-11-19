/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_store_ui.c (2026-11-19-17-hd-r62-ports-staged)
   sha256 06edf4df5fce02ccea289b3241e0d215cb8908db6d89b0fc94acf3c0da7f3b80 (tar-sha256); compiled at -Xr
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
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define OBJ_ERR_SAVE 0x7f0288L
#define OBJ_ERR_SAVE_CATCH 0x7f028aL
#define OBJ_ERR_SAVE_EXIT 0x7f0289L
#define OBJ_HD_PLEASE 0x7f02b2L
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_FlsName_SetAndStore(unsigned int fls, char *name, int keep);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern void HDAE5000_NameHistory_Push();
extern unsigned char HDAE5000_RAM_FlsNameHistory[];
void HDAE5000_FlsName_StoreWithUi(unsigned int fls, char *name, long obj)
{
    char buf[18];

    HDAE5000_StrNCpy(buf, name, 16);
    buf[16] = 0;
    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 3L);
    HDAE5000_YieldUntilSem1Zero();
    if (HDAE5000_FlsName_SetAndStore(fls, (void *)buf, 0) != -1) {
        CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
    } else {
        CALLV(ROOT->SendEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    HDAE5000_NameHistory_Push(HDAE5000_RAM_FlsNameHistory, buf);
}
