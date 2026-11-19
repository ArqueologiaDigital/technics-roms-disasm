/* Phase 6, lane_p6 helper L, round 1, form a: module 159 (factory_test/test_init.s).
   - ListDir2_Entry: lists A:\HAMA\*.LSW to the diagnostic printer.  The ROM passes _findnext the LONG at the
     find record's start (ld, not lda), so the record is spelled {long, int, name[260]} and the long passed. */
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

	h = _findfirst(ListDir2_Entry_Str_A_HAMA_LSW, &d);
	if (h == -1)
		return -1;
	FDTest_PrintDiag(d.name);
	while (_findnext(h, d.l) != -1)
		FDTest_PrintDiag(d.name);
	_findclose(h);
	return 0;
}
