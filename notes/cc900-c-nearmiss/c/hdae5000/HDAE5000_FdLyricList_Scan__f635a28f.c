/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r27_b_uih.c (2026-11-16-119-hd-r30)
   sha256 f635a28f1d0c793ffd40a7ac651c47f9c0ef79992ad0de6ea4c184eff78ea4b1 (tar-sha256); compiled at -Xr */
/* hd_r27_b_uih.c (helper h_r27b, lane_hd round 27): hd_r23_uih.c with AddTlx's row addresses respelled, and four
   named variants of AddTlx.  Run 102: FdLyricList_Scan matched but for its calr target; AddTlx could not be
   checked ("llvm-mc refused the translation"): V4.23's listing wrote the row before the first as
   `lda XWA,_HDAE5000_RAM_FdLyricNames + 0xfffffff7`, which the checker adds without wrapping to 32 bits
   (0x10023087b).  With that patched in memory (h_r27b/rshow4.py) AddTlx departs only in the four row addresses:
   ROM `muls wa,9; lda xbc,(Names:24); exts xwa; add xwa,xbc`, V4.23 (for `(char *)Names[0] + j * 9`)
   `muls; ld bc,wa; lda xwa,(Names); lda xwa,xwa+bc`.  The ROM widens the int product AFTER loading the base and
   adds the base to it.  Spellings here (none uses a negative offset, so the checker gap is avoided too: the row
   before the first is the extern ram_23087b):
   - HDAE5000_FdLyricList_AddTlx: the names as a flat char array through a cast, `&FLAT[j * 9]`, and
     `&FLAT[(k - 1) * 9]` for the shift's source (if V4.23 does not fold the -9 into the address, see _b);
   - AddTlx_b: flat extern arrays, `&ram_230884[j * 9]`, `&ram_23087b[k * 9]`;
   - AddTlx_c: the product on the left of a pointer sum, `j * 9 + ram_230884`;
   - AddTlx_d: an integer sum, `(char *)(j * 9 + (unsigned long)&ram_230884[0])`;
   - AddTlx_e: `ram_230884 + (long)(j * 9)`.
   cc900-name: AddTlx_b=HDAE5000_FdLyricList_AddTlx
   cc900-name: AddTlx_c=HDAE5000_FdLyricList_AddTlx
   cc900-name: AddTlx_d=HDAE5000_FdLyricList_AddTlx
   cc900-name: AddTlx_e=HDAE5000_FdLyricList_AddTlx
   hd_r23_uih.c's header follows.
   hd_r23_uih.c (helper h_nm3b, lane_hd round 23): HDAE5000_FdLyricList_Scan and HDAE5000_FdLyricList_AddTlx
   (hdae5000_ui_display.s), in ROM order; calr group HDAE5000_FDFileSelectProc HDAE5000_FdLyricList_AddTlx
   HDAE5000_FdLyricList_Scan (FDFileSelectProc is not in this file).  Round 20's hd_r20_uih.c with these changes,
   from run 95:
   - Scan: StrLen takes `const char *` (its argument is converted: the ROM evaluates it first, `lda xwa,(sym);
     push xwa` for the volume label and `ld xwa,xiz; push xwa` for the returned label, where V4.23 pushed the
     constant / XIZ); StrCat keeps `char *`, so the volume label it gets is pushed as a constant (`pushw 35;
     pushw 3706` = HDAE5000_RAM_FdVolumeLabel@hi16/@lo16; r20's `(char *)0x230e7aL` gave `ld xwa,imm`).
     The label is tested as an assignment's value, `if ((label = ..()) != 0)` (the ROM reads it back:
     `ld xiz,xhl; ld xwa,xiz; or xwa,xwa`; r20 gave `or xiz,xiz`).  ff is converted for findfirst and findnext,
     `(void *)ff` (the ROM evaluates it first: `lda xwa,(xsp+8); ld xbc,xwa`), and declared after fname (ROM: ff
     at xsp+8, fname at xsp+274; V4.23 lays arrays out in reverse declaration order).
   - AddTlx: tmp declared before base (ROM: base at xsp+4, tmp above it); the sorted-insert rows are addressed as
     `(char *)HDAE5000_RAM_FdLyricNames[0] + j * 9` (the ROM multiplies the int, `muls wa,9`, then adds a converted
     base, `lda xbc,(HDAE5000_RAM_FdLyricNames:24); exts xwa; add xwa,xbc`; r20's `Names[j]` gave `exts; sll;
     add; ld xwa,imm`), the shift loop's source as `(char *)HDAE5000_RAM_FdLyricNames[-1] + k * 9` (the ROM's
     `lda xbc,(HDAE5000_RAM_FdLyricNames-9:24)` after `muls`, no `dec`).
   The library string routines otherwise take char * (not const char *) so that a ROM label pushed as an argument
   is a constant (pushw @hi16 / @lo16).
   cc900-options: -Xr
   cc900-module: HDAE5000_FdLyricList_AddTlx
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
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);
extern char *__cdecl HDAE5000_StrRev(char *);
extern char *__cdecl HDAE5000_StrUpr(char *);

extern unsigned char HDAE5000_RAM_FdLyricNames[][9];
extern char HDAE5000_RAM_FdLyricTitles[][27];
extern unsigned char HDAE5000_RAM_FdLyricHasMid[];
extern unsigned int HDAE5000_RAM_FdLyricCount;
/* HDAE5000_RAM_FdLyricNames as a flat char array, and the row before it (HDAE5000_RAM_FdLyricNames - 9) */
extern char ram_230884[], ram_23087b[];
extern char HDAE5000_RAM_FdVolumeLabel[];
extern unsigned char ram_230e82;                /* HDAE5000_RAM_FdVolumeLabel + 8 */

