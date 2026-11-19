/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_fs_screens2.c (2026-11-19-17-hd-r62-ports-staged)
   sha256 e9d073b5a5d47c43548615d3e37f389775dfbee23cc3a612b4fa973ff51fea66 (tar-sha256); compiled at -Xr
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
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_HDAE_OVER_FLOW 0x1ea0000L
#define EVT_HDAE_UNDER_FLOW 0x1ea0001L
#define EVT_HDAE_CHANGE_SEL_NUM 0x1ea0002L
#define EVT_HDAE_SET_SEL_NUM 0x1ea0003L
#define EVT_HDAE_SELECT_OK 0x1ea0006L
#define EVT_HDAE_SELECT_SAVE 0x1ea0008L
#define OBJ_ATTEN_DEL_FLS1 0x7f0223L
#define OBJ_ATTEN_DEL_FLS2 0x7f0201L
#define OBJ_ERR_SAVE 0x7f028bL
#define OBJ_ERR_SAVE_CATCH 0x7f028dL
#define OBJ_ERR_SAVE_EXIT 0x7f028cL
#define OBJ_FLS_DIR_BOX 0x7f014bL
#define OBJ_FLS_DIR_SEL 0x7f0148L
#define OBJ_FLS_EDIT 0x7f015dL
#define OBJ_FLS_EDIT_LIST_BOX 0x7f0163L
#define OBJ_HD_PLEASE 0x7f02b5L
extern int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item);
extern void HDAE5000_FlsItem_SetAutoStart(unsigned int fls, unsigned int item, int on);
extern void HDAE5000_FlsItem_SetAutoLoad(unsigned int fls, unsigned int item, int on);
extern unsigned int HDAE5000_HD_StoreTables(int keep);
extern void HDAE5000_DirList_BuildPage(long obj);
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);
extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern unsigned int HDAE5000_RAM_FlsItemPageBase;
long HDAE5000_FlsEditScreen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT_LIST_BOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_FLS1, EVT_SHOW, 0L);
            break;
        case 1:
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_DEL_FLS2, EVT_SHOW, 0L);
            break;
        case 5:
            HDAE5000_FlsItem_Insert(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        case 6:
            if (arg & 0x80)
                HDAE5000_FlsItem_SetAutoStart(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 0);
            else
                HDAE5000_FlsItem_SetAutoStart(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 1);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        case 7:
            if (arg & 0x80)
                HDAE5000_FlsItem_SetAutoLoad(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 0);
            else
                HDAE5000_FlsItem_SetAutoLoad(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, 1);
            HDAE5000_FlsScreen_Refresh(1, 0);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_DirList_BuildPage(OBJ_FLS_DIR_BOX);
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_DIR_SEL, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
        CALLV(HAMA->pdly_tim_X)(100);
        HDAE5000_YieldUntilSem1Zero();
        if (HDAE5000_HD_StoreTables(0) != 0xffff)
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        else {
            CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
            HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_FLS_EDIT);
            CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_FLS_EDIT);
            CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_FLS_EDIT);
        }
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase != 0) {
            HDAE5000_RAM_FlsItemPageBase = 0;
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT_LIST_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase == 0) {
            HDAE5000_RAM_FlsItemPageBase = 16;
            HDAE5000_FlsScreen_Refresh(1, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT_LIST_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurFlsItem = (unsigned int)arg + HDAE5000_RAM_FlsItemPageBase;
        HDAE5000_FlsScreen_Refresh(1, 1);
        break;
    }
    return 0;
}
