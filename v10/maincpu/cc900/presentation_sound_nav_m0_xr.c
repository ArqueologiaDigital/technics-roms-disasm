/* Functions of audio/presentation_sound_nav.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: DrawTitleBar ScreenProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_DRAW 0x1c0000dL
extern long ScreenProc(long obj, long evt, long par);
extern long IvScreenProc(long obj, long evt, long par);

long IvScreenProc(long obj, long evt, long par)
{
	if (evt != EVT_DRAW)
		return ScreenProc(obj, evt, par);
	return 0;
}
