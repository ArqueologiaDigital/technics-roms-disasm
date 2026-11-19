/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_fs_screens2.c (2026-11-19-39-hd-r67-apfunc-ports)
   sha256 94a1df973e1ed543986dbcd0698bdeffcb2226933a1c4d3dbdf7584a3deaf15b (tar-sha256); compiled at -Xr
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
struct HamaFns {
    void *pad0[1];
    void *FDLoadSaveTest;
    void *GetMediaType;
    void *PreLswLoad;
    void *PostLswLoad;
    void *PreLswSave;
    void *PostLswSave;
    void *PrePmLoad;
    void *PostPmLoad;
    void *PrePmSave;
    void *PostPmSave;
    void *SeqLoadPre;
    void *SeqLoadPost;
    void *SeqSavePre;
    void *SeqSavePost;
    void *cmp_ld_mae;
    void *cmp_ld_ato;
    void *cmp_sv_mae;
    void *cmp_sv_ato;
    void *PreTmLoad;
    void *PostTmLoad;
    void *PreTmSave;
    void *PostTmSave;
    void *msp_ld_mae;
    void *msp_ld_ato;
    void *msp_sv_mae;
    void *msp_sv_ato;
    void *PreMidiLoad;
    void *PostMidiLoad;
    void *PreMidiSave;
    void *PostMidiSave;
    void *FlashWrite;
    void *GetResouceInfo;
    void *SetSepaOutMode;
    void *pad1[2];
    void *GetVolumeLabel;
    void *findfirst;
    void *findnext;
    void *findclose;
    void *fopen_ext;
    void *pad2[1];
    void *fread_ext;
    void *fclose_ext;
    void *rcm_ld_XAPR_j;
    void *rcm_sv_XAPR_j;
    void *rot_rdq_X;
    void *pad3[5];
    void *ref_sem_X;
    void *pad4[4];
    void *pdly_tim_X;
    void *PlayHalt;
    void *PlayStandBy;
    void *EditSwRefresh;
    void *pad5[3];
    void *GetAdr_sqbtof;
    void *GetAdr_sq_beadt;
    void *GetAdr_sqsrtc;
    void *pad6[2];
    void *sendCOMM;
    void *pad7[2];
    void *SwbtWr;
    void *pad8[2];
    void *SetGlobalError;
    void *malloc_X;
    void *free_X;
    void *ChangePalette;
    void *ChangeWall;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HDAE_SEQ_STOP 0x1ca0000L
#define EVT_HDAE_AFTER_LOAD 0x1ca0001L
#define EVT_SW_IN 0x1c00007L
#define EVT_SET_STRING 0x1e00086L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_CHANGE_SEL_NUM 0x1ea0002L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define OBJ_FLS_EDIT 0x7f015dL
#define OBJ_FLS_FILE_BOX 0x7f0142L
#define OBJ_FLS_FILE_LOAD 0x7f0134L
#define OBJ_HDD_FLS_NAMING2 0x7f0238L
#define OBJ_Tech_lyrics 0x7f02e4L
#define APFUNC_FlsNamingCheck 0x012a0016L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */
struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, void *out);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls);
extern unsigned int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int flag, long obj);
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
extern unsigned int HDAE5000_RAM_FlsChainFls;
extern unsigned int HDAE5000_RAM_FlsChainItem;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_LyricJump;
long HDAE5000_FlsLoadScreen(long obj, long ev, long arg)
{
    struct FlsItem it;
    unsigned int fls;
    unsigned int item;
    int mask;

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SEQ_STOP:
        CALLV(ROOT->SetApTimer)(0x53L, obj, -1L, EVT_HDAE_AFTER_LOAD, 0L);
        break;
    case EVT_HDAE_AFTER_LOAD:
        if (HDAE5000_RAM_FlsAutoLoadPending == 1) {
            fls = HDAE5000_RAM_FlsChainFls;
            if ((item = HDAE5000_RAM_FlsChainItem + 1) >= 32) {
                if (++fls >= 120)
                    fls = 0;
                item = 0;
            }
            if (HDAE5000_FlsItem_Get(fls, item, &it) != 0xffff) {
                if (it.al == 1) {
                    HDAE5000_RAM_FlsAutoLoadPending = 1;
                    HDAE5000_RAM_FlsChainFls = fls;
                    HDAE5000_RAM_FlsChainItem = item;
                } else
                    HDAE5000_RAM_FlsAutoLoadPending = 0;
                mask = HDAE5000_Song_PartMask(it.dir, it.song);
                if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, 0, OBJ_FLS_FILE_LOAD) != 0xffff) {
                    if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                        CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
                    if (it.as == 1)
                        CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
                }
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
        }
        break;
    case EVT_SW_IN:
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_RAM_CurFlsItem = (int)HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &it) != 0xffff) {
            if (it.al == 1) {
                HDAE5000_RAM_FlsAutoLoadPending = 1;
                HDAE5000_RAM_FlsChainFls = HDAE5000_RAM_CurFls;
                HDAE5000_RAM_FlsChainItem = HDAE5000_RAM_CurFlsItem;
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
            mask = HDAE5000_Song_PartMask(it.dir, it.song);
            if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, 0, OBJ_FLS_FILE_LOAD) != 0xffff) {
                if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
                if (it.as == 1)
                    CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        HDAE5000_RAM_CurFlsItem = (int)HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(1, 0);
        if (HDAE5000_Fls_IsBlankName(HDAE5000_RAM_CurFls) != 0xffff)
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        else {
            CALLV(ROOT->ApFuncCall)(APFUNC_FlsNamingCheck, EVT_SET_STRING,
                                    HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls));
            CALLV(ROOT->ApPostEvent)(OBJ_HDD_FLS_NAMING2, EVT_SHOW, 0L);
        }
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase == 0) {
            if (HDAE5000_RAM_CurFls != 0) {
                HDAE5000_RAM_CurFls--;
                HDAE5000_RAM_FlsItemPageBase = 16;
                HDAE5000_FlsScreen_Refresh(0, 0);
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
            }
        } else {
            HDAE5000_RAM_FlsItemPageBase = 0;
            HDAE5000_FlsScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase != 0) {
            if (HDAE5000_RAM_CurFls < 119) {
                HDAE5000_RAM_CurFls++;
                HDAE5000_RAM_FlsItemPageBase = 0;
                HDAE5000_FlsScreen_Refresh(0, 0);
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
            }
        } else {
            HDAE5000_RAM_FlsItemPageBase = 16;
            HDAE5000_FlsScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurFlsItem = (int)HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(0, 1);
        break;
    }
    return 0;
}
