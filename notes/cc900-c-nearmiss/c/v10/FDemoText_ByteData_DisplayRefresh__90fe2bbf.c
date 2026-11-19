/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdemotext_routines_m265_xr.c (2026-11-19-29-p6-r46)
   sha256 90fe2bbff3f38abf77954c7b643a9268484d15443ef05eb979507db4bb4e508c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr
   cc900-name: FdtDisplayRefresh=FDemoText_ByteData_DisplayRefresh
   cc900-name: FdtStrFmt=FDemoText_ByteData_DisplayRefresh_Str_Fmts_Fmtd
   cc900-name: FdtStrNone=FDemoText_ByteData_DisplayRefresh_Str_NONE */
#define TITLE_PS 0x1a00000L
#define EVT_GET_NAME 0x1e00015L
extern char FdtStrNone[];
extern char FdtStrFmt[];
extern char ram_247f6[];
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
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
