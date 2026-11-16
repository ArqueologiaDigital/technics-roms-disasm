/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r2_ma.c (2026-11-16-48-hd-r2b)
   sha256 3dc112c56ffc9fe0435ce604d056875001eec301be930b905b124ba34e7a14bf (tar-sha256); compiled at -Xr */
typedef void (*VFN)();
struct RootFns {
    VFN pad0[33];
    VFN UpdateScreen;
    VFN pad1[5];
    VFN DrawLine;
    VFN pad2[1];
    VFN DrawBox;
    VFN DrawFrame;
    VFN pad3[1];
    VFN MovePixels;
    VFN pad4[4];
    VFN DrawString;
    VFN pad5[5];
    VFN InheritedProc;
    VFN pad6[1];
    VFN RegisterObjectTable;
    VFN pad7[6];
    VFN SendEvent;
    VFN PostEvent;
    VFN pad8[7];
    VFN ApPostEvent;
    VFN pad9[5];
    VFN ResEventProc;
    VFN ResMethodProc;
    VFN pad10[1];
    VFN ResNameProc;
    VFN pad11[1];
    VFN GetCharHeight;
    VFN GetCharDescent;
    VFN GetCenteredDelta;
    VFN ConvertStrings;
    VFN pad12[2];
    VFN ClassProc;
    VFN pad13[54];
    VFN FunctionProc;
    VFN ApFunctionProc;
    VFN MainFunctionProc;
    VFN ApFuncCall;
    VFN MainFuncCall;
    VFN pad14[6];
    VFN RegisterTitle;
    VFN pad15[1];
    VFN GetTitleNow;
    VFN pad16[1];
    VFN ViewableProc;
    VFN pad17[4];
    VFN SetVisible;
    VFN pad18[11];
    VFN GetViewInstance;
    VFN pad19[3];
    VFN GetClientBox;
    VFN pad20[1];
    VFN DrawDesignBox;
    VFN pad21[57];
    VFN SetDialEnable;
    VFN SetDialUp;
    VFN SetDialDown;
    VFN pad22[16];
    VFN SetApTimer;
    VFN pad23[1];
    VFN KillApTimer;
    VFN pad24[4];
    VFN SetAutoInc;
    VFN pad25[55];
    VFN GetNamingWindowID;
    VFN pad26[9];
    VFN DeleteEvent;
    VFN SleepMainTask;
    VFN WakeUpMainTask;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern char HDAE5000_RAM_DirListText[24][21];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Fmt_3_3d[];
void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText[i], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText[i], num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[i][4], HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    ROOT->ApPostEvent(obj, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_DirListText);
    ROOT->ApPostEvent(obj, EVT_PARA_DRAW, -1L);
}
