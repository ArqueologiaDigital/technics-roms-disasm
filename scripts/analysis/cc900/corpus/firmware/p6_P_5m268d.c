/* lane_p6 round 5 (2026-11-19): p6_K_4m268b.c (r37: +25, O3Xr) with the two branches swapped: the ROM tests
   `len > 64` with `jr gt` to the long-field loop and falls into the short one, so the short loop is the then-part.
   Phase 6, lane_p6 helper K, round 4, module 268, form b of p6_K_4m268a.c: ReadFieldToBuffer with the long-field
   loop taking the byte (C) and its slot address (XWA) into locals before the leading-blank test, as the ROM orders
   them, and the trim loop through a pointer local. */

extern int FileIO_ReadByte(void);

void ReadFieldToBuffer(int len, char *buf)
{
	int lead;
	int i;
	int r;
	char c;
	char *p;

	if (*buf != 0)
		return;
	i = 0;
	if (len <= 64) {
		while (len > 0) {
			r = FileIO_ReadByte();
			if (r < 0)
				r = 0;
			buf[i] = r;
			len--;
			i++;
		}
	} else {
		lead = 1;
		do {
			r = FileIO_ReadByte();
			if (r < 0)
				break;
			c = r;
			p = &buf[i];
			if (lead != 0) {
				if (r == ' ')
					goto skip;
				lead = 0;
			}
			*p = c;
skip:
			len--;
			i++;
		} while (i < 64);
		while (len > 0) {
			FileIO_ReadByte();
			len--;
		}
	}
	buf[i] = 0;
	while (i--, *(p = &buf[i]) == ' ' && i > 0)
		*p = 0;
}
