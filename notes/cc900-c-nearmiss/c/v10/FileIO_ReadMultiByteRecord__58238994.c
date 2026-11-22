/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m302c.c (2026-11-22-11-p6-r78)
   sha256 582389946da6388bbf11fcbeb32b5646775038896770b8fbccebf5e9c3c0b7fb (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern int FileIO_ReadNextRecord(void);
long FileIO_ReadMultiByteRecord(void)
{
	long v;
	int c;

	if ((v = FileIO_ReadNextRecord()) < 0)
		return -1L;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			if ((c = FileIO_ReadNextRecord()) < 0)
				return -1L;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}
