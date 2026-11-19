/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_drv_screens2.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 abd06046cc70f080dbec159905722a831e60f094136938af941e3dedc8d521aa (tar-sha256); compiled at -Xr
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
#define EVT_SW_IN 0x1c00007L
#define EVT_GET_STRING 0x1e0003aL
#define EVT_GET_STRING_LENGTH 0x1e0007cL
#define EVT_GET_NAMING_MODE 0x1e00084L
#define EVT_SET_STRING 0x1e00086L
#define OBJ_SELECT_DIR 0x7f0023L
#define OBJ_SEL_DIR 0x7f0026L
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern void HDAE5000_DirList_BuildPage(long obj);
extern char *HDAE5000_NameHistory_Recall(unsigned char *hist);
extern int HDAE5000_DirName_StoreWithUi(unsigned int dir, char *name, long obj);
extern unsigned int HDAE5000_RAM_CurDir;
extern char HDAE5000_RAM_NameEditBuffer[];
extern unsigned char HDAE5000_RAM_DirNameHistory[];
long HDAE5000_HDD_DIRNAMECheck(long obj, long ev, long arg)
{
    char *p;

    switch (ev) {
    case EVT_GET_STRING:
        HDAE5000_StrNCpy((char *)arg, HDAE5000_RAM_NameEditBuffer, 16);
        return obj;
    case EVT_SET_STRING:
        HDAE5000_StrNCpy(HDAE5000_RAM_NameEditBuffer, (char *)arg, 16);
        HDAE5000_RAM_NameEditBuffer[16] = 0;
        return obj;
    case EVT_GET_NAMING_MODE:
        return 0;
    case EVT_GET_STRING_LENGTH:
        return 16;
    case EVT_SW_IN:
        switch (arg) {
        case 0x8a:
            /* r23: as the matched CP_FD_DIRNAMECheck (run 95's only departure: `or xiz,xiz` for the ROM's
               `ld xwa,xiz; or xwa,xwa`) */
            if ((p = HDAE5000_NameHistory_Recall(HDAE5000_RAM_DirNameHistory)) != 0) {
                HDAE5000_MemCopy(HDAE5000_RAM_NameEditBuffer, p, HDAE5000_StrLen(p));
                CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_SET_STRING,
                                       (long)HDAE5000_RAM_NameEditBuffer);
            }
            break;
        case 0x0b:
            CALLV(ROOT->SendEvent)(CALLR(long, ROOT->GetNamingWindowID)(), EVT_GET_STRING,
                                   (long)HDAE5000_RAM_NameEditBuffer);
            HDAE5000_DirName_StoreWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_NameEditBuffer, OBJ_SELECT_DIR);
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        }
        break;
    }
    return 0;
}
