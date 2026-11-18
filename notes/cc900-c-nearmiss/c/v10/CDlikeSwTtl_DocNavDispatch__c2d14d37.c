/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_23m203b.c (2026-11-18-1-p6-r33)
   sha256 c2d14d37afebbc3e24b02ff01c6df22c8bfe3c62e129d10a87b7624689bd3dc4 (tar-sha256); compiled at -Xr */
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
