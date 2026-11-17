/* cc900-module: CDlikeSwTtl_ShowDocTitle DisplayMode_DispatchEvents DisplayMode_RefreshState NameGetFuncCall */
/* Phase 6, lane_p6 helper A, round 23, form b: module 203 (ui/ui_playback_modes.s), CDlikeSwTtl_DocNavDispatch
   (new): the CD-like title's DOC navigation.  When the sequencer flags show a song playing (bit 1) or paused
   (bit 0) it is stopped first and the title redrawn at the end; the DOC list moves by n, 0x21086 is cleared, the
   display state refreshed and the file-number and song-name fields re-read.  Flags as unsigned int. */
extern unsigned int SeqState_GetFlags(void);
extern void Song_AbortPlayback(void);
extern void NavigateDocList(int n);
extern int ram_21086;
extern void DisplayMode_RefreshState(void);
extern void DisplayMode_DispatchEvents(void);
extern void NameGetFuncCall(long obj, long evt, long par);
extern void CDlikeSwTtl_ShowDocTitle(void);
#define EVT_GET_DOC_SONG_NAME 0x1e70012L
#define EVT_GET_DOC_FILE_NO 0x1e70013L

void CDlikeSwTtl_DocNavDispatch(int n)
{
    if (SeqState_GetFlags() & 2) {
        Song_AbortPlayback();
        NavigateDocList(n);
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_DOC_FILE_NO, 0);
        NameGetFuncCall(-1L, EVT_GET_DOC_SONG_NAME, 0);
        CDlikeSwTtl_ShowDocTitle();
    } else if (SeqState_GetFlags() & 1) {
        Song_AbortPlayback();
        NavigateDocList(n);
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_DOC_FILE_NO, 0);
        NameGetFuncCall(-1L, EVT_GET_DOC_SONG_NAME, 0);
        CDlikeSwTtl_ShowDocTitle();
    } else {
        NavigateDocList(n);
        ram_21086 = 0;
        DisplayMode_RefreshState();
        DisplayMode_DispatchEvents();
        NameGetFuncCall(-1L, EVT_GET_DOC_FILE_NO, 0);
        NameGetFuncCall(-1L, EVT_GET_DOC_SONG_NAME, 0);
    }
}
