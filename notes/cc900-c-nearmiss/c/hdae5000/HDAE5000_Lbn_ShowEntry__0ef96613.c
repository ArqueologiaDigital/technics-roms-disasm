/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_lbn_show.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 0ef96613cc67b1aa83c952b0fc7074804e2a1deeeeb7e21eea05c116c620c5b4 (tar-sha256); compiled at -Xr
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
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_LBN_DIRNAME_BOX 0x7f00a5L
#define OBJ_LBN_DIRNO_BOX 0x7f00a4L
#define OBJ_LBN_FILENAME_BOX 0x7f00a7L
#define OBJ_LBN_FILENO_BOX 0x7f00a6L
#define OBJ_LBN_OPTION 0x7f0094L
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
extern void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask);
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern char HDAE5000_RAM_LbnEntryText[];
extern char ram_22aa68[], ram_22aa7a[], ram_22aa80[];
extern char HDAE5000_Str_Blank3Tab[];
extern char HDAE5000_Str_Blank16Tab[];
extern char HDAE5000_Str_Blank3Tab_Lbn_ShowEntry[];
extern char HDAE5000_Str_Blank26Tab[];
extern char HDAE5000_Fmt_1_1d[];
extern char ram_2e2d2a[];
extern char HDAE5000_Fmt_3_3d_Lbn_ShowEntry[];
extern char HDAE5000_Fmt_1_1d_Lbn_ShowEntry[];
extern char ram_2e2d3e[];
int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int direct)
{
    char s[32];
    int ret = 0;

    switch (pos) {
    case 0:
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, HDAE5000_Str_Blank3Tab, 5);
        HDAE5000_MemCopy(ram_22aa68, HDAE5000_Str_Blank16Tab, 18);
        HDAE5000_MemCopy(ram_22aa7a, HDAE5000_Str_Blank3Tab_Lbn_ShowEntry, 5);
        HDAE5000_MemCopy(ram_22aa80, HDAE5000_Str_Blank26Tab, 28);
        break;
    case 1:
        HDAE5000_SPrintf(s, HDAE5000_Fmt_1_1d, dir / 100);
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, s, HDAE5000_StrLen(s));
        break;
    case 2:
        HDAE5000_SPrintf(s, ram_2e2d2a, dir / 10);
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, s, HDAE5000_StrLen(s));
        break;
    case 3:
        HDAE5000_SPrintf(s, HDAE5000_Fmt_3_3d_Lbn_ShowEntry, dir);
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, s, HDAE5000_StrLen(s));
        if (dir != 0 && dir <= 120)
            HDAE5000_MemCopy(ram_22aa68, HDAE5000_DirName_Address(dir - 1), 16);
        else
            ret = -1;
        break;
    case 4:
        HDAE5000_SPrintf(s, HDAE5000_Fmt_1_1d_Lbn_ShowEntry, song / 10);
        HDAE5000_MemCopy(ram_22aa7a, s, HDAE5000_StrLen(s));
        break;
    case 5:
        HDAE5000_SPrintf(s, ram_2e2d3e, song);
        HDAE5000_MemCopy(ram_22aa7a, s, HDAE5000_StrLen(s));
        if (dir != 0 && dir <= 120) {
            if (song != 0 && song <= 16)
                HDAE5000_MemCopy(ram_22aa80, HDAE5000_SongRecord_Address(dir - 1, song - 1), 26);
            else
                ret = -2;
        } else
            ret = -1;
        break;
    case 6:
        HDAE5000_MemCopy(HDAE5000_RAM_LbnEntryText, HDAE5000_Str_Blank3Tab, 5);
        HDAE5000_MemCopy(ram_22aa68, HDAE5000_Str_Blank16Tab, 18);
        HDAE5000_MemCopy(ram_22aa7a, HDAE5000_Str_Blank3Tab_Lbn_ShowEntry, 5);
        HDAE5000_MemCopy(ram_22aa80, HDAE5000_Str_Blank26Tab, 28);
        HDAE5000_RAM_LbnDir = 0;
        HDAE5000_RAM_LbnSong = 0;
        HDAE5000_RAM_LbnDigitPos = 0;
        HDAE5000_PartList_Build(OBJ_LBN_OPTION, 0xffff, 0xffff, 0xffff);
        break;
    }
    if (direct == 1) {
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_LbnEntryText));
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa68));
        CALLV(ROOT->SendEvent)(OBJ_LBN_DIRNAME_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa7a));
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa80));
        CALLV(ROOT->SendEvent)(OBJ_LBN_FILENAME_BOX, EVT_PARA_DRAW, -1L);
    } else {
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_LbnEntryText));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa68));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_DIRNAME_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENO_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa7a));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENO_BOX, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENAME_BOX, EVT_HDAE_SET_STR_ADR, WRAP(ram_22aa80));
        CALLV(ROOT->ApPostEvent)(OBJ_LBN_FILENAME_BOX, EVT_PARA_DRAW, -1L);
    }
    return ret;
}
