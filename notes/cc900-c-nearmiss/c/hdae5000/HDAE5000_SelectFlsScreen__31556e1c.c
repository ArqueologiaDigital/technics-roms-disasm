/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_fs_screens2.c (2026-11-19-17-hd-r62-ports-staged)
   sha256 31556e1ce24bc8cb23c4669f61a949f3f59b135ef10a8bb75a5378627f199ddc (tar-sha256); compiled at -Xr
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
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_SET_STRING 0x1e00086L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_OK2 0x1ea0007L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define OBJ_FLS_FILE_LOAD 0x7f013cL
#define OBJ_HDD_FLS_NAMING 0x7f0136L
#define OBJ_SEL_FLS 0x7f00fdL
#define APFUNC_FlsNamingCheck 0x012a0017L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern void HDAE5000_FlsList_BuildPage(void);
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);
extern unsigned int HDAE5000_RAM_CurFls;
extern int HDAE5000_RAM_FlsPageBase;
long HDAE5000_SelectFlsScreen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_FlsPageBase = 0;
            HDAE5000_FlsList_BuildPage();
            break;
        case 1:
            HDAE5000_RAM_FlsPageBase = 24;
            HDAE5000_FlsList_BuildPage();
            break;
        case 5:
            HDAE5000_RAM_FlsPageBase = 48;
            HDAE5000_FlsList_BuildPage();
            break;
        case 6:
            HDAE5000_RAM_FlsPageBase = 72;
            HDAE5000_FlsList_BuildPage();
            break;
        case 7:
            HDAE5000_RAM_FlsPageBase = 96;
            HDAE5000_FlsList_BuildPage();
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
    case EVT_HDAE_SELECT_OK2:
        HDAE5000_RAM_CurFls = (unsigned int)arg + HDAE5000_RAM_FlsPageBase;
        HDAE5000_FlsScreen_Refresh(0, 2);
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_FlsNamingCheck, EVT_SET_STRING,
                                HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls =
                                                               (unsigned int)arg + HDAE5000_RAM_FlsPageBase));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_FLS_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsPageBase >= 24) {
            HDAE5000_RAM_FlsPageBase -= 24;
            HDAE5000_FlsList_BuildPage();
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsPageBase < 96) {
            HDAE5000_RAM_FlsPageBase += 24;
            HDAE5000_FlsList_BuildPage();
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}
