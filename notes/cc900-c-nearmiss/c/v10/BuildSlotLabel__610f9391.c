/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m269a.c (2026-11-19-15-p6-r42)
   sha256 610f93910b2017f0e62ec22a20372e904f21ba58fb2367f64cc6c960c31add2f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_SONG_SLOTS[][0x800];
extern char __near ram_8202[][21];
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
char *BuildSlotLabel(unsigned int n, unsigned int mark, char flag)
{
	unsigned char *src;
	char *p;

	src = &SEQ_SONG_SLOTS[n][256];
	p = ram_8202[n];
	*p++ = mark;
	if (flag != 0) {
		if (n == 9) {
			*p++ = '1';
			*p = '0';
		} else {
			*p++ = ' ';
			*p = n + '1';
		}
		p++;
		*p++ = ':';
	}
	FileIO_CopyString_WriteNull((unsigned char *)p, src, 16);
	p[16] = 0;
	return ram_8202[n];
}
