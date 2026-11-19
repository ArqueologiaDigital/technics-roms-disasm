/* Phase 6, lane_p6 helper L, round 3, form a: module 159.  Retry of ListDir2_Entry (round 1: +39 at Xr).  At O3Xr
   round 1 already had the ROM's _findnext argument order (XBC first) but loaded the path with `ld xwa, imm`
   after XBC; the ROM has `lda xwa` first.  The path is converted through long (the `(long)ram_8094 gives lda`
   idiom of run r36). */
/* cc900-module: FDTest_PrintDiag */   /* scripts/analysis/cc900/module_calls.py v10 */

struct lsrec { long l; int w; char name[260]; };
extern char ListDir2_Entry_Str_A_HAMA_LSW[];
extern long _findfirst(char *, struct lsrec *);
extern int _findnext(long, long);
extern int _findclose(long);
extern void FDTest_PrintDiag(char *s);
extern int ListDir2_Entry(void);

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
