/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_drv_screens6.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 dc41a30cb074fecc844677c3939132fc7bf36722295272dd56e23c4e498340ed (tar-sha256); compiled at -Xr
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
#define EVT_ACTIVATE_STATE 0x1c00013L
#define EVT_HDAE_SEQ_STOP 0x1ca0000L
#define EVT_INDEXSW_DOWN 0x1c00018L
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_FLS_FILE_LOAD 0x7f0134L
#define OBJ_HARD_DISK_OPT 0x7f000aL
#define OBJ_HDDMENU 0x7f0000L
#define OBJ_LOAD_BY_NUM 0x7f008bL
#define OBJ_PP_STATUS 0x7f0065L
#define OBJ_SELECT_FILE 0x7f0015L
#define OBJ_SEL_DIR 0x7f0022L
#define OBJ_SEL_FLS 0x7f00f5L
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void HDAE5000_SongScreen_Refresh(int page, int skip);
extern void HDAE5000_FlsScreen_Refresh(int page, int skip);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_FlsList_BuildPage(void);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern unsigned char HDAE5000_Get_Init_Flag(void);
extern long ram_23d2d2;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_FlsSeqStopPending;
extern char HDAE5000_RAM_TitleInfoText[];
extern char HDAE5000_RAM_FlsListText[];
extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_PcLinkStatusText[];
extern char HDAE5000_Str_STATUS[];
extern long HDAE5000_HDAETitleFunc_ObjIds[];
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
long HDAE5000_HDAETitleFunc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ACTIVATE_STATE:
        switch ((unsigned long)arg) {     /* r23: the ROM's bound checks are unsigned (`dec 2; cp 0; jrl c`) */
        case 2:
            HDAE5000_RAM_TitleInfoText[150] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_TitleInfoText));
            HDAE5000_SongScreen_Refresh(0, 0);
            HDAE5000_RAM_FlsListText[1920] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
            HDAE5000_FlsScreen_Refresh(0, 2);
            HDAE5000_RAM_DirListText[504] = 0;
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            HDAE5000_FlsList_BuildPage();
            HDAE5000_Lbn_ShowEntry(0, 0, 6, 0);
            HDAE5000_MemCopy(HDAE5000_RAM_PcLinkStatusText, HDAE5000_Str_STATUS, 0x21);
            CALLV(ROOT->ApPostEvent)(OBJ_PP_STATUS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_PcLinkStatusText));
            ram_23d2d2 = OBJ_HDDMENU;
            if (HDAE5000_RAM_FlsAutoLoadPending == 1 && HDAE5000_RAM_FlsSeqStopPending == 1)
                ram_23d2d2 = OBJ_FLS_FILE_LOAD;
            break;
        case 9:
            switch (HDAE5000_RAM_QuickLoadMode) {
            case 1:
                ram_23d2d2 = OBJ_SELECT_FILE;
                break;
            case 2:
                ram_23d2d2 = OBJ_LOAD_BY_NUM;
                break;
            case 3:
                ram_23d2d2 = OBJ_FLS_FILE_LOAD;
                break;
            }
            break;
        case 8:
            CALLV(ROOT->ApPostEvent)(ram_23d2d2, EVT_SHOW, 0L);
            CALLV(ROOT->ApPostEvent)(-1L, EVT_INDEXSW_DOWN, 0L);
            if (HDAE5000_RAM_FlsAutoLoadPending == 1 && HDAE5000_RAM_FlsSeqStopPending == 1) {
                HDAE5000_RAM_FlsSeqStopPending = 0;
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_LOAD, EVT_HDAE_SEQ_STOP, 0L);
            }
            break;
        case 6:
            ram_23d2d2 = HDAE5000_HDAETitleFunc_ObjIds[HDAE5000_Get_Init_Flag()];
        /* r27: the ROM dispatches through a jump table over 2..9 whose entries for 3, 4, 5 and 7 are the
           switch's end; V4.23 wrote a compare chain for the four cases alone.  The four empty labels make the
           case set dense; placed last, with case 6 falling into them, they add no code. */
        case 3:
        case 4:
        case 5:
        case 7:
            ;
        }
    }
    return 0;
}
