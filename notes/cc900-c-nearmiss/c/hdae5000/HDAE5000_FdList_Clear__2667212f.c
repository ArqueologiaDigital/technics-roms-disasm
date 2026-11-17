/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_fd_stream.c (2026-11-16-76-hd-r14-staged)
   sha256 2667212f1d35bb65de501ab64224d5dc8de3194d8d9513a2e680769d3685f832 (tar-sha256); compiled at -Xr
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
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_CP_FD_LINE1 0x7f00d9L
#define OBJ_CP_FD_LINE2 0x7f00d8L
#define OBJ_CP_FD_LIST 0x7f00d7L
#define OBJ_CP_FD_VOLLABEL 0x7f00deL
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern char HDAE5000_Str_Blank12Tab[];
extern char HDAE5000_FdList_RowsTemplate[];
void HDAE5000_FdList_Clear(void)
{
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, HDAE5000_Str_Blank12Tab, 14);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.rows, HDAE5000_FdList_RowsTemplate, 0xf1);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line1, 0, 20);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line2, 0, 20);
}
