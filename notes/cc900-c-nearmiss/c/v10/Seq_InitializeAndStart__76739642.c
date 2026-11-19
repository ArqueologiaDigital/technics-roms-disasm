/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdemotext_routines_m265_xr.c (2026-11-19-73-p6-r53)
   sha256 7673964230bb0a9eb890f388998197b8110bd9ca39c68064d88521ddddf1d90f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
