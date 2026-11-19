/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v2_01i/hdae5000_ui_display.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 589c2134c284ee68c45a073c4796561c62085da9b3796a282f8097eb84523b0a (tar-sha256); compiled at -Xr */
/* Functions of hdae5000_ui_display.s.  (hdae5000_ui_display.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_ui_display.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
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
#define EVT_INTERRUPT_TITLE 0x1c00016L
#define TITLE_PS 0x1a00000L
#define EVT_CHANGE_MODE 0x1c00014L
#define EVT_CHANGE_TITLE 0x1c00015L
#define NAKA_MODE_MD_PS 0x1800000L
#define OBJ_CP_FD_HDSWSEL 0x7f00deL
#define OBJ_CP_FD_HDSWTO 0x7f00dcL
#define OBJ_FLS_FILE_LOAD_SW_EDIT 0x7f0140L
#define OBJ_FLS_SELECT_SW_EDIT 0x7f00fbL
#define OBJ_HD_FILE_LOAD_SW_DEL 0x7f010cL
#define OBJ_HD_FILE_LOAD_SW_DELFILE 0x7f010fL
#define OBJ_HD_FILE_LOAD_SW_SAVE 0x7f0102L
#define OBJ_SELECT_DIR_SW_EDIT 0x7f002dL
#define OBJ_SW_HD_FORMAT 0x7f0082L
/* ---- end of hdae_ids.h ---- */

struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_SongRecords[1920][76];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_FlsSeqStopPending;
extern unsigned int HDAE5000_RAM_RcmStreamResult;

unsigned char HDAE5000_Fls_GetAutoLoadPending(void)
{
    return HDAE5000_RAM_FlsAutoLoadPending;
}

void HDAE5000_Fls_SetSeqStopPending(unsigned char v)
{
    HDAE5000_RAM_FlsSeqStopPending = v;
}

void HDAE5000_UiObj_SetCaption(long obj, long caption)
{
    unsigned char *v = CALLR(unsigned char *, ROOT->GetViewInstance)(obj);
    *(long *)(v + 0x16) = caption;
}

void HDAE5000_Delay_Loop(unsigned long n)
{
    while (n--)
        ;
}

unsigned int HDAE5000_RcmStream_LastResult(void)
{
    return HDAE5000_RAM_RcmStreamResult;
}

void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi)
{
    switch (block) {
    case 0:
        bi->base = HDAE5000_RAM_DirNames; bi->size = 16; bi->count = 120;
        break;
    case 1:
        bi->base = HDAE5000_RAM_SongRecords; bi->size = 76; bi->count = 1920;
        break;
    case 2:
        bi->base = HDAE5000_RAM_FlsRecords; bi->size = 144; bi->count = 120; bi->extra = 32;
        break;
    }
}

unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x & 0xff;
    return r;
}

unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    unsigned long t, r;
    t = x;
    r = t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    return r;
}

void HDAE5000_RequestMode(unsigned char mode)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_CHANGE_MODE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_MODE, (long)mode + NAKA_MODE_MD_PS);
}

void HDAE5000_RequestTitle15(unsigned char title)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_CHANGE_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_TITLE, (long)title + TITLE_PS);
}

void HDAE5000_RequestTitle16(unsigned char title)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_INTERRUPT_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, (long)title + TITLE_PS);
}

void HDAE5000_YieldUntilSem1Zero(void)
{
    while (CALLR(int, HAMA->ref_sem_X)(1) != 0)
        CALLV(HAMA->rot_rdq_X)(3);
}

void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    if (hide == 0)
        v = 1;
    else
        v = 0;
    CALLV(ROOT->SetVisible)(OBJ_SELECT_DIR_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DEL, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_SELECT_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWTO, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWSEL, v);
    CALLV(ROOT->SetVisible)(OBJ_SW_HD_FORMAT, v);
}

/* Song-record fields: part byte k at +26+k, first-cluster slot k at +36+4k; k = 0 LSW, 1 PMT, 2 SQT, 3 CMP,
   4 TM, 5 MSP, 6 RCM, 7 MD, 8 TLX.  The address is written as an integer, (unsigned long)&sym[field] + offset:
   that is what gives the ROM's lda xR,(sym+field) after the offset (run 2026-11-16-52-hd-r4v). */
extern void HDAE5000_HD_FreeChain(unsigned long first);

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define PART(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
#define DELETE_PART(k)                                   \
    if (SLOT(k, dir, song) != 0xffffffffUL) {            \
        HDAE5000_HD_FreeChain(SLOT(k, dir, song));       \
        SLOT(k, dir, song) = 0xffffffffUL;               \
        PART(k, dir, song) = 0;                          \
    }

void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song) { DELETE_PART(0) }
void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song) { DELETE_PART(1) }
void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song) { DELETE_PART(2) }
void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song) { DELETE_PART(3) }
void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song) { DELETE_PART(4) }
void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song) { DELETE_PART(5) }
void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song) { DELETE_PART(6) }
void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song) { DELETE_PART(7) }
void HDAE5000_DeleteSongPart_Tlx(unsigned int dir, unsigned int song) { DELETE_PART(8) }

#define FLS(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item)
{
    FLS(16, fls, item) = 0;
    FLS(48, fls, item) = 0;
    FLS(80, fls, item) = 0;
    FLS(112, fls, item) = 0;
    return 0;
}
