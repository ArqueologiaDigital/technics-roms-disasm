/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m268a.c (2026-11-19-15-p6-r42)
   sha256 53ef57a4e3ec2557c168e2014a5d0dbdcefb20fe2ec77a4d1b39945f632c9a75 (tar-sha256); compiled at -Xr */
extern long ram_27416;
extern char ram_27414;
extern char ram_27412;
extern int FileIO_FindFirstMatch(char *name, long *size);
extern int FileIO_FindNextMatch(char *name, long *size);
int FileIO_SearchStringMatch(char *name, long *size)
{
	int r;

	r = -1;
	if (ram_27416 < 0)
		r = FileIO_FindFirstMatch(name, size);
	else if (ram_27414 < ram_27412) {
		r = FileIO_FindNextMatch(name, size);
		if (r < 0) {
			ram_27414++;
			r = FileIO_FindFirstMatch(name, size);
		}
	}
	return r;
}
