/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r3_mb.c (2026-11-16-49-hd-r3)
   sha256 3cba5bb9dddf77555e8c2a1b9fdb2db22b5056824341b66343c4390405617eb7 (tar-sha256); compiled at -Xr */
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
#define OBJ_CP_FD_HDSWSEL 0x7f00dcL
#define OBJ_CP_FD_HDSWTO 0x7f00daL
#define OBJ_FLS_FILE_LOAD_SW_EDIT 0x7f013eL
#define OBJ_FLS_SELECT_SW_EDIT 0x7f00f9L
#define OBJ_HD_FILE_LOAD_SW_DEL 0x7f010aL
#define OBJ_HD_FILE_LOAD_SW_DELFILE 0x7f010dL
#define OBJ_HD_FILE_LOAD_SW_SAVE 0x7f0100L
#define OBJ_SELECT_DIR_SW_EDIT 0x7f002cL
#define OBJ_SW_HD_FORMAT 0x7f0080L
void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    v = hide == 0 ? 1 : 0;
    CALLV(ROOT->SetVisible)(OBJ_SELECT_DIR_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DEL, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_SELECT_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWTO, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWSEL, v);
    CALLV(ROOT->SetVisible)(OBJ_SW_HD_FORMAT, v);
}
