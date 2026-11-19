/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_drv_screens3.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 78954c9b0399e051b2cc5bf508ddd2c318ac06f35d12ff3b576fe205528a829d (tar-sha256); compiled at -Xr
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
#define OBJ_HDD_DIR_NAMING 0x7f0055L
#define OBJ_SELECT_FILE 0x7f0015L
#define OBJ_SEL_DIR 0x7f0022L
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern void HDAE5000_DirList_BuildPage(long obj);
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned int HDAE5000_RAM_CurDir;
extern int HDAE5000_RAM_DirPageBase;
#define APFUNC_HDD_DIRNAMECHECK 0x012a0002L
long HDAE5000_SEL_DIR_Screen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_DirPageBase = 0;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 1:
            HDAE5000_RAM_DirPageBase = 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 5:
            HDAE5000_RAM_DirPageBase = 48;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 6:
            HDAE5000_RAM_DirPageBase = 72;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 7:
            HDAE5000_RAM_DirPageBase = 96;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
    case EVT_HDAE_SELECT_OK2:
        /* r23: the int base is converted to unsigned, so V4.23 loads it first (`ld bc,(base); ld wa,iz;
           add wa,bc`), as the ROM; r20's (int)arg + base added it as a memory operand */
        HDAE5000_RAM_CurDir = (unsigned int)arg + HDAE5000_RAM_DirPageBase;
        HDAE5000_SongScreen_Refresh(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_HDD_DIRNAMECHECK, EVT_SET_STRING,
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir =
                                                             (unsigned int)arg + HDAE5000_RAM_DirPageBase));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_DIR_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_DirPageBase >= 24) {
            HDAE5000_RAM_DirPageBase -= 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_DirPageBase < 96) {
            HDAE5000_RAM_DirPageBase += 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}
