/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_setup_hd_driver.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 5f502ef26a50387fdfac0d50b91b32db050a6dd830dfe4dd301097faf7fdebb5 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: SetupPage_BuildDriveInfo=HDAE5000_SetupPage_BuildDriveInfo */
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
#define OBJ_HD_INFO_LIST 0x7f021eL
struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *);
extern char HDAE5000_DriveInfo_Template[];
extern float HDAE5000_Float_100_DriveInfo;
extern float HDAE5000_Float_100_DriveInfo_2;
extern float HDAE5000_Float_100_DriveInfo_3;
extern char ram_22b2f6[];
extern char ram_22b30c[], ram_22b333[], ram_22b35a[], ram_22b381[], ram_22b3a8[], ram_22b3cf[], ram_22b3f6[],
    ram_22b41d[];
extern char HDAE5000_Fmt_6_1f[];
extern char ram_2e2cc4[];
extern char ram_2e2cca[];
#define FMT_61F_A HDAE5000_Fmt_6_1f
#define FMT_61F_B ram_2e2cc4
#define FMT_61F_C ram_2e2cca
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
int HDAE5000_CopyVersionString(char *dst);
void SetupPage_BuildDriveInfo(void)
{
    struct HdGeom geom;
    struct DiskUsage usage;
    char buf[16];

    HDAE5000_MemCopy(ram_22b2f6, HDAE5000_DriveInfo_Template, 0x139);
    HDAE5000_HD_GetGeometry(&geom);
    HDAE5000_MemCopy(ram_22b30c, geom.model, 16);
    HDAE5000_IToA(geom.cyl, buf, 10);
    HDAE5000_MemCopy(ram_22b333, buf, HDAE5000_StrLen(buf));
    HDAE5000_IToA(geom.heads, buf, 10);
    HDAE5000_MemCopy(ram_22b35a, buf, HDAE5000_StrLen(buf));
    HDAE5000_IToA(geom.spt, buf, 10);
    HDAE5000_MemCopy(ram_22b381, buf, HDAE5000_StrLen(buf));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_A, usage.drive / HDAE5000_Float_100_DriveInfo);
    HDAE5000_MemCopy(ram_22b3a8, buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_B, usage.system / HDAE5000_Float_100_DriveInfo_2);
    HDAE5000_MemCopy(ram_22b3cf, buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_C, usage.free / HDAE5000_Float_100_DriveInfo_3);
    HDAE5000_MemCopy(ram_22b3f6, buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_CopyVersionString(buf);
    HDAE5000_MemCopy(ram_22b41d, buf, HDAE5000_StrLen(buf));
    CALLV(ROOT->ApPostEvent)(OBJ_HD_INFO_LIST, EVT_HDAE_SET_STR_ADR, WRAP(ram_22b2f6));
    CALLV(ROOT->ApPostEvent)(OBJ_HD_INFO_LIST, EVT_PARA_DRAW, -1L);
}
