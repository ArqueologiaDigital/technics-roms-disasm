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
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_SW_IN 0x1c00007L
#define EVT_GET_STRING 0x1e0003aL
#define EVT_GET_STRING_LENGTH 0x1e0007cL
#define EVT_GET_NAMING_MODE 0x1e00084L
#define EVT_SET_STRING 0x1e00086L
#define OBJ_ATTEN_OVER_FILE 0x7f023bL
#define OBJ_HddNamingWindow 0x7f01aeL
#define OBJ_SAVE_OPT_SCREEN 0x7f0182L
#define OBJ_SELECT_FILE 0x7f0018L
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern char *HDAE5000_NameHistory_Recall(unsigned char *hist);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, char *name, int ui, long obj);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern char ram_23a04e[];
extern unsigned char ram_22ac7e[];
extern unsigned char HDAE5000_TypeSel_TemplateAllNo[];
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
long HDAE5000_HDDNamingCheck(long obj, long ev, long arg)
{
    char *p;
    unsigned int m;

    switch (ev) {
    case EVT_GET_STRING:
        HDAE5000_StrNCpy((char *)arg, ram_23a04e, 26);
        return obj;
    case EVT_SET_STRING:
        HDAE5000_StrNCpy(ram_23a04e, (char *)arg, 26);
        return obj;
    case EVT_GET_NAMING_MODE:
        return 0;
    case EVT_GET_STRING_LENGTH:
        return 26;
    case EVT_SW_IN:
        switch (arg) {
        case 0x8a:
            if ((p = HDAE5000_NameHistory_Recall(ram_22ac7e)) != 0) {     /* r23: the ROM tests a copy */
                HDAE5000_MemCopy(ram_23a04e, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_SET_STRING, WRAP(ram_23a04e));
            }
            break;
        case 0x0a:
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) == 0xffff)
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0x3f, HDAE5000_TypeSel_TemplateAllNo, 2);
            else
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateAllNo, 2);
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23a04e));
            CALLV(ROOT->PostEvent)(OBJ_SAVE_OPT_SCREEN, EVT_SHOW, 0L);
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(OBJ_HddNamingWindow, EVT_GET_STRING, WRAP(ram_23a04e));
            if (HDAE5000_RAM_WriteConfirm == 1 && HDAE5000_Song_IsUsed(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong) != -1)
                CALLV(ROOT->PostEvent)(OBJ_ATTEN_OVER_FILE, EVT_SHOW, 0L);
            else
                HDAE5000_SaveSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        ram_23a04e, 1, OBJ_SELECT_FILE);
            HDAE5000_SongScreen_Refresh(0, 0);
            break;
        }
        break;
    }
    return 0;
}
