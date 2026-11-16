/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_g5.c (2026-11-16-59-hd-r8)
   sha256 9b0c0f4ec6d968f67e6d5c734d749d278a050bf57d06d7d22ad712f56d196230 (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_small, group 5 (one calr group = one module), in ROM address order:
   HDAE5000_TitleInfo_Build, HDAE5000_HdTitleEventCatch.  Options: -Xr.
   Reading of the hand source:
   - TitleInfo_Build's frame (32 B): the disk usage record at +16 (four longs; +12 = free), a 6-byte text at +10 for
     the "%s" / "%d" settings and a 10-byte text at +0 for "%4ldMB"; locals declared highest address first.
   - The title text HDAE5000_RAM_TitleInfoText (0x22ada6, 0x97 bytes from HDAE5000_TitleInfo_Template) is three
     50-byte rows with values at +20 and +43: WRITE PROTECT +20, WRITE CONFIRM +70, LOAD BY NUMBER +120, QUICK LOAD +43,
     JUMP AFTER LOAD +93, free space +143.  Each destination is an `lda` of a fixed address: ram_<hex> arrays
     (form b: offsets into the named array).
   - OFF/ON texts: HDAE5000_TextPtrs_OFF_ON[byte] (`lda xbc,(sym); ld xwa,(xbc+wa)` with an int index);
     formats pushed as 32-bit constants (`pushw hi16/lo16`): constant pointers.
   - usage.free / 100 is the library's unsigned 32-bit divide (HDAE5000_UDivMod32).
   - HdTitleEventCatch: compares DRAW then ARE_YOU_CLASS_PROC, default body first, then ARE_YOU, then DRAW: V4.23's
     reverse-source-order compares with `default:` written first (hd_r3_la AttenCpToHDSwCatch, run 49). */
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
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_HARD_DISK_OPT 0x7f000aL
/* ---- end of hdae_ids.h ---- */

struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *);

extern unsigned char HDAE5000_RAM_WriteProtect;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern char HDAE5000_RAM_TitleInfoText[];
extern char HDAE5000_TitleInfo_Template[];
extern char *HDAE5000_TextPtrs_OFF_ON[];
extern char HDAE5000_Str_HDAE[];
extern char ram_22adba[], ram_22adec[], ram_22ae1e[], ram_22add1[], ram_22ae03[], ram_22ae35[];

#define FMT_S_A ((const char *)0x2e235cL)   /* HDAE5000_Fmt_s, "%s" */
#define FMT_S_B ((const char *)0x2e2360L)   /* HDAE5000_Fmt_s_TitleInfo_Build */
#define FMT_D_A ((const char *)0x2e2364L)   /* HDAE5000_Fmt_d */
#define FMT_D_B ((const char *)0x2e236aL)   /* HDAE5000_Fmt_d_TitleInfo_Build */
#define FMT_D_C ((const char *)0x2e2372L)   /* HDAE5000_Fmt_d_TitleInfo_Build_2 */
#define FMT_MB ((const char *)0x2e237aL)    /* HDAE5000_Fmt_4ldMB, "%4ldMB" */

void HDAE5000_TitleInfo_Build(void)
{
    struct DiskUsage usage;
    char s[6];
    char mb[10];

    HDAE5000_MemCopy(HDAE5000_RAM_TitleInfoText, HDAE5000_TitleInfo_Template, 0x97);
    HDAE5000_SPrintf(s, FMT_S_A, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteProtect]);
    HDAE5000_MemCopy(ram_22adba, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_S_B, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteConfirm]);
    HDAE5000_MemCopy(ram_22adec, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_A, HDAE5000_RAM_LoadByNumberMode);
    HDAE5000_MemCopy(ram_22ae1e, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_B, HDAE5000_RAM_QuickLoadMode);
    HDAE5000_MemCopy(ram_22add1, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_C, HDAE5000_RAM_JumpAfterLoad);
    HDAE5000_MemCopy(ram_22ae03, s, HDAE5000_StrLen(s));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_SPrintf(mb, FMT_MB, usage.free / 100);
    HDAE5000_MemCopy(ram_22ae35, mb, HDAE5000_StrLen(mb));
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_TitleInfoText);
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_PARA_DRAW, -1L);
}

long HDAE5000_HdTitleEventCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        HDAE5000_TitleInfo_Build();
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, HDAE5000_Str_HDAE);
        return 0;
    }
}
