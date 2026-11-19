/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m268b.c (2026-11-19-15-p6-r42)
   sha256 5c0f7ea6e6b0ebcbb0be87659f4ce4997dc8734d4bc1244e806c612641400d9e (tar-sha256); compiled at -O3 -Xr */
extern long ram_27416;
extern char ram_27414;
extern char ram_27412;
extern int FileIO_FindFirstMatch(char *name, long *size);
extern int FileIO_FindNextMatch(char *name, long *size);
int FileIO_SearchStringMatch(char *name, long *size)
{
	int r;

	r = -1;
	if (ram_27416 >= 0) {
		if (ram_27414 >= ram_27412)
			return r;
		r = FileIO_FindNextMatch(name, size);
		if (r >= 0)
			return r;
		ram_27414++;
	}
	return FileIO_FindFirstMatch(name, size);
}
