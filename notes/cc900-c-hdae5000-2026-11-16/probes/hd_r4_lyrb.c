/* lane_hd round 4, helper h_lyr, form b: second forms of the lyric module (see hd_r4_lyra.c for the notes).
   Differences from form a:
   - the lyric buffer is a struct {hdr[22]; ev[]} and the events are .ev[i] (form a: (&buf[22])[i]);
   - LyricBoxProc: EVT_SW_IN lists the empty cases 1..6 (to force the 0..7 jump table);
   - PlayToPosition: highlight sum in the other order; the chord test as a one-case switch;
   - FillLines: both row addresses spelled as integers, (unsigned long)&rows[N] + slot * 40;
   - CheckFile: two flat ifs; LoadTestFile: an if instead of the switch.
   Options: -Xr. */
#include "hdae_ws.h"
#include "hdae_ids.h"

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

struct TlxFile { unsigned char hdr[22]; unsigned char ev[0x5000 - 22]; };
extern struct TlxFile HDAE5000_RAM_LyricBuffer;
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
#define LYRIC_EV(i) HDAE5000_RAM_LyricBuffer.ev[i]
#define TLX_HDLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer.hdr[4])
#define TLX_FORMAT (*(unsigned int *)&HDAE5000_RAM_LyricBuffer.hdr[8])
#define TLX_NTRK (*(unsigned int *)&HDAE5000_RAM_LyricBuffer.hdr[10])
#define TLX_DIV (*(unsigned int *)&HDAE5000_RAM_LyricBuffer.hdr[12])
#define TLX_TRLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer.hdr[18])

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
long HDAE5000_LyricBoxProc(long obj, long ev, long p)
{
    struct Point pt;
    unsigned int i;
    int k;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, p);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
        return 0;
    case EVT_PAINT:
        CALLV(ROOT->InheritedProc)(obj, ev, p);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRIC_PARAM, 0L);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRICS, 0L);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_LYRIC_ALL_DRAW, 1L);
        return 0;
    case EVT_HDAE_INIT_LYRIC_PARAM:
        if (ram_23a19a == 0) {
            ram_23a19a = 1;
            CALLV(ROOT->GetClientBox)(obj, &ram_22a08c);
            ram_22a08c.x1 += 2;
            ram_22a08c.y1 += 4;
            ram_22a08c.x2 -= 1;
            ram_22a08c.y2 -= 2;
            ram_22a094.x1 = ram_22a08c.x1 + 2;
            ram_22a094.y1 = ram_22a08c.y1 - 2;
            ram_22a094.x2 = ram_22a08c.x2 - 2;
            ram_22a094.y2 = ram_22a094.y1 + 13;
            ram_22a09c.x = ram_22a08c.x1 + 6;
            ram_22a09c.y = ram_22a08c.y1 + 2;
            CALLV(ROOT->GetClientBox)(OBJ_MeasureinLyric, &ram_22a0a0);
            ram_22a0a8.x = ram_22a0a0.x1 + 20;
            ram_22a0a8.y = ram_22a0a0.y1 + 5;
            CALLV(ROOT->GetClientBox)(OBJ_TimeSigInLyric, &ram_22a0ac);
            ram_22a0b4.x = ram_22a0ac.x1 + 20;
            ram_22a0b4.y = ram_22a0ac.y1 + 5;
            ram_2307b8[0] = 0;
            for (k = 0; k < 39; k++)
                ram_2307ba[k] = ram_22a08c.x1 + 156 - (k * 4 + 4);
            for (k = 0; k < 39; k++)
                ram_23080e[k] = k << 3;
            for (k = 0; k < 6; k++)
                ram_230808[k] = k * 18 + ram_22a08c.y1 + 15;
        }
        return 0;
    case EVT_HDAE_INIT_LYRICS:
        switch (p) {
        default:
            return 0;
        case 0:
            if (ram_2307b2 != 0) {
                ram_2307b2 = 0;
                ram_2307b4 = 1;
                HDAE5000_Lyrics_ResetState();
                HDAE5000_Lyrics_ReadSongInfo(0L);
                ram_22a0b8 = 0;
                ram_230870 = HDAE5000_Lyrics_FillLines(0, 0);
                CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
                ram_2307b4 = 0;
            }
            return 0;
        case 1:
            HDAE5000_Lyrics_ResetState();
            HDAE5000_Lyrics_ReadSongInfo(0L);
            ram_22a0b8 = 0;
            CALLV(ROOT->SendEvent)(obj, EVT_PAINT, 0L);
            return 0;
        }
    case EVT_HDAE_LYRIC_ALL_DRAW:
        ram_22a088 = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj);
        for (i = 0; i < 6; i++) {
            ram_2304d8.len[i] = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[i]);
            pt.x = ram_230806;
            pt.y = ram_230808[i];
            CALLV(ROOT->DrawString)(&ram_22a08c, &pt, HDAE5000_Str_Blank40, ram_22a088->a22, ram_230880, ram_22a088->l32);
            pt.x = ram_2307b8[ram_2304d8.len[i]];
            if (ram_2304d8.line > i)
                CALLV(ROOT->DrawString)(&ram_22a08c, &pt, HDAE5000_RAM_LyricLines[i], ram_22a088->a22, ram_23087e,
                                        ram_22a088->l32);
            else
                CALLV(ROOT->DrawString)(&ram_22a08c, &pt, HDAE5000_RAM_LyricLines[i], ram_22a088->a22, ram_230880,
                                        ram_22a088->l32);
        }
        CALLV(ROOT->DrawFrame)(&ram_22a094, 0xf9);
        CALLV(ROOT->DrawString)(&ram_22a08c, &ram_22a09c, ram_2306b6, ram_22a088->a22, ram_22a088->a44, ram_22a088->l40);
        if (p == 1) {
            CALLV(ROOT->SendEvent)(OBJ_Conductor, EVT_PARA_DRAW, ram_230736);
            CALLV(ROOT->SendEvent)(OBJ_SongTitle, EVT_PARA_DRAW, ram_230768);
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_SYLLABLE, 4L);
            CALLV(ROOT->SendEvent)(OBJ_bottom01, EVT_PARA_DRAW, HDAE5000_Str_Reset);
            CALLV(ROOT->SendEvent)(OBJ_bottom08, EVT_PARA_DRAW, HDAE5000_Str_Load);
        }
        return 0;
    case EVT_HDAE_DRAW_SYLLABLE:
        switch (p) {
        case 0:
            CALLV(ROOT->DrawString)(&ram_22a08c, &ram_23087a, ram_23051e, ram_22a088->a22, ram_23087e, ram_22a088->l32);
            break;
        case 1:
            CALLV(ROOT->DrawString)(&ram_22a08c, &ram_23087a, ram_23051e, ram_22a088->a22, ram_230880, ram_22a088->l32);
            break;
        case 2:
            CALLV(ROOT->DrawString)(&ram_22a08c, &ram_22a09c, ram_2306b6, ram_22a088->a22, ram_22a088->a44,
                                    ram_22a088->l40);
            break;
        case 3:
            CALLV(ROOT->DrawString)(&ram_22a0a0, &ram_22a0a8, ram_23079a, 8, 0xff, ram_22a088->l40);
            break;
        case 4:
            CALLV(ROOT->DrawString)(&ram_22a0ac, &ram_22a0b4, ram_230790, 8, 0xff, ram_22a088->l40);
            break;
        }
    default:
    inherited:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, p);
    case EVT_HDAE_TICKS:
        if (ram_2307b4 != 0)
            goto inherited;
        HDAE5000_Lyrics_PlayToPosition((struct LyricPosEvt *)p, 1);
        if (ram_230874 >= ram_2307b0) {
            ram_2307b0 = ram_2307ae;
            ram_230872++;
            ram_230874 = 0;
            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_BEAT_MESSAGE, 0L);
        }
        ram_230874++;
        ram_230876 += 1;
        goto inherited;
    case EVT_HDAE_BEAT_MESSAGE:
        ram_2307ac++;
        if (ram_2307ac > ram_2307a6) {
            ram_2307a6 = ram_2307a4;
            ram_2307aa++;
            ram_2307ac = 1;
        }
        HDAE5000_SPrintf(ram_23079a, HDAE5000_Fmt_03i_i, ram_2307aa, ram_2307ac);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_SYLLABLE, 3L);
        goto inherited;
    case EVT_SHOW:
        *(ram_22a088 = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj))->flag = 1;
        HDAE5000_RAM_LyricBoxObj = obj;
        ram_2307b2 = 1;
        goto inherited;
    case EVT_HIDE:
        *(ram_22a088 = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj))->flag = 0;
        HDAE5000_RAM_LyricBoxObj = -1L;
        goto inherited;
    case EVT_SW_IN:
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, p)) {
        case 0:
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRICS, 1L);
            ram_230870 = HDAE5000_Lyrics_FillLines(0, 0);
            CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
            break;
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            break;
        case 7:
            ram_22a088 = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj);
            HDAE5000_Lyrics_ClearBuffer();
            CALLV(ROOT->ApPostEvent)(OBJ_LoadLyricFD, EVT_SHOW, 0L);
        }
        return 0;
    }
}

