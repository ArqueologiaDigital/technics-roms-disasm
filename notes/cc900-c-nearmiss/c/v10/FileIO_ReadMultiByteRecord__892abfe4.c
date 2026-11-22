/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m302b.c (2026-11-22-9-p6-r76)
   sha256 892abfe478a4939b9053f36a0f90bb459d501e4b096acc589bd3ecbbdf307d46 (tar-sha256); compiled at -Xr
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
			v = (c & 0x7f) + (v << 7);
		} while (c & 0x80);
	}
	return v;
}
