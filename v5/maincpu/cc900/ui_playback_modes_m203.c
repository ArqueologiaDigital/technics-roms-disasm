/* Functions of ui/ui_playback_modes.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
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

/* CDlikeSwTtl_DocNavDispatch is not here: in v5 V4.23 differs at +41 (run 2026-11-18-12-p6-r35); built in the
   other four trees. */
/* cc900-data: DisplayMode_DispatchEvents 1 = DisplayMode_DispatchEvents_CaseTable */
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