void HDAE5000_Lyrics_ClearBuffer(void)
{
    HDAE5000_MemFill(&HDAE5000_RAM_LyricBuffer, 0, 0x5000);
    HDAE5000_RAM_LyricFileLength = 0;
    HDAE5000_RAM_LyricLoaded = 0;
}

long HDAE5000_Lyrics_CheckFile(void)
{
    if (HDAE5000_Lyrics_CheckHdrChunk() != 0)
        return -2L;
    if (HDAE5000_Lyrics_CheckTrackChunk() != 0)
        return -1L;
    HDAE5000_RAM_LyricLoaded = 1;
    return 0L;
}

long HDAE5000_Lyrics_LoadTestFile(void)
{
    unsigned char m;
    if ((m = CALLR(unsigned char, HAMA->GetMediaType)()) != 3 && m != 2)
        return -1L;
    {
        CALLV(ROOT->SleepMainTask)();
        CALLV(HAMA->fopen_ext)(HDAE5000_Str_TESTTESTTLX, HDAE5000_Str_Rb);
        CALLV(HAMA->fread_ext)(&HDAE5000_RAM_LyricBuffer, 0x5000L);
        CALLV(HAMA->fclose_ext)();
        CALLV(ROOT->WakeUpMainTask)();
        return 0L;
    }
}

