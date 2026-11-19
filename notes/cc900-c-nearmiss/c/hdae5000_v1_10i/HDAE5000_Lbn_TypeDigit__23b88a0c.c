/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hd_r85b_drv_screens5__lbntypedigit_r2.c (2026-11-19-82-hd-r85-v1fix2)
   sha256 23b88a0c02cadbb915dda044ecd81863ed432173c9c62b18bff5981ac1304422 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TypeDigit_b=HDAE5000_Lbn_TypeDigit */
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
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define OBJ_DIR_OUT_RANGE 0x7f02a8L
#define OBJ_DIR_OUT_RANGE_CATCH 0x7f02a9L
#define OBJ_FILE_OUT_RANGE 0x7f02adL
#define OBJ_FILE_OUT_RANGE_CATCH 0x7f02aeL
#define OBJ_LBN_OPTION 0x7f0094L
#define OBJ_LOAD_BY_NUM 0x7f008bL
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int ui, long obj);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];
void TypeDigit_b(long obj, unsigned int digit)
{
    register int m;      /* r2 form b: v2.06i's order, m register (asked for IZ first) */
    int r;

    r = 0;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        HDAE5000_RAM_LbnDir = digit * 100;
        HDAE5000_RAM_LbnSong = 0;
        HDAE5000_RAM_LbnDigitPos = 1;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 1:
        HDAE5000_RAM_LbnDir += digit * 10;
        HDAE5000_RAM_LbnDigitPos = 2;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 2:
        HDAE5000_RAM_LbnDir += digit;
        HDAE5000_RAM_LbnDigitPos = 3;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 3:
        HDAE5000_RAM_LbnSong = digit * 10;
        HDAE5000_RAM_LbnDigitPos = 4;
        r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
        break;
    case 4:
        HDAE5000_RAM_LbnSong += digit;
        HDAE5000_RAM_LbnDigitPos = 5;
        if ((r = HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1))
                == 0) {
            HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
            HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
            if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
                HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
            } else {
                HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
                HDAE5000_PartList_Build(OBJ_LBN_OPTION, 0xffff, 0xffff, 0xffff);
            }
            if (HDAE5000_RAM_LoadByNumberMode == 2) {
                HDAE5000_LoadSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        1, OBJ_LOAD_BY_NUM);
                HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
            }
        }
    }
    switch (r) {
    case -1:
        CALLV(ROOT->PostEvent)(OBJ_DIR_OUT_RANGE, EVT_SHOW, 5L);
        CALLV(ROOT->SetApTimer)(0x21L, OBJ_DIR_OUT_RANGE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_LOAD_BY_NUM);
        break;
    case -2:
        CALLV(ROOT->PostEvent)(OBJ_FILE_OUT_RANGE, EVT_SHOW, 5L);
        CALLV(ROOT->SetApTimer)(0x21L, OBJ_FILE_OUT_RANGE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_LOAD_BY_NUM);
    }
}
