/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r2_lb.c (2026-11-16-48-hd-r2b)
   sha256 f72cab3f3eed2e90653320247647d296146f08c236ebb0f7d95273915b394dcb (tar-sha256); compiled at -Xr */
/* lane_hd round 2, helper l, form b: other spellings of hd_r2_la.c's functions.  Differences from form a:
   - the song record as a struct pointer (SONGREC(d, s)->slot[n] / ->has[n]) instead of DirNames + field + offset,
     in case V4.23 folds the member offset into the symbol itself;
   - ret declared before info, and initialised in its declaration;
   - LoadSong_Cmp / _Msp: size computed in two statements (size = blocks; size <<= 4;);
   - the AttenCp procedures with default last;
   - HD_WriteClose with the byte count as an unsigned long difference. */
/* ---- hdae_ws.h (inlined) ---- */
/* the main CPU workspace and its function tables (gen_ws_header.py, from the RootFn_* / HamaFn_* .equ) */
typedef void (*VFN)();
struct RootFns {
    VFN pad0[33];
    VFN UpdateScreen;
    VFN pad1[5];
    VFN DrawLine;
    VFN pad2[1];
    VFN DrawBox;
    VFN DrawFrame;
    VFN pad3[1];
    VFN MovePixels;
    VFN pad4[4];
    VFN DrawString;
    VFN pad5[5];
    VFN InheritedProc;
    VFN pad6[1];
    VFN RegisterObjectTable;
    VFN pad7[6];
    VFN SendEvent;
    VFN PostEvent;
    VFN pad8[7];
    VFN ApPostEvent;
    VFN pad9[5];
    VFN ResEventProc;
    VFN ResMethodProc;
    VFN pad10[1];
    VFN ResNameProc;
    VFN pad11[1];
    VFN GetCharHeight;
    VFN GetCharDescent;
    VFN GetCenteredDelta;
    VFN ConvertStrings;
    VFN pad12[2];
    VFN ClassProc;
    VFN pad13[54];
    VFN FunctionProc;
    VFN ApFunctionProc;
    VFN MainFunctionProc;
    VFN ApFuncCall;
    VFN MainFuncCall;
    VFN pad14[6];
    VFN RegisterTitle;
    VFN pad15[1];
    VFN GetTitleNow;
    VFN pad16[1];
    VFN ViewableProc;
    VFN pad17[4];
    VFN SetVisible;
    VFN pad18[11];
    VFN GetViewInstance;
    VFN pad19[3];
    VFN GetClientBox;
    VFN pad20[1];
    VFN DrawDesignBox;
    VFN pad21[57];
    VFN SetDialEnable;
    VFN SetDialUp;
    VFN SetDialDown;
    VFN pad22[16];
    VFN SetApTimer;
    VFN pad23[1];
    VFN KillApTimer;
    VFN pad24[4];
    VFN SetAutoInc;
    VFN pad25[55];
    VFN GetNamingWindowID;
    VFN pad26[9];
    VFN DeleteEvent;
    VFN SleepMainTask;
    VFN WakeUpMainTask;
};
struct HamaFns {
    VFN pad0[1];
    VFN FDLoadSaveTest;
    VFN GetMediaType;
    VFN PreLswLoad;
    VFN PostLswLoad;
    VFN PreLswSave;
    VFN PostLswSave;
    VFN PrePmLoad;
    VFN PostPmLoad;
    VFN PrePmSave;
    VFN PostPmSave;
    VFN SeqLoadPre;
    VFN SeqLoadPost;
    VFN SeqSavePre;
    VFN SeqSavePost;
    VFN cmp_ld_mae;
    VFN cmp_ld_ato;
    VFN cmp_sv_mae;
    VFN cmp_sv_ato;
    VFN PreTmLoad;
    VFN PostTmLoad;
    VFN PreTmSave;
    VFN PostTmSave;
    VFN msp_ld_mae;
    VFN msp_ld_ato;
    VFN msp_sv_mae;
    VFN msp_sv_ato;
    VFN PreMidiLoad;
    VFN PostMidiLoad;
    VFN PreMidiSave;
    VFN PostMidiSave;
    VFN FlashWrite;
    VFN GetResouceInfo;
    VFN SetSepaOutMode;
    VFN pad1[2];
    VFN GetVolumeLabel;
    VFN findfirst;
    VFN findnext;
    VFN findclose;
    VFN fopen_ext;
    VFN pad2[1];
    VFN fread_ext;
    VFN fclose_ext;
    VFN rcm_ld_XAPR_j;
    VFN rcm_sv_XAPR_j;
    VFN rot_rdq_X;
    VFN pad3[5];
    VFN ref_sem_X;
    VFN pad4[4];
    VFN pdly_tim_X;
    VFN PlayHalt;
    VFN PlayStandBy;
    VFN EditSwRefresh;
    VFN pad5[3];
    VFN GetAdr_sqbtof;
    VFN GetAdr_sq_beadt;
    VFN GetAdr_sqsrtc;
    VFN pad6[2];
    VFN sendCOMM;
    VFN pad7[2];
    VFN SwbtWr;
    VFN pad8[2];
    VFN SetGlobalError;
    VFN malloc_X;
    VFN free_X;
    VFN ChangePalette;
    VFN ChangeWall;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
/* a call with a result: CALLR(int, ROOT->GetTitleNow)() */
#define CALLR(t, f) ((t (*)())(f))
/* ---- end of hdae_ws.h ---- */
/* ---- hdae_ids.h (inlined) ---- */
/* HD-AE5000 UI object ids and event codes (gen_ids_header.py) */
#define EVT_SHOW 0x1c00001L
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_SW_IN 0x1c00007L
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define EVT_ARE_YOU_CLASS_PROC 0x1e00085L
#define OBJ_CP_FD 0x7f00d2L
#define OBJ_HDDMENU 0x7f0000L
/* ---- end of hdae_ids.h ---- */

struct ResInfo { unsigned char *addr; unsigned long size; };
struct SongRec { unsigned char name[26]; unsigned char has[10]; long slot[10]; };
struct CmpHdr { unsigned char pad[46]; unsigned int blocks; };
struct MspHdr { unsigned char pad[28]; unsigned int blocks; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern char HDAE5000_Str_Cphd[];
extern char HDAE5000_Str_Cphd_AttenCpToMarkSwCatch[];

extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, long *slot);
extern int HDAE5000_HD_WriteFile(void *src, unsigned long n, long *slot);
extern int HDAE5000_HD_AppendFile(void *src, unsigned long n, long *slot);

#define SONGREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + \
                       ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)))

