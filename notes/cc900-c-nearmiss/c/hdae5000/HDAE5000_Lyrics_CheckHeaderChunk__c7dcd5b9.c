/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v2_01i/hdae5000_lyrics.c (2026-11-16-63-hd-r9s-staged)
   sha256 c7dcd5b9c2f3d99417c7c240df0f47e4b096b85f5c2bc88ddc8d80e7df639b1e (tar-sha256); compiled at -Xr */
/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_lyrics.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_lyrics.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32
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

extern char *__cdecl HDAE5000_StrCpy(char *, const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern char *__cdecl HDAE5000_StrCat(char *, const char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_MemCmp(const void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);

struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
/* the lyric box's view instance (RootFn_GetViewInstance) */
struct LyrView { char p0[22]; int a22; char p1[4]; int *flag; long l32; char p2[4]; long l40; int a44; };
/* the event HDAE5000_Lyrics_ParseEvent parsed last */
struct LyricEvent {
    int type;                   /* +0  meta type, 0x2f = end of track */
    int w2;
    int eot;                    /* +4  end of track reached */
    unsigned int len;           /* +6  data length */
    unsigned int pos;           /* +8  position of the event */
    unsigned int endpos;        /* +10 position after it */
    unsigned int prevpos;       /* +12 */
    int w14;
    unsigned long tick;         /* +16 running tick */
    unsigned long nexttick;     /* +20 tick of the next event */
    unsigned long l24, l28, l32, l36;
    unsigned char data[128];    /* +40 */
};
/* line state at 0x2304d8 */
struct LyrLine {
    long l0;
    char p4[4];
    int w8, w10;
    unsigned int col;           /* +12 column of the next syllable */
    int w14;
    unsigned char len[6];       /* +16 length of each text line */
    unsigned char line;         /* +22 current line */
    unsigned char b23;
    unsigned char hilite;       /* +24 */
};
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };

extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern char HDAE5000_RAM_LyricLines[6][40];
extern unsigned char HDAE5000_RAM_LyricLoaded;
extern long HDAE5000_RAM_LyricBoxObj;
extern unsigned long HDAE5000_RAM_LyricFileLength;
extern unsigned char HDAE5000_RAM_LyricForeColor;
extern unsigned char HDAE5000_RAM_LyricBackColor;
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
extern struct LyrLine ram_2304d8;
extern struct LyrView *ram_22a088;
extern struct Box ram_22a08c, ram_22a094, ram_22a0a0, ram_22a0ac;
extern struct Point ram_22a09c, ram_22a0a8, ram_22a0b4, ram_23087a;
extern int ram_22a0b8;
extern char ram_23051e[];
extern unsigned char ram_230636[128];
extern char ram_2306b6[128];
extern char ram_230736[50];
extern char ram_230768[40];
extern char ram_230790[10];
extern char ram_23079a[10];
extern unsigned char ram_2307a4, ram_2307a6, ram_2307a8;
extern unsigned int ram_2307aa, ram_2307ac, ram_2307ae, ram_2307b0, ram_2307b2, ram_2307b4, ram_2307b6;
extern int ram_2307b8[40];
extern int ram_2307ba[39];
extern int ram_230806;
extern unsigned char ram_230808[6];
extern int ram_23080e[39];
extern unsigned int ram_23085e;
extern long ram_230860;
extern unsigned long ram_230864;
extern unsigned long ram_230868;
extern unsigned int ram_23086c, ram_23086e, ram_230870, ram_230872, ram_230874;
extern unsigned long ram_230876;
extern unsigned char ram_23087e, ram_230880, ram_230882;
extern unsigned char ram_23a19a;

extern char HDAE5000_Str_Blank40[], HDAE5000_Str_Reset[], HDAE5000_Str_Load[], HDAE5000_Fmt_03i_i[];
extern char HDAE5000_Str_Rb[], HDAE5000_Str_TESTTESTTLX[], HDAE5000_Fmt_Fault_No_Lyrics_loaded_o[];
extern char HDAE5000_Fmt_i_i[], HDAE5000_Fmt_Chord_s[], HDAE5000_Str_Info[], HDAE5000_Str_NoCopyrightInfo[];
extern char HDAE5000_Str_NoSongTitle[], HDAE5000_Fmt_i_i_File_Load[], HDAE5000_Str_Empty_File_Delete[];
extern char HDAE5000_Str_Empty_File_Delete_2[], HDAE5000_Str_Tlhd[], HDAE5000_Str_Tltr[];

/* events of the lyric track start at +22, after the TLhd (14) and TLtr (8) headers */
#define LYRIC_EV(i) (&HDAE5000_RAM_LyricBuffer[22])[i]
#define TLX_HDLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer[4])
#define TLX_FORMAT (*(unsigned int *)&HDAE5000_RAM_LyricBuffer[8])
#define TLX_NTRK (*(unsigned int *)&HDAE5000_RAM_LyricBuffer[10])
#define TLX_DIV (*(unsigned int *)&HDAE5000_RAM_LyricBuffer[12])
#define TLX_TRLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer[18])

void HDAE5000_Lyrics_ClearBuffer(void);
long HDAE5000_Lyrics_CheckHdrChunk(void);
long HDAE5000_Lyrics_CheckTrackChunk(void);
void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *, int);
long HDAE5000_Lyrics_ResetState(void);
long HDAE5000_Lyrics_ReadSongInfo(long);
long HDAE5000_Lyrics_FillLines(int, unsigned int);
long HDAE5000_Lyrics_FindEvent(int, int, int, long);
unsigned int HDAE5000_Lyrics_ParseEvent(int, unsigned int);
long HDAE5000_Lyrics_ReadVarLen(unsigned int);
unsigned long HDAE5000_SwapBytes32(unsigned long);
unsigned int HDAE5000_SwapBytes16(unsigned int);

