/* Phase 6, lane_p6 helper L, round 2, form a: module 265 (demo/fdemotext_routines.s).
   - FDemoText_ByteData_DisplayRefresh: the display name of object id: "NONE" for -1; else the object's own name
     (EVT_GET_NAME) copied to the buffer at 0x247f6, or, when that is empty, "<title name><number>" formatted
     there from the title (id >> 16) & 0xfff and the low word of id.  The function and both string labels share
     their first 31 characters, so all three get short C names. */
/* (no module-local callee) */

/* cc900-name: FdtDisplayRefresh=FDemoText_ByteData_DisplayRefresh */
/* cc900-name: FdtStrNone=FDemoText_ByteData_DisplayRefresh_Str_NONE */
/* cc900-name: FdtStrFmt=FDemoText_ByteData_DisplayRefresh_Str_Fmts_Fmtd */
#define TITLE_PS 0x1a00000L
#define EVT_GET_NAME 0x1e00015L
extern char FdtStrNone[];
extern char FdtStrFmt[];
extern char ram_247f6[];
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern char *FdtDisplayRefresh(unsigned long id);

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
