/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m203a.c (2026-11-22-15-p6-r82)
   sha256 8c6d39ac58adb8a464dc3f5e1f693ca2f6d778b24633fbeab42fa383aec55bba (tar-sha256); compiled at -Xr */
extern int SeqState_GetFlags(void);
extern void Song_AbortPlayback(void);
extern void NavigatePdList(int n);
extern int ram_21086;
extern void DisplayMode_RefreshState(void);
extern void DisplayMode_DispatchEvents(void);
extern void NameGetFuncCall(long obj, long evt, long par);
extern void CDlikeSwTtl_ShowPdTitle(void);
#define EVT_GET_PD_SONG_NAME 0x1e70014L
#define EVT_GET_PD_FILE_NO 0x1e70015L
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
