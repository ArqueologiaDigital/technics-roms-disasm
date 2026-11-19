/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_8m265a.c (2026-11-19-68-p6-r52)
   sha256 24effdfc408b5055af959813f7224739b233096b7146e316b82f5eb1d4a71c2a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int PRESENTATION_LOADED;
extern void Seq_InitVoiceStructures(int);
extern int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern long MainFuncCall(long, long, long);
void Seq_InitializeAndStart(char *name)
{
	char *s;
	long f;
	long e;

	PRESENTATION_LOADED = 1;
	Seq_InitVoiceStructures(0);
	s = Malloc(Strlen(name) + 1);
	Strcpy(s, name);
	f = 0x1410000L;
	e = 0x1e10003L;
	MainFuncCall(f, e, (long)s);
	f = 0x1400003L;
	e = 0x1e00023L;
	MainFuncCall(f, e, (long)s);
}
