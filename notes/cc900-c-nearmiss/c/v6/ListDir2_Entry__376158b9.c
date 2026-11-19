/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/test_init_m159.c (2026-11-19-29-p6-r46)
   sha256 376158b995387931b215f6bf2aee5a95aec84fac7f9855b1551c54fd79bf818b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct lsrec { long l; int w; char name[260]; };
extern char ListDir2_Entry_Str_A_HAMA_LSW[];
extern long _findfirst(char *, struct lsrec *);
extern int _findnext(long, long);
extern int _findclose(long);
extern void FDTest_PrintDiag(char *s);
int ListDir2_Entry(void)
{
	struct lsrec d;
	long h;

	h = _findfirst((char *)(long)ListDir2_Entry_Str_A_HAMA_LSW, &d);
	if (h == -1)
		return -1;
	FDTest_PrintDiag(d.name);
	while (_findnext(h, d.l) != -1)
		FDTest_PrintDiag(d.name);
	_findclose(h);
	return 0;
}
