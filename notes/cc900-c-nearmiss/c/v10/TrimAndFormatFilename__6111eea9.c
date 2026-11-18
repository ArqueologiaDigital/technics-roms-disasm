/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m268a.c (2026-11-18-12-p6-r35)
   sha256 6111eea969d4b0e851eb2322d57ac297a826610984fa01854a293d1d344be8b5 (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_CopyString(char *, char *);
int TrimAndFormatFilename(int len, unsigned char *s, unsigned char sep)
{
	unsigned char buf[128];
	int i;
	unsigned char *p;
	unsigned char c;

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
		p = &s[i];
		if (*p != ' ')
			break;
		*p = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		for (i = 0; buf[i] == ' '; i++)
			;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}
