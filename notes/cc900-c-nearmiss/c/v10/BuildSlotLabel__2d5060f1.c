/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m269b.c (2026-11-19-22-p6-r45)
   sha256 2d5060f1a85dd308187c74abf5ac4504f66df5f2add7ce19d20cd177b56e987c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_SONG_SLOTS[][0x800];
extern char __near ram_8202[][21];
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
char *BuildSlotLabel(unsigned int n, unsigned int mark, char flag)
{
	unsigned char *src;
	char *p;

	src = (unsigned char *)((unsigned long)SEQ_SONG_SLOTS[n] + 256);
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
	return (char *)((unsigned long)(n * 21) + (unsigned long)ram_8202);
}
