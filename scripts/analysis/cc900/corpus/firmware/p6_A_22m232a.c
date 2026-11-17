/* cc900-module: SongEdit_CheckBounds */
/* Phase 6, lane_p6 helper A, round 22, form a: module 232 (sequencer/sequencer_ui.s), LyricsTrack_ReadAndParse
   (new): reads the next lyric record into the 0x20e4e buffer (cut at 33 characters).  A CR or LF alone ends the
   line: CR and NUL into LYRIC_LINES at the cursor 0x20e4a {col, line} (lines of 64), EVT_LYRICS_RENEW, both
   cursors (0x20e46 and 0x20e4a) to the next line, buffer emptied; any other text goes to SongEdit_CheckBounds (the
   ROM's tail jrl).  Globals as structs and a 2-D line array. */
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
    SeqFile_ReadTrackData(ram_20e4e);
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
            ram_20e4a.col++;
            LYRIC_LINES[ram_20e4a.line][ram_20e4a.col] = 0;
            ram_20e4a.col++;
            SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
            ram_20e46.line++;
            ram_20e46.col = 0;
            ram_20e4a.line++;
            ram_20e4a.col = 0;
            ram_20e4e[0] = 0;
            return;
        }
        SongEdit_CheckBounds((unsigned char)Strlen(ram_20e4e));
    } else
        SongEdit_CheckBounds((unsigned char)Strlen(ram_20e4e));
}
