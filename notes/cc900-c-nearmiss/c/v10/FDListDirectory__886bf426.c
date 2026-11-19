/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_7m159b.c (2026-11-19-56-p6-r51)
   sha256 886bf426d1b93aa6e6de4d1d96d26ef5db46afebc436f1013a256629fe9204b7 (tar-sha256); compiled at -O3 -Xr */
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

	if ((h = _findfirst((char *)(long)FDListDirectory_Str_Star_Dot_Star, &f)) == -1)
		return -1;
	FDTest_PrintDiag(f.name);
	while (_findnext(h, &f) != -1)
		FDTest_PrintDiag(f.name);
	_findclose(h);
	return 0;
}
