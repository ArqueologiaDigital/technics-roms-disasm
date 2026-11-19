/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v1_15i/hdae5000_lbn_page.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 f705ec41db45a5b36815ae721156987bcf7e5f7e96a7dcc1a5a102dbacdcfa60 (tar-sha256); compiled at -Xr */
/* Functions of hdae5000_hd_driver.s.  (hdae5000_lbn_page.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_lbn_page.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   cc900-data: HDAE5000_Lbn_StepDigit 1 = HDAE5000_Lbn_StepDigit_CaseTable
   cc900-data: HDAE5000_LBNPage1SwCatch 1 = HDAE5000_LBNPage1SwCatch_CaseTable
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
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define OBJ_LBN_OPTION 0x7f0094L
/* ---- end of hdae_ids.h ---- */

struct TypeSel { unsigned int mask; unsigned char flag[10]; };

/* ---- this module (calr) ---- */
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_Lbn_TypeDigit(long obj, int digit);
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
/* the same three cells as int: HDAE5000_RAM_LbnDigitPos, _LbnDir, _LbnSong */
extern int ram_22aa5c;
extern int ram_22aa5e;
extern int ram_22aa60;

/* ---- ROM ---- */
extern char HDAE5000_Str_LBNS[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

/* ---- HDAE5000_Lbn_StepDigit ------------------------------------------------------------------------------ */

/* a local copy of dir */
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step)
{
    int m;
    int d;

    d = dir;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        return;
    case 1:
        d += step * 100;
        if (d >= 100)
            d = 100;
        else if (d <= 0)
            d = 0;
        break;
    case 2:
        d += step * 10;
        if (d >= 120)
            d = 120;
        else if (d <= 1)
            d = 0;
        break;
    case 3:
        d += step;
        if (d > 120)
            d = 120;
        else if (d <= 0)
            d = 1;
        break;
    case 4:
        song += step * 10;
        if (song >= 10)
            song = 10;
        else if (song <= 0)
            song = 0;
        break;
    case 5:
        song += step;
        if (song > 16)
            song = 16;
        else if (song <= 0)
            song = 1;
    }
    HDAE5000_RAM_LbnDir = d;
    HDAE5000_RAM_LbnSong = song;
    if (HDAE5000_RAM_LbnDigitPos == 5) {
        HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
        HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
        } else {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, -1, -1, 0xffff);
        }
    }
    HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
}

/* the copy as an initialiser */

/* the unused third parameter reused as the copy */

/* dir unsigned, the int copy being the conversion */

/* ---- HDAE5000_LBNPage1SwCatch ---------------------------------------------------------------------------- */

/* int cells; unsigned s by if / else */
long HDAE5000_LBNPage1SwCatch(long obj, long ev, long arg)
{
    unsigned int s;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_LBNS);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 12:
            HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
            break;
        case 5:
        case 6:
        case 7:
            if ((arg & 0x80) == 0)
                s = 1;
            else
                s = 0xffff;
            HDAE5000_Lbn_StepDigit(ram_22aa5e, ram_22aa60, ram_22aa5c, s);
            break;
        case 0:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 0);
            else
                HDAE5000_Lbn_TypeDigit(obj, 1);
            break;
        case 1:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 2);
            else
                HDAE5000_Lbn_TypeDigit(obj, 3);
            break;
        case 2:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 4);
            else
                HDAE5000_Lbn_TypeDigit(obj, 5);
            break;
        case 3:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 6);
            else
                HDAE5000_Lbn_TypeDigit(obj, 7);
            break;
        case 4:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 8);
            else
                HDAE5000_Lbn_TypeDigit(obj, 9);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* int cells; int s by if / else */

/* int cells; unsigned s passed through a cast */

/* int cells; the conditional expression with 0xffff */

/* the unsigned cells, each cast to int; unsigned s */
