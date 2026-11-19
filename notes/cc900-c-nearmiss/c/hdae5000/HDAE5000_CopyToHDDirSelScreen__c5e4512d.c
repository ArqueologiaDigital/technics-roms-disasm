/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_fs_screens.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 c5e4512d6300c98840efa632ffc26ad916c4ec88ceff908872b2472320c349ff (tar-sha256); compiled at -Xr
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
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_SET_STRING 0x1e00086L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define OBJ_ATTEN_CP_UNNAMED 0x7f02a1L
#define OBJ_ATTEN_CP_UNNAMED_CATCH 0x7f02a3L
#define OBJ_ATTEN_FULL_DIR 0x7f029aL
#define OBJ_ATTEN_FULL_DIR_CATCH 0x7f029cL
#define OBJ_CP_FD 0x7f00ceL
#define OBJ_CP_FD_DIRBOX 0x7f00e0L
#define OBJ_CP_FD_DIRSEL 0x7f00dcL
#define OBJ_CP_FD_DIR_NAMING 0x7f0175L
#define OBJ_HD_PLEASE 0x7f02b2L
#define APFUNC_CP_FD_DIRNAMECheck 0x012a0019L   /* NAKA_APFUNC_CP_FD_DIRNAMECheck */
struct FdList { char label[14]; char rows[242]; unsigned char present[20]; unsigned char sel[20]; };
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned int HDAE5000_Dir_IsBlankName(unsigned int dir);
extern unsigned int HDAE5000_Dir_CountEmptySongs(unsigned int dir);
extern void HDAE5000_DirList_BuildPage(long obj);
extern unsigned int HDAE5000_Count_Active_Files(void);
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir);
extern unsigned int HDAE5000_RAM_CurDir;
extern int HDAE5000_RAM_DirPageBase;
extern struct FdList HDAE5000_RAM_FdList;
long HDAE5000_CopyToHDDirSelScreen(long obj, long ev, long arg)
{
    unsigned int n;

    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_DirPageBase = 0;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 1:
            HDAE5000_RAM_DirPageBase = 24;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 5:
            HDAE5000_RAM_DirPageBase = 48;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 6:
            HDAE5000_RAM_DirPageBase = 72;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        case 7:
            HDAE5000_RAM_DirPageBase = 96;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
        if (HDAE5000_Dir_IsBlankName(HDAE5000_RAM_CurDir = (unsigned int)arg + HDAE5000_RAM_DirPageBase) == 0xffff) {
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CP_UNNAMED, EVT_SHOW, 0L);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ATTEN_CP_UNNAMED_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ATTEN_CP_UNNAMED_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
        } else {
            n = HDAE5000_Count_Active_Files();
            if (HDAE5000_Dir_CountEmptySongs(HDAE5000_RAM_CurDir) >= n) {
                CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
                if (HDAE5000_CopyToHd_Execute(HDAE5000_RAM_FdList.sel, 20, HDAE5000_RAM_CurDir) != 0xffff)
                    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, 0L);
            } else {
                CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_FULL_DIR, EVT_SHOW, 0L);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ATTEN_FULL_DIR_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ATTEN_FULL_DIR_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD_DIRSEL);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_CP_FD_DIRNAMECheck, EVT_SET_STRING,
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir =
                                                             (unsigned int)arg + HDAE5000_RAM_DirPageBase));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIR_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_DirPageBase >= 24) {
            HDAE5000_RAM_DirPageBase -= 24;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRBOX, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_DirPageBase < 96) {
            HDAE5000_RAM_DirPageBase += 24;
            HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRBOX, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}
