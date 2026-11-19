/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_lyrics2__filllines_r74.c (2026-11-19-64-hd-r76-staged)
   sha256 1d6f84003f6d72812e2e872e30e7eb12a42ce8774d5b4a97e95d9b31e6117641 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
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
extern char HDAE5000_RAM_LyricLines[6][35];
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
extern unsigned char ram_230610[128];
extern char HDAE5000_Str_Empty_File_Delete[];
extern char HDAE5000_Str_Empty_File_Delete_2[];
long HDAE5000_Lyrics_FindEvent(int, int, int, long);
long HDAE5000_Lyrics_FillLines(int scroll, unsigned int pos)
{
    int slot;
    unsigned int cur;
    long r;
    unsigned long savetick;
    unsigned long savenext;
    char line[35];
    unsigned char first;
    unsigned int n;

    savetick = HDAE5000_RAM_LyricEvent.tick;
    savenext = HDAE5000_RAM_LyricEvent.nexttick;
    if ((unsigned char)scroll == 1) {
        for (slot = 0; slot < 5; slot++) {
            HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot],
                            (&HDAE5000_RAM_LyricLines[1])[slot]);
            LYR_LEN(slot) = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
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
        if (ram_230610[0] != 0x0d)
            goto try_lf;
        cur = r;
        HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], line);
    store:
        LYR_LEN(slot) = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
    }
done:
    HDAE5000_RAM_LyricEvent.tick = savetick;
    HDAE5000_RAM_LyricEvent.nexttick = savenext;
    return cur;

try_lf:
    if (ram_230610[0] != 0x0a)
        goto other;
    cur = r;
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete);
    goto store;
other:
    if (HDAE5000_StrLen((char *)ram_230610) > 34) {
        cur = r;
        goto top;
    }
    n = HDAE5000_StrLen(line);
    if (HDAE5000_StrLen((char *)ram_230610) + n > 34)
        goto tail;
    HDAE5000_StrCat(line, (char *)ram_230610);
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
    LYR_LEN(slot) = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
    if (HDAE5000_RAM_LyricEvent.eot != 1)
        goto store;
    HDAE5000_RAM_LyricEvent.eot = 0;
    goto done;
}
