/* Probe round 31r1, helper R: twins of the built CDlikeSwTtl_DocNavDispatch (cc900/ui_playback_modes_m203.c),
   written the same way with each one's own callees and events.  ui/ui_playback_modes.s, -O3 -Xr. */
/* cc900-module: CDlikeSwTtl_ShowPdTitle CDlikeSwTtl_ShowSongTitle DisplayMode_DispatchEvents DisplayMode_RefreshState NameGetFuncCall */

extern int SeqState_GetFlags(void);
extern void Song_AbortPlayback(void);
extern void NavigateSongList(int n);
extern void NavigatePdList(int n);
extern int ram_21086;
extern unsigned char ram_21088;
extern void DisplayMode_RefreshState(void);
extern void DisplayMode_DispatchEvents(void);
extern void NameGetFuncCall(long obj, long evt, long par);
extern void CDlikeSwTtl_ShowSongTitle(void);
extern void CDlikeSwTtl_ShowPdTitle(void);
extern long ApPostEvent(long, long, long);
#define EVT_LYRICS_ALL_CLEAR 0x1c70009L
#define EVT_GET_SMF_FILE_NAME 0x1e7000fL
#define EVT_GET_SMF_SONG_NAME 0x1e70010L
#define EVT_GET_PD_SONG_NAME 0x1e70014L
#define EVT_GET_PD_FILE_NO 0x1e70015L
#define EVT_GET_LYRICS_SONG_NAME 0x1e70019L
#define EVT_GET_COMPOSER_NAME 0x1e7001aL
extern void CDlikeSwTtl_SongNavDispatch(int n);
extern void CDlikeSwTtl_PdNavDispatch(int n);

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

void CDlikeSwTtl_PdNavDispatch(int n)
{
    if (SeqState_GetFlags() & 2) {
        Song_AbortPlayback();
        NavigatePdList(n);
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_PD_FILE_NO, 0);
        NameGetFuncCall(-1L, EVT_GET_PD_SONG_NAME, 0);
        CDlikeSwTtl_ShowPdTitle();
    } else if (SeqState_GetFlags() & 1) {
        Song_AbortPlayback();
        NavigatePdList(n);
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_PD_FILE_NO, 0);
        NameGetFuncCall(-1L, EVT_GET_PD_SONG_NAME, 0);
        CDlikeSwTtl_ShowPdTitle();
    } else {
        NavigatePdList(n);
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_PD_FILE_NO, 0);
        NameGetFuncCall(-1L, EVT_GET_PD_SONG_NAME, 0);
    }
}