void HDAE5000_Lyrics_PlayToPosition(pe, redraw)
struct LyricPosEvt *pe;
unsigned char redraw;
{
    long r;
    unsigned long t;
    int len;
    unsigned int n;

    t = pe->pos * ram_230868;
    if (ram_230864 == t)
        return;
    ram_230864 = t;
    if (HDAE5000_RAM_LyricEvent.nexttick > ram_230864)
        return;
    if (HDAE5000_RAM_LyricEvent.eot != 0)
        return;
    n = 0;
    do {
        r = HDAE5000_Lyrics_FindEvent(0x7c, 2, -2, ram_23086c);
        if (HDAE5000_RAM_LyricEvent.eot == 1)
            return;
        if (r <= 0)
            goto fault;
        ram_23086c += r;
        n++;
        switch (HDAE5000_RAM_LyricEvent.type) {
        case 5:
            if (ram_230636[0] == 0x0d || ram_230636[0] == 0x0a) {
                ram_2304d8.col = 0;
                if (ram_2304d8.line >= 2)
                    goto scroll;
                ram_2304d8.line++;
                return;
            fault:
                HDAE5000_SPrintf(ram_2306b6, HDAE5000_Fmt_Fault_No_Lyrics_loaded_o, r, ram_2307b6, n);
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 2L);
                return;
            scroll:
                r = HDAE5000_Lyrics_FillLines(1, ram_230870);
                ram_2304d8.hilite = 0;
                if (r > 0)
                    ram_230870 = r;
                if (redraw == 1)
                    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                return;
            }
            if ((len = HDAE5000_StrLen((char *)ram_230636)) > 39)
                return;
            HDAE5000_StrCpy(ram_23051e, (char *)ram_230636);
            if (len + ram_2304d8.col > 39) {
                ram_2304d8.col = 0;
                if (ram_2304d8.line < 2)
                    ram_2304d8.line++;
                else {
                    r = HDAE5000_Lyrics_FillLines(1, ram_230870);
                    if (r > 0)
                        ram_230870 = r;
                    if (redraw == 1)
                        CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                }
            }
            ram_23087a.x = ram_2307b8[ram_2304d8.len[ram_2304d8.line]] + ram_23080e[ram_2304d8.col];
            ram_23087a.y = ram_230808[ram_2304d8.line];
            ram_2304d8.col += len;
            ram_2304d8.hilite = 1;
            if (redraw == 1)
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 0L);
            if (ram_2304d8.col == ram_230870) {
                if (ram_230882 != 0x0d || ram_230882 != 0x0a) {
                    ram_2304d8.col = 0;
                    if (ram_2304d8.line < 2)
                        ram_2304d8.line++;
                    else {
                        r = HDAE5000_Lyrics_FillLines(1, ram_230870);
                        if (r > 0)
                            ram_230870 = r;
                        if (redraw == 1)
                            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                    }
                }
            }
            break;
        case 88:
            ram_2307a4 = ram_230636[0];
            if (ram_230636[1] == 1) {
                ram_2307a8 = 2;
                ram_2307ae = 24;
            }
            if (ram_230636[1] == 2) {
                ram_2307a8 = 4;
                ram_2307ae = 12;
            }
            if (ram_230636[1] == 3) {
                ram_2307a8 = 8;
                ram_2307ae = 6;
            }
            if (ram_230636[1] == 4) {
                ram_2307a8 = 16;
                ram_2307ae = 3;
            }
            HDAE5000_SPrintf(ram_230790, HDAE5000_Fmt_i_i, ram_2307a4, ram_2307a8);
            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 4L);
            break;
        case 126:
            switch (ram_230636[0]) {
            case '0':
                HDAE5000_SPrintf(ram_2306b6, HDAE5000_Fmt_Chord_s, &ram_230636[1]);
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 2L);
            }
            break;
        }
    } while (HDAE5000_RAM_LyricEvent.nexttick <= ram_230864 && r > 0);
}