extern char HDAE5000_Str_Chr202D3E[];           /* " ->" */
extern unsigned char HDAE5000_Str_Chr2A2E2A[];  /* "*.*", passed converted: the ROM evaluates it first */
extern char HDAE5000_Str_TTX[];
extern char HDAE5000_Str_Rb_FdLyricTtx[];
extern char HDAE5000_Str_MID[];
extern char HDAE5000_Str_Rb_FdLyricMid[];
extern char HDAE5000_Str_XLT[];

long HDAE5000_FdLyricList_AddTlx(char *name);

long HDAE5000_FdLyricList_Scan(void)
{
    long r;
    char fname[100];
    char ff[266];
    char *label;
    long h;
    unsigned int i;

    r = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->SleepMainTask)();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdVolumeLabel, label, HDAE5000_StrLen(label));
        else
            HDAE5000_RAM_FdVolumeLabel[0] = 0;
        ram_230e82 = 0;
        if (HDAE5000_StrLen(HDAE5000_RAM_FdVolumeLabel) != 0)
            HDAE5000_StrCat(HDAE5000_RAM_FdVolumeLabel, HDAE5000_Str_Chr202D3E);
        h = CALLR(long, HAMA->findfirst)((char *)HDAE5000_Str_Chr2A2E2A, (void *)ff);
        r = HDAE5000_FdLyricList_AddTlx(&ff[6]);
        while (CALLR(int, HAMA->findnext)(h, (void *)ff) == 0)
            r = HDAE5000_FdLyricList_AddTlx(&ff[6]);
        CALLV(HAMA->findclose)(h);
        for (i = 0; i < HDAE5000_RAM_FdLyricCount; i++) {
            HDAE5000_StrCpy(fname, (char *)HDAE5000_RAM_FdLyricNames[i]);
            HDAE5000_StrCat(fname, HDAE5000_Str_TTX);
            CALLV(HAMA->fopen_ext)(fname, HDAE5000_Str_Rb_FdLyricTtx);
            CALLV(HAMA->fread_ext)(HDAE5000_RAM_FdLyricTitles[i], 26L);
            CALLV(HAMA->fclose_ext)();
            HDAE5000_StrCpy(fname, (char *)HDAE5000_RAM_FdLyricNames[i]);
            HDAE5000_StrCat(fname, HDAE5000_Str_MID);
            if (CALLR(int, HAMA->fopen_ext)(fname, HDAE5000_Str_Rb_FdLyricMid) >= 0)
                HDAE5000_RAM_FdLyricHasMid[i] = 1;
            else
                HDAE5000_RAM_FdLyricHasMid[i] = 0;
            CALLV(HAMA->fclose_ext)();
        }
        CALLV(ROOT->WakeUpMainTask)();
    }
    return r;
}

/* the names as a flat char array: indexed with the int product */
#define FLAT ((char *)HDAE5000_RAM_FdLyricNames)

long HDAE5000_FdLyricList_AddTlx(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, &FLAT[j * 9]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(&FLAT[k * 9], &FLAT[(k - 1) * 9]);
                HDAE5000_StrCpy(&FLAT[j * 9], base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}

/* AddTlx_b: flat extern arrays, no cast; the row before the first is its own extern */
long AddTlx_b(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, &ram_230884[j * 9]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(&ram_230884[k * 9], &ram_23087b[k * 9]);
                HDAE5000_StrCpy(&ram_230884[j * 9], base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}

/* AddTlx_c: the int product on the LEFT of a pointer sum */
long AddTlx_c(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, j * 9 + ram_230884) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(k * 9 + ram_230884, k * 9 + ram_23087b);
                HDAE5000_StrCpy(j * 9 + ram_230884, base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}

/* AddTlx_d: an INTEGER sum, the int product (converted implicitly) + the address as an unsigned long */
long AddTlx_d(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, (char *)(j * 9 + (unsigned long)&ram_230884[0])) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy((char *)(k * 9 + (unsigned long)&ram_230884[0]),
                                    (char *)(k * 9 + (unsigned long)&ram_23087b[0]));
                HDAE5000_StrCpy((char *)(j * 9 + (unsigned long)&ram_230884[0]), base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}

/* AddTlx_e: a pointer plus the int product converted to long by a cast */
long AddTlx_e(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, ram_230884 + (long)(j * 9)) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(ram_230884 + (long)(k * 9), ram_23087b + (long)(k * 9));
                HDAE5000_StrCpy(ram_230884 + (long)(j * 9), base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}
