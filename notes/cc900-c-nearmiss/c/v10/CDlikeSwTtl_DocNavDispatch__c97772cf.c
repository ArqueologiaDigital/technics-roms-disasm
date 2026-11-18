/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_23m203a.c (2026-11-18-1-p6-r33)
   sha256 c97772cf91d80bc280ee77e337db1f71fc757267e399a4221530897948faa278 (tar-sha256); compiled at -Xr */
extern int SeqState_GetFlags(void);
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
