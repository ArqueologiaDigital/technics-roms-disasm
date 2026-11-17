/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_2b.c (2026-11-16-72-p6-r13)
   sha256 a7078af977481bf63e6c415c1e9d9dd350bc6ebe373b96a02fe5a2304c8cc198 (tar-sha256); compiled at -Xr */
extern void *__cdecl Memset(void *, int, int);
int FileIO_MatchWildcard(char *name, char *pat)
{
	char buf[12];
	int r;
	int n = 0;

	if (*pat == 0)
		return 0;
	Memset(buf, '?', 11);
	buf[11] = 0;
	{
		char *p;

		p = buf;
		while (*pat != 0) {
			if (*pat == '.') {
				p = buf + 8;
				pat++;
			} else
				*p++ = *pat++;
		}
	}
	{
		int i;

		for (i = 0; i < 8; i++) {
			if (buf[i] == '*')
				for (; i < 8; i++)
					buf[i] = '?';
		}
		for (i = 8; i < 11; i++) {
			if (buf[i] == '*')
				for (; i < 11; i++)
					buf[i] = '?';
		}
	}
	{
		char *s;
		char *p;

		r = 1;
		s = name;
		p = buf;
		while (*s != 0) {
			if (*p != '?' && *s != *p) {
				r = 0;
				break;
			}
			s++;
			p++;
		}
	}
	return r;
}
