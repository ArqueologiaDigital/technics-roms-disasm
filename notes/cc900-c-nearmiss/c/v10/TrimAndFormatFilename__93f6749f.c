/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_3m268b.c (2026-11-18-28-p6-r36)
   sha256 93f6749fcab8e9b777b3f18af456766ad8f02a2b7002b66ae48158e27b074291 (tar-sha256); compiled at -Xr */
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
