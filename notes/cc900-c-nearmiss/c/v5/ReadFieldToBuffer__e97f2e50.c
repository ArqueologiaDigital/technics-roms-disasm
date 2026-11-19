/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-19-29-p6-r46)
   sha256 e97f2e507475721b491eebcdb518419275efb602c2c127836ca044ba1f02999e (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
