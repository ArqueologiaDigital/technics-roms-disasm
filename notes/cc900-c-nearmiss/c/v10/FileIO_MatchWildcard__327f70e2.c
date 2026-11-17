/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_2c.c (2026-11-16-72-p6-r13)
   sha256 327f70e29f4189d450874d1c3c9dd05f2cb4127ef566b492108b2f8c8102e86c (tar-sha256); compiled at -Xr */
extern void *__cdecl Memset(void *, int, int);
int FileIO_MatchWildcard(char *name, char *pat)
{
	char buf[12];
	int i;
	char *p;
	char *s;
	int r;

	if (*pat == 0)
		return 0;
	Memset(buf, '?', 11);
	buf[11] = 0;
	p = buf;
	while (*pat != 0) {
		if (*pat == '.') {
			p = buf + 8;
			pat++;
		} else
			*p++ = *pat++;
	}
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
	return r;
}
