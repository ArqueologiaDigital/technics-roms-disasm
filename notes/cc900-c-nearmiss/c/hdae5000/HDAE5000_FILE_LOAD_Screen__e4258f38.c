/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r50_fload.c (2026-11-18-13-hd-r52)
   sha256 e4258f3874a0dba278eedc53376c5eb9421223a1ae2dd996c483b3196d6119cb (tar-sha256); compiled at -Xr
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
#define EVT_SW_IN 0x1c00007L
#define EVT_SET_STRING 0x1e00086L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_CHANGE_SEL_NUM 0x1ea0002L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define EVT_HDAE_SELECT_DEL 0x1ea000cL
#define EVT_HDAE_SELECT_DEL_FILE 0x1ea000dL
#define OBJ_ATTEN_DEL_DIR 0x7f01efL
#define OBJ_FILE_DEL_SCREEN 0x7f01c2L
#define OBJ_HDD_FILE_NAMING 0x7f004eL
#define OBJ_HD_FILE_LIST 0x7f0103L
#define APFUNC_HDDNamingCheck 0x012a0001L       /* NAKA_APFUNC_HDDNamingCheck (hdae5000_ui_tree.s) */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_DelOpt_InitFromSong(unsigned int dir, unsigned int song, int all);
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
long HDAE5000_FILE_LOAD_Screen(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_HD_FILE_LIST, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
        HDAE5000_RAM_CurSong = arg;
        CALLV(ROOT->ApFuncCall)(APFUNC_HDDNamingCheck, EVT_SET_STRING,
                                HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_FILE_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_DEL_FILE:
        HDAE5000_RAM_CurSong = arg;
        HDAE5000_DelOpt_InitFromSong(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_FILE_DEL_SCREEN, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_DEL:
        CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_DIR, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_CurDir == 0)
            break;
        HDAE5000_RAM_CurDir--;
        HDAE5000_SongScreen_Refresh(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_HD_FILE_LIST, EVT_HDAE_SET_SEL_NUM, arg + 16);
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_CurDir >= 119)
            break;
        HDAE5000_RAM_CurDir++;
        HDAE5000_SongScreen_Refresh(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_HD_FILE_LIST, EVT_HDAE_SET_SEL_NUM, arg - 16);
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurSong = arg;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
        else
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
        HDAE5000_SongScreen_Refresh(0, 1);
    case EVT_SW_IN:
        ;
    }
    return 0;
}
