/* FORM B of p6_P_3m240a.c (read its notes): the store and increment as `comp[n++] = **pp`, the test `n >= 13`. */
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
			comp[n++] = **pp;
			if (n >= 13)
				return -1;
		}
		*pp += 1;
	}
	*pp = start;
	return 0;
}
