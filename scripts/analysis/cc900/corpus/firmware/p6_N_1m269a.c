/* lane_p6 helper N, round 1, form a: module 269 (file_io/single_load.s).
   BuildSlotLabel: writes the label of song slot n into the 21-byte row n at 0x8202 -- the mark character, then
   (with flag) the slot number "nn:" (" 1:" .. " 9:", "10:"), then 16 characters of the slot's name (offset 256 of
   its 2 KB record in SEQ_SONG_SLOTS) and a terminating zero -- and returns the row.
   cc900-options: -O3 -Xr
*/

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
