/* lane_p6 helper N, round 3, form b: module 269 (file_io/single_load.s), retry of p6_N_1m269a.
   BuildSlotLabel, form b against a: the name address as an integer sum (row address, then + 256) and the returned
   row converted from an integer sum, index first (the ROM: `mul wa,21; lda xbc,(0x8202); extz xwa; add xwa,xbc;
   ld xhl,xwa`).
   cc900-options: -O3 -Xr
*/

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
