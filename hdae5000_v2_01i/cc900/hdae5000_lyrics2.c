/* Functions of hdae5000_ui_display.s.  (hdae5000_lyrics2.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_lyrics2.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32 HDAE5000_Lyrics_FindEvent HDAE5000_Lyrics_ParseEvent
   cc900-module: HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_CheckHeaderChunk HDAE5000_Lyrics_CheckHdrChunk
   cc900-module: HDAE5000_Lyrics_CheckTrackChunk HDAE5000_Lyrics_ClearBuffer HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_ResetState
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
/* the line state as bytes too: its line lengths are reached as b[index + 16] (ROM: ld wa,(index); add wa,16;
   lda xbc,(0x2304d8); (xbc+wa)) */
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
extern struct Point ram_230822;
extern char ram_23051e[];
extern unsigned char ram_230610[128];
extern char ram_230690[128];
extern char ram_23074c[10];
extern unsigned char ram_230760, ram_230762, ram_230764;
extern unsigned int ram_2307aa, ram_2307ac, ram_23076a, ram_23076c, ram_2307b2, ram_2307b4, ram_230772;
extern int ram_230774[40];
extern unsigned char ram_2307ba[6];
extern int ram_23080e[39];
extern unsigned int ram_230806;
extern long ram_230808;
extern unsigned long ram_23080c;
extern unsigned long ram_230810;
extern unsigned int ram_230814, ram_230816, ram_230818, ram_230872, ram_230874;
extern unsigned char ram_23087e, ram_230880, ram_230826;

extern char HDAE5000_Fmt_Fault_No_Lyrics_loaded_o[];
extern char HDAE5000_Fmt_i_i[], HDAE5000_Fmt_Chord_s[];
extern char HDAE5000_Str_Empty_File_Delete[];
extern char HDAE5000_Str_Empty_File_Delete_2[];

/* events of the lyric track start at +22, after the TLhd (14) and TLtr (8) headers */
#define LYRIC_EV(i) (&HDAE5000_RAM_LyricBuffer[22])[i]

void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *, int);
long HDAE5000_Lyrics_FillLines(int, unsigned int);
long HDAE5000_Lyrics_FindEvent(int, int, int, long);
unsigned int HDAE5000_Lyrics_ParseEvent(int, unsigned int);
long HDAE5000_Lyrics_ReadVarLen(unsigned int);

unsigned int HDAE5000_Lyrics_ParseEvent(int flags, unsigned int pos)
{
    unsigned int p;
    unsigned char keep;
    long n;
    unsigned int ps;
    unsigned char f;

    ps = pos;
    f = flags;
    keep = 0;
    if (ps + 4 > 20457) {
        ram_230772 = 0xffff;
        return 0;
    }
    p = ps;
    if ((f & 1) == 1)
        keep = 1;
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.prevpos = HDAE5000_RAM_LyricEvent.pos;
        HDAE5000_RAM_LyricEvent.pos = ps;
    }
    if ((ram_230808 = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_230772 = 0xfffe;
        return 0;
    }
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.l24 = HDAE5000_RAM_LyricEvent.tick;
        HDAE5000_RAM_LyricEvent.l36 = HDAE5000_RAM_LyricEvent.l28;
        HDAE5000_RAM_LyricEvent.l28 = ram_230808;
    }
    HDAE5000_RAM_LyricEvent.tick += ram_230808;
    p += ram_230806;
    if (LYRIC_EV(p++) != 0xff) {
        ram_230772 = 0xfffd;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.type = LYRIC_EV(p++);
    if (HDAE5000_RAM_LyricEvent.type == 47) {
        HDAE5000_RAM_LyricEvent.eot = 1;
        ram_230808 = -1L;
        return 0;
    }
    if ((n = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_230772 = 0xfffc;
        return 0;
    }
    p += ram_230806;
    HDAE5000_RAM_LyricEvent.len = n;
    if (p + HDAE5000_RAM_LyricEvent.len > 20457) {
        ram_230772 = 0xfffb;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.endpos = p + HDAE5000_RAM_LyricEvent.len;
    if ((HDAE5000_RAM_LyricEvent.l32 = HDAE5000_Lyrics_ReadVarLen(p + HDAE5000_RAM_LyricEvent.len)) == -1L) {
        ram_230772 = 0xfffa;
        return 0;
    }
    ram_230826 = LYRIC_EV(p + HDAE5000_RAM_LyricEvent.len + ram_230806 + 4);
    if (keep == 1) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            (&HDAE5000_RAM_LyricEvent.data[0])[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), 127);
            HDAE5000_RAM_LyricEvent.data[127] = 0;
        }
    }
    HDAE5000_RAM_LyricEvent.nexttick = HDAE5000_RAM_LyricEvent.l32 + HDAE5000_RAM_LyricEvent.tick;
    if ((f & 2) == 2) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(ram_230610, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            ram_230610[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(ram_230610, &LYRIC_EV(p), 127);
            ram_230610[127] = 0;
        }
    }
    return HDAE5000_RAM_LyricEvent.endpos - ps;
}
