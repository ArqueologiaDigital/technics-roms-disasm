/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-19-29-p6-r46)
   sha256 e97f2e507475721b491eebcdb518419275efb602c2c127836ca044ba1f02999e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
