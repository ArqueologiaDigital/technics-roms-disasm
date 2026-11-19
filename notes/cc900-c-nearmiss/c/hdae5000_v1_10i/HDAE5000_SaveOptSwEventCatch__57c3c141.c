/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_drv_screens3.c (2026-11-19-46-hd-r68-learned-ports)
   sha256 57c3c141100dc65970cf99d5ec12a6b8fd6278c8cdc8c394900c86db578f5d53 (tar-sha256); compiled at -Xr
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
#define EVT_GET_STRING 0x1e0003aL
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define OBJ_ATTEN_OVER_FILE 0x7f022fL
#define OBJ_HddNamingWindow 0x7f01a5L
#define OBJ_SELECT_FILE 0x7f0015L
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_TypeSel_ShowSaveFlags(void);
extern int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, char *name, int ui, long obj);
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern char ram_23d286[];
extern char HDAE5000_Str_SVOP[];
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
long HDAE5000_SaveOptSwEventCatch(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_SVOP);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 8:
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23d286));
            if (HDAE5000_RAM_WriteConfirm == 1 && HDAE5000_Song_IsUsed(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong) != -1)
                CALLV(ROOT->PostEvent)(OBJ_ATTEN_OVER_FILE, EVT_SHOW, 0L);
            else
                HDAE5000_SaveSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        ram_23d286, 1, OBJ_SELECT_FILE);
            HDAE5000_SongScreen_Refresh(0, 0);
            break;
        case 9:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x0a:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x1ff, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x0b:
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        case 0x8b:
            m = HDAE5000_RAM_SaveOptions.mask;
            if ((m & 0x100) == 0x100)
                m -= 0x100;
            else
                m += 0x100;
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateAllNo, 2);
            HDAE5000_TypeSel_ShowSaveFlags();
            break;
        }
        return 0;
    }
}
