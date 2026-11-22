/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m268b.c (2026-11-22-13-p6-r80)
   sha256 1d7f9953cadd46362c52527a167de367eb3d22de3e0966a88593cbdb1aafcbaf (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct FileRec82 {
	char b[0x42];
	unsigned char f0 : 7;
	unsigned char f7 : 1;
	char rest[82 - 0x43];
};
extern struct FileRec82 ram_25ec0[];
extern int ValidateFileRange(int i);
int FileIO_ByteBlock_DemoProc2(int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return ram_25ec0[(unsigned int)i].f7;
}
