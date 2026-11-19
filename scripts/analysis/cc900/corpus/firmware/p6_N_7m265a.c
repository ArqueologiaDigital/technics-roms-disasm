/* lane_p6 helper N, round 7, form a: module 265 (demo/fdemotext_routines.s), new function.
   Seq_InitializeAndStart: marks a presentation loaded, resets the voice structures, copies the file name into a
   heap block and posts the read request to MainPreControl, then the block's auto-free to MainAutoFree.  The three
   __cdecl library calls' arguments are popped together (`lda xsp,(xsp+14)`).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Seq_InitVoiceStructures */

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
