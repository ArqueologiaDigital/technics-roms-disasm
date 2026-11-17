/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_setup_copy.c (2026-11-17-11-hd-r40-staged)
   sha256 e7dac43c67c6a7ce0ae44d4c9ce0a1b7e40f6ec0d9c9afd5cc6da124754e8a4d (tar-sha256); compiled at -Xr
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
#define EVT_HDAE_CHANGE_SEL_NUM 0x1ea0002L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define EVT_HDAE_SELECT_ALL 0x1ea0009L
#define OBJ_ATTEN_CPFD_MARK 0x7f027aL
#define OBJ_CP_FD_DIRBOX 0x7f00e6L
#define OBJ_CP_FD_DIRSEL 0x7f00e2L
extern void HDAE5000_FdList_Redisplay(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern unsigned int HDAE5000_Count_Active_Files(void);
extern unsigned char ram_22aa9c[];
#define FD_PRESENT(i) ram_22aa9c[(i) + 0x100]
#define FD_SEL(i) ram_22aa9c[(i) + 0x114]
long HDAE5000_CopyToHDScreen(long obj, long ev, unsigned long arg)
{
    unsigned int i;

    switch (ev) {
    case EVT_HDAE_SELECT_ALL:
        for (i = 0; i < 20; i++) {
            if (FD_PRESENT((unsigned long)i) == 1) {
                FD_SEL((unsigned long)i) = 1;
                HDAE5000_FdList_Redisplay();
            }
        }
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
        if (HDAE5000_Count_Active_Files() != 0)
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRSEL, EVT_SHOW, 0L);
        else
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CPFD_MARK, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        if (FD_PRESENT(arg) == 1) {
            if (FD_SEL(arg) == 1)
                FD_SEL(arg) = 0;
            else
                FD_SEL(arg) = 1;
            HDAE5000_FdList_Redisplay();
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_FdList_Redisplay();
        break;
    }
    return 0;
}
