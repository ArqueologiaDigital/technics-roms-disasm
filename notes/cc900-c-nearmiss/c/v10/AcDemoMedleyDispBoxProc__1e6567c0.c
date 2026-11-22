/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_22r1m232c.c (2026-11-21-21-p6-r66)
   sha256 1e6567c08c715fc9d94212fe454b41a0e7eaab4abc9ab89cfa1ba7c7391bfba7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AcDemoMedley_Str=AcDemoMedley_HandleScrollEvent_Str
   cc900-name: AcDemoMedley_Str_2=AcDemoMedley_HandleScrollEvent_Str_2 */
#define EVT_SHOW                     0x1c00001L
#define EVT_HIDE                     0x1c00002L
#define EVT_PAINT                    0x1c0000bL
#define EVT_REPAINT                  0x1c0000cL
#define EVT_PARA_DRAW                0x1c0000fL
extern unsigned char ram_21090;
extern char AcDemoMedley_Str[];
extern char AcDemoMedley_Str_2[];
extern long InheritedProc(long, long, long);
extern long SendEvent(long, long, long);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
long AcDemoMedleyDispBoxProc(long obj, long evt, long p)
{
	char buf[256];

	switch (evt) {
	case EVT_SHOW:
		InheritedProc(obj, evt, p);
		return 0;
	case EVT_HIDE:
		InheritedProc(obj, evt, p);
		return 0;
	case EVT_PAINT:
	case EVT_REPAINT:
		InheritedProc(obj, evt, p);
		Sprintf_Locked(buf, ram_21090 == 1 ? AcDemoMedley_Str : AcDemoMedley_Str_2);
		SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		return 0;
	default:
		return InheritedProc(obj, evt, p);
	}
}
