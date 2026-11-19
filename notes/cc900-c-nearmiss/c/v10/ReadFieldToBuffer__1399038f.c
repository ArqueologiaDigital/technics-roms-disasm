/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_5m268d.c (2026-11-19-19-p6-r43)
   sha256 1399038f03744d991eb8e200f18907bb44bb2f3131468945d986094b5e9e9328 (tar-sha256); compiled at -O3 -XS -Xr */
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
