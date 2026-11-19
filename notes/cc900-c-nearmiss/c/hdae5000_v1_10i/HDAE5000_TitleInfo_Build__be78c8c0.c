/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_title_info.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 be78c8c0018b97c82b31f09e32bacdcf7426ac9793ad2951a8f6b9956b472ad5 (tar-sha256); compiled at -Xr
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
#define OBJ_HARD_DISK_OPT 0x7f000aL
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *);
extern unsigned char HDAE5000_RAM_WriteProtect;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern char HDAE5000_RAM_TitleInfoText[];
extern char HDAE5000_TitleInfo_Template[];
extern char *HDAE5000_TextPtrs_OFF_ON[];
extern char ram_22ad72[], ram_22ada4[], ram_22add6[], ram_22ad89[], ram_22adbb[], ram_22aded[];
extern char HDAE5000_Fmt_s[];
extern char HDAE5000_Fmt_s_TitleInfo_Build[];
extern char HDAE5000_Fmt_d[];
extern char HDAE5000_Fmt_d_TitleInfo_Build[];
extern char ram_2ca99c[];
extern char HDAE5000_Fmt_4ldMB[];
#define FMT_S_A HDAE5000_Fmt_s
#define FMT_S_B HDAE5000_Fmt_s_TitleInfo_Build
#define FMT_D_A HDAE5000_Fmt_d
#define FMT_D_B HDAE5000_Fmt_d_TitleInfo_Build
#define FMT_D_C ram_2ca99c
#define FMT_MB HDAE5000_Fmt_4ldMB
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
void HDAE5000_TitleInfo_Build(void)
{
    struct DiskUsage usage;
    char s[16];

    HDAE5000_MemCopy(HDAE5000_RAM_TitleInfoText, HDAE5000_TitleInfo_Template, 0x97);
    HDAE5000_SPrintf(s, FMT_S_A, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteProtect]);
    HDAE5000_MemCopy(ram_22ad72, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_S_B, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteConfirm]);
    HDAE5000_MemCopy(ram_22ada4, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_A, HDAE5000_RAM_LoadByNumberMode);
    HDAE5000_MemCopy(ram_22add6, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_B, HDAE5000_RAM_QuickLoadMode);
    HDAE5000_MemCopy(ram_22ad89, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_C, HDAE5000_RAM_JumpAfterLoad);
    HDAE5000_MemCopy(ram_22adbb, s, HDAE5000_StrLen(s));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_SPrintf(s, FMT_MB, usage.free / 100);
    HDAE5000_MemCopy(ram_22aded, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_TitleInfoText));
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_PARA_DRAW, -1L);
}
