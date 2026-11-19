/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m265a.c (2026-11-19-56-p6-r51)
   sha256 4fbf3816a14ec8075f2ea398a04c112c1800275f2d7cbc39f454d59f9646ebfc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define NAKA_MAINFUNC_MainPreControl 0x1410000L
#define NAKA_MAINFUNC_MainAutoFree   0x1400003L
#define EVT_READ_PRESENTATION_REQ    0x1e10003L
#define EVT_AUTO_FREE                0x1e00023L
extern int PRESENTATION_LOADED;
extern void Seq_InitVoiceStructures(int);
extern int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern long MainFuncCall(long, long, long);
void Seq_InitializeAndStart(char *name)
{
	char *s;

	PRESENTATION_LOADED = 1;
	Seq_InitVoiceStructures(0);
	s = Malloc(Strlen(name) + 1);
	Strcpy(s, name);
	MainFuncCall(NAKA_MAINFUNC_MainPreControl, EVT_READ_PRESENTATION_REQ, (long)s);
	MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, (long)s);
}
