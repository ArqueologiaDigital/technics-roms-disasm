/* lane_p6 helper N, round 8, form a: module 265 (demo/fdemotext_routines.s), retry of p6_N_7m265a
   (p6-r51 Xr: +47).  Seq_InitializeAndStart: the ROM loads the two MainFuncCall constants first and the heap
   pointer (XDE) last; V4.23 loaded the pointer first.  Form a: the constants through initialised locals
   (lane_sub's spelling for a constant loaded in argument order).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Seq_InitVoiceStructures */

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
