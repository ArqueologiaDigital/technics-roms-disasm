/* Phase 6, lane_p6 helper G, round 9, module 271, form c: AcTempoBoxProc alone.  Run 2026-11-16-107-p6-r21:
   - with the event parameter a `long *` (round 8 form a) the two reads `ld xwa,(xiz)` match, but the argument
     `(long)p` passed to PsParaBoxProc became one conversion that V4.23 hoisted to the entry (`ld xde,xiz` once) where
     the ROM copies XIZ to XDE before each call;
   - with a plain `long` parameter (form b) the calls match but the reads go through a copied pointer.
   Here the parameter stays `long *` and PsParaBoxProc's third parameter is declared `void *` (this file does not
   define it), so the argument is passed with no conversion.
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: MainLswGet PsParaBoxProc */

#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_LSW_DATA          0x1c0001cL

/* module 271 (calr) */
extern long PsParaBoxProc(long, long, void *);
extern int MainLswGet(long);
/* elsewhere (call) */
extern long SendEvent(long, long, long);
extern int SndParam_LookupReadOnly(long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);

/* cc900-name: tempo_fmt=AcTempoBox_MatchTempoID_Str_aa_Fmt3d */
/* cc900-name: tempo_none=AcTempoBox_CopyTempoString_Str_aa */
extern char tempo_fmt[], tempo_none[];

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
