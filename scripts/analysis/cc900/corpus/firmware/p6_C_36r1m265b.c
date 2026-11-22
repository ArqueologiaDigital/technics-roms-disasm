/* Probe round 36r1, helper C, form b: demo/fdemotext_routines.s (module 265), the xr_screen.py shape at -O3 -Xr.
   FDemoText_ReadTaggedBlock, as form a but the two outer loops test `state` in their conditions instead of the
   breaks after the inner loops, and the stores spell buf[n++]. */

extern int FileIO_ReadByte(void);
extern int FDemoText_ReadTaggedBlock(unsigned char *buf, unsigned long max, unsigned char *open, unsigned char *close);

int FDemoText_ReadTaggedBlock(unsigned char *buf, unsigned long max, unsigned char *open, unsigned char *close)
{
	unsigned long mark;
	unsigned long n;
	int state;
	int c;
	register int i;

	state = 1;
	while (state != 0 && (c = FileIO_ReadByte()) >= 0) {
		if (c == '<') {
			i = 1;
			while ((c = FileIO_ReadByte()) >= 0 && open[i] == c) {
				i++;
				if (open[i] == 0) {
					state = 0;
					break;
				}
			}
		}
	}
	if (state != 0)
		return -3;
	n = 0;
	while (state != 1 && (c = FileIO_ReadByte()) >= 0) {
		if (c != 13 && c != 10 && c != 9) {
			mark = n;
			buf[n++] = c;
			if (n >= max)
				return -5;
		}
		if (c == '<') {
			i = 1;
			while ((c = FileIO_ReadByte()) >= 0) {
				buf[n++] = c;
				if (n >= max)
					return -5;
				if (close[i] != c)
					break;
				i++;
				if (close[i] == 0) {
					state = 1;
					buf[mark] = 0;
					break;
				}
			}
		}
	}
	if (state == 1)
		return 0;
	return -4;
}
