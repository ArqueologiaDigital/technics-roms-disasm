/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_g3b.c (2026-11-16-59-hd-r8)
   sha256 c1db5894d1a6ebdfcb7b877c95bce552e25b08026bcf87b9cdeaec3b1e258f97 (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_small, group 3, form b: hd_r4_g3.c's functions (same names) with:
   - SendPartMsg defined K&R style (char parameters, int-widened arguments), with early returns and the two
     message arrays filled by assignments from extern templates (a struct copy) instead of auto initialisers;
   - Apply's case 0 written `return;`.
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutModeCheck=HDAE5000_SeparateOutputModeCheck */
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
#define EVT_GET_LARGE_STEP 0x1e0003eL
#define EVT_GET_SMALL_STEP 0x1e0003fL
#define EVT_GET_MAX 0x1e00043L
#define EVT_GET_MIN 0x1e00044L
#define EVT_GET_RAM_ADDRESS 0x1e00045L
#define EVT_GET_RAM_SIZE 0x1e00046L
#define EVT_GET_RAM_STRING 0x1e00047L
#define EVT_RAM_DATA_REQ 0x1e00082L
/* ---- end of hdae_ids.h ---- */

struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned char HDAE5000_RAM_SeparateOutputMode;
extern unsigned char HDAE5000_RAM_SeparateDrumPart;
extern unsigned char HDAE5000_RAM_SeparateBassPart;
extern unsigned char HDAE5000_RAM_SeparateDrumPartSent;
extern unsigned char HDAE5000_RAM_SeparateBassPartSent;
extern char *HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[];
extern char *HDAE5000_TextPtrs_NONE_to_16[];
extern char *HDAE5000_TextPtrs_NONE_to_16_2[];

#define FMT_S_MODE ((const char *)0x2e2786L)   /* HDAE5000_Fmt_s_SeparateOutputModeCheck, "%s" */
#define FMT_S_DRUM ((const char *)0x2e2848L)   /* HDAE5000_Fmt_s_SeparateDrumPartCheck */
#define FMT_S_BASS ((const char *)0x2e290aL)   /* HDAE5000_Fmt_s_SeparateBassPartCheck */

struct Msg4 { unsigned char b[4]; };
extern struct Msg4 ram_2e272e;   /* HDAE5000_SeparateOutput_MsgTemplateA (its first 31 characters are shared with B) */
extern struct Msg4 ram_2e2732;   /* HDAE5000_SeparateOutput_MsgTemplateB */

void SepOut_SendPartMsg(part, bank, mode)
unsigned char part, bank, mode;
{
    struct Msg4 a;
    struct Msg4 b;

    a = ram_2e272e;
    b = ram_2e2732;   /* HDAE5000_SeparateOutput_MsgTemplateB */
    if (part >= 16)
        return;
    if (bank > 1)
        return;
    if (mode > 2)
        return;
    a.b[1] = part;
    b.b[1] = part;
    if (bank == 0)
        a.b[3] = 0x01;
    else
        a.b[3] = 0x20;
    if (mode == 0)
        b.b[3] = 0;
    else if (mode == 1)
        b.b[3] = 1;
    else
        b.b[3] = 2;
    CALLV(HAMA->sendCOMM)(0, 4, &a);
    CALLV(HAMA->sendCOMM)(0, 4, &b);
}

void HDAE5000_SeparateOutput_Apply(void)
{
    CALLV(HAMA->SetSepaOutMode)(HDAE5000_RAM_SeparateOutputMode);
    if (HDAE5000_RAM_SeparateDrumPartSent != 0) {
        SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateDrumPartSent = 0;
    }
    if (HDAE5000_RAM_SeparateBassPartSent != 0) {
        SepOut_SendPartMsg(HDAE5000_RAM_SeparateBassPartSent - 1, 0, 0);
        HDAE5000_RAM_SeparateBassPartSent = 0;
    }
    switch (HDAE5000_RAM_SeparateOutputMode) {
    case 0:
        return;
    case 1:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        break;
    case 2:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 0);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 0);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    case 3:
        if (HDAE5000_RAM_SeparateDrumPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateDrumPart - 1, 1, 2);
            HDAE5000_RAM_SeparateDrumPartSent = HDAE5000_RAM_SeparateDrumPart;
        }
        if (HDAE5000_RAM_SeparateBassPart != 0) {
            SepOut_SendPartMsg(HDAE5000_RAM_SeparateBassPart - 1, 1, 1);
            HDAE5000_RAM_SeparateBassPartSent = HDAE5000_RAM_SeparateBassPart;
        }
        break;
    }
}

long SepOutModeCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, FMT_S_MODE, HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 3;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SeparateOutputMode;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        CALLV(ROOT->SleepMainTask)();
        HDAE5000_SeparateOutput_Apply();
        CALLV(ROOT->WakeUpMainTask)();
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SeparateDrumPartCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, FMT_S_DRUM, HDAE5000_TextPtrs_NONE_to_16[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 16;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SeparateDrumPart;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        CALLV(ROOT->SleepMainTask)();
        HDAE5000_SeparateOutput_Apply();
        CALLV(ROOT->WakeUpMainTask)();
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_SeparateBassPartCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, FMT_S_BASS, HDAE5000_TextPtrs_NONE_to_16_2[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 16;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SeparateBassPart;
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        CALLV(ROOT->SleepMainTask)();
        HDAE5000_SeparateOutput_Apply();
        CALLV(ROOT->WakeUpMainTask)();
        return 0;
    default:
        return 0;
    }
}
