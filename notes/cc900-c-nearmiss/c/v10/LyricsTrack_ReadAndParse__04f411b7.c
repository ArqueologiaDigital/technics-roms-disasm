/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_23m232b.c (2026-11-18-1-p6-r33)
   sha256 04f411b7548a698d522a7075a996bcb1ae56aa800ad9eb5b543acc0590c0fc9b (tar-sha256); compiled at -O3 -Xr */
struct lyrpos { int col; int line; };
extern unsigned char ram_20e4e[];
extern struct lyrpos ram_20e4a;
extern struct lyrpos ram_20e46;
extern unsigned char LYRIC_LINES[4][64];
extern void SeqFile_ReadTrackData(unsigned char *);
extern unsigned int __cdecl Strlen(unsigned char *);
extern unsigned char SongEdit_CheckBounds(unsigned char n);
extern long SendEvent(unsigned long, long, long);
#define EVT_LYRICS_RENEW 0x1c7000bL
void LyricsTrack_ReadAndParse(void)
{
    unsigned char c;
    SeqFile_ReadTrackData((unsigned char *)ram_20e4e);
    if (Strlen(ram_20e4e) >= 0x22)
        ram_20e4e[0x21] = 0;
    if (ram_20e4e[0] == 0)
        return;
    c = ram_20e4e[Strlen(ram_20e4e) - 1];
    if (c == '\n' || c == '\r') {
        if ((unsigned char)Strlen(ram_20e4e) == 1) {
            if (ram_20e4a.line >= 4)
                return;
            LYRIC_LINES[ram_20e4a.line][ram_20e4a.col] = '\r';
            ram_20e4a.col = ram_20e4a.col + 1;
            LYRIC_LINES[ram_20e4a.line][ram_20e4a.col] = 0;
            ram_20e4a.col = ram_20e4a.col + 1;
            SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
            ram_20e46.line = ram_20e46.line + 1;
            ram_20e46.col = 0;
            ram_20e4a.line = ram_20e4a.line + 1;
            ram_20e4a.col = 0;
            ram_20e4e[0] = 0;
            return;
        }
        SongEdit_CheckBounds((unsigned char)Strlen(ram_20e4e));
    } else
        SongEdit_CheckBounds((unsigned char)Strlen(ram_20e4e));
}