long HDAE5000_Lyrics_ResetState(void)
{
    ram_23a19a = 1;
    ram_2304d8.w8 = 0;
    ram_2304d8.w10 = 0;
    ram_2304d8.col = 0;
    ram_2304d8.line = 0;
    ram_2304d8.w14 = 0;
    ram_2304d8.b23 = 0;
    ram_2304d8.l0 = 0;
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
    HDAE5000_StrCpy(ram_2306b6, HDAE5000_Str_Info);
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
            HDAE5000_StrNCpy(ram_230736, (char *)ram_230636, 50);
            ram_230736[49] = 0;
        } else {
            HDAE5000_StrNCpy(ram_230736, (char *)ram_230636, HDAE5000_RAM_LyricEvent.len);
            ram_230736[HDAE5000_RAM_LyricEvent.len] = 0;
        }
    } else
        HDAE5000_StrCpy(ram_230736, HDAE5000_Str_NoCopyrightInfo);
    if (HDAE5000_Lyrics_FindEvent(3, 2, -2, 0L) > 0) {
        if (HDAE5000_RAM_LyricEvent.len >= 40) {
            HDAE5000_StrNCpy(ram_230768, (char *)ram_230636, 40);
            ram_230768[39] = 0;
        } else {
            HDAE5000_StrNCpy(ram_230768, (char *)ram_230636, HDAE5000_RAM_LyricEvent.len);
            ram_230768[HDAE5000_RAM_LyricEvent.len] = 0;
        }
    } else
        HDAE5000_StrCpy(ram_230736, HDAE5000_Str_NoSongTitle);
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
    HDAE5000_SPrintf(ram_230790, HDAE5000_Fmt_i_i_File_Load, ram_2307a4, ram_2307a8);
    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_BEAT_MESSAGE, 0L);
    HDAE5000_RAM_LyricEvent.type = 0xff;
    HDAE5000_RAM_LyricEvent.w2 = 0;
    HDAE5000_RAM_LyricEvent.eot = 0;
    HDAE5000_RAM_LyricEvent.len = 0;
    ram_2304d8.hilite = 0;
    ram_23086e = 0;
    HDAE5000_RAM_LyricEvent.tick = 0;
    HDAE5000_Lyrics_FindEvent(0x7c, 2, -2, 0L);
    HDAE5000_RAM_LyricEvent.tick = 0;
    return 0L;
}

