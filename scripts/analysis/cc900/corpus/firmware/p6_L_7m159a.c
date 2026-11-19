/* Phase 6, lane_p6 helper L, round 7, form a: module 159 (factory_test/fd_test_code.s), new.
   - FDListDirectory: the sibling of the matched ListDir2_Entry, listing "*.*".  Unlike ListDir2 it passes
     _findnext the record's ADDRESS (lda) with XWA loaded first, tests the handle through a copy in XWA (the value
     of the assignment), and starts with a dead `ld wa,0`: an int local set to 0 (form a); form b drops it. */
/* cc900-module: FDTest_PrintDiag */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern char FDListDirectory_Str_Star_Dot_Star[];
extern long _findfirst(char *, struct ffblk *);
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
extern void FDTest_PrintDiag(char *s);
extern int FDListDirectory(void);

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
