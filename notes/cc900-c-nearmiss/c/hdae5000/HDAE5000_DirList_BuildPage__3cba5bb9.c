/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r3_mb.c (2026-11-16-49-hd-r3)
   sha256 3cba5bb9dddf77555e8c2a1b9fdb2db22b5056824341b66343c4390405617eb7 (tar-sha256); compiled at -Xr */
/* lane_hd round 3 (round 2 with every function-table call cast, CALLV), form b (lane_hd's own functions): other spellings of hd_r2_ma.c's functions. */
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
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
#define OBJ_CP_FD_HDSWSEL 0x7f00dcL
#define OBJ_CP_FD_HDSWTO 0x7f00daL
#define OBJ_FLS_FILE_LOAD_SW_EDIT 0x7f013eL
#define OBJ_FLS_SELECT_SW_EDIT 0x7f00f9L
#define OBJ_HD_FILE_LOAD_SW_DEL 0x7f010aL
#define OBJ_HD_FILE_LOAD_SW_DELFILE 0x7f010dL
#define OBJ_HD_FILE_LOAD_SW_SAVE 0x7f0100L
#define OBJ_SELECT_DIR_SW_EDIT 0x7f002cL
#define OBJ_SEL_FLS 0x7f00fbL
#define OBJ_SW_HD_FORMAT 0x7f0080L
/* ---- end of hdae_ids.h ---- */

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);

extern unsigned char HDAE5000_RAM_DirNames[120][16];
extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_FlsListText[24][21];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage[];
extern char HDAE5000_Fmt_3_3d[];
extern char HDAE5000_Fmt_3_3d_FlsList_BuildPage[];

unsigned char *HDAE5000_DirName_Address(unsigned int dir)
{
    return HDAE5000_RAM_DirNames[dir];
}

unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    return (x >> 8) + ((x & 0xff) << 8);
}

unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    unsigned int r = x & 0xff;
    x >>= 8;
    r <<= 8;
    x &= 0xff;
    r += x;
    return r;
}

unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    register unsigned long t = x;
    register unsigned long r;
    r = t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    return r;
}

void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    v = hide == 0 ? 1 : 0;
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

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * i, num, 3);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 4 + 21 * i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_DirListText);
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void HDAE5000_FlsList_BuildPage(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_FlsListText[i], HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d_FlsList_BuildPage, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_FlsListText[i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[i][4], HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FlsListText);
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

extern unsigned char HDAE5000_RAM_HdStreamState;
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern unsigned long HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern int HDAE5000_HD_WriteFile(unsigned char *buf, unsigned long size, unsigned long slot);
extern int HDAE5000_HD_AppendFile(unsigned char *buf, unsigned long size, unsigned long slot);

int HDAE5000_HD_WriteStream(unsigned char *src, unsigned long n)
{
    unsigned long room;
    int r;
    register unsigned long chunk;
    r = 0;
    switch (HDAE5000_RAM_HdStreamState) {
    case 2:
    case 1:
        if (n == 0)
            return -1;
        break;
    default:
        return -1;
    }
    do {
        room = HDAE5000_RAM_RcmStreamState - HDAE5000_RAM_HdStreamFill;
        if (n > room)
            chunk = room;
        else
            chunk = n;
        if (chunk > 0xffff) {
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, 0xffff);
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill + 0xffff, src + 0xffff, chunk - 0xffff);
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, chunk);
        }
        src += chunk;
        HDAE5000_RAM_HdStreamFill += chunk;
        room -= chunk;
        if (room == 0) {
            if (HDAE5000_RAM_HdStreamState == 1) {
                r = HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer, 0x8000L, HDAE5000_RAM_HdStreamSlot);
                HDAE5000_RAM_HdStreamState = 2;
            } else
                r = HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer, 0x8000L, HDAE5000_RAM_HdStreamSlot);
            if (r != 0)
                return r;
            HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        }
        n -= chunk;
    } while (n != 0);
    return r;
}
