/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r2_mb.c (2026-11-16-48-hd-r2b)
   sha256 d06153cc0723f789446f61a2356ea7a77f429736b1e25b3b9c9d805e52a4bd37 (tar-sha256); compiled at -Xr */
/* lane_hd round 2, form b (lane_hd's own functions): other spellings of hd_r2_ma.c's functions. */
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
    ROOT->SetVisible(OBJ_SELECT_DIR_SW_EDIT, v);
    ROOT->SetVisible(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    ROOT->SetVisible(OBJ_HD_FILE_LOAD_SW_DEL, v);
    ROOT->SetVisible(OBJ_FLS_SELECT_SW_EDIT, v);
    ROOT->SetVisible(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    ROOT->SetVisible(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    ROOT->SetVisible(OBJ_CP_FD_HDSWTO, v);
    ROOT->SetVisible(OBJ_CP_FD_HDSWSEL, v);
    ROOT->SetVisible(OBJ_SW_HD_FORMAT, v);
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
    ROOT->ApPostEvent(obj, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_DirListText);
    ROOT->ApPostEvent(obj, EVT_PARA_DRAW, -1L);
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
    ROOT->ApPostEvent(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FlsListText);
    ROOT->ApPostEvent(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
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
