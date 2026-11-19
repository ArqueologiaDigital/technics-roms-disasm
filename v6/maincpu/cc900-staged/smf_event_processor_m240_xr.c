/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern char *__cdecl Strcat(char *, char *);
extern char ParseLoop_Str_Backslash[];
extern int FileIO_ParsePathComponents(char *out, char **pp);

/* cc900-name: ParseLoop_Str_Backslash=FileIO_ParseLoop_CheckChar_Str_Backslash */
int FileIO_ParsePathComponents(char *out, char **pp)
{
	char comp[13];
	int n;
	char *start;

	n = 0;
	*out = 0;
	start = *pp;
	while (**pp != 0) {
		if (**pp == '\\') {
			comp[n] = 0;
			if (*out != 0)
				Strcat(out, ParseLoop_Str_Backslash);
			Strcat(out, comp);
			n = 0;
			start = *pp + 1;
		} else {
			comp[n] = **pp;
			n++;
			if (n > 12)
				return -1;
		}
		*pp += 1;
	}
	*pp = start;
	return 0;
}
