/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m159a.c (2026-11-19-68-p6-r52)
   sha256 d2f3cb4d8d93d90789986fc63dc46bc21c23197229bce4ee2e4d9fad0f38adfb (tar-sha256); compiled at -O3 -Xr */
struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern char FDListDirectory_Str_Star_Dot_Star[];
extern long _findfirst(char *, struct ffblk *);
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
extern void FDTest_PrintDiag(char *s);
int FDListDirectory(void)
{
	struct ffblk f;
	long h;

	if ((h = _findfirst((0, FDListDirectory_Str_Star_Dot_Star), &f)) == -1)
		return -1;
	FDTest_PrintDiag(f.name);
	while (_findnext(h, &f) != -1)
		FDTest_PrintDiag(f.name);
	_findclose(h);
	return 0;
}
