/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_3m240b.c (2026-11-19-9-p6-r40)
   sha256 994e7cfb6f3f26d81ae97803aee65f46f7162cf1b8ba351c106d57ac644987ea (tar-sha256); compiled at -O3 -Xr
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
			comp[n++] = **pp;
			if (n >= 13)
				return -1;
		}
		*pp += 1;
	}
	*pp = start;
	return 0;
}
