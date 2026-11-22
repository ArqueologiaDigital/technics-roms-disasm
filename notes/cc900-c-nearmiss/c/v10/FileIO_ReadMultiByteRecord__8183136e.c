/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m302b.c (2026-11-22-11-p6-r78)
   sha256 8183136e612a619ab370f131ca236c5731d971ab39b95f1530e30243e3711041 (tar-sha256); compiled at -O3 -Xr
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
