/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MainLswGet PsParaBoxProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_LSW_DATA          0x1c0001cL
extern long PsParaBoxProc(long, long, void *);
extern int MainLswGet(long);
extern long SendEvent(long, long, long);
extern int SndParam_LookupReadOnly(long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern char tempo_fmt[], tempo_none[];
extern long AcTempoBoxProc(long obj, long evt, long *p);

/* cc900-name: tempo_fmt=AcTempoBox_MatchTempoID_Str_aa_Fmt3d */
/* cc900-name: tempo_none=AcTempoBox_CopyTempoString_Str_aa */
long AcTempoBoxProc(long obj, long evt, long *p)
{
	char buf[256];

	switch (evt) {
	case EVT_SHOW:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_HIDE:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		MainLswGet(4);
		return 0;
	case EVT_LSW_DATA:
		PsParaBoxProc(obj, evt, p);
		if (*p == 4 || *p == 0x2200) {
			if (SndParam_LookupReadOnly(0x2200) == 0)
				Sprintf_Locked(buf, tempo_fmt, SndParam_LookupReadOnly(4));
			else
				Strcpy(buf, tempo_none);
			SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		}
		return 0;
	}
	return PsParaBoxProc(obj, evt, p);
}