int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SONGREC(dir, song)->slot[4] != -1L) {
        HAMA->GetResouceInfo(6, &info);
        info.size = 0x72aaL;
        HAMA->PreTmLoad();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SONGREC(dir, song)->slot[4]);
        HAMA->PostTmLoad(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SONGREC(dir, song)->slot[3] != -1L) {
        HAMA->GetResouceInfo(5, &info);
        if (HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, 0x200L, &SONGREC(dir, song)->slot[3]) == -1)
            return -1;
        size = ((struct CmpHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks;
        size <<= 4;
        HAMA->cmp_ld_mae();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SONGREC(dir, song)->slot[3]);
        HAMA->cmp_ld_ato(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SONGREC(dir, song)->slot[5] != -1L) {
        HAMA->GetResouceInfo(7, &info);
        if (HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, 0x200L, &SONGREC(dir, song)->slot[5]) == -1)
            return -1;
        size = ((struct MspHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks;
        size <<= 4;
        HAMA->msp_ld_mae();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SONGREC(dir, song)->slot[5]);
        HAMA->msp_ld_ato(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SONGREC(dir, song)->slot[7] != -1L) {
        HAMA->GetResouceInfo(9, &info);
        HAMA->PreMidiLoad();
        ret = HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, info.size, &SONGREC(dir, song)->slot[7]);
        HAMA->FlashWrite(1, HDAE5000_RAM_HdStreamBuffer, (unsigned int)info.size, 0x3d3000L);
        HAMA->PostMidiLoad(ret);
    }
    return ret;
}

int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(6, &info);
    info.size = 0x72aaL;
    HAMA->PreTmSave();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[4]);
    if (ret != -1)
        SONGREC(dir, song)->has[4] = 1;
    HAMA->PostTmSave(ret);
    return ret;
}

int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(5, &info);
    info.size = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[3]);
    if (ret != -1)
        SONGREC(dir, song)->has[3] = 1;
    HAMA->cmp_sv_ato(ret);
    return ret;
}

int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(7, &info);
    info.size = CALLR(unsigned long, HAMA->msp_sv_mae)();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[5]);
    if (ret != -1)
        SONGREC(dir, song)->has[5] = 1;
    HAMA->msp_sv_ato(ret);
    return ret;
}

int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(9, &info);
    HAMA->PreMidiSave();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[7]);
    if (ret != -1)
        SONGREC(dir, song)->has[7] = 1;
    HAMA->PostMidiSave(ret);
    return ret;
}

long HDAE5000_AttenCpToHDSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        ROOT->InheritedProc(obj, ev, arg);
        ROOT->SendEvent(obj, EVT_PARA_DRAW, HDAE5000_Str_Cphd);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 6:
        case 7:
            ROOT->PostEvent(OBJ_HDDMENU, EVT_SHOW, 0L);
        }
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}

long HDAE5000_AttenCpToMarkSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        ROOT->InheritedProc(obj, ev, arg);
        ROOT->SendEvent(obj, EVT_PARA_DRAW, HDAE5000_Str_Cphd_AttenCpToMarkSwCatch);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 6:
        case 7:
            ROOT->PostEvent(OBJ_CP_FD, EVT_SHOW, 0L);
        }
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}

void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer,
                                  (unsigned long)HDAE5000_RAM_HdStreamFill
                                  - (unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer,
                                   (unsigned long)HDAE5000_RAM_HdStreamFill
                                   - (unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
