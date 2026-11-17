/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_6m271a.c (2026-11-16-100-p6-r19)
   sha256 bc075ca6d6c0cf917b1bf121bd79d23bbeae99784e1a636de07748b880b717f1 (tar-sha256); compiled at -O3 -Xr
   cc900-name: tempo_fmt=AcTempoBox_MatchTempoID_Str_aa_Fmt3d
   cc900-name: tempo_none=AcTempoBox_CopyTempoString_Str_aa */
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_LSW_DATA          0x1c0001cL
extern long PsParaBoxProc(long, long, long);
extern int MainLswGet(long);
extern long SendEvent(long, long, long);
extern int SndParam_LookupReadOnly(long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern char tempo_fmt[], tempo_none[];
long AcTempoBoxProc(long obj, long evt, long p)
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
		if (*(long *)p == 4 || *(long *)p == 0x2200) {
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