/* source order DRAW, PAINT, 3, 7, 8, 9, default, 4, 5, SHOW, HIDE, SW_IN: V4.23 compares the cases in reverse
   source order (SW_IN, HIDE, SHOW, PAINT, DRAW, then the 3..9 table) and lays the bodies out in source order */

void HDAE5000_Lyrics_ClearBuffer(void)
{
    HDAE5000_MemFill(HDAE5000_RAM_LyricBuffer, 0, 0x5000);
    HDAE5000_RAM_LyricFileLength = 0;
    HDAE5000_RAM_LyricLoaded = 0;
}

long HDAE5000_Lyrics_LoadTestFile(void)
{
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    default:
        return -1L;
    case 2:
    case 3:
        CALLV(ROOT->SleepMainTask)();
        CALLV(HAMA->fopen_ext)(HDAE5000_Str_TESTTESTTLX, HDAE5000_Str_Rb);
        CALLV(HAMA->fread_ext)(HDAE5000_RAM_LyricBuffer, 0x5000L);
        CALLV(HAMA->fclose_ext)();
        CALLV(ROOT->WakeUpMainTask)();
        return 0L;
    }
}

long HDAE5000_Read_Table_Multi(pos)
unsigned int pos;
{
    long v;
    unsigned int i;
    v = LYRIC_EV(pos);
    for (i = 0; i < 3; i++)
        v = (v << 8) + LYRIC_EV(pos + i);
    return v;
}

/* cc900-name: HDAE5000_Lyrics_CheckHdrChunk=HDAE5000_Lyrics_CheckHeaderChunk */
long HDAE5000_Lyrics_CheckHdrChunk(void)
{
    if (HDAE5000_MemCmp(HDAE5000_RAM_LyricBuffer, HDAE5000_Str_Tlhd, 4) != 0)
        return -1L;
    if (TLX_HDLEN != HDAE5000_SwapBytes32(6L))
        return -2L;
    if (TLX_FORMAT > HDAE5000_SwapBytes16(0))
        return -3L;
    if (TLX_NTRK > HDAE5000_SwapBytes16(1))
        return -4L;
    if ((TLX_DIV & HDAE5000_SwapBytes16(0x8000)) != 0)
        return -5L;
    return 0L;
}

/* SwapBytes32 / SwapBytes16: hdae5000/cc900-staged/hdae5000_ui_display.c, unchanged (they match) */
unsigned long HDAE5000_SwapBytes32(unsigned long x)
{
    unsigned long r = x & 0xff;
    int i;
    for (i = 0; i < 3; i++) {
        x >>= 8;
        r <<= 8;
        r += x & 0xff;
    }
    return r;
}

unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x;
    return r;
}
