/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m159b.c (2026-11-19-68-p6-r52)
   sha256 de7509f2aabfdb199fd742ef35e30d1863e407d988cb8eab585b5da671f74992 (tar-sha256); compiled at -O3 -Xr */
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
	register int n;

	n = 0;
	if ((h = _findfirst(FDListDirectory_Str_Star_Dot_Star, &f)) == -1)
		return -1;
	FDTest_PrintDiag(f.name);
	while (_findnext(h, &f) != -1)
		FDTest_PrintDiag(f.name);
	_findclose(h);
	return 0;
}
