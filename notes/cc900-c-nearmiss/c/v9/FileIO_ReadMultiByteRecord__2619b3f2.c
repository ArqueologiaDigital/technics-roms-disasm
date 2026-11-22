/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m302_xr.c (2026-11-22-12-p6-r79)
   sha256 2619b3f28f7b0d0fe9516b16282fcd4ed36a317d1b38e98385518c77ef76251f (tar-sha256); compiled at -O3 -Xr
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
