/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_drv_screens6.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 2007d5c37159654fe0d6b1314652e44b57ee2264400b67cc798a770e306f3862 (tar-sha256); compiled at -Xr
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
#define EVT_SHOW 0x1c00001L
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define OBJ_AGAIN_HD_FORMAT 0x7f02bfL
#define OBJ_AGAIN_HD_FORMAT_CATCH 0x7f02c1L
#define OBJ_ATTEN_HD_FORMAT 0x7f020eL
#define OBJ_ERR_HD_FORMAT 0x7f02b8L
#define OBJ_ERR_HD_FORMAT_CATCH 0x7f02baL
#define OBJ_ERR_SAVE 0x7f028bL
#define OBJ_ERR_SAVE_CATCH 0x7f028dL
#define OBJ_ERR_SAVE_EXIT 0x7f028cL
#define OBJ_SEL_DIR 0x7f0022L
#define OBJ_SETUPS_TOOLS 0x7f0010L
#define OBJ_WAIT_HD_FORMAT 0x7f0217L
#define OBJ_WAIT_TR0_RECOVER 0x7f0288L
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern void HDAE5000_FlsScreen_Refresh(int page, int skip);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_FlsList_BuildPage(void);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern int HDAE5000_FormatDialog_CodeDigit(int digit);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern int HDAE5000_HD_FormatDrive(int ui);
extern int HDAE5000_HD_StoreSettings(int keep);
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern unsigned char ram_22ad9c[];
extern char HDAE5000_Str_FMT[];
long HDAE5000_AttenHDFormatSwCatch(long obj, long ev, register long arg)
{
    int res;
    int d;

    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_FMT);
        return 0;
    case EVT_SW_IN:
        res = 0;
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            if (arg & 0x80)
                d = 0;
            else
                d = 1;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 1:
            if (arg & 0x80)
                d = 2;
            else
                d = 3;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 2:
            if (arg & 0x80)
                d = 4;
            else
                d = 5;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 3:
            if (arg & 0x80)
                d = 6;
            else
                d = 7;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 4:
            if (arg & 0x80)
                d = 8;
            else
                d = 9;
            res = HDAE5000_FormatDialog_CodeDigit(d);
            break;
        case 6:
        case 7:
            HDAE5000_MemFill(ram_22ad9c, 0, 10);
            CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
        }
        switch (res) {
        case 1:
            CALLV(ROOT->SendEvent)(OBJ_AGAIN_HD_FORMAT, EVT_SHOW, 3L);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_AGAIN_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_AGAIN_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            break;
        case 2:
            CALLV(ROOT->SendEvent)(OBJ_WAIT_HD_FORMAT, EVT_SHOW, 0L);
            HDAE5000_YieldUntilSem1Zero();
            if (HDAE5000_HD_FormatDrive(1) == 0) {
                CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
                HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
                HDAE5000_SongScreen_Refresh(0, 0);
                HDAE5000_FlsList_BuildPage();
                HDAE5000_FlsScreen_Refresh(0, 2);
            } else {
                CALLV(ROOT->PostEvent)(OBJ_ERR_HD_FORMAT, EVT_SHOW, 3L);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_HD_FORMAT_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            }
            break;
        case 3:
            HDAE5000_RAM_QuickLoadMode = 1;
            HDAE5000_RAM_LoadByNumberMode = 1;
            HDAE5000_RAM_JumpAfterLoad = 1;
            CALLV(ROOT->SendEvent)(OBJ_WAIT_TR0_RECOVER, EVT_SHOW, 0L);
            HDAE5000_YieldUntilSem1Zero();
            if (HDAE5000_HD_StoreSettings(0) != -1) {
                CALLV(ROOT->PostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
            } else {
                CALLV(ROOT->PostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 3L);
                HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
                CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_ATTEN_HD_FORMAT);
            }
            break;
        }
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(OBJ_ATTEN_HD_FORMAT, EVT_SHOW, 0L);
        return 0;
    }
}
