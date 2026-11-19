/* lane_p6 round 3 (2026-11-19), module 240: FileIO_ParsePathComponents from p6_J_2m240a.c (r36: +99, Xr).  The ROM
   increments the count in DE and compares DE itself (`cp de,12`); V4.23 copied it to WA first for `++n > 12`.
   Form a: the increment as its own statement. */
/* cc900-name: ParseLoop_Str_Backslash=FileIO_ParseLoop_CheckChar_Str_Backslash */

extern char *__cdecl Strcat(char *, char *);
extern char ParseLoop_Str_Backslash[];
extern int FileIO_ParsePathComponents(char *out, char **pp);

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
