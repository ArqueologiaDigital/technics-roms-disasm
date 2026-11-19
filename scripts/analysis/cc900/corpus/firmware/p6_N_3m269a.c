/* lane_p6 helper N, round 3, form a: module 269 (file_io/single_load.s), retry of p6_N_1m269a (p6-r42: +3 at -Xr).
   BuildSlotLabel: V4.23 computed the slot name address as base + ((n << 11) + 256) in XHL and kept the mark in C;
   the ROM adds n << 11 to the base, then 256, in XBC, so it first moves the mark to HL.  Form a: the name address
   written as row + 256 (the return is round 1's).
   cc900-options: -O3 -Xr
*/

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
