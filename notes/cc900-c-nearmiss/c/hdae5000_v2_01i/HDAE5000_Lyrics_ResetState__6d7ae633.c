/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_lyrics__resetstate_r74.c (2026-11-19-64-hd-r76-staged)
   sha256 6d7ae633ed43fb74c629d6efdbb2cf51378908243a70bbd997ffc79500b68b3e (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
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
extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
extern char ram_230690[128];
extern unsigned int ram_230766, ram_230768;
extern unsigned long ram_23080c;
extern unsigned long ram_230810;
extern unsigned int ram_230814, ram_230818, ram_23081a, ram_23081c;
extern unsigned long ram_23081e;
extern unsigned char ram_23a104;
extern char HDAE5000_Str_Info[];
#define TLX_DIV (*(unsigned int *)&HDAE5000_RAM_LyricBuffer[12])
unsigned int HDAE5000_SwapBytes16(unsigned int);
long HDAE5000_Lyrics_ResetState(void)
{
    ram_23a104 = 1;
    ram_2304d8.s.w8 = 0;
    ram_2304d8.s.w10 = 0;
    ram_2304d8.s.col = 0;
    ram_2304d8.s.line = 0;
    ram_2304d8.s.w14 = 0;
    ram_2304d8.s.b23 = 0;
    ram_2304d8.s.l0 = 0;
    ram_230818 = 0;
    ram_230814 = 0;
    HDAE5000_RAM_LyricEvent.pos = 0;
    HDAE5000_RAM_LyricEvent.endpos = 0;
    HDAE5000_RAM_LyricEvent.prevpos = 0;
    HDAE5000_RAM_LyricEvent.tick = 0;
    HDAE5000_RAM_LyricEvent.nexttick = 0;
    HDAE5000_RAM_LyricEvent.l24 = 0;
    HDAE5000_RAM_LyricEvent.l28 = 0;
    HDAE5000_RAM_LyricEvent.l32 = 0;
    HDAE5000_RAM_LyricEvent.l36 = 0;
    ram_23080c = 0xffffffffL;
    ram_23081a = 0;
    ram_23081c = 0;
    ram_23081e = 0;
    HDAE5000_StrCpy((void *)ram_230690, HDAE5000_Str_Info);
    ram_230766 = 1;
    ram_230768 = 0;
    ram_230810 = (unsigned long)HDAE5000_SwapBytes16(TLX_DIV) / 12;
    return 0;
}
