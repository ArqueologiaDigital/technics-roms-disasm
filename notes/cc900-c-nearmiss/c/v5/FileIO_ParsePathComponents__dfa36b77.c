/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/smf_event_processor_m240_xr.c (2026-11-19-15-p6-r42)
   sha256 dfa36b7705ea3a3ea30eb6dca0e2890a75e04953c1ecd683395626834f19b64f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr
   cc900-name: ParseLoop_Str_Backslash=FileIO_ParseLoop_CheckChar_Str_Backslash */
extern char *__cdecl Strcat(char *, char *);
extern char ParseLoop_Str_Backslash[];
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
