/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
