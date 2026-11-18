/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v7/ui_playback_modes_m203.c (2026-11-18-5-p6-r34-staged)
   sha256 086b6f5a2402b3a3654660203c6f131b5eeaf418b3c95b7be60429d2eccb9cec (tar-sha256); compiled at -Xr */
/* Functions of ui/ui_playback_modes.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: CDlikeSwTtl_ShowDocTitle DisplayMode_DispatchEvents DisplayMode_RefreshState NameGetFuncCall */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void CDlikeSwTtl_DocNavDispatch(int n);
extern unsigned char __near CURRENT_TITLE;
extern long ApPostEvent(long, long, long);

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

void DisplayMode_DispatchEvents(void)
{
    switch (CURRENT_TITLE) {
    case 0x6f:
        ApPostEvent(0x6f000aL, 0x1e0003bL, 0L);
        break;
    case 0x73:
        ApPostEvent(0x73000cL, 0x1e0003bL, 0L);
        break;
    case 0x70:
        ApPostEvent(0x700007L, 0x1e0003bL, 0L);
        ApPostEvent(0x700008L, 0x1e0003bL, 0L);
        ApPostEvent(0x700009L, 0x1e0003bL, 0L);
        break;
    case 0x74:
        ApPostEvent(0x74000aL, 0x1e0003bL, 0L);
        ApPostEvent(0x74000bL, 0x1e0003bL, 0L);
        ApPostEvent(0x74000cL, 0x1e0003bL, 0L);
        break;
    case 0x71:
        ApPostEvent(0x710007L, 0x1e0003bL, 0L);
        ApPostEvent(0x710008L, 0x1e0003bL, 0L);
        break;
    case 0x75:
        ApPostEvent(0x750009L, 0x1e0003bL, 0L);
        ApPostEvent(0x75000aL, 0x1e0003bL, 0L);
        break;
    }
}
