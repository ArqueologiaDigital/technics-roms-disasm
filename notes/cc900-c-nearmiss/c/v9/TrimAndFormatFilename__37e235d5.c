/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc_m268.c (2026-11-18-34-p6-r38-staged)
   sha256 37e235d5d02e9b9f3b20ba24a55a27c7a808391da024823d4a02be942531db12 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_CopyString(char *, char *);
int TrimAndFormatFilename(int len, unsigned char *s, unsigned char sep)
{
	unsigned char buf[128];
	int i;
	unsigned char *p;
	unsigned char c;
	unsigned char *q;

	s[len] = 0;
	for (i = 0; i < len; i++) {
		p = &s[i];
		c = *p;
		if (c < 0x20)
			*p = ' ';
		else if (c == sep) {
			*p = 0;
			break;
		}
	}
	while (--i >= 0) {
		q = &s[i];
		if (*q != ' ')
			break;
		*q = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		for (i = 0; buf[i] == ' '; i++)
			;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}
