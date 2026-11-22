/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m302a.c (2026-11-22-9-p6-r76)
   sha256 f09457da4526f8530fa2e22c3c83eb764085b9d5e8b54511eed8c2f23129d159 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern int FileIO_ReadNextRecord(void);
long FileIO_ReadMultiByteRecord(void)
{
	long v;
	int c;

	v = FileIO_ReadNextRecord();
	if (v < 0)
		return -1L;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			c = FileIO_ReadNextRecord();
			if (c < 0)
				return -1L;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}
