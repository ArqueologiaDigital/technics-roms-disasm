/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_5m268a.c (2026-11-19-37-p6-r47)
   sha256 a0a67259421a771e85ad9ededdaf09d9939aae46ec0b3b032049680ce383b562 (tar-sha256); compiled at -O3 -Xr */
extern int ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern int FileIO_ValidateModeAndRange(int i);
extern void FileIO_ScanDirEntries(void);
int FileIO_SelectWallpaperByIndex(int i)
{
	int r;
	int t;

	r = FileIO_ValidateModeAndRange(i);
	if (r == -1)
		return ram_272c8;
	if (r == 1) {
		t = (unsigned int)i / 10 * 10;
		ram_271ee = t;
		t += 9;
		FILE_LIST_LAST = t < ram_272ca ? t : ram_272ca;
		FileIO_ScanDirEntries();
	}
	return ram_272c8 = i;
}