long HDAE5000_Lyrics_FillLines(scroll, pos)
unsigned char scroll;
unsigned int pos;
{
    int slot;
    unsigned int cur;
    long r;
    unsigned long savetick;
    unsigned long savenext;
    char line[40];
    unsigned char first;
    unsigned int n;

    savetick = HDAE5000_RAM_LyricEvent.tick;
    savenext = HDAE5000_RAM_LyricEvent.nexttick;
    if (scroll == 1) {
        for (slot = 0; slot < 5; slot++) {
            HDAE5000_StrCpy((char *)((unsigned long)HDAE5000_RAM_LyricLines[0] + slot * 40),
                            (char *)((unsigned long)HDAE5000_RAM_LyricLines[1] + slot * 40));
            ram_2304d8.len[slot] = HDAE5000_StrLen((char *)((unsigned long)HDAE5000_RAM_LyricLines[0] + slot * 40));
        }
        first = 5;
    } else
        first = 0;
    cur = pos;
    for (slot = first; slot < 6; slot++) {
    top:
        line[0] = 0;
    next:
        r = HDAE5000_Lyrics_FindEvent(5, 2, -2, cur);
        if (HDAE5000_RAM_LyricEvent.eot == 1)
            goto tail;
        if (r <= 0)
            goto no_entry;
        if (ram_230636[0] != 0x0d)
            goto try_lf;
        cur = r;
        HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], line);
    store:
        ram_2304d8.len[slot] = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
    }
done:
    HDAE5000_RAM_LyricEvent.tick = savetick;
    HDAE5000_RAM_LyricEvent.nexttick = savenext;
    return cur;

try_lf:
    if (ram_230636[0] != 0x0a)
        goto other;
    cur = r;
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete);
    goto store;
other:
    if (HDAE5000_StrLen((char *)ram_230636) > 39) {
        cur = r;
        goto top;
    }
    n = HDAE5000_StrLen(line);
    if (HDAE5000_StrLen((char *)ram_230636) + n > 39)
        goto tail;
    HDAE5000_StrCat(line, (char *)ram_230636);
    cur = r;
no_entry:
    if (r == 0) {
        HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete_2);
        goto store;
    }
    if (r > 0)
        goto next;
