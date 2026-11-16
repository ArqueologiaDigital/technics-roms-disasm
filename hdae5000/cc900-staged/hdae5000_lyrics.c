/* The lyric-display module of hdae5000_ui_display.s (0x28cd08-0x28e623 in v2.06i): the functions that match; Lyrics_CheckHdrChunk calls SwapBytes32 / SwapBytes16 relatively (cc900-module).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r9_nl.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

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
