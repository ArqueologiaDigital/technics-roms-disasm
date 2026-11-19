/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_refresh.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 ef6782e900765fd2f28f753a7e88bfc0bfafbe87b81a81d39c6753be0ce2d4f0 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: SongScr_q=HDAE5000_SongScreen_Refresh */
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
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, char *, int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern char HDAE5000_RAM_SongScreenTitle[];
extern char HDAE5000_RAM_SongListText[];
extern char HDAE5000_Str_DIRECTORY[];
extern char ram_2cab20[];
extern char HDAE5000_Str_Blank0Tab[];
extern char HDAE5000_Str_Chr3A2020202020[];
extern char ram_2cab1a[];
extern char ram_2cab42[];
extern unsigned long ram_2caaf6[];
extern unsigned long ram_2caafe[];
extern unsigned long ram_2cab06[];
void SongScr_q(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2cab1a, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2cab20);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2caaf6[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2caaf6[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[2], HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2cab42, i + 1);
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[0], buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[3], rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2caafe[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2caafe[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2cab06[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2cab06[page], 0xffff, 0xffff, 0xffff);
}