tail:
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], line);
    ram_2304d8.len[slot] = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
    if (HDAE5000_RAM_LyricEvent.eot != 1)
        goto store;
    HDAE5000_RAM_LyricEvent.eot = 0;
    goto done;
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
            n = HDAE5000_Lyrics_ParseEvent(0, pos);
            pos += n;
            if (n == 0)
                return -1L;
        }
        if (type == 0x7c) {
            if ((n = HDAE5000_Lyrics_ParseEvent(flags, pos)) != 0)
                return (unsigned long)pos + n;
            return -1L;
        }
        do {
            n = HDAE5000_Lyrics_ParseEvent(flags, pos);
            pos += n;
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
            n = HDAE5000_Lyrics_ParseEvent(flags, pos);
            pos += n;
        } while (n != 0 && type != HDAE5000_RAM_LyricEvent.type);
        if (n != 0)
            return pos;
        return -1L;
    }
    return 0L;
}

unsigned int HDAE5000_Lyrics_ParseEvent(flags, pos)
unsigned char flags;
unsigned int pos;
{
    unsigned int p;
    unsigned char keep;
    long n;

    keep = 0;
    if (pos + 4 > 20457) {
        ram_2307b6 = 0xffff;
        return 0;
    }
    p = pos;
    if ((flags & 1) == 1)
        keep = 1;
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.prevpos = HDAE5000_RAM_LyricEvent.pos;
        HDAE5000_RAM_LyricEvent.pos = pos;
    }
    if ((ram_230860 = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffe;
        return 0;
    }
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.l24 = HDAE5000_RAM_LyricEvent.tick;
        HDAE5000_RAM_LyricEvent.l36 = HDAE5000_RAM_LyricEvent.l28;
        HDAE5000_RAM_LyricEvent.l28 = ram_230860;
    }
    HDAE5000_RAM_LyricEvent.tick += ram_230860;
    p += ram_23085e;
    if (LYRIC_EV(p++) != 0xff) {
        ram_2307b6 = 0xfffd;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.type = LYRIC_EV(p++);
    if (HDAE5000_RAM_LyricEvent.type == 47) {
        HDAE5000_RAM_LyricEvent.eot = 1;
        ram_230860 = -1L;
        return 0;
    }
    n = HDAE5000_Lyrics_ReadVarLen(p);
    if (n == -1L) {
        ram_2307b6 = 0xfffc;
        return 0;
    }
    p += ram_23085e;
    HDAE5000_RAM_LyricEvent.len = n;
    if (p + HDAE5000_RAM_LyricEvent.len > 20457) {
        ram_2307b6 = 0xfffb;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.endpos = p + HDAE5000_RAM_LyricEvent.len;
    if ((HDAE5000_RAM_LyricEvent.l32 = HDAE5000_Lyrics_ReadVarLen(p + HDAE5000_RAM_LyricEvent.len)) == -1L) {
        ram_2307b6 = 0xfffa;
        return 0;
    }
    ram_230882 = LYRIC_EV(p + HDAE5000_RAM_LyricEvent.len + ram_23085e + 4);
    if (keep == 1) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            HDAE5000_RAM_LyricEvent.data[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), 127);
            HDAE5000_RAM_LyricEvent.data[127] = 0;
        }
    }
    HDAE5000_RAM_LyricEvent.nexttick = HDAE5000_RAM_LyricEvent.tick + HDAE5000_RAM_LyricEvent.l32;
    if ((flags & 2) == 2) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            ram_230636[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), 127);
            ram_230636[127] = 0;
        }
    }
    return HDAE5000_RAM_LyricEvent.endpos - pos;
}

unsigned int HDAE5000_Read_Table_Word(pos)
unsigned int pos;
{
    unsigned int lo;
    lo = LYRIC_EV(pos + 1);
    return LYRIC_EV(pos) << 8 | lo;
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
    if (HDAE5000_MemCmp(HDAE5000_RAM_LyricBuffer.hdr, HDAE5000_Str_Tlhd, 4) != 0)
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
    if (HDAE5000_MemCmp(&HDAE5000_RAM_LyricBuffer.hdr[14], HDAE5000_Str_Tltr, 4) != 0)
        return -10L;
    HDAE5000_RAM_LyricFileLength = HDAE5000_SwapBytes32(TLX_TRLEN) + 22;
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
