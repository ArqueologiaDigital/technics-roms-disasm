/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_2b.c (2026-11-16-72-p6-r13)
   sha256 d7ebfc4bdcd96a4883e6f8a50a09654b33ffc160f14c1b66362b35a893ac039c (tar-sha256); compiled at -O3 -Xr */
#define EVT_LYRICS_RENEW              0x1c7000bL
extern long SendEvent(long, long, long);
struct LyrCur { int col; int line; };
extern char LYRIC_LINES[];
extern char ram_20e4e[];
extern struct LyrCur ram_20e46[];
extern char *__cdecl Strncpy(char *, char *, unsigned int);
char SongEdit_CheckBounds(unsigned char c)
{
    struct LyrCur *k;
    struct LyrCur *k0;

    k = &ram_20e46[1];
    if (c + k->col < 34) {
        Strncpy(LYRIC_LINES + (k->line * 64 + k->col), ram_20e4e, (unsigned char)(c + 1));
        k = &ram_20e46[1];
        k->col += c;
        ram_20e4e[0] = 0;
        SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
        return 0;
    }
    if (k->line >= 4) return -1;
    LYRIC_LINES[k->line * 64 + k->col] = 0x0d;
    k->col++;
    LYRIC_LINES[k->line * 64 + k->col] = 0;
    k->col++;
    SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
    k0 = &ram_20e46[0];
    k0->line++;
    k0->col = 0;
    k = &ram_20e46[1];
    k->line++;
    k->col = 0;
    Strncpy(LYRIC_LINES + (k->line * 64 + k->col), ram_20e4e, (unsigned char)(c + 1));
    k = &ram_20e46[1];
    k->col += c;
    ram_20e4e[0] = 0;
    SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
    return 0;
}
