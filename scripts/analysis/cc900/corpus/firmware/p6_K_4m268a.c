/* Phase 6, lane_p6 helper K, round 4, module 268 (demo/file_demo_proc.s), form a: ReadFieldToBuffer(len, buf),
   adecl, apparently -Xr (the trim loop jumps to its bottom test, the constant-bound loops copy theirs; the index i
   is an int register variable, IZ saved with pushw).  Unless buf already holds a string, reads a len-byte field
   with FileIO_ReadByte: up to 64 bytes are stored (a short field stores 0 for a read error), a longer one skips
   leading blanks, stops at 64 and discards the rest; then terminates and strips trailing blanks (never the first
   byte). */

extern int FileIO_ReadByte(void);

void ReadFieldToBuffer(int len, char *buf)
{
	int lead;
	int i;
	int r;

	if (*buf != 0)
		return;
	i = 0;
	if (len > 64) {
		lead = 1;
		do {
			r = FileIO_ReadByte();
			if (r < 0)
				break;
			if (lead != 0) {
				if (r == ' ')
					goto skip;
				lead = 0;
			}
			buf[i] = r;
skip:
			len--;
			i++;
		} while (i < 64);
		while (len > 0) {
			FileIO_ReadByte();
			len--;
		}
	} else {
		while (len > 0) {
			r = FileIO_ReadByte();
			if (r < 0)
				r = 0;
			buf[i] = r;
			len--;
			i++;
		}
	}
	buf[i] = 0;
	while (i--, buf[i] == ' ' && i > 0)
		buf[i] = 0;
}
