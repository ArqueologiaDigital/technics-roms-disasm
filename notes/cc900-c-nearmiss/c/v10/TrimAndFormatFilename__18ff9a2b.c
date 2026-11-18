/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m268b.c (2026-11-18-12-p6-r35)
   sha256 18ff9a2bc7c75af7b758ec9f89e2d75c9e89d0b8100dbe770fb3e64e8dac1fe6 (tar-sha256); compiled at -O3 -Xr */
extern void FileIO_CopyString(char *, char *);
int TrimAndFormatFilename(int len, unsigned char *s, unsigned char sep)
{
	unsigned char buf[128];
	int i;
	unsigned char *p;

	s[len] = 0;
	for (i = 0; i < len; i++) {
		p = &s[i];
		if (*p < 0x20)
			*p = ' ';
		else if (*p == sep) {
			*p = 0;
			break;
		}
	}
	for (i--; i >= 0; i--) {
		p = &s[i];
		if (*p != ' ')
			break;
		*p = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		i = 0;
		while (buf[i] == ' ')
			i++;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}
