/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r23_uig.c (2026-11-16-102-hd-r23a)
   sha256 328e4738e389b87391dcf834988c635ba6eebb357fb0c4aaa8e58ec569b914ff (tar-sha256); compiled at -Xr */
/* hd_r23_uig.c (helper h_nm3b, lane_hd round 23): the calr group HDAE5000_CheckFileSignature +
   HDAE5000_FdSong_CheckFiles (hdae5000_ui_display.s), in ROM order; round 20's hd_r20_uig.c with these changes:
   - CheckFileSignature: the table index as a SHIFT, `(unsigned long)part << 3` (the ROM shifts the extended part in
     place, `sll xde,3`; `* 8` copied it first, `ld xhl,xde; sll xhl,3`); the length passed to an `int` parameter
     of HDAE5000_StrNCmp (a conversion: the ROM loads it, `ld de,(xhl); pushw de`, where V4.23 pushed the memory
     word, `pushw (xde)`); one exit through a local, `r = 0` / `r = -1` (the ROM's `ld hl,0; jr t,Return`, as
     CPanel_CheckSpecialCombos); buf a `const unsigned char *`, so the caller's HdStreamBuffer argument is
     converted (the ROM evaluates it first: `lda xwa,(buf); ld xbc,xwa; ld wa,k`).
   - FdSong_CheckFiles: ff declared before path (V4.23 put path at xsp+270; the ROM has path at xsp+4, ff at +18);
     ff converted for findfirst, `(void *)ff` (the ROM evaluates it first, `lda xwa,(xsp+18); ld xbc,xwa`); the
     pushed extensions are EXTERN symbols ram_<hex> (an extern pushed directly gives `pushw X@hi16 / @lo16`; the
     numeric `(char *)0x2f8e9cL` gave `ld xwa,imm; push xwa`).  The labels HDAE5000_FdSong_CheckFiles_Str_* share
     their first 31 characters, hence ram_<hex>.
   cc900-options: -Xr
   cc900-module: HDAE5000_CheckFileSignature
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
/* ---- end of hdae_ids.h ---- */

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);     /* no const: the pushed extensions stay constants */
extern int __cdecl HDAE5000_StrNCmp(char *, char *, int);

struct PartSig { char *sig; unsigned int offset; unsigned int len; };
extern struct PartSig HDAE5000_PartSignatureTable[];
extern unsigned char HDAE5000_PartSignatureTable_FileOffset[];
extern unsigned char HDAE5000_PartSignatureTable_Length[];

extern unsigned char HDAE5000_RAM_HdStreamBuffer[];

/* HDAE5000_FdSong_CheckFiles_Str_<EXT> (pushed) and _Str_rb, _Str_rb_2 .. _rb_9 (lda) */
extern char ram_2f8e9c[], ram_2f8ea2[], ram_2f8ea8[], ram_2f8eb2[], ram_2f8ebc[], ram_2f8ec6[];
extern char ram_2f8ed0[], ram_2f8ed8[], ram_2f8ee2[], ram_2f8eec[], ram_2f8ef4[];
extern char ram_2f8eae[], ram_2f8eb8[], ram_2f8ec2[], ram_2f8ecc[], ram_2f8ed4[];
extern char ram_2f8ede[], ram_2f8ee8[], ram_2f8ef0[], ram_2f8efa[];

int HDAE5000_CheckFileSignature(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)((unsigned long)&HDAE5000_PartSignatureTable_FileOffset[0] + ((unsigned long)part << 3))),
                         *(unsigned int *)((unsigned long)&HDAE5000_PartSignatureTable_Length[0] + ((unsigned long)part << 3))) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask)
{
    long h;
    unsigned char ff[266];
    char path[13];

    HDAE5000_MemFill(path, 0, 13);
    HDAE5000_MemCopy(path, name, 8);
    HDAE5000_StrCpy(&path[8], ram_2f8e9c);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    HDAE5000_StrCpy(&path[8], ram_2f8ea2);
    if ((h = CALLR(long, HAMA->findfirst)(path, (void *)ff)) != -1L) {
        CALLV(HAMA->findclose)(h);
        return -1;
    }
    if (mask & 0x001) {
        HDAE5000_StrCpy(&path[8], ram_2f8ea8);
        CALLV(HAMA->fopen_ext)(path, ram_2f8eae);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(0, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x002) {
        HDAE5000_StrCpy(&path[8], ram_2f8eb2);
        CALLV(HAMA->fopen_ext)(path, ram_2f8eb8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(1, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x004) {
        HDAE5000_StrCpy(&path[8], ram_2f8ebc);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ec2);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(2, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x008) {
        HDAE5000_StrCpy(&path[8], ram_2f8ec6);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ecc);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(3, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x010) {
        HDAE5000_StrCpy(&path[8], ram_2f8ed0);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ed4);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(4, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x020) {
        HDAE5000_StrCpy(&path[8], ram_2f8ed8);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ede);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(5, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x040) {
        HDAE5000_StrCpy(&path[8], ram_2f8ee2);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ee8);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(6, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x080) {
        HDAE5000_StrCpy(&path[8], ram_2f8eec);
        CALLV(HAMA->fopen_ext)(path, ram_2f8ef0);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(7, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    if (mask & 0x100) {
        HDAE5000_StrCpy(&path[8], ram_2f8ef4);
        CALLV(HAMA->fopen_ext)(path, ram_2f8efa);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_HdStreamBuffer, 0x200L);
        CALLV(HAMA->fclose_ext)();
        if (HDAE5000_CheckFileSignature(8, HDAE5000_RAM_HdStreamBuffer) == -1)
            return -1;
    }
    return 0;
}
