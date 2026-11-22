/* Probe round 36r1, helper C, form a: demo/fdemotext_routines.s (module 265), the xr_screen.py shape at -O3 -Xr.
   FDemoText_ReadTaggedBlock(buf, max, open, close): read the open file byte by byte up to the opening tag `open`
   (after its '<'), then copy every byte but CR / LF / TAB into buf up to and including the closing tag `close`,
   cut buf at the closing tag's '<'.  Returns 0, -3 (no opening tag), -4 (no closing tag), -5 (buf full).
   Frame (last declared lowest): c +0 (kept in HL), state +2, n +4, mark +8; i is a `register` local (IZ). */

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
	while ((c = FileIO_ReadByte()) >= 0) {
		if (c == '<') {
			i = 1;
			while ((c = FileIO_ReadByte()) >= 0 && open[i] == c) {
				i++;
				if (open[i] == 0) {
					state = 0;
					break;
				}
			}
			if (state == 0)
				break;
		}
	}
	if (state != 0)
		return -3;
	n = 0;
	while ((c = FileIO_ReadByte()) >= 0) {
		if (c != 13 && c != 10 && c != 9) {
			mark = n;
			buf[n] = c;
			n += 1;
			if (n >= max)
				return -5;
		}
		if (c == '<') {
			i = 1;
			while ((c = FileIO_ReadByte()) >= 0) {
				buf[n] = c;
				n += 1;
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
			if (state == 1)
				break;
		}
	}
	if (state == 1)
		return 0;
	return -4;
}
