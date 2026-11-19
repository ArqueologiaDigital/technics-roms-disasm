/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m238b.c (2026-11-19-15-p6-r42)
   sha256 0a27a208d7af84aa1c8b4327afb31afb1156ece3fef2e127e682f5452ba5b152 (tar-sha256); compiled at -Xr */
extern void *__cdecl Memset(void *, int, unsigned int);
int __cdecl FatPath_Next83Component(char *dst, char **pp)
{
	int r;
	int i;

	do {
		Memset(dst, ' ', 11);
		dst[11] = 0;
		r = 0;
		if (**pp == '/' || **pp == '\\')
			(*pp)++;
		i = 0;
		if (i < 11)
			do {
				if (**pp == 0)
					break;
				if (**pp == '/' || **pp == '\\') {
					r = 1;
					break;
				}
				if (**pp == '.') {
					if (i > 1 || (i == 1 && dst[0] != '.')) {
						i = 7;
						(*pp)++;
						continue;
					}
				}
				dst[i] = **pp;
				(*pp)++;
			} while (++i < 11);
		if (**pp == '/' || **pp == '\\')
			r = 1;
		else if (**pp != 0)
			r = -1;
	} while (dst[0] == '.' && dst[1] == ' ');
	return r;
}
