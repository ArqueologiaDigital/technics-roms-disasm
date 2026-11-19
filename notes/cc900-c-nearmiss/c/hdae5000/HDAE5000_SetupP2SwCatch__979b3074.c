/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_setup_copy_hd_driver.c (2026-11-19-17-hd-r62-ports-staged)
   sha256 979b30743f222629e814b7e01f86d0b7d7feaff50c53b49a76f4efb5f410f43d (tar-sha256); compiled at -Xr
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
#define OBJ_ATTEN_HD_FORMAT 0x7f021cL
#define OBJ_HD_PLEASE 0x7f02c0L
#define OBJ_SETUPS_TOOLS 0x7f0014L
#define OBJ_SETUP_HDINFO 0x7f0229L
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int HDAE5000_HD_StoreSettings(int keep);
extern void HDAE5000_SetupPage_BuildDriveInfo(void);
extern unsigned char HDAE5000_RAM_WriteProtect;
extern unsigned char ram_22ad9c[];
long HDAE5000_SetupP2SwCatch(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0x8c:
            CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
            HDAE5000_HD_StoreSettings(0);
            CALLV(ROOT->ApPostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
            break;
        case 9:
            HDAE5000_MemFill(ram_22ad9c, 0, 10);
            if (HDAE5000_RAM_WriteProtect == 0)
                CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_HD_FORMAT, EVT_SHOW, 0L);
            break;
        case 0x0c:
            HDAE5000_SetupPage_BuildDriveInfo();
            CALLV(ROOT->ApPostEvent)(OBJ_SETUP_HDINFO, EVT_SHOW, 0L);
            break;
        }
    }
    return 0;
}
