/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m238a.c (2026-11-19-15-p6-r42)
   sha256 9f07ec82f18c434e025e8722fb7d8f0ba0ab8796d08b51906bff49154255030f (tar-sha256); compiled at -Xr */
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
			*pp += 1;
		for (i = 0; i < 11; i++) {
			if (**pp == 0)
				break;
			if (**pp == '/' || **pp == '\\') {
				r = 1;
				break;
			}
			if (**pp == '.') {
				if (i > 1 || (i == 1 && dst[0] != '.')) {
					i = 7;
					*pp += 1;
					continue;
				}
			}
			dst[i] = **pp;
			*pp += 1;
		}
		if (**pp == '/' || **pp == '\\')
			r = 1;
		else if (**pp != 0)
			r = -1;
	} while (dst[0] == '.' && dst[1] == ' ');
	return r;
}
