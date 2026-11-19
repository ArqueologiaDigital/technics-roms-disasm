/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_2m302a.c (2026-11-19-19-p6-r43)
   sha256 5fe673f35360d416db5db74c2fe7c442f0ea82796274575387512084839cac10 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern int TaskBuf_ReadNextByte(void);
long FileIO_ReadVariableLengthData(unsigned int *pos, unsigned char *buf)
{
	long v;
	int c;

	v = TaskBuf_ReadNextByte();
	if (v < 0)
		return -1;
	buf[(*pos)++] = v;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			c = TaskBuf_ReadNextByte();
			if (c < 0)
				return -1;
			buf[(*pos)++] = c;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}
