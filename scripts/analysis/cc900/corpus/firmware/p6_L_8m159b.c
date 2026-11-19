/* Phase 6, lane_p6 helper L, round 8, form b: module 159, FDListDirectory with a `register int` local set to 0 at
   entry and returned at the end (to place the dead zero in WA rather than the frame). */
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
