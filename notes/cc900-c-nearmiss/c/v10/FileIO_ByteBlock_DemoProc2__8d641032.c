/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_O_29r1m268b.c (2026-11-22-11-p6-r78)
   sha256 8d641032bef8ac640e6767ff6e8ab4c0a3c416f2171f15655b1087df68ed29ba (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern char ram_25ec0[];
extern int ValidateFileRange(int i);
int FileIO_ByteBlock_DemoProc2(unsigned int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return (((unsigned char *)ram_25ec0 + (unsigned long)i * 82)[0x42] >> 7) & 1;
}
