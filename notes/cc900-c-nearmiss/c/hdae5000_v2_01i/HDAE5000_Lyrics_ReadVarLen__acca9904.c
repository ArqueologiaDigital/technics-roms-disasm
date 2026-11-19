/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v2_01i/hdae5000_lyrics.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 acca99045a4d1deb7d0e03581ec212b45e4243c4aa4890d5c430472c6044969c (tar-sha256); compiled at -Xr */
/* Functions of hdae5000_ui_display.s.  (hdae5000_lyrics.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_lyrics.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32 HDAE5000_Lyrics_FindEvent HDAE5000_Lyrics_ParseEvent
   cc900-module: HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_CheckHeaderChunk HDAE5000_Lyrics_CheckHdrChunk
   cc900-module: HDAE5000_Lyrics_CheckTrackChunk HDAE5000_Lyrics_ClearBuffer HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_ResetState
*/
/* lane_hd round 9, helper h_near, form a: hd_r4_lyra.c's lyric module (the whole calr group), with only these
   functions changed after run 2026-11-16-57:
   - the string library prototypes (module-wide, so LyricBoxProc / PlayToPosition / ResetState change too; none of
     them matched): StrCpy / StrNCpy / StrCat / SPrintf take plain char * sources and StrNCpy an int count.  Run 57's
     listing shows V4.23 pushes an array address as a constant (`pushw hi / pushw lo`) when the argument needs no
     conversion, and loads it (`lda xwa,(sym); push xwa`) when it does (the const qualifier, (char *) of the
     unsigned ram_230636, unsigned char * to const void *).  The ROM has the opposite of what the const prototypes
     gave: the ROM strings as pushw pairs (no conversion: char * sources), the RAM text buffers loaded (a
     conversion), and the unsigned event length loaded before its push (`ld wa,(len); pushw wa`, an unsigned to
     int conversion; V4.23 wrote `pushw (len)` for an unsigned parameter);
   - Lyrics_ReadSongInfo: the RAM text buffers it passes (ram_230736 / _768 / _790) cast, (char *)buf, to give them
     the ROM's `lda xwa,(buf); push xwa` (whether V4.23 keeps a cast to the same type is the open question: form b
     casts to void *);
   - Lyrics_FillLines: the copy source as a row of the 2-D array, (&LyricLines[1])[slot] (the ROM's `muls wa,40;
     lda xbc,(LyricLines+40); exts xwa; add xwa,xbc`, the shape V4.23 gives the destination LyricLines[slot]); the
     line-length stores through a byte pointer, ((unsigned char *)&ram_2304d8)[slot + 16]: the ROM adds the member
     offset to the index (`ld wa,(slot); add wa,16; lda xbc,(ram_2304d8)`), V4.23 folded it into the symbol for
     the member spelling;
   - Lyrics_FindEvent: pos += (n = ParseEvent(..)): the ROM adds through WA (`ld wa,hl; add (pos),wa`) and tests HL,
     the reload V4.23 writes for an assignment used as an operand;
   - Read_Table_Word: the high byte widened before the shift, (unsigned int)b << 8 (ROM `extz wa; sll wa,8`;
     V4.23 shifted the byte, `sll a,8; extz wa`);
   - Lyrics_CheckTrackChunk: 22 + SwapBytes32(..), the constant first (ROM `ld xwa,xhl; add xwa,22`; V4.23 added in
     XHL for the call on the left).
   hd_r4_lyra.c's notes follow:
   lane_hd round 4, helper h_lyr, form a: the lyric-display module of hdae5000_ui_display.s (0x28cd08-0x28e61b), one
   calr group, in ROM order.  Options: -Xr.
   HDAE5000_LyricBoxProc_Ev01CA0004 / _Ev01CA0007 / _OnReset are not functions: they are case arms of
   HDAE5000_LyricBoxProc (0x28cd08, one frame `lda xsp,(xsp-16); pushw iz`, one epilogue at 0x28d5f9, two
   jump tables HDAE5000_LyricBoxProc_CaseTable1/2), so the whole procedure is written here.  Lyrics_ClearBuffer is
   in the group too (OnLoad calls it with calr).  Lyrics_LoadTestFile, Read_Table_Word and Read_Table_Multi sit
   between members and are added; Lyrics_WriteVarLen (djnz16) is left out.
   The lyric functions take char parameters in A / C but their callers load WA / BC (ints): they are old-style
   definitions, called through prototypes with the promoted types.
   The ROM lays several blocks out of source order (the fault message of PlayToPosition between the CR/LF case and
   the scroll; FillLines' LF / long-syllable / end blocks after its return; LyricBoxProc's cases 4, 5, SHOW and HIDE
   ending in a jump to the default): V4.23 lays out in source order, so those are written with goto.
   ram_<hex>: lyric RAM the tree has not named.  ram_2307ba / ram_23a19a are cells the ROM reaches as a folded
   symbol+offset (colx[i + 1], LyricLines_Init+240): declared at the folded address. */
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
#define EVT_HDAE_BEAT_MESSAGE 0x1ca0005L
/* ---- end of hdae_ids.h ---- */

extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, char *, int);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_MemCmp(const void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

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
/* the line state as bytes too: its line lengths are reached as b[index + 16] (ROM: ld wa,(index); add wa,16;
   lda xbc,(0x2304d8); (xbc+wa)), a member array at offset 0 with the offset in the index, as V4.23 keeps the
   index's constant out of a base that already has an offset (micro ptrar, pa_caer: *(&gcu[2] + (b + 1)) -> inc wa;
   lda xbc,(gcu+2)) */
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
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

long HDAE5000_Lyrics_CheckFile(void)
{
    if (HDAE5000_Lyrics_CheckHdrChunk() == 0) {
        if (HDAE5000_Lyrics_CheckTrackChunk() == 0) {
            HDAE5000_RAM_LyricLoaded = 1;
            return 0L;
        } else
            return -1L;
    } else
        return -2L;
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

long HDAE5000_Lyrics_ResetState(void)
{
    ram_23a19a = 1;
    ram_2304d8.s.w8 = 0;
    ram_2304d8.s.w10 = 0;
    ram_2304d8.s.col = 0;
    ram_2304d8.s.line = 0;
    ram_2304d8.s.w14 = 0;
    ram_2304d8.s.b23 = 0;
    ram_2304d8.s.l0 = 0;
    HDAE5000_MemFill(HDAE5000_RAM_LyricLines, ' ', 240);
    ram_230870 = 0;
    ram_23086c = 0;
    HDAE5000_RAM_LyricEvent.pos = 0;
    HDAE5000_RAM_LyricEvent.endpos = 0;
    HDAE5000_RAM_LyricEvent.prevpos = 0;
    HDAE5000_RAM_LyricEvent.tick = 0;
    HDAE5000_RAM_LyricEvent.nexttick = 0;
    HDAE5000_RAM_LyricEvent.l24 = 0;
    HDAE5000_RAM_LyricEvent.l28 = 0;
    HDAE5000_RAM_LyricEvent.l32 = 0;
    HDAE5000_RAM_LyricEvent.l36 = 0;
    ram_230864 = 0xffffffffL;
    ram_230872 = 0;
    ram_230874 = 0;
    ram_230876 = 0;
    HDAE5000_StrCpy((void *)ram_2306b6, HDAE5000_Str_Info);
    ram_2307aa = 1;
    ram_2307ac = 0;
    ram_230868 = (unsigned long)HDAE5000_SwapBytes16(TLX_DIV) / 12;
    switch (HDAE5000_RAM_LyricForeColor) {
    case 0:
        ram_23087e = 0xf9;
        break;
    case 1:
        ram_23087e = 0x02;
        break;
    case 2:
        ram_23087e = 0xfc;
        break;
    case 3:
        ram_23087e = 0x00;
        break;
    case 4:
        ram_23087e = 0xfb;
        break;
    default:
        ram_23087e = 0xfc;
    }
    switch (HDAE5000_RAM_LyricBackColor) {
    case 0:
        ram_230880 = 0xf9;
        break;
    case 1:
        ram_230880 = 0x02;
        break;
    case 2:
        ram_230880 = 0xfc;
        break;
    case 3:
        ram_230880 = 0x00;
        break;
    case 4:
        ram_230880 = 0xfb;
        break;
    default:
        ram_230880 = 0x00;
    }
    return 0L;
}

long HDAE5000_Lyrics_ReadSongInfo(unused)
long unused;
{
    if (HDAE5000_Lyrics_FindEvent(2, 2, -2, 0L) > 0) {
        if (HDAE5000_RAM_LyricEvent.len >= 50) {
            HDAE5000_StrNCpy((void *)ram_230736, (char *)ram_230636, 50);
            ram_230736[49] = 0;
        } else {
            HDAE5000_StrNCpy((void *)ram_230736, (char *)ram_230636, HDAE5000_RAM_LyricEvent.len);
            ram_230736[HDAE5000_RAM_LyricEvent.len] = 0;
        }
    } else
        HDAE5000_StrCpy((void *)ram_230736, HDAE5000_Str_NoCopyrightInfo);
    if (HDAE5000_Lyrics_FindEvent(3, 2, -2, 0L) > 0) {
        if (HDAE5000_RAM_LyricEvent.len >= 40) {
            HDAE5000_StrNCpy((void *)ram_230768, (char *)ram_230636, 40);
            ram_230768[39] = 0;
        } else {
            HDAE5000_StrNCpy((void *)ram_230768, (char *)ram_230636, HDAE5000_RAM_LyricEvent.len);
            ram_230768[HDAE5000_RAM_LyricEvent.len] = 0;
        }
    } else
        HDAE5000_StrCpy((void *)ram_230736, HDAE5000_Str_NoSongTitle);
    if (HDAE5000_Lyrics_FindEvent(88, 2, -2, 0L) > 0) {
        ram_2307a6 = ram_2307a4 = ram_230636[0];
        if (ram_230636[1] == 1) {
            ram_2307a8 = 2;
            ram_2307ae = 24;
            ram_2307b0 = 24;
        }
        if (ram_230636[1] == 2) {
            ram_2307a8 = 4;
            ram_2307ae = 12;
            ram_2307b0 = 12;
        }
        if (ram_230636[1] == 3) {
            ram_2307a8 = 8;
            ram_2307ae = 6;
            ram_2307b0 = 6;
        }
        if (ram_230636[1] == 4) {
            ram_2307a8 = 16;
            ram_2307ae = 3;
            ram_2307b0 = 3;
        }
    } else {
        ram_2307a6 = 4;
        ram_2307a4 = 4;
        ram_2307a8 = 4;
        ram_2307ae = 12;
        ram_2307b0 = 12;
    }
    HDAE5000_SPrintf((void *)ram_230790, HDAE5000_Fmt_i_i_File_Load, ram_2307a4, ram_2307a8);
    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_BEAT_MESSAGE, 0L);
    HDAE5000_RAM_LyricEvent.type = 0xff;
    HDAE5000_RAM_LyricEvent.w2 = 0;
    HDAE5000_RAM_LyricEvent.eot = 0;
    HDAE5000_RAM_LyricEvent.len = 0;
    ram_2304d8.s.hilite = 0;
    ram_23086e = 0;
    HDAE5000_RAM_LyricEvent.tick = 0;
    HDAE5000_Lyrics_FindEvent(0x7c, 2, -2, 0L);
    HDAE5000_RAM_LyricEvent.tick = 0;
    return 0L;
}

long HDAE5000_Lyrics_FindEvent(type, flags, start, at)
unsigned char type;
unsigned char flags;
int start;
long at;
{
    unsigned int pos;
    int i;
    unsigned int n;

    if (start >= 0) {
        pos = 0;
        HDAE5000_RAM_LyricEvent.tick = 0;
        for (i = 0; i < start; i++) {
            pos += (n = HDAE5000_Lyrics_ParseEvent(0, pos));
            if (n == 0)
                return -1L;
        }
        if (type == 0x7c) {
            if ((n = HDAE5000_Lyrics_ParseEvent(flags, pos)) != 0)
                return (unsigned long)n + pos;
            return -1L;
        }
        do {
            pos += (n = HDAE5000_Lyrics_ParseEvent(flags, pos));
        } while (n != 0 && type != HDAE5000_RAM_LyricEvent.type);
        if (n != 0)
            return pos;
        return -1L;
    }
    if (start == -1)
        return -1L;
    if (start == -2) {
        if (type == 0x7c)
            return HDAE5000_Lyrics_ParseEvent(flags, (unsigned int)at);
        pos = at;
        do {
            pos += (n = HDAE5000_Lyrics_ParseEvent(flags, pos));
        } while (n != 0 && type != HDAE5000_RAM_LyricEvent.type);
        if (n != 0)
            return pos;
        return -1L;
    }
    return 0L;
}

unsigned int HDAE5000_Read_Table_Word(pos)
unsigned int pos;
{
    unsigned int lo;
    lo = LYRIC_EV(pos + 1);
    return (unsigned int)LYRIC_EV(pos) << 8 | lo;
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

long HDAE5000_Lyrics_ReadVarLen(pos)
unsigned int pos;
{
    unsigned long v = 0;
    unsigned int i;
    for (i = 0; i < 4; i++) {
        v += LYRIC_EV(pos + i) & 0x7f;
        if (LYRIC_EV(pos + i) < 0x80) {
            ram_23085e = i + 1;
            return v;
        }
        v <<= 7;
    }
    return -1L;
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

long HDAE5000_Lyrics_CheckTrackChunk(void)
{
    unsigned long len;

    if (HDAE5000_MemCmp(&HDAE5000_RAM_LyricBuffer[14], HDAE5000_Str_Tltr, 4) != 0)
        return -10L;
    HDAE5000_RAM_LyricFileLength = (len = HDAE5000_SwapBytes32(TLX_TRLEN)) + 22;
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
