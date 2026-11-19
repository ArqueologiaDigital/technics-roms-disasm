/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_3m159a.c (2026-11-19-22-p6-r45)
   sha256 9999098b96f08a2400fc71e2e4e5fc997ccf301a8f7d4617936b0fe3538087dd (tar-sha256); compiled at -Xr */
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
