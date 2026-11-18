/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_2m240a.c (2026-11-18-28-p6-r36)
   sha256 c24a1d7591adeb59de4d704d2d0c4c65a1bd2e4454efb31bf006c722f3dfca1b (tar-sha256); compiled at -O3 -Xr
   cc900-name: ParseLoop_Str_Backslash=FileIO_ParseLoop_CheckChar_Str_Backslash */
extern char *__cdecl Strcat(char *, char *);
extern char PathInfo_BuildAndOpen_Str_A[], PathInfo_BuildAndOpen_Str_wb[], ParseLoop_Str_Backslash[];
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
			if (++n > 12)
				return -1;
		}
		*pp += 1;
	}
	*pp = start;
	return 0;
}
