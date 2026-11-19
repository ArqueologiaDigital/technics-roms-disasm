/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/smf_event_processor_m238_xr.c (2026-11-19-43-p6-r48)
   sha256 20a913e2c3c09a95e832a48c8a4200dffd36bf777495d7d53eff220e3e7eb4d7 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
