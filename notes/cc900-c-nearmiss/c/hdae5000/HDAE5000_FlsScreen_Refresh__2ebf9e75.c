/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r23_fs.c (2026-11-16-109-hd-r23c)
   sha256 2ebf9e75b10ec238b5d3b3a3ee9d45694165f2362d66a06b3226dcafc21284ef (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: FlsScrRefresh_c=HDAE5000_FlsScreen_Refresh */
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
struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, const char *, unsigned int);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, void *out);
extern unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask);
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
extern char ram_22a058[];
extern char ram_22a078[];
extern char ram_22b020[];
extern unsigned long ram_2e2e7c[], ram_2e2e84[], ram_2e2e8c[], ram_2e2e94[], ram_2e2e9c[], ram_2e2ea4[];
extern char HDAE5000_Str_FLSNAME[];
extern char ram_2e2eb6[];
extern char ram_2e2ebc[];
extern char ram_2e2ebe[];
extern char HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh[];
extern char ram_2e2ee4[];
extern char HDAE5000_Fmt_LOC_3_3d_2_2d[];
extern char HDAE5000_Str_LOC00000[];
void FlsScrRefresh_c(unsigned char variant, unsigned char mode)
{
    char s[22];
    struct FlsItem item;
    unsigned int i;
    unsigned int r;
    const void *rec;

    if (mode == 0 || mode == 2) {
        HDAE5000_MemFill(ram_22a058, 0, 0x20);
        HDAE5000_StrCat(ram_22a058, HDAE5000_Str_FLSNAME);
        HDAE5000_SPrintf(s, ram_2e2eb6, HDAE5000_RAM_CurFls + 1);
        HDAE5000_StrCat(ram_22a058, s);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebc);
        HDAE5000_StrNCat(ram_22a058, (char *)HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls), 16);
        HDAE5000_StrCat(ram_22a058, ram_2e2ebe);
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a058));
        CALLV(ROOT->SendEvent)((long)ram_2e2e7c[variant], EVT_PARA_DRAW, -1L);
    }
    if (mode == 0 || mode == 2) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&ram_22b020[37 * i + 2], HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh, 35);
            HDAE5000_SPrintf(s, ram_2e2ee4, HDAE5000_RAM_FlsItemPageBase + i + 1);
            HDAE5000_MemCopy(&ram_22b020[37 * i], s, HDAE5000_StrLen(s));
            rec = HDAE5000_FlsItem_SongRecord(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i);
            HDAE5000_MemCopy(&ram_22b020[37 * i + 3], rec, 26);
            if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_FlsItemPageBase + i, &item) != 0xffff) {
                if (item.as == 1)
                    ram_22b020[37 * i + 32] = '*';
                if (item.al == 1)
                    ram_22b020[37 * i + 35] = '*';
            }
        }
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22b020));
        CALLV(ROOT->SendEvent)((long)ram_2e2e84[variant], EVT_PARA_DRAW, -1L);
    }
    HDAE5000_MemFill(ram_22a078, 0, 16);
    if ((r = HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &item)) != 0xffff)
        HDAE5000_SPrintf(s, HDAE5000_Fmt_LOC_3_3d_2_2d, item.dir + 1, item.song + 1);
    else
        HDAE5000_SPrintf(s, HDAE5000_Str_LOC00000);
    HDAE5000_MemCopy(ram_22a078, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_HDAE_SET_STR_ADR, WRAP(ram_22a078));
    CALLV(ROOT->SendEvent)((long)ram_2e2e8c[variant], EVT_PARA_DRAW, -1L);
    if (r != 0xffff) {
        r = HDAE5000_Song_PartMask(item.dir, item.song);
        HDAE5000_PartList_Build(ram_2e2e94[variant], item.dir, item.song, r);
    } else
        HDAE5000_PartList_Build(ram_2e2e94[variant], 0xffff, 0xffff, 0xffff);
    if (mode != 2) {
        CALLV(ROOT->SendEvent)((long)ram_2e2e9c[variant], EVT_DRAW, 0L);
        CALLV(ROOT->SendEvent)((long)ram_2e2ea4[variant], EVT_DRAW, 0L);
    }
}
