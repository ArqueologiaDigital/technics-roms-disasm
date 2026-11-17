/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_boot.c (2026-11-16-98-hd-r22)
   sha256 05ebfc57a7544b6cdef09ea1442db94c79706ff4e30dfd199f8c28056fb65a35 (tar-sha256); compiled at -Xr
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
#define EVT_INTERRUPT_TITLE 0x1c00016L
#define EVT_GET_BITMAP_DATA 0x1e000a1L
#define TITLE_HDDEXT 0x1a0007fL
#define NAKA_CLASS_HDTitleMenu 0x16a0005L
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void HDAE5000_Clear_Work_Buffer(void);
extern void HDAE5000_Handler_Registration(void);
extern void HDAE5000_Load_Palette(unsigned char *pal);
extern unsigned char *HDAE5000_Alloc_Memory(long obj, long ev, long arg);
extern unsigned char HDAE5000_Check_HD_Present(void);
extern void HDAE5000_Finalize_Init(void);
extern void HDAE5000_UiState_Reset(void);
extern unsigned char HDAE5000_Palette_BootSplash[];
extern char HDAE5000_Display_Params[];
extern unsigned char HDAE5000_RAM_HdPresent;
extern unsigned char *HDAE5000_RAM_SqSrtcPtr;
extern unsigned int *HDAE5000_RAM_SqBtofPtr;
extern unsigned char *HDAE5000_RAM_SqBeadtPtr;
void HDAE5000_Boot_Init(struct NakaWs *ws)
{
    unsigned char *bmp;
    unsigned char *v;

    HDAE5000_Clear_Work_Buffer();
    HDAE5000_RAM_MainWorkspacePtr = ws;
    HDAE5000_Handler_Registration();
    HDAE5000_Load_Palette(HDAE5000_Palette_BootSplash);
    bmp = HDAE5000_Alloc_Memory(0L, EVT_GET_BITMAP_DATA, 0L);
    HDAE5000_MemCopy((unsigned char *)0x1a0000L, bmp, 0x9600);     /* converted: ld xwa,imm; push xwa */
    HDAE5000_MemCopy((unsigned char *)0x1a9600L, bmp + 0x9600, 0x9600);
    v = CALLR(unsigned char *, ROOT->GetViewInstance)(0x600002L);
    *(long *)v = NAKA_CLASS_HDTitleMenu;
    *(char **)(v + 42) = HDAE5000_Display_Params;
    HDAE5000_RAM_SqSrtcPtr = CALLR(unsigned char *, HAMA->GetAdr_sqsrtc)();
    HDAE5000_RAM_SqBtofPtr = CALLR(unsigned int *, HAMA->GetAdr_sqbtof)();
    HDAE5000_RAM_SqBeadtPtr = CALLR(unsigned char *, HAMA->GetAdr_sq_beadt)();
    if ((HDAE5000_RAM_HdPresent = HDAE5000_Check_HD_Present()) != 0)
        CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, TITLE_HDDEXT);
    HDAE5000_Finalize_Init();
    HDAE5000_UiState_Reset();
}
