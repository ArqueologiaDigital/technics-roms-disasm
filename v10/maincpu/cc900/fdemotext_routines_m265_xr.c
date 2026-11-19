/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct pt { int x, y; };

void FDemoText_ScaleDownCoords(struct pt *s, struct pt *d)
{
	d->x = s->x / 8;
	d->y = s->y / 4;
}

#define TITLE_PS 0x1a00000L
#define EVT_GET_NAME 0x1e00015L
extern char FdtStrNone[];
extern char FdtStrFmt[];
extern char ram_247f6[];
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern char *FdtDisplayRefresh(unsigned long id);

/* cc900-name: FdtDisplayRefresh=FDemoText_ByteData_DisplayRefresh */
/* cc900-name: FdtStrNone=FDemoText_ByteData_DisplayRefresh_Str_NONE */
/* cc900-name: FdtStrFmt=FDemoText_ByteData_DisplayRefresh_Str_Fmts_Fmtd */
char *FdtDisplayRefresh(unsigned long id)
{
	char *s;

	if (id == 0xffffffffUL)
		return FdtStrNone;
	s = (char *)SendEvent(id, EVT_GET_NAME, 0);
	if (*s == 0) {
		s = (char *)SendEvent((unsigned int)((id >> 16) & 0xfff) + TITLE_PS, EVT_GET_NAME, 0);
		Sprintf_Locked(ram_247f6, FdtStrFmt, s, (unsigned int)(id & 0xffff));
	} else
		Strcpy(ram_247f6, s);
	return ram_247f6;
}

/* cc900-module: FDemoText_LookupTableEntry FDemoText_NotifyUIChange */
extern void FDemoText_DeactivateVoice_RetOnly(void);

void FDemoText_DeactivateVoice_RetOnly(void)
{
}

/* cc900-module: Seq_InitVoiceStructures */
extern int PRESENTATION_LOADED;
extern void Seq_InitVoiceStructures(int);
extern int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long, long, long);
extern void Seq_InitializeAndStart(char *name);

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
