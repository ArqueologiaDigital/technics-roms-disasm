/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_O_29r1m268a.c (2026-11-22-11-p6-r78)
   sha256 a3503c2148fc99b6744d22ff7e59684cfa096696dab1d905aab0d7bb837755be (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct FileRec82 {
	char b[82];
};
extern struct FileRec82 ram_25ec0[];
extern int ValidateFileRange(int i);
int FileIO_ByteBlock_DemoProc2(int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return (ram_25ec0[(unsigned int)i].b[0x42] & 0x80) != 0;
}
