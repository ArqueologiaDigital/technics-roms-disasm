/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m159a.c (2026-11-19-15-p6-r42)
   sha256 baf9e159b2c0fd39dcb720a91c6f0c24ab42e815d5b9d17c0e4657c57584c62d (tar-sha256); compiled at -O3 -Xr */
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

	h = _findfirst(ListDir2_Entry_Str_A_HAMA_LSW, &d);
	if (h == -1)
		return -1;
	FDTest_PrintDiag(d.name);
	while (_findnext(h, d.l) != -1)
		FDTest_PrintDiag(d.name);
	_findclose(h);
	return 0;
}
