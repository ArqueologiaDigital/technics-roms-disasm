/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_drv.c (2026-11-16-119-hd-r30)
   sha256 c1e95b0b1972650cc03bcaffa80ae13edc8a2f019e323fcf2ce096764c1624e1 (tar-sha256); compiled at -Xr
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
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define OBJ_FILE_DEL_SCREEN 0x7f01c2L
#define OBJ_SELECT_FILE 0x7f0018L
#define OBJ_SEL_DIR 0x7f0025L
#define OBJ_WAIT_DEL_FILE 0x7f0217L
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_DelOpt_InitFromSong(unsigned int dir, unsigned int song, int all);
extern void HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int sleep, int keep);
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern char HDAE5000_Str_DELF[];
long HDAE5000_AttenDelFileSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_DELF);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0:
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_WAIT_DEL_FILE, EVT_SHOW, 3L);
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_DeleteSongParts(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_DeleteOptions.mask, 1, 0);
            HDAE5000_DelOpt_InitFromSong(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, 1);
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            HDAE5000_SongScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
            break;
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_FILE_DEL_SCREEN, EVT_SHOW, 0L);
        }
        return 0;
    }
}
