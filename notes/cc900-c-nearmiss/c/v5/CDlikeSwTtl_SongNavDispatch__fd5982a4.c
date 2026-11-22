/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_playback_modes_m203.c (2026-11-22-16-p6-r83)
   sha256 fd5982a4b1b568f61d36feb271a1794a5554021f307ee5df84454f36b702fdfa (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int SeqState_GetFlags(void);
extern void Song_AbortPlayback(void);
extern int ram_21086;
extern void DisplayMode_RefreshState(void);
extern void DisplayMode_DispatchEvents(void);
extern void NameGetFuncCall(long obj, long evt, long par);
extern void NavigateSongList(int n);
extern unsigned char ram_21088;
extern void CDlikeSwTtl_ShowSongTitle(void);
extern long ApPostEvent(long, long, long);
#define EVT_LYRICS_ALL_CLEAR 0x1c70009L
#define EVT_GET_SMF_FILE_NAME 0x1e7000fL
#define EVT_GET_SMF_SONG_NAME 0x1e70010L
#define EVT_GET_LYRICS_SONG_NAME 0x1e70019L
#define EVT_GET_COMPOSER_NAME 0x1e7001aL
void CDlikeSwTtl_SongNavDispatch(int n)
{
    if (SeqState_GetFlags() & 2) {
        Song_AbortPlayback();
        ApPostEvent(0x6f0026L, EVT_LYRICS_ALL_CLEAR, 0L);
        NavigateSongList(n);
        ram_21088 = 0;
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_SMF_FILE_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_SMF_SONG_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_LYRICS_SONG_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_COMPOSER_NAME, 0);
        CDlikeSwTtl_ShowSongTitle();
    } else if (SeqState_GetFlags() & 1) {
        Song_AbortPlayback();
        ApPostEvent(0x6f0026L, EVT_LYRICS_ALL_CLEAR, 0L);
        NavigateSongList(n);
        ram_21088 = 0;
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_SMF_FILE_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_SMF_SONG_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_LYRICS_SONG_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_COMPOSER_NAME, 0);
        CDlikeSwTtl_ShowSongTitle();
    } else {
        NavigateSongList(n);
        ram_21088 = 0;
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_SMF_FILE_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_SMF_SONG_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_LYRICS_SONG_NAME, 0);
        NameGetFuncCall(-1L, EVT_GET_COMPOSER_NAME, 0);
    }
}
