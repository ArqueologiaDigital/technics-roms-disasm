/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m269a.c (2026-11-19-22-p6-r45)
   sha256 b143270043a95d46b632a084d60e932e8da5bffa1b51b1e0df7a59383fe3824d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_SONG_SLOTS[][0x800];
extern char __near ram_8202[][21];
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
char *BuildSlotLabel(unsigned int n, unsigned int mark, char flag)
{
	unsigned char *src;
	char *p;

	src = SEQ_SONG_SLOTS[n] + 256;
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
