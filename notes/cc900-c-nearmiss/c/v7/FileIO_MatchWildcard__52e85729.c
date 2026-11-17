/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_event_processor_m240_xr.c (2026-11-16-92-p6-r18)
   sha256 52e8572951ac34c02be964d0a88a65fa15f1b0701ab8f4fff3abc657bd70e6aa (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
