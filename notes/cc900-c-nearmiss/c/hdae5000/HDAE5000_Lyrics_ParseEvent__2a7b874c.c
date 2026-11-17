/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_lyrics2.c (2026-11-17-11-hd-r40-staged)
   sha256 2a7b874ce0186bbf6618e66194d2198d50cca97b9f2a02c5121f7e5896ba2d64 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
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
extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
extern unsigned char ram_230636[128];
extern unsigned int ram_2307aa, ram_2307ac, ram_2307ae, ram_2307b0, ram_2307b2, ram_2307b4, ram_2307b6;
extern unsigned int ram_23085e;
extern long ram_230860;
extern unsigned char ram_23087e, ram_230880, ram_230882;
#define LYRIC_EV(i) (&HDAE5000_RAM_LyricBuffer[22])[i]
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
        ram_2307b6 = 0xffff;
        return 0;
    }
    p = ps;
    if ((f & 1) == 1)
        keep = 1;
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.prevpos = HDAE5000_RAM_LyricEvent.pos;
        HDAE5000_RAM_LyricEvent.pos = ps;
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
    if ((n = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
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
            (&HDAE5000_RAM_LyricEvent.data[0])[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), 127);
            HDAE5000_RAM_LyricEvent.data[127] = 0;
        }
    }
    HDAE5000_RAM_LyricEvent.nexttick = HDAE5000_RAM_LyricEvent.l32 + HDAE5000_RAM_LyricEvent.tick;
    if ((f & 2) == 2) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            ram_230636[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), 127);
            ram_230636[127] = 0;
        }
    }
    return HDAE5000_RAM_LyricEvent.endpos - ps;
}
