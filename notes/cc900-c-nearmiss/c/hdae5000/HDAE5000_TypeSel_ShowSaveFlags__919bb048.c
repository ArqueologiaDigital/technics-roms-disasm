/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_showflags_drv.c (2026-11-18-14-hd-r52-staged)
   sha256 919bb048d1b9e32cbd83b22e0132c44bead2c8c2312956d8a4386b06bbc158f7 (tar-sha256); compiled at -Xr
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
#define EVT_PARA_DRAW 0x1c0000fL
#define OBJ_RAM_EDIT_CMP 0x7f0194L
#define OBJ_RAM_EDIT_LSW 0x7f0196L
#define OBJ_RAM_EDIT_MD 0x7f019cL
#define OBJ_RAM_EDIT_MSP 0x7f019aL
#define OBJ_RAM_EDIT_PMT 0x7f0197L
#define OBJ_RAM_EDIT_RCM 0x7f019bL
#define OBJ_RAM_EDIT_SQT 0x7f0198L
#define OBJ_RAM_EDIT_TLX 0x7f01aaL
#define OBJ_RAM_EDIT_TM 0x7f0199L
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
void HDAE5000_TypeSel_ShowSaveFlags(void)
{
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_LSW, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[0]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_PMT, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[1]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_SQT, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[2]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_CMP, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[3]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_TM, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[4]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_MSP, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[5]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_RCM, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[6]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_MD, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[7]]);
    CALLV(ROOT->PostEvent)(OBJ_RAM_EDIT_TLX, EVT_PARA_DRAW,
                           HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[HDAE5000_RAM_SaveOptions.flag[8]]);
}
