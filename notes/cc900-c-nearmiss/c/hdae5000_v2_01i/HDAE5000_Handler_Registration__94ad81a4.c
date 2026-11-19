/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v2_01i/hdae5000_handler_registration__hreg_r74.c (2026-11-19-64-hd-r76-staged)
   sha256 94ad81a478b9b5fe5cbda19cc612a07469e8aade080a02d743774c351930925a (tar-sha256); compiled at -Xr */
/* hdae5000_v2_01i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-62-hd-r74-v201 (hd_r74v_handler_registration__hreg.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r74v_handler_registration__hreg.c.
   cc900-options: -Xr
*/
/* ---- hdae_ws.h (inlined) ---- */
/* the main CPU workspace and its function tables (gen_ws_header.py, from the RootFn_* / HamaFn_* .equ) */
typedef void (*VFN)();
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
/* every call goes through a cast: CALLR(int, ROOT->GetTitleNow)(), CALLV(ROOT->SendEvent)(obj, ev, arg) */
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
/* ---- end of hdae_ws.h ---- */
/* ---- hdae_ids.h (inlined) ---- */
/* HD-AE5000 UI object ids and event codes (gen_ids_header.py) */
#define NAKA_MAINFUNC_HDAETitleFunc 0x14a0000L
#define NAKA_CLASS_Function 0x1600001L
#define NAKA_CLASS_ApFunction 0x1600002L
#define NAKA_CLASS_MainFunction 0x1600003L
#define NAKA_CLASS_Class 0x1600004L
#define NAKA_CLASS_ResEvent 0x160000cL
#define NAKA_CLASS_ResMethod 0x160000dL
#define NAKA_CLASS_ResName 0x160000fL
#define NAKA_CLASS_Viewable 0x1600010L
#define OBJ_IV_HDDMENU 0x7f01f0L
/* ---- end of hdae_ids.h ---- */

struct ObjReg { long cls; void *proc; unsigned int count; void *table; };

extern unsigned int HDAE5000_RECORD_COUNT;
extern unsigned char HDAE5000_RECORD_TABLE[];
extern void *HDAE5000_UiObject_PtrTable[];
extern void *HDAE5000_UiObjectName_PtrTable[];
extern char HDAE5000_GFX_INIT_PARAMS[];

extern unsigned int ram_2397b6;     /* HDAE5000_RAM_EventName_Count */
extern unsigned int ram_239804;     /* HDAE5000_RAM_MessageName_Count */
extern void *ram_2394ce[];          /* HDAE5000_RAM_ObjHandler_Table */
extern void *ram_2395de[];          /* HDAE5000_RAM_ObjName_Table */
extern void *ram_23977e[];          /* HDAE5000_RAM_EventName_Table */
extern void *ram_2397b8[];          /* HDAE5000_RAM_MessageName_Table */
extern void *ram_239806[];          /* HDAE5000_RAM_ClassProc_Table */
extern void *ram_23983e[];          /* HDAE5000_RAM_ClassName_Table */
extern void *ram_239f5a[];          /* HDAE5000_RAM_ScreenProc_Table */
extern void *ram_239f96[];          /* HDAE5000_RAM_ScreenName_Table */

#define REG(n, c, p, cnt, t) \
    rec.cls = c; rec.proc = ROOT->p; rec.count = cnt; rec.table = t; \
    CALLV(ROOT->RegisterObjectTable)(n, (void *)&rec)

void HDAE5000_Handler_Registration(void)
{
    struct ObjReg rec;

    REG(0x16a, NAKA_CLASS_Class, ClassProc, HDAE5000_RECORD_COUNT, HDAE5000_RECORD_TABLE);
    REG(0x1ca, NAKA_CLASS_ResEvent, ResEventProc, ram_2397b6, ram_23977e);
    REG(0x1ea, NAKA_CLASS_ResMethod, ResMethodProc, ram_239804, ram_2397b8);
    REG(0x12a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x43, ram_2394ce);
    REG(0x42a, NAKA_CLASS_ApFunction, ApFunctionProc, 0x43, ram_2395de);
    REG(0x10a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_239806);
    REG(0x40a, NAKA_CLASS_Function, FunctionProc, 0x0d, ram_23983e);
    REG(0x14a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239f5a);
    REG(0x44a, NAKA_CLASS_MainFunction, MainFunctionProc, 0x0e, ram_239f96);
    REG(0x7f, NAKA_CLASS_Viewable, ViewableProc, 0x312, HDAE5000_UiObject_PtrTable);
    REG(0x37f, NAKA_CLASS_ResName, ResNameProc, 0x312, HDAE5000_UiObjectName_PtrTable);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, 10, (long)HDAE5000_GFX_INIT_PARAMS);
}
