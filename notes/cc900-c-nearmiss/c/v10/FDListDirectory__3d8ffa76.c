/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_7m159a.c (2026-11-19-56-p6-r51)
   sha256 3d8ffa76eecf06813d3b8eefe0c4d89ca7447920fb23627472c295d6f31c11df (tar-sha256); compiled at -O3 -Xr */
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
	int n;

	n = 0;
	if ((h = _findfirst(FDListDirectory_Str_Star_Dot_Star, &f)) == -1)
		return -1;
	FDTest_PrintDiag(f.name);
	while (_findnext(h, &f) != -1)
		FDTest_PrintDiag(f.name);
	_findclose(h);
	return n;
}
