/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fd_test_code_m159_xr.c (2026-11-19-73-p6-r53)
   sha256 a3ae96d6380777aacba92a590595930550fa6edb6b4ad6918128899428fd3107 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
