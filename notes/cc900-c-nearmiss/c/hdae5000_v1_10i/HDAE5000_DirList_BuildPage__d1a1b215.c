/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_list_pages_hd_driver.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 d1a1b215c31fe6e8c319daeb8485e86bf5d2ca08cc2443732c9c2c545da8127b (tar-sha256); compiled at -Xr
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
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned char *HDAE5000_DirName_Address();
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
extern char HDAE5000_RAM_DirListText[];
extern int HDAE5000_RAM_DirPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Fmt_3_3d[];
void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    const void *rec;

    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[0], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[0], num, 3);
        rec = HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i);
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[4], rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}
