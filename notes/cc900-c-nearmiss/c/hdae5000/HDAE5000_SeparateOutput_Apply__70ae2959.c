/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_g3.c (2026-11-16-59-hd-r8)
   sha256 70ae29597923025f96f5a6ca04f70ab4541a8996965e957ed2fe77c72a66967e (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_small, group 3 (one calr group = one module): SEPARATE OUTPUT, in ROM address order:
   HDAE5000_SeparateOutput_SendPartMsg, _SeparateOutput_Apply, _SeparateOutputModeCheck, _SeparateDrumPartCheck,
   _SeparateBassPartCheck.  Options: -Xr.
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutModeCheck=HDAE5000_SeparateOutputModeCheck
   Reading of the hand source:
   - SendPartMsg's two 4-byte messages are initialised auto arrays: V4.23 copies the initialiser from a hidden ROM
     copy (HDAE5000_SeparateOutput_MsgTemplateA / B = {0xb0,0,0x9b,0} / {0xb0,0,0x9d,0}) with two ldiw each; the first
     declared is at the higher frame address (xsp+4), as round 3 found; `ld l,c` saves C from ldiw's BC counter.
     Its parameters are char (it reads A, C, E) but Apply loads BC / DE with 16-bit zeros and widens A: char
     arguments are passed widened (form b tries a K&R definition instead).
   - `uc - 1` is computed in byte width (`dec 1,a; extz wa`), V4.23's own narrowing (run 2026-11-16-45 SeqPart_*).
   - Apply's switch: V4.23 compares the cases in REVERSE SOURCE ORDER (AttenCpToHDSwCatch, run 49: 07, 0d, 85 for
     source order 85, 0d, 07; HD_GetBlockInfo's 2, 1, 0 fits both readings), so the source order is 0, 1, 2, 3.
   - The three *Check procedures: (obj, event, arg) with arg a parameter block (+0x0e the value as a long, +0x12 the
     destination string).  Case bodies in ROM order: GET_RAM_STRING, LARGE_STEP, SMALL_STEP, MAX, MIN, RAM_ADDRESS,
     RAM_SIZE, RAM_DATA_REQ, then the default; GET_LSW_* fall to the default (return 0, no InheritedProc).
   - The format strings are pushed as 32-bit constants (`pushw hi16 / lo16`), which V4.23 does for a stacked string
     literal and not for an extern array (h_pport, run 56): written as constant pointers at their ROM addresses.
     The value-text tables are extern arrays indexed by a long (`ld xbc, sym` immediate: a dereference). */
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

void SepOut_SendPartMsg(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, a);
        CALLV(HAMA->sendCOMM)(0, 4, b);
    }
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
        break;
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
